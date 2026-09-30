// ArithBench-100: 8-bit Signed Comparator (two's complement)
// Operation: comparison (signed)
// Bit width: 8
// Source: standard textbook design
// Ground truth: treats a and b as signed 8-bit. eq=(a==b), gt=(a>b), lt=(a<b)
//               e.g. 2 > -3, and -5 < -1.

module comparator_signed_8bit (
    input  signed [7:0] a,
    input  signed [7:0] b,
    output              eq,
    output              gt,
    output              lt
);
    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);
endmodule
