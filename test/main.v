module main (

	input clk,
	input start,
	
	input [127:0] data_in,
	input [127:0] key_in,
	
	output [127:0] result_out,
	output done
);

	reg [3:0] round;
	wire [3:0] round_next;
	
	wire completed;
	wire round_last;

	reg [127:0] next_reg;
	wire [127:0] data_next;
		
	reg [127:0] key_reg;
	wire [127:0] next_round_key;
	wire [127:0] next_key;
	wire [127:0] current_key;
	wire [127:0] round_key;
	
	wire [127:0] subbyte_val;
	wire [127:0] shiftrow_val;
	wire [127:0] mixcol_val;
	
	wire [31:0] col0_in, col1_in, col2_in, col3_in;
	wire [31:0] col0_out, col1_out, col2_out, col3_out;
	
	initial begin
		round = 4'd0;
		next_reg = 128'd0;
		key_reg = 128'd0;
	end
	
	//the complete round is at 10
	assign completed = (round == 4'd10);
	assign round_next = completed ? 4'd0 : (round + 4'd1);
	assign round_last = (round == 4'd10);
	
	always @(posedge clk) begin
		//check if round is zero
		if ( (|round) || start )
			round <= round_next;
		
		if (start)
			//round start with one add round key
			
			next_reg <= data_in ^ key_in;
		else if (|round)
			next_reg <= data_next;
			
//		   $display("time=%0t round=%0d start=%b next_reg=%h data_next=%h", 
//         			$time, round, start, next_reg, data_next);
//			$display("subbyte=%h shiftrow=%h mixcol=%h roundkey=%h", 
//						subbyte_val, shiftrow_val, mixcol_val, current_key);
//			$display("current_key=%h next_key=%h", current_key, next_key);
//			$display("current_key=%h roundkey=%h mixcol XOR current_key=%h", 
//						current_key, round_key, mixcol_val ^ current_key);
	end
	
	subbyte subbyte1(.wordin(next_reg), .wordout(subbyte_val));
	
	shiftrows shiftrows1(.wordin(subbyte_val), .wordout(shiftrow_val));

	mixcolumns_one_column mix_0 (.col_in(shiftrow_val[127:96]), .col_out(mixcol_val[127:96]));
	mixcolumns_one_column mix_1 (.col_in(shiftrow_val[95:64]), .col_out(mixcol_val[95:64]));
   mixcolumns_one_column mix_2 (.col_in(shiftrow_val[63:32]), .col_out(mixcol_val[63:32]));
   mixcolumns_one_column mix_3 (.col_in(shiftrow_val[31:0]), .col_out(mixcol_val[31:0]));	 

	//check what key we using
	assign current_key = start ? key_in : key_reg;
	assign data_next = round_last ? (shiftrow_val ^ current_key)
						  : (mixcol_val ^ current_key);

	always @(posedge clk) begin
		if ( (|round) || start )
			key_reg <= next_key;
	end
	key_gen key_gen1(.round(round + 4'd1), .keyin(current_key), .keyout(next_key));
	
	assign done = completed;
	assign result_out = next_reg;
	
endmodule
