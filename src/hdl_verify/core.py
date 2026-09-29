"""
core.py — the main verify() function.

Compares a known-correct reference Verilog module against a candidate
(typically AI-generated) module and returns a VerificationReport.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile

from hdl_verify.fingerprint import Fingerprint
from hdl_verify.report import VerificationReport

# How long (seconds) to let the formal checker run before giving up.
DEFAULT_TIMEOUT = 600

# ---------------------------------------------------------------------------
# Verilog module-name detection
# ---------------------------------------------------------------------------

_COMMENT_BLOCK = re.compile(r"/\*.*?\*/", re.DOTALL)
_COMMENT_LINE = re.compile(r"//[^\n]*")
_MODULE_DECL = re.compile(r"\bmodule\s+([A-Za-z_][A-Za-z0-9_$]*)")


def find_modules(path: str) -> list[str]:
    """Return every module name declared in a Verilog file, in order."""
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    text = _COMMENT_BLOCK.sub(" ", text)
    text = _COMMENT_LINE.sub(" ", text)
    return _MODULE_DECL.findall(text)


def _rename_all_modules(src_text: str, suffix: str = "_cand") -> str:
    """Add a suffix to every module declared in src_text and to all its
    instantiations, so the renamed design cannot clash with same-named
    modules in the reference (e.g. a shared 'fulladder' helper)."""
    names = _MODULE_DECL.findall(
        _COMMENT_LINE.sub(" ", _COMMENT_BLOCK.sub(" ", src_text))
    )
    out = src_text
    for name in names:
        out = re.sub(
            r"\bmodule\s+" + re.escape(name) + r"\b",
            "module " + name + suffix,
            out,
        )
        out = re.sub(
            r"\b" + re.escape(name) + r"(\s+[A-Za-z_][A-Za-z0-9_$]*\s*\()",
            name + suffix + r"\1",
            out,
        )
    return out


def top_module(path: str) -> str:
    """
    Best guess at the top-level module of a Verilog file.

    The top module is the one that no other module in the file instantiates.
    In a single-module file, that is simply the one module. This is more
    reliable than taking the last module, because a self-contained structural
    design may list its helper modules after the top, or before it.
    """
    mods = find_modules(path)
    if not mods:
        raise ValueError(f"No module declaration found in {path}")
    if len(mods) == 1:
        return mods[0]

    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    text = _COMMENT_BLOCK.sub(" ", text)
    text = _COMMENT_LINE.sub(" ", text)

    instantiated = set()
    for name in mods:
        pattern = re.compile(
            r"\b" + re.escape(name) + r"\s+[A-Za-z_][A-Za-z0-9_$]*\s*\("
        )
        if pattern.search(text):
            instantiated.add(name)

    tops = [m for m in mods if m not in instantiated]
    if len(tops) == 1:
        return tops[0]
    return mods[-1]


# ---------------------------------------------------------------------------
# Yosys plumbing
# ---------------------------------------------------------------------------


def _q(path: str) -> str:
    """Quote a path for a Yosys script."""
    return '"' + os.path.abspath(path).replace('"', '\\"') + '"'


def _run_yosys(script: str, timeout: int = DEFAULT_TIMEOUT):
    """
    Run a Yosys script. Returns (finished_ok, combined_output).

    finished_ok is False only if Yosys itself failed or timed out; a proof
    that comes back "not equivalent" still counts as finished_ok=True.
    """
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".ys", delete=False, encoding="utf-8"
    ) as fh:
        fh.write(script)
        script_path = fh.name
    try:
        result = subprocess.run(
            ["yosys", "-s", script_path],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return True, (result.stdout or "") + (result.stderr or "")
    except subprocess.TimeoutExpired:
        return False, "__TIMEOUT__"
    except Exception as exc:  # noqa: BLE001
        return False, f"__ERROR__ {exc}"
    finally:
        try:
            os.unlink(script_path)
        except OSError:
            pass


def _run_formal(
    reference: str,
    candidate: str,
    report: VerificationReport,
    timeout: int = DEFAULT_TIMEOUT,
) -> str:
    """
    Prove or disprove equivalence with Yosys + ABC.

    Builds a miter circuit and asks the SAT solver whether the two designs
    can ever disagree. No model found means they agree on every input.

    Returns PASS, FAIL, TIMEOUT, or ERROR.
    """
    try:
        ref_mod = top_module(reference)
        cand_mod = top_module(candidate)
    except (ValueError, OSError) as exc:
        report.errors.append(str(exc))
        return "ERROR"

    report.metadata = getattr(report, "metadata", {})
    report.metadata["reference_module"] = ref_mod
    report.metadata["candidate_module"] = cand_mod

    # Write a copy of the candidate with all modules renamed, so a shared
    # helper name (e.g. fulladder) does not clash with the reference.
    with open(candidate, "r", encoding="utf-8", errors="replace") as fh:
        cand_text = _rename_all_modules(fh.read())
    cand_fd, cand_renamed = tempfile.mkstemp(suffix=".v", prefix="hdlverify_cand_")
    with os.fdopen(cand_fd, "w", encoding="utf-8") as fh:
        fh.write(cand_text)
    cand_mod_r = cand_mod + "_cand"

    script = f"""
