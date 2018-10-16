`timescale 1ns / 1ns

module systemImplementation(input clk,rst);
	wire BrTaken,flush_IDin,flush_IDout,WB_En_IDin,WB_En_IDout;
	wire [1:0] MEM_Signal_ID,Branch_Type_ID;
	wire [3:0] EXE_CMD_ID;
	wire [4:0] WB_Dest_ID,dest_ID;
	wire [31:0] PC_IF,PC_ID,instruction,WB_Data_ID,val1,reg2,val2;

	IF _IF(clk,rst,flush,BrTaken,PC_IF,instruction);
	
	ID _ID (
		clk,rst,
		// from IF
		instruction,PC_IF,
		// from WB stage
		WB_En_IDin,
		WB_Dest_ID,
		WB_Data_ID,
		//to stage register
		WB_En_IDout,
		MEM_Signal_ID,Branch_Type_ID,
		EXE_CMD_ID,
		val1,val2,reg2,PC_ID,
		dest_ID,
		
		flush_IDin,
		flush_IDout
	);
endmodule