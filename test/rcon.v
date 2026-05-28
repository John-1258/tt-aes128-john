//This is Rcon in key expansion. 
//Input: round number
//output: Value that use to XOR with the keyword


module rcon (
	input [3:0] round,
	input [31:0] keyin,
	
	output reg [31:0] keyout
	);
	
	reg [31:0] roundval;

	always @(*) begin
		case(round)
			4'd1: roundval = 32'h01000000;
			4'd2: roundval = 32'h02000000;
			4'd3: roundval = 32'h04000000;
			4'd4: roundval = 32'h08000000;
			4'd5: roundval = 32'h10000000;
			4'd6: roundval = 32'h20000000;
			4'd7: roundval = 32'h40000000;
			4'd8: roundval = 32'h80000000;
			4'd9: roundval = 32'h1b000000;
			4'd10: roundval = 32'h36000000;
			default: roundval = 32'h00000000;
		endcase
		
		keyout = roundval ^ keyin;

	end
endmodule

module key_col0 (
	input [3:0] round,
	input [31:0] key_col_in,
	
	output [31:0] key_col_out
	);
	
	wire [31:0] rotword_val;
	wire [31:0] subword_val;
	
	rotword rotword1(.inword(key_col_in), .outword(rotword_val));
	subword subword1(.inword(rotword_val), .outword(subword_val));
	rcon rcon1(.round(round), .keyin(subword_val), .keyout(key_col_out));

endmodule 

module key_gen (
		input [3:0] round,
		input [127:0] keyin,
		
		output [127:0] keyout
		
	);
	
		wire [31:0] key_col[3:0];
		wire [31:0] key_col_next[3:0];
		wire [31:0] key_col_0;
	
		assign key_col[3] = keyin[31:0];
		assign key_col[2] = keyin[63:32];
		assign key_col[1] = keyin[95:64];
		assign key_col[0] = keyin[127:96];
		
		assign keyout[31:0] = key_col_next[3];
		assign keyout[63:32] = key_col_next[2];
		assign keyout[95:64] = key_col_next[1];
		assign keyout[127:96] = key_col_next[0];
		
		key_col0 key_col0_1(.round(round), .key_col_in(key_col[3]), .key_col_out(key_col_0));
		
		assign key_col_next[0] = key_col[0] ^ key_col_0;
		assign key_col_next[1] = key_col_next[0] ^ key_col[1];
		assign key_col_next[2] = key_col_next[1] ^ key_col[2];
		assign key_col_next[3] = key_col_next[2] ^ key_col[3];		
		
endmodule