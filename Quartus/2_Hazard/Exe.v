module Exe
	(
		input clk,rst,
		// from ID stage to Mem stage : input
		input WB_En_IDout,
		input [1:0] MEM_Signal_ID,
		input [4:0] dest_ID,

		input [3:0] EXE_CMD,
		input [31:0] val1,val2,reg2,PC,
		input [1:0] Br_type,

		output [31:0] Br_Adder,
		output Br_tacken,
		// from ID stage to Mem stage : output
		output WB_En_EXE,
		output [1:0] MEM_Signal_EXE,
		output [4:0] dest_EXE,
		output [31:0] PC_EXE,ALU_result_EXE,reg2_EXE,
		//To other stage
		output freezCos,
		// To Copro
		input cntrlCos

	);

	wire[31:0] ALU_result;

	ExeSub _ExeSub (clk,rst,EXE_CMD,val1,val2,reg2,PC,Br_type,ALU_result,Br_Adder,Br_tacken,
			//To other stage
			freezCos,
			// To Copro
			cntrlCos
	);

	ExeReg _ExeReg(clk,rst,WB_En_IDout,MEM_Signal_ID,dest_ID,PC,ALU_result,reg2,WB_En_EXE,MEM_Signal_EXE,dest_EXE,PC_EXE,ALU_result_EXE,reg2_EXE);

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ExeSub
	(
		input clk,rst,
		input [3:0] EXE_CMD,
		input [31:0] val1,val2,reg2,PC,
		input [1:0] Br_type,

		output [31:0] ALU_result,Br_Address,
		output Br_tacken,
		//To other stage
		output freezCos,
		// To Copro
		input cntrlCos
	);
	wire [31:0]  resultCos, _ALU_result;
	wire readyCos;
	ALU _ALU(val1, val2, EXE_CMD, _ALU_result);
	AdderBranch _AdderBranch (PC, val2, Br_Address);
	ConditionCheck _ConditionCheck (val1, reg2, Br_type, Br_tacken);
	//Copro (input clk,rst,cntrlCos,input [31:0]  dataCos, output [31:0]  resultCos, output reg readyCos,freezCos);
	Copro _Copro(clk,rst,cntrlCos,val1,resultCos,freezCos);

	assign ALU_result = (readyCos) ? resultCos : _ALU_result;
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ExeReg
	(
		input clk,rst,
		// from ID stage to Mem stage
		input WB_en_in,
		input [1:0] MEM_Signal_in,
		input [4:0] Dest_in,

		input [31:0] PC_in,
		input [31:0] ALU_result_in,
		input [31:0] reg2_in,

		// MEM_Signals
		output reg WB_en,
		output reg [1:0] MEM_Signal,
		output reg [4:0] Dest,
		output reg [31:0] PC,
		output reg [31:0] ALU_result,
		output reg [31:0] reg2
	);

	always@(posedge clk) begin
		if (rst) begin
			WB_en <= 1'd0;
			MEM_Signal <= 2'd0;
			Dest <= 5'd0;
			PC <= 32'd0;
			ALU_result <= 32'd0;
			reg2 <= 32'd0;

		end
		else begin
			WB_en <= WB_en_in;
			MEM_Signal <= MEM_Signal_in;
			Dest <= Dest_in;
			PC <= PC_in;
			ALU_result <= ALU_result_in;
			reg2 <= reg2_in;
		end
	end

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module Copro (input clk,rst,cntrlCos,input [31:0]  dataCos, output reg [31:0]  resultCos, output reg  readyCos,freezCos);
reg  [5:0] counter;
wire [31:0]  _resultCos;
//assign resultCos = (readyCos) ? _resultCos : 32'b0;
always @ (posedge clk) begin
	freezCos <= 1'b0;
	readyCos <= 1'b0;
	if (rst) begin
		counter <= 6'd0;
		freezCos <= 1'b0;
		readyCos <= 1'b0;
	end
	else begin
		if (cntrlCos) begin
			counter <= counter  + 1'b1;
			freezCos <= 1'b1;
			if (counter == 6'd34) begin
				counter <= 6'd0;
				readyCos <= 1'b1;
				resultCos <= _resultCos;
			end
		end
	end
end
Cos_Test _cosTest(
			clk,
			dataCos,
			_resultCos
		);

endmodule // Copro
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ALU(input[31:0] val1, val2, input[3:0] selector, output reg[31:0] ALU_res);
	always @(*) begin
		case (selector)
			4'b0000: ALU_res <= val1 + val2; // ADD , ADDI , LD , ST
			4'b0010: ALU_res <= val1 - val2; // SUB , SUBI
			4'b0100: ALU_res <= val1 & val2; // AND
			4'b0101: ALU_res <= val1 | val2; // OR
			4'b0110: ALU_res <= ~(val1 | val2); // NOR
			4'b0111: ALU_res <= val1 ^ val2; // XOR
			4'b1000: ALU_res <= val1 << val2; // SLA , SLL
			4'b1001: ALU_res <= $signed(val1) >>> val2; // SRA
			4'b1010: ALU_res <= val1 >> val2; // SRL

			default: ALU_res = 32'bx;
		endcase
	end
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module AdderBranch (input[31:0] PC, val2, output[31:0] result);
	assign result = PC + {val2[31:2],2'b0};
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module ConditionCheck (input[31:0] val1, val2, input[1:0] br_type, output reg isBr);
	always @(*)begin
		isBr = 0;
		if(br_type == 2'b01) begin
			if(val1 == 0)
				isBr = 1;
		end
		// Branch Not Equal
		else if(br_type == 2'b10) begin
			if (val1 != val2)
				isBr = 1;
		end
		// Jump
		else if(br_type == 2'b11) begin
			isBr = 1;
		end
		else begin
			isBr = 0;
		end
	end
endmodule
