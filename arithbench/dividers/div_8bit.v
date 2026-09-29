// ArithBench-100: 8-bit Unsigned Divider
// Operation: division
// Bit width: 8
// Source: standard textbook design (unsigned integer division)
// Ground truth: quotient = a / b, remainder = a % b.
//               When b = 0, quotient = 8'hFF and remainder = a (defined convention).

module div_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] quotient,
    output [7:0] remainder
);
    assign quotient  = (b == 8'b0) ? 8'hFF : (a / b);
    assign remainder = (b == 8'b0) ? a     : (a % b);
endmodule
