// ArithBench-100: 8-bit Logical Left Shifter
// Operation: shift
// Bit width: 8 (data), 3 (shift amount)
// Source: standard textbook design (barrel shifter behavior)
// Ground truth: result = a << shift_amount (logical, zero-filled)

module shift_left_8bit (
    input  [7:0] a,
    input  [2:0] shift_amount,
    output [7:0] result
);
    assign result = a << shift_amount;
endmodule
