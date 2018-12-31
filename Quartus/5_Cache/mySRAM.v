module (
			input clk, rst,
			inout  [15:0]	SRAM_DQ,	//	SRAM Data bus 16 Bits
            input [17:0]	SRAM_ADDR,	//	SRAM Address bus 18 Bits
            input			SRAM_UB_N,	//	SRAM High-byte Data Mask
            input			SRAM_LB_N,	//	SRAM Low-byte Data Mask
            input			SRAM_WE_N,	//	SRAM Write Enable // ***********
            input			SRAM_CE_N,	//	SRAM Chip Enable
            input			SRAM_OE_N
		);
	
	reg[15:0] mem[2048:0]