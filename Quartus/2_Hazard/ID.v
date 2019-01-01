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
		output[4:0] src1, src2,
		//Copro : To other stage
		input freezCos,
		// To Copro
		output cntrlCos
	);
	wire WB_EnWire, _cntrlCos;
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
		WB_EnWire, src1, src2,
		// To Copro
		_cntrlCos
	);

	IDReg _IDReg(
		clk,rst, flush,freezCos,
		// to stage Register
		DestWire,
		reg1,reg2,muxOut,PCIn,
		Branch_TypeIn,
		EXE_CMDin,
		MEM_SignalIn,
		WB_EnWire,
		_cntrlCos,
		// to stage register
		destOut,
		val1,reg2_,val2,PCOut,
		Branch_TypeOut,
		EXE_CMDout,
		MEM_SignalOut,
		WB_ENout,
		cntrlCos
	);
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
		output[4:0] source1, source2,
		// To Copro
		output cntrlCos
	);

	wire is_imm;
	wire [31:0] sgnExtendOut;

	// * * * * * * * Description * * * * * * *
	// val1 is reg1
	// val2 is muxOut
	// * * * * * * * * * * * * * * * * * * * *

	// **** Registe File ****
	//RegisterFile(input clk,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
	RegisterFile _regFile (clk,rst,WB_ENin,instruction[25:21],instruction[20:16],WB_Dest,WB_Data,reg1,reg2);


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
	controller _cont(instruction[31:26],__WB_EN,__MEM_Signal,__Branch_Type,__EXE_CMD,is_imm,isSrc2,cntrlCos);

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
		input clk,rst, flush,freezCos,
		// to stage Register
		input[4:0] destIn,
		input[31:0] reg1_in,reg2_in,muxOut,PCIn,
		input[1:0] Branch_TypeIn,
		input[3:0]EXE_CMDin,
		input[1:0] MEM_SignalIn,
		input WB_ENin,
		input _cntrlCos,
		// to stage register
		output reg[4:0] destOut,
		output reg[31:0] val1,reg2,val2,PCOut,
		output reg[1:0] Branch_TypeOut,
		output reg[3:0]EXE_CMDout,
		output reg[1:0] MEM_SignalOut,
		output reg WB_ENout,
		output reg cntrlCos
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
			cntrlCos <= 1'b0;
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
				cntrlCos <= 1'b0;
			end // if(flush)
			else begin
				if (freezCos) begin 
					destOut <= destOut;
					val1 <= val1;
					reg2 <= reg2;
					val2 <= val2;
					PCOut <= PCOut;
					WB_ENout <= WB_ENout;
					MEM_SignalOut <= MEM_SignalOut;
					Branch_TypeOut <= Branch_TypeOut;
					EXE_CMDout <= EXE_CMDout;
					cntrlCos <= cntrlCos;
				end
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
					cntrlCos <= _cntrlCos;
				end
			end // else
		end
	end


endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module controller(input [5:0] opcode, output reg WB_En, output reg [1:0] Mem_Signals, output reg [1:0] Branch_Type, output reg [3:0] Exe_Cmd, output reg isImm, isSrc2, cntrlCos);
	always @(*) begin
		case (opcode)
			6'b000000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b000000000000; // NOP
			6'b000001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000000010; // ADD
			6'b000011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000010010; // SUB
			6'b000101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000100010; // AND
			6'b000110: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000101010; // OR
			6'b000111: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000110010; // NOR
			6'b001000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000111010; // XOR
			6'b001001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100001000010; // SLA
			6'b001010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100001000010; // SLL
			6'b001011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100001001010; // SRA
			6'b001100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100001010010; // SRL
			6'b100000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000000100; // ADDI
			6'b100001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000010100; // SUBI
			6'b100100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b110000000100; // LD
			6'b100101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b001000000110; // ST
			6'b101000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b000010000100; // BEZ
			6'b101001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b000100000110; // BNE
			6'b101010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b000110000110; // JMP
			6'b111111: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b100000000001; // COS Controller -> 1 00 00 0000  0 0 1
			default :  {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm, isSrc2, cntrlCos} = 12'b000000000000; // NOP
		endcase
	end
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module RegisterFile(input clk,rst,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
	reg	[31:0] reg_file[31:0];
	integer i;
    always @(negedge clk,posedge rst) begin
		if (rst) begin
			for(i = 0; i < 32; i = i+1) begin
				reg_file[i] = i;
			end
		end
		else begin
			if (RegWrt && WrtReg!= 0) begin
				reg_file[WrtReg] <= WrtData;
			end
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
