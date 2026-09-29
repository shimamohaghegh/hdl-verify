// Full adder building block (included so this file is self-contained)
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

// ArithBench-100: 4-bit Ripple Carry Adder (structural)
// Operation: addition, Bit width: 4
// Source: structural construction from full adders (Harris & Harris style)
// Ground truth: a + b + carry_in = {carry_out, sum}
module adder_4bit_structural (
    input  [3:0] a,
    input  [3:0] b,
    input        carry_in,
    output [3:0] sum,
    output       carry_out
);
    wire c1, c2, c3;

    fulladder fa0 (.a(a[0]), .b(b[0]), .cin(carry_in), .s(sum[0]), .cout(c1));
    fulladder fa1 (.a(a[1]), .b(b[1]), .cin(c1),       .s(sum[1]), .cout(c2));
    fulladder fa2 (.a(a[2]), .b(b[2]), .cin(c2),       .s(sum[2]), .cout(c3));
    fulladder fa3 (.a(a[3]), .b(b[3]), .cin(c3),       .s(sum[3]), .cout(carry_out));
endmodule