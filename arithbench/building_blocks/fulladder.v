// ArithBench-100: 1-bit Full Adder (structural / gate-level)
// Operation: addition (building block)
// Bit width: 1
// Source: Harris & Harris, Digital Design and Computer Architecture
// Ground truth: s = a ^ b ^ cin, cout = (a & b) | ((a ^ b) & cin)

module fulladder (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);
    wire p, g;
    assign p = a ^ b;
    assign g = a & b;
    assign s = p ^ cin;
    assign cout = g | (p & cin);
endmodule