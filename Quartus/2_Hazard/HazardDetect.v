module HazardDetect
    (
        input WB_EN_EXE,WB_EN_MEM,isSrc2,
        input [4:0]src1,src2,Dest_EXE,Dest_MEM,

        output freez
    );

    always @ ( * ) begin
        if (WB_EN_EXE == 1 || WB_En_MEM == 1) begin
            if (src1 == Dest_EXE || src1 == Dest_MEM)
                freez = 1'b1;
            if(isSrc2 == 1)
                if (src2 == Dest_EXE || src2 == Dest_MEM)
                    freez = 1'b1;
        end
    end

endmodule // HazardDetect
