module sramUnit (
            input clk,rst,
            // From Memory Stage
            input WR_EN,RD_EN,
            input [31:0] address, writeData,
            //To Next Stage
            output [31:0] readDate,

            // For freeze other Stage
            output ready,

            inout  [15:0]	SRAM_DQ;	//	SRAM Data bus 16 Bits
            output [17:0]	SRAM_ADDR;	//	SRAM Address bus 18 Bits
            output			SRAM_UB_N;	//	SRAM High-byte Data Mask
            output			SRAM_LB_N;	//	SRAM Low-byte Data Mask
            output			SRAM_WE_N;	//	SRAM Write Enable
            output			SRAM_CE_N;	//	SRAM Chip Enable
            output			SRAM_OE_N;	//	SRAM Output Enable
    );
    assign SRAM_UB_N = 1'b0;
    assign SRAM_LB_N = 1'b0;
    assign SRAM_CE_N = 1'b0;
    assign SRAM_OE_N = 1'b0;


endmodule // sramUnit
