module MEM
	(
		input clk,rst,
		input WB_En_EXE,
		//input [1:0] MEM_Signal_EXE,
		input [4:0] dest_EXE,
		input [31:0] ALU_result_EXE,
		
		output WB_En_MEM,
		output [4:0] dest_MEM,
		output [31:0] ALU_result_MEM
	);
		
	MEMReg _MEMReg (clk,rst,WB_En_EXE,dest_EXE,ALU_result_EXE,WB_En_MEM,dest_MEM,ALU_result_MEM);
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMSub
	(
	
	);
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMReg
	(	
		input clk,rst,
		input WB_En_in,
		input [4:0] dest_in,
		input [31:0] ALU_result_in,
		
		output reg WB_En,
		output reg [4:0] dest,
		output reg [31:0] ALU_result
		
	);
	always@(posedge clk) begin
		if (rst) begin
			WB_En <= 1'd0;
			dest <= 5'd0;
			ALU_result <= 32'd0;
		end
		else begin
			WB_En <= WB_En_in;
			dest <= dest_in;
			ALU_result <= ALU_result_in;
		end
	end
	
endmodule	