module MEM (
		input clk,rst,
		// SRAM  UNIT
		output pause,
		inout  [15:0]	SRAM_DQ,	//	SRAM Data bus 16 Bits
		output [17:0]	SRAM_ADDR,	//	SRAM Address bus 18 Bits
		output			SRAM_UB_N,	//	SRAM High-byte Data Mask
		output			SRAM_LB_N,	//	SRAM Low-byte Data Mask
		output			SRAM_WE_N,	//	SRAM Write Enable
		output			SRAM_CE_N,	//	SRAM Chip Enable
		output			SRAM_OE_N,	//	SRAM Output Enable

		input WB_En_EXE,
		input [1:0] MEM_Signal_EXE,
		input [4:0] dest_EXE,
		input [31:0] ALU_result_EXE,reg2_EXE,

		output WB_En_MEM,MEM_R_EN,
		output [4:0] dest_MEM,
		output [31:0] ALU_result_MEM,dataMemOut
	);
	wire hit;
	wire WR_EN_SRAM, RD_EN_SRAM, pause_SRAM, readyFlagData64B;
	wire [31:0] ALU_result_EXE_;
	wire [31:0] dataMemOut_in32B, dataMemOut_in32B_temp, data_32B_ForSelect;
	wire [63:0] dataMemOut_in64B;
	assign ALU_result_EXE_ = ALU_result_EXE - 1024;
	SRAM _SRAM (
	            clk,rst,
	            // From Memory Stage
				WR_EN_SRAM, RD_EN_SRAM,	//WR_EN,RD_EN,
				hit,
	            ALU_result_EXE_,reg2_EXE, 	//address, writeData,
	            //To Next Stage
	            dataMemOut_in64B,	//readDate,

	            // For Cashe Stage
	            pause_SRAM,
				readyFlagData64B,

	            SRAM_DQ,	//	SRAM Data bus 16 Bits
	            SRAM_ADDR,	//	SRAM Address bus 18 Bits
	            SRAM_UB_N,	//	SRAM High-byte Data Mask
	            SRAM_LB_N,	//	SRAM Low-byte Data Mask
	            SRAM_WE_N,	//	SRAM Write Enable
	            SRAM_CE_N,	//	SRAM Chip Enable
	            SRAM_OE_N	//	SRAM Output Enable
	);
	Cache _chache (
				clk,rst,
				// From Memory Stage
				MEM_Signal_EXE[0],MEM_Signal_EXE[1], //WR_EN,RD_EN,
				ALU_result_EXE_,  	//address,

				//To Next Stage
				dataMemOut_in32B_temp,	//readData,

				// For freeze other Stage
				pause,
				readyFlagData64B,

				// From SRAM
				pause_SRAM,
				dataMemOut_in64B, 	//[63:0] outData_SRAM,

				//To SRAM
				WR_EN_SRAM, RD_EN_SRAM,hit

    );
	assign data_32B_ForSelect = (ALU_result_EXE_[2]) ? dataMemOut_in64B[63:32] : dataMemOut_in64B[31:0];
	assign dataMemOut_in32B = (readyFlagData64B) ? data_32B_ForSelect : dataMemOut_in32B_temp;
	MEMReg _MEMReg (clk,rst,pause,WB_En_EXE,MEM_Signal_EXE[1],dest_EXE,ALU_result_EXE,dataMemOut_in32B,WB_En_MEM,MEM_R_EN,dest_MEM,ALU_result_MEM,dataMemOut);
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMSub (
		input clk,rst,
		input [1:0] MEM_Signal_EXE,
		input [31:0] ALU_result_EXE,reg2_EXE,//address

		output [31:0] dataMemOut
	);
	//MEMSub _MEMSub(
	//	clk,rst,
	//	MEM_Signal_EXE,
	//	ALU_result_EXE,reg2_EXE,//address

	//	dataMemOut_in
	//);
	wire [31:0] addrMapping;
	wire [5:0] addrMem;
	assign addrMapping = ALU_result_EXE - 1024;
	assign addrMem = {addrMapping[7:2]};

	reg	[31:0] dataMem[63:0]; //2 ^ 6 = 64
	//integer i;
	//initial begin
	//    for(i = 0; i < 1024; i = i+1) begin
	//        dataMem[i] = 32'd0;
	//	end
	//end

    always @(posedge clk) begin
		if (MEM_Signal_EXE[0]) begin
			dataMem[addrMem] <= reg2_EXE;
		end
	end

	assign dataMemOut = dataMem[addrMem];

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMReg (
		input clk,rst,
		// SRAM  UNIT
		pause,
		input WB_En_in,MEM_R_ENin,
		input [4:0] dest_in,
		input [31:0] ALU_result_in,dataMemOut_in,

		output reg WB_En,MEM_R_EN,
		output reg [4:0] dest,
		output reg [31:0] ALU_result,dataMemOut

	);
	always@(posedge clk) begin
		if (rst) begin
			WB_En <= 1'd0;
			MEM_R_EN <= 1'b0;
			dest <= 5'd0;
			ALU_result <= 32'd0;
			dataMemOut <= 32'd0;
		end
		else begin
			if (pause) begin
				WB_En <= WB_En;
				MEM_R_EN <= MEM_R_EN;
				dest <= dest;
				ALU_result <= ALU_result;
				dataMemOut <= dataMemOut;
			end
			else begin
				WB_En <= WB_En_in;
				MEM_R_EN <= MEM_R_ENin;
				dest <= dest_in;
				ALU_result <= ALU_result_in;
				dataMemOut <= dataMemOut_in;
			end
		end
	end

endmodule
