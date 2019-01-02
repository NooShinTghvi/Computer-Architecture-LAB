`timescale 1ns / 1ns

module systemImplementation(input clk,rst);
wire BrTaken, WB_En_IDin, WB_En_IDout, WB_En_EXE, WB_En_MEM, MEM_R_EN, isSrc2, freeze,pause;
wire [1:0] MEM_Signal_ID,Branch_Type_ID,MEM_Signal_EXE,
//ForwardDetect
ALU_vONE_Mux,ALU_vTWO_Mux,SRC_vTWO_Mux;
wire [3:0] EXE_CMD_ID;
wire [4:0] WB_Dest_ID,dest_ID,dest_EXE,dest_MEM, src1, src2, src1Fw, src2Fw;
wire [31:0] PC_IF,PC_ID,BrAdder,instruction,WB_Data_ID,val1,reg2_ID,val2,PC_EXE,ALU_result_EXE,reg2_EXE,ALU_result_MEM,dataMemOut,
						//ForwardDetect
						ALU_result_ForForward , WB_result_ForForward;
//#####################################
wire [15:0]	SRAM_DQ;	
wire [17:0]	SRAM_ADDR;
wire 		SRAM_UB_N;	//	SRAM High-byte Data Mask
wire		SRAM_LB_N;	//	SRAM Low-byte Data Mask
wire		SRAM_WE_N;	//	SRAM Write Enable
wire		SRAM_CE_N;	//	SRAM Chip Enable
wire		SRAM_OE_N;	//	SRAM Output Enable					
//#####################################						
IF _IF(
	clk,rst,freeze,BrTaken,
	// SRAM  UNIT
	pause,
	BrAdder,PC_IF,instruction
);

ID _ID (
	clk,rst,freeze,BrTaken,
	// SRAM  UNIT
	pause,
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
	dest_ID, src1, src2, src1Fw, src2Fw
);

Exe _EXE (
	clk,rst,
	// SRAM  UNIT
	pause,
	//ForwardDetect
	ALU_vONE_Mux,ALU_vTWO_Mux,SRC_vTWO_Mux,

	// from ID stage to Mem stage : input
	WB_En_IDout,
	MEM_Signal_ID,
	dest_ID,

	EXE_CMD_ID,
	val1,val2,reg2_ID,PC_ID,
	Branch_Type_ID,
	//ForwardDetect
	ALU_result_EXE, //ALU_result_ForForward
	WB_Data_ID, //WB_result_ForForward,

	BrAdder,
	BrTaken,
	// from ID stage to Mem stage : output
	WB_En_EXE,
	MEM_Signal_EXE,
	dest_EXE,
	PC_EXE,ALU_result_EXE,reg2_EXE
);

MEM _MEM (
	clk,rst,
	// SRAM  UNIT
	pause,
	SRAM_DQ,	//	SRAM Data bus 16 Bits
	SRAM_ADDR,	//	SRAM Address bus 18 Bits
	SRAM_UB_N,	//	SRAM High-byte Data Mask
	SRAM_LB_N,	//	SRAM Low-byte Data Mask
	SRAM_WE_N,	//	SRAM Write Enable
	SRAM_CE_N,	//	SRAM Chip Enable
	SRAM_OE_N,	//	SRAM Output Enable

	WB_En_EXE,
	MEM_Signal_EXE,
	dest_EXE,
	ALU_result_EXE,reg2_EXE,

	WB_En_MEM,MEM_R_EN,
	dest_MEM,
	ALU_result_MEM,dataMemOut
);

WB _WB (
	WB_En_MEM,MEM_R_EN,
	dest_MEM,
	dataMemOut,ALU_result_MEM,

	WB_En_IDin,
	WB_Dest_ID,
	WB_Data_ID
);

HazardDetect _HazardDetect (
        WB_En_IDout, WB_En_EXE,isSrc2,
        src1, src2, dest_ID, dest_EXE,
        0, MEM_Signal_ID[1],
        freeze
    );

ForwardDetect _ForwardDetect (
    	1,
        src1Fw, src2Fw,
        dest_ID,	//Dest_EXE
		dest_EXE,	//Dest_MEM
		dest_MEM,	//Dest_WB

        WB_En_EXE,	//WB_EN_MEM
		WB_En_MEM,	//WB_EN_WB

        ALU_vONE_Mux,ALU_vTWO_Mux,SRC_vTWO_Mux
    );
SramMem _SramMem(
			clk, rst,
			SRAM_DQ,	//	SRAM Data bus 16 Bits
			SRAM_ADDR,	//	SRAM Address bus 18 Bits
            SRAM_WE_N,
			SRAM_CE_N //***
		);
endmodule
