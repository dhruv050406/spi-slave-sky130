module spi_slave (
	input wire clk,
	input wire cs_n,
	input wire mosi,
	output reg miso,
        output reg [3:0] parallel_out
	);
	reg [7:0] shift_reg;
	reg [2:0] bit_cnt;

	always @(posedge clk or posedge cs_n) begin
		if(cs_n) begin
			shift_reg <= 8'b00000000;
		end else begin
			shift_reg <= {shift_reg[6:0], mosi};
		end
	end

	always @(posedge clk or posedge cs_n) begin
		if(cs_n) begin
			bit_cnt <= 3'b000;
		end else begin
			bit_cnt <= bit_cnt + 1'b1;
		end
	end

	localparam idle = 1'b0;
	localparam transfer = 1'b1;

	reg current_state, next_state;
	always @(posedge clk or posedge cs_n) begin
		if(cs_n) begin
			current_state <= idle;
		end else begin
			current_state <= next_state;
		end
	end

		always @(*) begin
			case (current_state)
				idle: begin
					if(!cs_n) next_state = transfer;
					else next_state = idle;
				end
			transfer: begin
				if (bit_cnt == 3'b111) next_state = idle;
				else next_state = transfer;
			end
		default: next_state = idle;
	endcase
end

reg [3:0] reg_control;
reg [3:0] reg_status;

always @(posedge clk) begin
	if(!cs_n && (bit_cnt == 3'b111)) begin
		if(shift_reg[7:4] == 4'b0000) begin
			reg_control <= shift_reg[3:0];
		end
		else if(shift_reg [7:4] == 4'b0001) begin
		      reg_status <= shift_reg[3:0];
	      end
      end
end

always @(*) begin
	if(!cs_n) begin
		miso = shift_reg[7];
	end else begin
		miso=1'bz;
	end
end

always @(*) begin
	if(!cs_n) begin
		parallel_out = reg_control;
	end else begin
		parallel_out = reg_status;
	end
end

endmodule 



	
