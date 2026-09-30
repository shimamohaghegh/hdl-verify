// ArithBench-100: 8-bit Unsigned Multiplier (behavioral)
// Operation: multiplication | Bit width: 8 in, 16 out
// Source: standard textbook design
// Ground truth: product = a * b (unsigned)
module mult_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [15:0] product
);
    assign product = a * b;
endmodule
