module SRAM (
            input clk,rst,
            // From Memory Stage
            input WR_EN,RD_EN,
            input [31:0] address, writeData,
            //To Next Stage
            output [63:0] readDate,

            // For freeze other Stage
            output pause,

            inout  [15:0]	SRAM_DQ,	//	SRAM Data bus 16 Bits
            output [17:0]	SRAM_ADDR,	//	SRAM Address bus 18 Bits
            output			SRAM_UB_N,	//	SRAM High-byte Data Mask
            output			SRAM_LB_N,	//	SRAM Low-byte Data Mask
            output			SRAM_WE_N,	//	SRAM Write Enable
            output			SRAM_CE_N,	//	SRAM Chip Enable
            output			SRAM_OE_N	//	SRAM Output Enable
    );
    assign SRAM_UB_N = 1'b0;
    assign SRAM_LB_N = 1'b0;
    assign SRAM_CE_N = 1'b0;
    assign SRAM_OE_N = 1'b0;

    // 1 -> Read
    //0 -> Write

    reg SRAM_WE_N_;
    reg [2:0]counter;
    //reg [15:0] dataTemp16;
    reg [63:0] dataTemp;
    reg [15:0] SRAM_DQ_;
    reg [17:0]	SRAM_ADDR_;

    always @ (posedge clk) begin
        if (rst) begin
            counter <= 3'd0;
        end
        else begin
            if (WR_EN == 1'b1 || RD_EN == 1'b1) begin
                counter <= counter + 1'b1;
                if(counter == 3'd5) begin
                    counter <= 3'd0;
                end
            end
        end
    end

     assign pause = ((WR_EN == 1'b1 || RD_EN == 1'b1) && (counter < 3'd5)); //  = 5 -> 0
     assign SRAM_DQ = (WR_EN) ? SRAM_DQ_ : 16'bZ;
     assign SRAM_ADDR = SRAM_ADDR_;
     assign SRAM_WE_N = SRAM_WE_N_;
     assign readDate = dataTemp;

     always @ (posedge clk) begin
         SRAM_WE_N_ <= 1'b1;
         if (rst) begin
            SRAM_WE_N_ <= 1'b1;
            //dataTemp16 <= 16'd0;
            dataTemp <= 32'd0;
            SRAM_DQ_ <= 16'd0;
            SRAM_ADDR_ <= 18'd0;
         end
        else begin
             if (WR_EN) begin
                if (counter == 3'd0) begin
                    SRAM_WE_N_ <= 1'b0;
                    SRAM_ADDR_ <= {address[18:2],1'd0};
                    SRAM_DQ_ <= writeData[15:0];
                end
                else if (counter == 3'd1) begin
                    SRAM_WE_N_ <= 1'b0;
                    SRAM_ADDR_ <= {address[18:2],1'd1};
                    SRAM_DQ_ <= writeData[31:16];
                end
                else SRAM_WE_N_ <= 1'b1;
             end
             else if(RD_EN) begin // 4clk - 18:3  00 to 11
                 if (counter == 3'd0) begin
                     SRAM_ADDR_ <= {address[18:2],1'd0};
                 end
                 else if (counter == 3'd1) begin
                     SRAM_ADDR_ <= {address[18:2],1'd1};
                     dataTemp <= {16'd0,SRAM_DQ};
                 end
                 else if (counter == 3'd2) begin
                     dataTemp <= {SRAM_DQ,dataTemp[15:0]};
                 end
             end
        end
     end

endmodule // sramUnit
