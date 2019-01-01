module IF (input clk,rst,freez, BrTaken,input [31:0] BrAdder, output [31:0] PC,instruction,input freezCos);

	wire [31:0] PCIn,instructionIn;

	IFSub _IFsub (clk,rst,freez,BrTaken,BrAdder,PCIn,instructionIn,
			//Copro : To other stage
			freezCos
		);
	IFReg _IFReg (clk,rst,freez, BrTaken, PCIn,instructionIn,PC,instruction,
			//Copro : To other stage
			freezCos
		);

endmodule

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module IFSub (input clk,rst,freez,BrTaken,input [31:0] BrAdder, output [31:0] PC4,output [31:0] Instruction,input freezCos);
	reg [31:0] ram [1023:0]; //2 ^ 10 = 1024
	wire [31:0] PCMuxOut;
	reg [31:0] PC; //
	integer i;
	initial begin
		ram[0] = 32'b10000000000000010011111101001001; //-- Addi r1 ,r0 ,0x‭3F49‬ //2
		ram[4] = 32'b10000000000000100000111111011011; //-- Addi r2 ,r0 ,‭0x0FDB‬
		ram[8] = 32'b10000000000000110000000000010000; //-- Addi r2 ,r0 ,‭16
		ram[12] = 32'b00101000001000110000100000000000;//-- sll r1 ,r1 ,r3
		ram[16] = 32'b00011000001000100000100000000000;//-- or r1,r1,r2 // r1=0.785398185253143310546875 , pi/4
		ram[20] = 32'b11111100001001000000000000000000; //-- cos r4,r1   // r4=0x3f3504f3, 0.707106769084930419921875
		ram[24] = 32'b10101000000000001111111111111111;//-- JMP -1*/
	end

	assign PC4 = PC + 4;	// PC + 4

	Mux2to1_32 _PCBrMux(BrTaken,PC4,BrAdder,PCMuxOut);

	always@(posedge clk,posedge rst) begin //Read from ram
		if (rst) begin
			PC = 32'd0;
		end
		else begin
			if (freez == 1'b1 || freezCos == 1'b1) begin
				PC = PC;
			end
			else begin
				PC = PCMuxOut;
			end
		end
	end
	assign Instruction = ram[{PC[31:2],2'b0}];

endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

module IFReg(input clk,rst,freez, BrTaken, input[31:0] PCin,instructionIn,output reg [31:0] PC,instruction,input freezCos);
	always@(posedge clk,posedge rst) begin
		if (rst) begin
			PC <= 32'd0;
			instruction <= 32'd0;
		end
		else if(BrTaken)
			instruction <= 32'b0;
		else begin
			if (freez == 1'b1 || freezCos == 1'b1) begin
				PC <= PC;
				instruction <= instruction;
			end
			else begin
				PC <= PCin;
				instruction <= instructionIn;
			end
		end
	end
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
