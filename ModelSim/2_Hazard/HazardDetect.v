module HazardDetect
    (
        input WB_EN_EXE,WB_EN_MEM,isSrc2,
        input [4:0]src1,src2,Dest_EXE,Dest_MEM,

        output reg freez
    );
    
    always @ ( * ) begin
        freez = 1'b0;
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
    end

endmodule // HazardDetect
