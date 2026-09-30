// ArithBench-100: 8-bit Arithmetic Right Shifter (signed, sign-filled)
// Operation: arithmetic shift | Bit width: 8 data, 3 shift
// Source: standard textbook design
// Ground truth: result = a >>> shift_amount, sign bit is replicated (a is signed)
module ashift_right_8bit (
    input  signed [7:0] a,
    input        [2:0]  shift_amount,
    output signed [7:0] result
);
    assign result = a >>> shift_amount;
endmodule
