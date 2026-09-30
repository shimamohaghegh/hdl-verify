// ArithBench-100: 4-to-1 Multiplexer, 8-bit data
// Operation: selection | Bit width: 8
// Source: standard textbook design
// Ground truth: sel picks one of a,b,c,d (00->a,01->b,10->c,11->d)
module mux_4to1_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    input  [7:0] d,
    input  [1:0] sel,
    output [7:0] y
);
    assign y = (sel == 2'b00) ? a :
               (sel == 2'b01) ? b :
               (sel == 2'b10) ? c : d;
endmodule
