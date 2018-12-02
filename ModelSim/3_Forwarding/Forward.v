module ForwardDetect
    (
        input [4:0] src1, src2,
        Dest_EXE,
        Dest_MEM,
        Dest_WB,
        input WB_EN_MEM,WB_EN_WB,MEM_R_EN,

        output reg [1:0] ALU_vONE_Mux,ALU_vTWO_Mux,SRC_vTWO_Mux
    );

    always @ ( * ) begin
		ALU_vONE_Mux = 2'b0;
		ALU_vTWO_Mux = 2'b0;
		SRC_vTWO_Mux = 2'b0;
        if (WB_EN_MEM == 1'b1) begin
            if (src1 == Dest_MEM) begin
                ALU_vONE_Mux = 2'b01;
            end
            if (src2 == Dest_MEM) begin
                ALU_vTWO_Mux = 2'b01;
            end
        end
        if (WB_EN_WB == 1'b1) begin
            if (src1 == Dest_MEM) begin
                ALU_vONE_Mux = 2'b10;
            end
            if (src2 == Dest_MEM) begin
                ALU_vTWO_Mux = 2'b10;
            end
        end
        if (MEM_R_EN == 1'b1) begin

        end
    end

endmodule // ForwardDetect
