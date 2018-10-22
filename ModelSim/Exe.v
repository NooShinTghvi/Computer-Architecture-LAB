module Exe
	(
		input clk,
		input [3:0] EXE_CMD,
		input [31,0] val1,val2,val1_src2,PC,
		input [1:0] Br_type,
		
		output [31:0] ALU_result,Br_Adder,
		output Br_tacken
	);
	
	
	ExeReg _ExeReg(clk,rst,WB_EN_ID_out,MEM_R_EN_ID_out,MEM_W_EN_ID_out,PC_out_ID,ALU_result_EXE_in,val_src2,
		Dest_ID_out,WB_en_EXE_out,MEM_R_EN_EXE_out,MEM_W_EN_EXE_out,PC_out_EXE,ALU_result_EXE_out,ST_val_EXE_out,Dest_EXE_out);	
	
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ExeSub
	(
		input clk,
		input [3:0] EXE_CMD,
		input [31,0] val1,val2,val1_src2,PC,
		input [1:0] Br_type,
		
		output [31:0] ALU_result,Br_Adder,
		output Br_tacken
	);

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ExeReg
	(
		input clk,rst,
		input WB_en_in,
		//MEM_Signals
		input MEM_R_EN_in,
		input MEM_W_EN_in,
	
		input [31:0] PC_in,
		input [31:0] ALU_result_in,
		input [31:0] ST_val_in,
		input [31:0] Dest_in,
		
		output reg WB_en,
		// MEM_Signals 
		output reg MEM_R_EN,
		output reg MEM_W_EN,
		output reg [31:0] PC,
		output reg [31:0] ALU_result,
		output reg [31:0] ST_val,
		output reg [4:0] Dest
	);
	
	always@(posedge clk) begin
		if (rst) begin
			MEM_R_EN <= 1'b0;
			MEM_W_EN <= 1'b0;
			WB_en <= 1'b0;
			PC <= 32'b0;
			ALU_result <= 32'b0;
			ST_val <= 32'b0;
			Dest <= 5'b0;
		end
		else begin
			MEM_R_EN <= MEM_R_EN_in;
			MEM_W_EN <= MEM_W_EN_in;
			WB_en <= WB_en_in;
			PC <= PC_in;
			ALU_result <= ALU_result_in;
			ST_val <= ST_val_in;
			Dest <= Dest_in;
		end
	end
	
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	
