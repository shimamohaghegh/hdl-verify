// ArithBench-100: 4-bit Unsigned Divider
// Operation: division
// Bit width: 4
// Source: standard textbook design (unsigned integer division)
// Ground truth: quotient = a / b, remainder = a % b.
//               When b = 0, quotient = 4'b1111 and remainder = a (defined convention).

module div_4bit (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] quotient,
    output [3:0] remainder
);
    assign quotient  = (b == 4'b0) ? 4'b1111 : (a / b);
    assign remainder = (b == 4'b0) ? a       : (a % b);
endmodule
