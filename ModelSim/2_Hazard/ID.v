module ID
	(
		input clk,rst,freez, flush,
		// from IF
		input [31:0] instruction,PCIn,
		// from WB stage
		input WB_ENin,
		input[4:0] WB_Dest,
		input [31:0] WB_Data,
		//to stage register
		output isSrc2,WB_ENout,
		output[1:0] MEM_SignalOut,Branch_TypeOut,
		output[3:0]EXE_CMDout,
		output[31:0] val1,val2,reg2_,PCOut,
		output[4:0] destOut,
		output[4:0] src1, src2
	);
	wire WB_EnWire;
	wire [1:0] Branch_TypeIn,MEM_SignalIn;
	wire [3:0] EXE_CMDin;
	wire [4:0] DestWire;
	wire [31:0] muxOut,reg1,reg2;
	wire __WB_EN;
	wire [1:0] __MEM_Signal,__Branch_Type;
	wire [3:0] __EXE_CMD;
	IDsub _IDsub(
		clk,rst,freez,
		// from IF
		instruction,
		// from WB stage
		WB_ENin,
		WB_Dest,
		WB_Data,

		isSrc2,
		//to stage register
		DestWire,
		reg1,muxOut,reg2,
		Branch_TypeIn,
		EXE_CMDin,
		// mem_signal
		MEM_SignalIn,
		// write back enable
		WB_EnWire, src1, src2);

	IDReg _IDReg(
		clk,rst, flush,
		// to stage Register
		DestWire,
		reg1,reg2,muxOut,PCIn,
		Branch_TypeIn,
		EXE_CMDin,
		MEM_SignalIn,
		WB_EnWire,
		// to stage register
		destOut,
		val1,reg2_,val2,PCOut,
		Branch_TypeOut,
		EXE_CMDout,
		MEM_SignalOut,
		WB_ENout);
