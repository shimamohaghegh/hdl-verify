// ArithBench-100: 8-bit Comparator
// Operation: comparison
// Bit width: 8
// Source: standard textbook design (magnitude comparator)
// Ground truth: eq = (a == b), gt = (a > b), lt = (a < b)

module comparator_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output       eq,
    output       gt,
    output       lt
);
    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);
endmodule
