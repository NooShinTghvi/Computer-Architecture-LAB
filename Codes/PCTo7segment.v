module PCTO7segment(input PC[3:0],output reg[6:0] sevenSegment);
	
	
	always@(PC)begin
		case(PC)
			4'd0 : sevenSegment = 7'b1000000;
			4'd1 : sevenSegment = 7'b1111001;
			4'd2 : sevenSegment = 7'b0100100;
			4'd3 : sevenSegment = 7'b0110000;
			4'd4 : sevenSegment = 7'b0011001;
			4'd5 : sevenSegment = 7'b0010010;//
			4'd6 : sevenSegment = 7'b0100000;
			4'd7 : sevenSegment = 7'b0001111;
			4'd8 : sevenSegment = 7'b0000000;
			4'd9 : sevenSegment = 7'b0000100;
			4'd10 : sevenSegment = 7'b0001000;
			4'd11 : sevenSegment = 7'b1100000;
			4'd12 : sevenSegment = 7'b0110001;
			4'd13 : sevenSegment = 7'b1000010;
			4'd14 : sevenSegment = 7'b0110000;
			4'd15 : sevenSegment = 7'b0111000;
			default : sevenSegment = 7'd1;
		endcase
	end
endmodule
