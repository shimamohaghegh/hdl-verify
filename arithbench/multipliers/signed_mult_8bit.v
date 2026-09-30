// ArithBench-100: 8-bit Signed Multiplier (two's complement)
// Operation: multiplication (signed) | Bit width: 8 in, 16 out
// Source: standard textbook design
// Ground truth: product = a * b, treating a and b as signed. e.g. (-2)*3 = -6
module signed_mult_8bit (
    input  signed [7:0] a,
    input  signed [7:0] b,
    output signed [15:0] product
);
    assign product = a * b;
endmodule
