// ArithBench-100: 8-bit Parity Generator
// Operation: parity (XOR reduction) | Bit width: 8
// Source: standard textbook design
// Ground truth: parity = XOR of all 8 bits (1 if odd number of ones)
module parity_8bit (
    input  [7:0] a,
    output       parity
);
    assign parity = ^a;
endmodule
