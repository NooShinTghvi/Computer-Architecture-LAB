module ID(input clk,rst,flush, input[4:0] Dest_WB, input [31:0] instruction,PCIn,result_WB, output reg[4:0] destOut,output reg[31:0] val1,reg2,val2,PCOut,output WB_ENout,output reg[1:0] MEM_SignalOut,Branch_TypeOut, output reg[3:0]EXE_CMDout);
	wire WB_EnWire;
	wire [1:0] MEM_SignalWire,Branch_TypeWire;
	wire [3:0] EXE_CMDWire;
	wire [4:0] DestWire;
	wire [31:0] muxOutWire,reg1Wire,reg2Wire;
	//module IDsub(input clk,rst,WB_ENin, input [31:0] instruction,input[4:0] Dest_WB, input[31:0] result_WB, output WB_EN,output[1:0] MEM_Signal, Branch_Type,output[3:0] EXE_CMD,output[4:0] Dest, output [31:0] muxOut,reg1,reg2);
	IDsub _IDsub(clk,rst,WB_ENin,instruction,Dest_WB,result_WB,WB_EnWire,MEM_SignalWire,Branch_TypeWire,EXE_CMDWire,DestWire,muxOutWire,reg1Wire,reg2Wire);
	
	//IDReg(input clk,rst,flush,input[4:0] destIn,input[31:0] reg1,reg2,muxOut,PCIn,input WB_ENin,input[1:0] MEM_SignalIn,Branch_TypeIn, input[3:0]EXE_CMDin,
	//		output reg[4:0] destOut,output reg[31:0] val1,reg2,val2,
	//		PCOut,
	//		output WB_ENout,output reg[1:0] MEM_SignalOut,Branch_TypeOut, output reg[3:0]EXE_CMDout);
	IDReg _IDReg(clk,rst,flush,DestWire,reg1Wire,reg2Wire,muxOutWire,PCIn,WB_EnWire,MEM_SignalWire,Branch_TypeWire,EXE_CMDWire,
					destOut,val1,reg2,val2,PCOut,WB_ENout,MEM_SignalOut,Branch_TypeOut,EXE_CMDout);



endmodule


module IDsub(input clk,rst,WB_ENin, input [31:0] instruction,input[4:0] Dest_WB, input[31:0] result_WB, output WB_EN,output[1:0] MEM_Signal, Branch_Type,output[3:0] EXE_CMD,output[4:0] Dest, output [31:0] muxOut,reg1,reg2);

wire is_imm;
wire [31:0] reg1,reg2,sgnExtendOut;
	
// **** Registe File ****
//RegisterFile(input clk,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
RegisterFile _regFile (clk,WB_ENin,instruction[25:21],instruction[20:16],Dest_WB,result_WB,reg1,reg2);


// **** Sign Extend ****
//module signExtend(input[15:0] in, output[31:0] out);
signExtend _signExtend(instruction[15:0],sgnExtendOut);

// **** Mux ****
//module Mux2to1_32(input s, input [31:0] in0,in1, output [31:0] w);
Mux2to1_32 _mux (is_imm,reg2,sgnExtendOut,muxOut);

// **** Mux ****
Mux2to1_5 _muxDest (is_imm,instruction[15:11],instruction[20:16],Dest);

// **** CU ****
//module controller(input[5:0] opcode, output WB_En,output[1:0] Mem_Signals, output[1:0] Branch_Type, output[3:0] Exe_Cmd, output isImm);
controller _cont(instruction[31:26],WB_EN,MEM_Signal,Branch_Type,EXE_CMD,is_imm);
	
endmodule

module IDReg(input clk,rst,
			flush,
			input[4:0] destIn,input[31:0] reg1,reg2,muxOut,
			PCIn,
			input WB_ENin,input[1:0] MEM_SignalIn,Branch_TypeIn, input[3:0]EXE_CMDin,
			
			output reg[4:0] destOut,output reg[31:0] val1,reg2,val2,
			PCOut,
			output WB_ENout,output reg[1:0] MEM_SignalOut,Branch_TypeOut, output reg[3:0]EXE_CMDout);
			
	always@(posedge clk,rst) begin
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
			destOut <= destIn;
			val1 <= reg1;
			reg2 <= reg2;
			val2 <= muxOut;
			PCOut <= PCIn;
			WB_ENout <= WB_ENin;
			MEM_SignalOut <= MEM_SignalIn;
			Branch_TypeOut <= Branch_TypeIn;
			EXE_CMDout <= EXE_CMDin;
		end
	end
			
			
endmodule
