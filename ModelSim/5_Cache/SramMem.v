module SramMem (
			input clk, rst,
			inout  [15:0]	SRAM_DQ,	//	SRAM Data bus 16 Bits
            input [17:0]	SRAM_ADDR,	//	SRAM Address bus 18 Bits
            input			WR_EN,
			input			RD_EN
		);
	
	reg[15:0] sramMemory [2047:0]; // 2^11 = 2048
	
	wire [10:0] addr;
	assign addr = SRAM_ADDR[10:0];
	
	integer i;
	always @(negedge clk,posedge rst) begin
		if (rst) begin
			for(i = 0; i < 2047; i = i+1) begin
				sramMemory[i] = 0;
			end
		end
		else begin
			if (!WR_EN) begin
				sramMemory[addr] <= SRAM_DQ;
			end
		end
	end
	
	assign SRAM_DQ = (RD_EN) ? sramMemory[addr] : 16'bzzzzzzzzzzzzzzzz;
	
endmodule