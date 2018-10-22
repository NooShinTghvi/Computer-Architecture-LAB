`timescale 1ns / 1ns

module A;
	reg clk,rst;
	systemImplementation U(clk,rst);
	
	initial begin
		clk = 1'b1;
		rst = 1'b1;
	end
	always #20 clk = ~clk;
	initial begin
		#20
		rst = 1'b0;
		#600
		$stop();
	end
endmodule