# --- reference design -------------------------------------------------
read_verilog -sv {_q(reference)}
hierarchy -top {ref_mod}
proc
flatten
opt_clean
rename {ref_mod} gold
design -stash gold

# --- candidate design -------------------------------------------------
read_verilog -sv {_q(cand_renamed)}
hierarchy -top {cand_mod_r}
proc
flatten
opt_clean
rename {cand_mod_r} gate
design -stash gate

# --- build the miter and prove it can never trigger -------------------
design -copy-from gold -as gold gold
design -copy-from gate -as gate gate
miter -equiv -flatten gold gate miter
hierarchy -top miter
flatten
opt_clean
sat -prove trigger 0 miter
"""

    try:
        finished, output = _run_yosys(script, timeout=timeout)
    finally:
        try:
            os.unlink(cand_renamed)
        except OSError:
            pass

    if not finished:
        if output == "__TIMEOUT__":
            return "TIMEOUT"
        report.errors.append(output)
        return "ERROR"

    if "SAT proof finished" in output and "SUCCESS" in output:
        return "PASS"
    if "SAT proof finished" in output and "FAIL" in output:
        tail = "\n".join(output.strip().splitlines()[-40:])
        report.errors.append("Counterexample found:\n" + tail)
        return "FAIL"

    tail = "\n".join(output.strip().splitlines()[-20:])
    report.errors.append("Formal check did not complete:\n" + tail)
    return "ERROR"


# ---------------------------------------------------------------------------
# Fuzzing (Month 2) — random-input simulation with Icarus Verilog
# ---------------------------------------------------------------------------

_PORT_RE = re.compile(
    r"\b(input|output)\b\s*(?:wire|reg|logic)?\s*(signed)?\s*"
    r"(?:\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*"
    r"([A-Za-z_][A-Za-z0-9_$]*)"
)


def _parse_ports(path: str, module: str):
    """Return (inputs, outputs), each a list of (name, width) for the module."""
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    text = _COMMENT_BLOCK.sub(" ", text)
    text = _COMMENT_LINE.sub(" ", text)

    m = re.search(
        r"\bmodule\s+" + re.escape(module) + r"\b(.*?)\bendmodule\b",
        text,
        re.DOTALL,
    )
    if not m:
        return [], []
    body = m.group(1)

    inputs, outputs = [], []
    for direction, _signed, hi, lo, name in _PORT_RE.findall(body):
        if hi is None or hi == "":
            width = 1
        else:
            width = abs(int(hi) - int(lo)) + 1
        (inputs if direction == "input" else outputs).append((name, width))
    return inputs, outputs


def _run_fuzz(
    reference: str,
    candidate: str,
    trials: int = 10_000,
    timeout: int = 300,
):
    """Fuzz-test two combinational designs against each other."""
    if not shutil.which("iverilog") or not shutil.which("vvp"):
        return "NOT_RUN", 0

    try:
        ref_mod = top_module(reference)
        cand_mod = top_module(candidate)
    except (ValueError, OSError):
        return "NOT_RUN", 0

    ref_in, ref_out = _parse_ports(reference, ref_mod)
    if not ref_in or not ref_out:
        return "NOT_RUN", 0

    clocklike = {"clk", "clock", "rst", "reset", "enable", "en"}
    if any(name.lower() in clocklike for name, _ in ref_in):
        return "NOT_RUN", 0

    workdir = tempfile.mkdtemp(prefix="hdlverify_fuzz_")
    try:
        ref_src = os.path.join(workdir, "ref_design.v")
        shutil.copyfile(reference, ref_src)
        cand_src = os.path.join(workdir, "cand_design.v")

        with open(candidate, "r", encoding="utf-8", errors="replace") as fh:
            cand_text = _rename_all_modules(fh.read())
        cand_mod_use = cand_mod + "_cand"

        with open(cand_src, "w", encoding="utf-8") as fh:
            fh.write(cand_text)

        tb = _build_fuzz_testbench(ref_mod, cand_mod_use, ref_in, ref_out, trials)
        tb_path = os.path.join(workdir, "tb.v")
        with open(tb_path, "w", encoding="utf-8") as fh:
            fh.write(tb)

        exe = os.path.join(workdir, "sim.vvp")
        compile_cmd = ["iverilog", "-o", exe, tb_path, ref_src, cand_src]
        c = subprocess.run(compile_cmd, capture_output=True, text=True, timeout=timeout)
        if c.returncode != 0:
            return "ERROR", 0

        r = subprocess.run(
            ["vvp", exe], capture_output=True, text=True, timeout=timeout
        )
        out = (r.stdout or "") + (r.stderr or "")

        if "FUZZ_MISMATCH" in out:
            return "FAIL", trials
        if "FUZZ_OK" in out:
            return "PASS", trials
        return "ERROR", 0
    except subprocess.TimeoutExpired:
        return "ERROR", 0
    except Exception:  # noqa: BLE001
        return "ERROR", 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


def _build_fuzz_testbench(ref_mod, cand_mod, inputs, outputs, trials):
    """Generate a self-checking Verilog testbench comparing two modules."""
    decls, ref_conns, cand_conns = [], [], []

    for name, width in inputs:
        rng = f"[{width-1}:0] " if width > 1 else ""
        decls.append(f"  reg {rng}{name};")
        ref_conns.append(f".{name}({name})")
        cand_conns.append(f".{name}({name})")

    for name, width in outputs:
        rng = f"[{width-1}:0] " if width > 1 else ""
        decls.append(f"  wire {rng}ref_{name};")
        decls.append(f"  wire {rng}cand_{name};")
        ref_conns.append(f".{name}(ref_{name})")
        cand_conns.append(f".{name}(cand_{name})")

    randomize = "\n".join(
        (
            f"      {name} = {{$random}} % {(1 << width)};"
            if width <= 30
            else f"      {name} = {{$random, $random, $random, $random, $random, $random}};"
        )
        for name, width in inputs
    )

    compare = " || ".join(f"(ref_{n} !== cand_{n})" for n, _ in outputs)

    return f"""// Auto-generated fuzz testbench (HDL-Verify)
