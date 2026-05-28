module tt_AES128 (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    reg [7:0] key_reg      [0:15];
    reg [7:0] plaintext_reg[0:15];
    reg [7:0] encrypted_reg[0:15];

    wire [127:0] key_flat;
    wire [127:0] plaintext_flat;
    wire [127:0] encrypted_flat;

    wire [4:0] byte_index = uio_in[4:0];
    wire       we         = uio_in[5];
    wire       start      = uio_in[6];
    wire       output_sel = uio_in[7];
	 
    integer i;
    genvar  j;

    // flatten plaintext and key
	generate
		 for (j = 0; j < 16; j = j+1) begin : flatten
			  // byte 0 → bits[127:120], byte 15 → bits[7:0]
			  assign key_flat      [127-(j*8) -: 8] = key_reg[j];
			  assign plaintext_flat[127-(j*8) -: 8] = plaintext_reg[j];
		 end
	endgenerate

    // start/busy/done interface
    reg  start_q, busy_q, done_q, done_w_d;
    wire done_w;

    main main1 (
        .clk       (clk),
        .start     (start_q),
        .data_in   (plaintext_flat),
        .key_in    (key_flat),
        .result_out(encrypted_flat),
        .done      (done_w)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_q <= 1'b0;
            busy_q <= 1'b0;
            done_q <= 1'b0;
            done_w_d <= 1'b0;
        end else begin
            done_w_d <= done_w;   

				// start_q pulses for one cycle
            if (start && !busy_q) begin
                start_q <= 1'b1;  
                busy_q  <= 1'b1;
                done_q  <= 1'b0;  
            end else begin
                start_q <= 1'b0;
            end

				// computations done
            if (done_w_d) begin
                busy_q <= 1'b0;
                done_q <= 1'b1; 
            end
        end
    end

    // using ui_in to input key and plaintext
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 16; i = i+1) begin
                key_reg[i] <= 8'd0;
                plaintext_reg[i] <= 8'd0;
            end
        end else if (we) begin
            if (byte_index < 5'd16)
                key_reg[byte_index] <= ui_in;
            else
                plaintext_reg[byte_index - 16] <= ui_in;
        end
    end

	// collect encrypted
	wire [7:0] encrypted_wire[0:15];
	generate
		 for (j = 0; j < 16; j = j+1) begin : flatten_cipher
          assign encrypted_wire[j] = encrypted_flat[127-(j*8) -: 8];
		 end
	endgenerate

	// gets encrypted
	always @(posedge clk or negedge rst_n) begin
		 if (!rst_n) begin
			  for (i = 0; i < 16; i = i+1)
					encrypted_reg[i] <= 8'd0;
		 end else if (done_w_d) begin
			  for (i = 0; i < 16; i = i+1)
					encrypted_reg[i] <= encrypted_wire[i];
		 end
	end

	// sends out encrypted
   always @(*) begin
        if (done_q && output_sel)
            uo_out = encrypted_reg[byte_index[3:0]];
        else if (done_q)
            uo_out = 8'h01;
        else
            uo_out = 8'h00;				
   end

	assign uio_out = {6'd0, done_q, busy_q};
   assign uio_oe  = 8'd0;

endmodule
