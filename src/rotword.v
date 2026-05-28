//module for rotword in key expansion
//Input: one row in key
//output: rotated row 

module rotword (
	input [31:0] inword, 
	output [31:0] outword
	);
								
	assign outword = {inword[23:0], inword[31:24]};
	
endmodule 

					
					
					
					
					
					
					
					

