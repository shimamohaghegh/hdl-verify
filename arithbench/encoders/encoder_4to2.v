// ArithBench-100: 4-to-2 Encoder (one-hot input assumed)
// Operation: encoding | Bit width: 4 in, 2 out
// Source: standard textbook design
// Ground truth: for a one-hot input d, output the index of the set bit.
//   d=0001->0, 0010->1, 0100->2, 1000->3.
module encoder_4to2 (
    input  [3:0] d,
    output [1:0] y
);
    assign y[1] = d[2] | d[3];
    assign y[0] = d[1] | d[3];
endmodule
