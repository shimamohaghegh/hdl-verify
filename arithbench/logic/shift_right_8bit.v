// ArithBench-100: 8-bit Logical Right Shifter
// Operation: shift | Bit width: 8 data, 3 shift
// Source: standard textbook design
// Ground truth: result = a >> shift_amount (zero-filled)
module shift_right_8bit (
    input  [7:0] a,
    input  [2:0] shift_amount,
    output [7:0] result
);
    assign result = a >> shift_amount;
endmodule
