// ArithBench-100: 2-to-1 Multiplexer, 8-bit data
// Operation: selection | Bit width: 8
// Source: standard textbook design
// Ground truth: y = sel ? b : a
module mux_2to1_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        sel,
    output [7:0] y
);
    assign y = sel ? b : a;
endmodule
