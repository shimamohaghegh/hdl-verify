// ArithBench-100: 8-bit Multiply-Accumulate (MAC)
// Operation: multiply then add | Bit width: 8 in, 16 out
// Source: standard datapath building block (core of matrix multiply)
// Ground truth: result = a * b + c
module mac_unit (
    input  [7:0]  a,
    input  [7:0]  b,
    input  [15:0] c,
    output [15:0] result
);
    assign result = a * b + c;
endmodule
