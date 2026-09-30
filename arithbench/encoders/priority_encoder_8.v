// ArithBench-100: 8-input Priority Encoder
// Operation: priority encoding | Bit width: 8 in, 3-bit code + valid
// Source: standard textbook design (higher index = higher priority)
// Ground truth: y = index of highest set bit; v = 1 if any bit set.
module priority_encoder_8 (
    input  [7:0] d,
    output [2:0] y,
    output       v
);
    assign v = |d;
    assign y = d[7] ? 3'd7 :
               d[6] ? 3'd6 :
               d[5] ? 3'd5 :
               d[4] ? 3'd4 :
               d[3] ? 3'd3 :
               d[2] ? 3'd2 :
               d[1] ? 3'd1 : 3'd0;
endmodule
