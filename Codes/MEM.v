module MEM
	(
		input clk,rst,
		input WB_En_EXE,
		input [1:0] MEM_Signal_EXE,
		input [4:0] dest_EXE,
		input [31:0] ALU_result_EXE,reg2_EXE,
		
		output WB_En_MEM,MEM_R_EN,
		output [4:0] dest_MEM,
		output [31:0] ALU_result_MEM,dataMemOut 
	);
	wire [31:0] dataMemOut_in;
	MEMSub _MEMSub(
		clk,rst,
		MEM_Signal_EXE,
		ALU_result_EXE,reg2_EXE,//address
		
		dataMemOut_in
	);
	MEMReg _MEMReg (clk,rst,WB_En_EXE,MEM_Signal_EXE[1],dest_EXE,ALU_result_EXE,dataMemOut_in,WB_En_MEM,MEM_R_EN,dest_MEM,ALU_result_MEM,dataMemOut);
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMSub
	(
		input clk,rst,
		input [1:0] MEM_Signal_EXE,
		input [31:0] ALU_result_EXE,reg2_EXE,//address
		
		output [31:0] dataMemOut
	);
	
	wire [31:0] addrMapping,
	wire [9:0] addrMem;
	assign addrMapping = ALU_result_EXE - 1024;
	assign addrMem = {addrMapping[11:2]};
	
	reg	[31:0] dataMem[1023:0]; //2 ^ 10 = 1024
	integer i;
	initial begin	
	    for(i = 0; i < 63; i = i+1) begin
	        dataMem[i] = i;
		end
	end
	
    always @(negedge clk) begin
		if (MEM_Signal_EXE[0]) begin
			dataMem[addrMem] <= reg2_EXE; 
		end
	end
	
	assign dataMemOut = dataMem[addrMem];
	
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module MEMReg
	(	
		input clk,rst,
		input WB_En_in,MEM_R_ENin,
		input [4:0] dest_in,
		input [31:0] ALU_result_in,dataMemOut_in
		
		output reg WB_En,MEM_R_EN,
		output reg [4:0] dest,
		output reg [31:0] ALU_result,dataMemOut
		
	);
	always@(posedge clk) begin
		if (rst) begin
			WB_En <= 1'd0;
			MEM_R_EN <= 1'b0;
			dest <= 5'd0;
			ALU_result <= 32'd0;
			dataMemOut <= 32'd0;
		end
		else begin
			WB_En <= WB_En_in;
			MEM_R_EN <= MEM_R_ENin;
			dest <= dest_in;
			ALU_result <= ALU_result_in;
			dataMemOut <= dataMemOut_in;
		end
	end
	
endmodule	