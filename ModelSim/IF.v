module IF (input clk,rst,flush,BrTaken, output [31:0] PC,instruction);

	wire [31:0] BrAdder,PCIn,instructionIn; 
		
	IFSub _IFsub (clk,rst,BrTaken,BrAdder,PCIn,instructionIn);
	IFReg _IFReg (clk,rst,flush,PCIn,instructionIn,PC,instruction);

endmodule

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module IFSub (input clk,rst,BrTaken, output reg [31:0] BrAdder,PC,Instruction);
	reg [31:0] ram [0:1023]; //2 ^ 10 = 1024
	
	integer i;
	initial begin	
	    for(i = 0; i < 1024; i = i+1) begin
	        ram[i] = i;
		end
		// 100100 //000001
	ram[1] = 32'b10000000000000010000011000001010;//-- Addi r1 ,r0 ,1546
	ram[2] = 32'b10010000000000010001000000000000;//-- Add  r2 ,r0 ,r1 
	ram[3] = 32'b00001100000000010001100000000000;//-- sub r3 ,r0 ,r1 
	ram[4] = 32'b00010100010000110010000000000000;//-- And r4 ,r2 ,r3
	ram[5] = 32'b10000100011001010001101000110100;//-- Subi r5 ,r3 ,6708 
	ram[6] = 32'b00011000011001000010100000000000;//-- or r5 ,r3 ,r4
	ram[7] = 32'b00011100101000000011000000000000;//-- nor  r6 ,r5 ,r0 	
	ram[8] = 32'b00011100100000000101100000000000;//-- nor  r11 ,r4 ,r0 
	ram[9] = 32'b00001100101001010010100000000000;//-- sub r5 ,r5 ,r5 
	ram[10] = 32'b10000000000000010000010000000000;//-- Addi  r1 ,r0 ,1024  
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


	