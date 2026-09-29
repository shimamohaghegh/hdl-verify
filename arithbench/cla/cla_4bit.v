// ArithBench-100: 4-bit Carry-Lookahead Adder (structural)
// Operation: addition
// Bit width: 4
// Source: standard textbook carry-lookahead design (Harris & Harris style)
// Ground truth: a + b + carry_in = {carry_out, sum}
// Method: parallel carry computation using generate (g) and propagate (p).

module cla_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        carry_in,
    output [3:0] sum,
    output       carry_out
);
    wire [3:0] g;   // generate:  g[i] = a[i] & b[i]
    wire [3:0] p;   // propagate: p[i] = a[i] ^ b[i]
    wire [4:0] c;   // carries;   c[0] = carry_in

    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = carry_in;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);

    assign sum = p ^ c[3:0];
    assign carry_out = c[4];
endmodule
