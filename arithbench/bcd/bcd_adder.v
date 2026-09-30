// ArithBench-100: 1-digit BCD Adder
// Operation: binary-coded decimal addition
// Bit width: 4 (each digit) + carry
// Source: standard textbook design (BCD add with +6 correction)
// Ground truth: sum of two decimal digits a,b (each 0-9) plus cin.
//               Output is a 4-bit BCD digit and a carry-out.
//               If raw sum > 9, add 6 and set carry (decimal correction).

module bcd_adder (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);
    wire [4:0] raw = a + b + cin;       // up to 9+9+1 = 19
    wire       need_correct = (raw > 9);
    wire [4:0] corrected = need_correct ? (raw + 6) : raw;
    assign sum  = corrected[3:0];
    assign cout = need_correct;
endmodule
