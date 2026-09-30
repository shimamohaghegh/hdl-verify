// ArithBench-100: 3-to-8 Decoder
// Operation: decoding | Bit width: 3 in, 8 out
// Source: standard textbook design
// Ground truth: one-hot output; y = 1 << sel
module decoder_3to8 (
    input  [2:0] sel,
    output [7:0] y
);
    assign y = 8'b1 << sel;
endmodule
