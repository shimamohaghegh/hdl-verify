// ArithBench-100: 32-bit Ripple Carry Adder (structural)
// Operation: addition
// Bit width: 32
// Source: structural construction from full adders, using a generate loop
// Ground truth: a + b + carry_in = {carry_out, sum}
// Note: 32 full adders chained; carry ripples through. Helper included below.

module adder_32bit_structural (
    input  [32-1:0] a,
    input  [32-1:0] b,
    input             carry_in,
    output [32-1:0] sum,
    output            carry_out
);
    wire [32:0] carry;
    assign carry[0] = carry_in;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : fa_stage
            fulladder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .s(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[32];
endmodule

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
