//odule for subword, sue Sbox to get the suitable value 
//Input: input word 
//process: it takes 2 bits as one letter and translate it.
//Output: translated word

module subword(
    input  [31:0] inword,
    output [31:0] outword
);

sbox w0 (
    inword[31:24],
    outword[31:24]
);

sbox w1 (
    inword[23:16],
    outword[23:16]
);

sbox w2 (
    inword[15:8],
    outword[15:8]
);

sbox w3 (
    inword[7:0],
    outword[7:0]
);

endmodule

