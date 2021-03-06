`timescale 1ns / 1ns

module systemImplementation(input clk,rst);
wire BrTaken, WB_En_IDin, WB_En_IDout, WB_En_EXE, WB_En_MEM, MEM_R_EN, isSrc2, freez;
wire [1:0] MEM_Signal_ID,Branch_Type_ID,MEM_Signal_EXE;
wire [3:0] EXE_CMD_ID;
wire [4:0] WB_Dest_ID,dest_ID,dest_EXE,dest_MEM, src1, src2;
wire [31:0] PC_IF,PC_ID,BrAdder,instruction,WB_Data_ID,val1,reg2_ID,val2,PC_EXE,ALU_result_EXE,reg2_EXE,ALU_result_MEM,dataMemOut;


IF _IF(clk,rst,freez,BrTaken,BrAdder,PC_IF,instruction);

ID _ID (
	clk,rst,freez,BrTaken,
	// from IF
	instruction,PC_IF,
	// from WB stage
	WB_En_IDin,
	WB_Dest_ID,
	WB_Data_ID,
	//to stage register
	isSrc2,WB_En_IDout,
	MEM_Signal_ID,Branch_Type_ID,
	EXE_CMD_ID,
	val1,val2,reg2_ID,PC_ID,
	dest_ID, src1, src2
);

Exe _EXE
(
	clk,rst,
	// from ID stage to Mem stage : input
	WB_En_IDout,
	MEM_Signal_ID,
	dest_ID,

	EXE_CMD_ID,
	val1,val2,reg2_ID,PC_ID,
	Branch_Type_ID,

	BrAdder,
	BrTaken,
	// from ID stage to Mem stage : output
	WB_En_EXE,
	MEM_Signal_EXE,
	dest_EXE,
	PC_EXE,ALU_result_EXE,reg2_EXE
);

MEM _MEM
(
	clk,rst,
	WB_En_EXE,
	MEM_Signal_EXE,
	dest_EXE,
	ALU_result_EXE,reg2_EXE,

	WB_En_MEM,MEM_R_EN,
	dest_MEM,
	ALU_result_MEM,dataMemOut
);

WB _WB
(
	WB_En_MEM,MEM_R_EN,
	dest_MEM,
	dataMemOut,ALU_result_MEM,

	WB_En_IDin,
	WB_Dest_ID,
	WB_Data_ID
);

HazardDetect _HazardDetect
    (
        WB_En_IDout, WB_En_EXE,isSrc2,
        src1,src2, dest_ID, dest_EXE,
        1,
        freez
    );

endmodule