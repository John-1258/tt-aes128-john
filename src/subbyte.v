module subbyte(
	input [127:0] wordin,
	output [127:0] wordout
	);

	sbox w0  (wordin[127:120], wordout[127:120]);
	sbox w1  (wordin[119:112], wordout[119:112]);
	sbox w2  (wordin[111:104], wordout[111:104]);
	sbox w3  (wordin[103:96],  wordout[103:96]);
	sbox w4  (wordin[95:88],   wordout[95:88]);
	sbox w5  (wordin[87:80],   wordout[87:80]);
	sbox w6  (wordin[79:72],   wordout[79:72]);
	sbox w7  (wordin[71:64],   wordout[71:64]);
	sbox w8  (wordin[63:56],   wordout[63:56]);
	sbox w9  (wordin[55:48],   wordout[55:48]);
	sbox w10 (wordin[47:40],   wordout[47:40]);
	sbox w11 (wordin[39:32],   wordout[39:32]);
	sbox w12 (wordin[31:24],   wordout[31:24]);
	sbox w13 (wordin[23:16],   wordout[23:16]);
	sbox w14 (wordin[15:8],    wordout[15:8]);
	sbox w15 (wordin[7:0],     wordout[7:0]);

	


endmodule 