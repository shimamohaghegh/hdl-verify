// ArithBench-100: 2-to-4 Decoder
// Operation: decoding | Bit width: 2 in, 4 out
// Source: standard textbook design
// Ground truth: one-hot output; y = 1 << sel (only bit 'sel' is high)
module decoder_2to4 (
    input  [1:0] sel,
    output [3:0] y
);
    assign y = 4'b1 << sel;
endmodule
