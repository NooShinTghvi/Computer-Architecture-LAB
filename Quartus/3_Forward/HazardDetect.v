module HazardDetect
    (
        input WB_EN_EXE,WB_EN_MEM,isSrc2,
        input [4:0]src1,src2,Dest_EXE,Dest_MEM,
        input en,
        input mem_r_en,
        output reg freez
    );
    
    always @(*) begin
        freez = 1'b0;
        if(en) begin
            if (WB_EN_EXE == 1'b1 || WB_EN_MEM == 1'b1) begin
                if (src1 == Dest_EXE || src1 == Dest_MEM) begin
                    freez = 1'b1;
                end
                if(isSrc2 == 1) begin
                    if (src2 == Dest_EXE || src2 == Dest_MEM) begin
                        freez = 1'b1;
                    end
                end
            end
            else
                freez = 0;
        end
        else begin
            if(mem_r_en) begin
                if (Dest_EXE == src1 || src2 == Dest_EXE)
                    freez = 1;
            end // if(mem_r_en)
        end // else
    end

endmodule // HazardDetect
