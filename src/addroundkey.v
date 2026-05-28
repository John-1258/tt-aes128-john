//first step in the process, add round key 
//Input: 128 bits of text and 128 bits of key
//Process: it XOR the text and key 
//Output: XOR result

module addroundkey (
	input [0:127] wordin,
	input [0:127] key,
	output [0:127] wordout
);

	assign wordout = wordin ^ key;	


endmodule 