// ArithBench-100: 4-operation ALU
// Operation: arithmetic-logic unit | Bit width: 8
// Source: Harris & Harris textbook (ALU, Table 5.1 style control encoding)
// Ground truth (control encoding):
//   00 -> a + b
//   01 -> a - b
//   10 -> a & b
//   11 -> a | b
module alu_4op (
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] alu_control,
    output [7:0] result
);
    assign result = (alu_control == 2'b00) ? (a + b) :
                    (alu_control == 2'b01) ? (a - b) :
                    (alu_control == 2'b10) ? (a & b) :
                                             (a | b);
endmodule
