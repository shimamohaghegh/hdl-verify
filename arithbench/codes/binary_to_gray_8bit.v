// ArithBench-100: 8-bit Binary-to-Gray Converter
// Operation: code conversion | Bit width: 8
// Source: standard textbook design
// Ground truth: gray = binary ^ (binary >> 1)
module binary_to_gray_8bit (
    input  [7:0] binary,
    output [7:0] gray
);
    assign gray = binary ^ (binary >> 1);
endmodule
