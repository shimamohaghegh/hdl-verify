// ArithBench-100: 4-input Priority Encoder
// Operation: priority encoding
// Bit width: 4 inputs -> 2-bit code + valid
// Source: Logic Design notes (EEE-248/CNG-232), Ch.4 priority encoder
// Ground truth (higher index = higher priority):
//   D3 on -> A=11 ; else D2 on -> A=10 ; else D1 on -> A=01 ;
//   else D0 on -> A=00 ; if none on -> V=0 (A is don't-care).
//   Reference equations from the notes:
//     A1 = D2 | D3
//     A0 = D3 | (~D2 & D1)
//     V  = D0 | D1 | D2 | D3

module priority_encoder_4 (
    input  [3:0] d,          // d[3] highest priority ... d[0] lowest
    output [1:0] a,          // encoded position of highest active input
    output       v           // valid: 1 if any input is active
);
    assign a[1] = d[2] | d[3];
    assign a[0] = d[3] | (~d[2] & d[1]);
    assign v    = d[0] | d[1] | d[2] | d[3];
endmodule
