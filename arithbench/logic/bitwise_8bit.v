// ArithBench-100: 8-bit Bitwise Logic Unit
// Operation: bitwise logic
// Bit width: 8
// Source: standard textbook design
// Ground truth: and_out = a & b, or_out = a | b, xor_out = a ^ b, not_out = ~a

module bitwise_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] and_out,
    output [7:0] or_out,
    output [7:0] xor_out,
    output [7:0] not_out
);
    assign and_out = a & b;
    assign or_out  = a | b;
    assign xor_out = a ^ b;
    assign not_out = ~a;
endmodule
