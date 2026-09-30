// ArithBench-100: 8-bit Gray-to-Binary Converter
// Operation: code conversion
// Bit width: 8
// Source: standard textbook design
// Ground truth: binary[i] = XOR of all gray bits from MSB down to i.
//               b[7]=g[7]; b[i]=b[i+1]^g[i].

module gray_to_binary_8bit (
    input  [7:0] gray,
    output [7:0] binary
);
    assign binary[7] = gray[7];
    assign binary[6] = binary[7] ^ gray[6];
    assign binary[5] = binary[6] ^ gray[5];
    assign binary[4] = binary[5] ^ gray[4];
    assign binary[3] = binary[4] ^ gray[3];
    assign binary[2] = binary[3] ^ gray[2];
    assign binary[1] = binary[2] ^ gray[1];
    assign binary[0] = binary[1] ^ gray[0];
endmodule
