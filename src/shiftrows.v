//Shift row for all 128 bits 
//Input: full 128 bits
//Output: full 128 bits shifted rows

module shiftrows (
	input [127:0] wordin, 
	output [127:0] wordout
);


//row0
	assign wordout[127:120] = wordin[127:120];
	assign wordout[95:88]   = wordin[95:88];
	assign wordout[63:56]   = wordin[63:56];
	assign wordout[31:24]   = wordin[31:24];

//row1
	assign wordout[119:112] = wordin[87:80];
	assign wordout[87:80]   = wordin[55:48];
	assign wordout[55:48]   = wordin[23:16];
	assign wordout[23:16]   = wordin[119:112];

//row2
	assign wordout[111:104] = wordin[47:40];
	assign wordout[79:72]   = wordin[15:8];
	assign wordout[47:40]   = wordin[111:104];
	assign wordout[15:8]    = wordin[79:72];

//row3
	assign wordout[103:96]  = wordin[7:0];
	assign wordout[71:64]   = wordin[103:96];
	assign wordout[39:32]   = wordin[71:64];
	assign wordout[7:0]     = wordin[39:32];

	
	
endmodule 