endmodule

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module IDsub
	(
		input clk,rst,freez,
		// from IF
		input [31:0] instruction,
		// from WB stage
		input WB_ENin,
		input[4:0] WB_Dest,
		input[31:0] WB_Data,

		output isSrc2,
		//to stage register
		output[4:0] Dest,
		output [31:0] reg1,muxOut,reg2,
		output[1:0] Branch_Type,
		output[3:0] EXE_CMD,
		// mem_signal
		output[1:0] MEM_Signal,
		// write back enable
		output WB_EN,
		output[4:0] source1, source2
	);

	wire is_imm;
	wire [31:0] sgnExtendOut;

	// * * * * * * * Description * * * * * * *
	// val1 is reg1
	// val2 is muxOut
	// * * * * * * * * * * * * * * * * * * * *

	// **** Registe File ****
	//RegisterFile(input clk,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
	RegisterFile _regFile (clk,WB_ENin,instruction[25:21],instruction[20:16],WB_Dest,WB_Data,reg1,reg2);


	// **** Sign Extend ****
	//module signExtend(input[15:0] in, output[31:0] out);
	signExtend _signExtend(instruction[15:0],sgnExtendOut);

	// **** Mux ****
	//module Mux2to1_32(input s, input [31:0] in0,in1, output [31:0] w);
	Mux2to1_32 _mux (is_imm,reg2,sgnExtendOut,muxOut);

	// **** Mux ****
	Mux2to1_5 _muxDest (is_imm,instruction[15:11],instruction[20:16],Dest);

	// **** CU ****
	wire __WB_EN;
	wire [1:0] __MEM_Signal,__Branch_Type;
	wire [3:0] __EXE_CMD;
	controller _cont(instruction[31:26],__WB_EN,__MEM_Signal,__Branch_Type,__EXE_CMD,is_imm,isSrc2);

	assign WB_EN = (freez == 1'b1) ? 1'b0 : __WB_EN;
	assign MEM_Signal = (freez == 1'b1) ? 2'b0 : __MEM_Signal;
	assign Branch_Type = (freez == 1'b1) ? 2'b0 : __Branch_Type;
	assign EXE_CMD = (freez == 1'b1) ? 4'b0 : __EXE_CMD;
	assign source1 = instruction[25:21];
	assign source2 = instruction[20:16];
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module IDReg
	(
		input clk,rst, flush,
		// to stage Register
		input[4:0] destIn,
		input[31:0] reg1_in,reg2_in,muxOut,PCIn,
		input[1:0] Branch_TypeIn,
		input[3:0]EXE_CMDin,
		input[1:0] MEM_SignalIn,
		input WB_ENin,
		// to stage register
		output reg[4:0] destOut,
		output reg[31:0] val1,reg2,val2,PCOut,
		output reg[1:0] Branch_TypeOut,
		output reg[3:0]EXE_CMDout,
		output reg[1:0] MEM_SignalOut,
		output reg WB_ENout
	);

	always@(posedge clk,posedge rst) begin
		if (rst) begin
			destOut <= 5'd0;
			val1 <= 32'd0;
			reg2 <= 32'd0;
			val2 <= 32'd0;
			PCOut <= 32'd0;
			WB_ENout <= 1'd0;
			MEM_SignalOut <= 2'd0;
			Branch_TypeOut <= 2'd0;
			EXE_CMDout <= 4'd0;
		end
		else begin
			if(flush) begin
				destOut <= 5'd0;
				val1 <= 32'd0;
				reg2 <= 32'd0;
				val2 <= 32'd0;
				PCOut <= 32'd0;
				WB_ENout <= 1'd0;
				MEM_SignalOut <= 2'd0;
				Branch_TypeOut <= 2'd0;
				EXE_CMDout <= 4'd0;
			end // if(flush)
			else begin
				destOut <= destIn;
				val1 <= reg1_in;
				reg2 <= reg2_in;
				val2 <= muxOut;
				PCOut <= PCIn;
				WB_ENout <= WB_ENin;
				MEM_SignalOut <= MEM_SignalIn;
				Branch_TypeOut <= Branch_TypeIn;
				EXE_CMDout <= EXE_CMDin;
			end // else
		end
	end


endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module controller(input [5:0] opcode, output reg WB_En, output reg [1:0] Mem_Signals, output reg [1:0] Branch_Type, output reg [3:0] Exe_Cmd, output reg isImm, isSrc2);
	always @(*) begin
		case (opcode)
			6'b000000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00000000000; // NOP
			6'b000001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000000001; // ADD
			6'b000011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000001001; // SUB
			6'b000101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000010001; // AND
			6'b000110: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000010101; // OR
			6'b000111: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000011001; // NOR
			6'b001000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000011101; // XOR
			6'b001001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000100001; // SLA
			6'b001010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000100001; // SLL
			6'b001011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000100101; // SRA
			6'b001100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000101001; // SRL
			6'b100000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000000010; // ADDI
			6'b100001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b10000001010; // SUBI
			6'b100100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b11000000010; // LD
			6'b100101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00100000011; // ST
			6'b101000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00001000010; // BEZ
			6'b101001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00010000011; // BNE
			6'b101010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00011000011; // JMP
			default :  {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2} = 11'b00000000000; // NOP
		endcase
	end
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module RegisterFile(input clk,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
	reg	[31:0] reg_file[31:0];
	integer i;
	initial begin
	    for(i = 0; i < 32; i = i+1) begin
	        reg_file[i] = i;
		end
	end

    always @(negedge clk) begin
		if (RegWrt && WrtReg!= 0) begin
			reg_file[WrtReg] <= WrtData;
		end
	end

	assign RdData1 = reg_file[RdReg1];
	assign RdData2 = reg_file[RdReg2];

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module signExtend(input[15:0] in, output[31:0] out);
	assign out = $signed(in);
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module Mux2to1_32(input s, input [31:0] in0,in1, output [31:0] w);
	assign w = (s == 0) ? in0 : in1;
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module Mux2to1_5(input s, input [4:0] in0,in1, output [4:0] w);
	assign w = (s == 0) ? in0 : in1;
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