`timescale 1ns/1ns
module fuzz_tb;
{chr(10).join(decls)}

  {ref_mod} ref_dut ({", ".join(ref_conns)});
  {cand_mod} cand_dut ({", ".join(cand_conns)});

  integer i;
  initial begin
    for (i = 0; i < {trials}; i = i + 1) begin
{randomize}
      #1;
      if ({compare}) begin
        $display("FUZZ_MISMATCH at trial %0d", i);
        $finish;
      end
      #1;
    end
    $display("FUZZ_OK");
    $finish;
  end
endmodule
"""


# ---------------------------------------------------------------------------
# Tool versions (part of the reproducibility fingerprint)
# ---------------------------------------------------------------------------


def _tool_version(tool: str) -> str:
    """Return a version string for a tool, or 'not found'."""
    if not shutil.which(tool):
        return "not found"
    flag = "-V" if tool == "iverilog" else "--version"
    try:
        result = subprocess.run(
            [tool, flag], capture_output=True, text=True, timeout=15
        )
        text = (result.stdout or result.stderr or "").strip()
        return text.splitlines()[0] if text else "unknown"
    except Exception:  # noqa: BLE001
        return "unknown"


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def verify(
    reference: str,
    candidate: str,
    timeout: int = DEFAULT_TIMEOUT,
    model_name: str = "",
    prompt: str = "",
    fingerprint_path: str = "",
) -> VerificationReport:
    """Compare a reference HDL file against a candidate."""
    report = VerificationReport(reference=reference, candidate=candidate)

    for label, path in (("reference", reference), ("candidate", candidate)):
        if not os.path.isfile(path):
            report.errors.append(f"{label} file not found: {path}")
            report.formal_verdict = "ERROR"
            report.fuzz_verdict = "NOT_RUN"
            return report

    fp = Fingerprint.capture(reference, candidate, model_name=model_name, prompt=prompt)
    report.fingerprint = fp
    report.tool_versions = fp.tool_versions

    if shutil.which("yosys"):
        report.formal_verdict = _run_formal(reference, candidate, report, timeout)
    else:
        report.formal_verdict = "NOT_RUN"
        report.errors.append("yosys not found — install it to enable formal checking.")

    if shutil.which("iverilog"):
        report.fuzz_verdict, report.fuzz_trials = _run_fuzz(reference, candidate)
    else:
        report.fuzz_verdict = "NOT_RUN"
        report.errors.append("iverilog not found — install it to enable fuzz testing.")

    if fingerprint_path:
        try:
            fp.save(fingerprint_path)
        except OSError as exc:
            report.errors.append(f"Could not save fingerprint: {exc}")

    return report
