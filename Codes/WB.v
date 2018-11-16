module WB(
			input WB_EN,MEM_R_EN,
			input [4:0] destIn,
			input [31:0] dataMemOut,ALU_result,
			
			output WB_EN_out,
			output [4:0] destOut,
			output [31:0] result_WB	
		);
		
	assign result_WB = MEM_R_EN ? dataMemOut : ALU_result;
	assign destOut = destIn;
	assign WB_EN_out = WB_EN;
	
endmodule