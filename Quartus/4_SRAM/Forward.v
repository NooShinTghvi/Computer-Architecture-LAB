module ForwardDetect
    (
    	input en,
        input [4:0] src1, src2,
        Dest_EXE,
        Dest_MEM,
        Dest_WB,
        input WB_EN_MEM, WB_EN_WB,

        output reg [1:0] ALU_vONE_Mux, ALU_vTWO_Mux, SRC_vTWO_Mux
    );

    always @ ( * ) begin
		if(en) begin
			ALU_vONE_Mux = 2'b0;
			ALU_vTWO_Mux = 2'b0;
			SRC_vTWO_Mux = 2'b0;

			if(WB_EN_MEM && (src1 == Dest_MEM)) ALU_vONE_Mux <= 2'b01;
			else if(WB_EN_WB && (src1 == Dest_WB)) ALU_vONE_Mux <= 2'b10;


			if(WB_EN_MEM && (src2 == Dest_MEM)) ALU_vTWO_Mux <= 2'b01;
			else if(WB_EN_WB && (src2 == Dest_WB)) ALU_vTWO_Mux <= 2'b10;


			if(WB_EN_MEM && (Dest_EXE == Dest_MEM)) SRC_vTWO_Mux <= 2'b01;
			else if(WB_EN_WB && (Dest_EXE == Dest_WB)) SRC_vTWO_Mux <= 2'b10;
			
	   //      if (WB_EN_MEM) begin
	   //          if (src1 == Dest_MEM) begin
	   //              ALU_vONE_Mux <= 2'b01;
	   //          end
	   //          if (src2 == Dest_MEM) begin
	   //              ALU_vTWO_Mux <= 2'b01;
	   //          end
	   //          if(Dest_EXE == Dest_MEM) begin
	   //          	SRC_vTWO_Mux <= 2'b01;
	   //          end
	   //      end
	   //      else if (WB_EN_WB) begin
	   //          if (src1 == Dest_WB) begin
	   //              ALU_vONE_Mux <= 2'b10;
	   //          end
	   //          if (src2 == Dest_WB) begin
	   //              ALU_vTWO_Mux <= 2'b10;
	   //          end
				// if(Dest_EXE == Dest_WB) begin
	   //          	SRC_vTWO_Mux <= 2'b10;
	   //          end
	   //      end
	    end
    end

endmodule // ForwardDetect
