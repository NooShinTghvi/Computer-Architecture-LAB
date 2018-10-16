module RegisterFile(input clk,RegWrt, input [4:0] RdReg1,RdReg2,WrtReg,input [31:0] WrtData, output [31:0] RdData1,RdData2);
	reg	[31:0] reg_file[0:31];
	integer i;
	initial begin	
	    for(i = 0; i < 32; i = i+1) begin
	        reg_file[i] = i;
		end
	end
	
    always @(negedge clk) begin
		if (RegWrt) begin
			reg_file[WrtReg] <= WrtData; 
		end
	end
	
	assign RdData1 = reg_file[RdReg1];
	assign RdData2 = reg_file[RdReg2];
	
endmodule  
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module signExtend(input[15:0] in, output[31:0] out);
	wire [15:0] sign;
	
	integer i;
	initial begin	
	    for(i = 0; i < 16; i = i+1) begin
	        assign sign[i] = in[15];
		end
	end
	
	assign out = {sign,in}
	
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module Mux2to1_32(input s, input [31:0] in0,in1, output [31:0] w);
	assign w = (s == 0) ? in0 : in1;
endmodule
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module Mux2to1_5(input s, input [4:0] in0,in1, output [4:0] w);
	assign w = (s == 0) ? in0 : in1;
endmodule





