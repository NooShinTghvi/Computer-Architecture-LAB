module IF (input clk,rst,flush,BrTaken, output [31:0] PC,instruction);

	wire [31:0] BrAdder,PCIn,instructionIn; 
		
	IFSub _IFsub (clk,rst,BrTaken,BrAdder,PCIn,instructionIn);
	IFReg _IFReg (clk,rst,flush,PCIn,instructionIn,PC,instruction);

endmodule

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module IFSub (input clk,rst,BrTaken, output reg [31:0] BrAdder,PC,Instruction);
	reg [31:0] ram [0:1023]; //2 ^ 10 = 1024
	initial begin
		ram[32'd0] = 32'b00000000001000100000000000001000;
		ram[32'd1] = 32'b00000000011001000000000000000100;
		ram[32'd2] = 32'b00000000101001100000000000001000;
		ram[32'd3] = 32'b00000000111010000001000000000100;
		ram[32'd4] = 32'b00000001001010100001100000001000;
		ram[32'd5] = 32'b00000001011011000000000000000100;
		ram[32'd6] = 32'b00000001101011100000000000001000; 	
	
	end
	always@(posedge clk,posedge rst) begin
		if (rst) begin
			PC = 32'd0;
			Instruction = ram[PC];
		end
		else begin
			PC = PC + 4;
			Instruction = ram[{2'd0,PC[31:2]}];
		end
			
	end
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

module IFReg(input clk,rst,flush, input[31:0] PCin,instructionIn,output reg [31:0] PC,instruction);
	always@(posedge clk,rst) begin
		if (rst) begin
			PC <= 32'd0;
			instruction <= 32'd0;
		end
		else begin
			PC <= PCin;
			instruction <= instructionIn;
		end
	end

endmodule


	