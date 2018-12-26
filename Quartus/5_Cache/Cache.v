module Cache (
        input clk,rst,
        // From Memory Stage
        input WR_EN,RD_EN,
        input [31:0] address,
        //To Next Stage
        output [31:0] readData,
        // For freeze other Stage
        output pause,
		input readyFlagData64B,
        // From SRAM
        input pause_SRAM,
        input [63:0] outData_SRAM,
        //To SRAM
        output WR_EN_SRAM, RD_EN_SRAM

    );
    reg [63:0] valid_W0,valid_W1 ;
    reg [63:0] LRU;
	reg	[9:0] tag_W0 [63:0];
    reg	[9:0] tag_W1 [63:0];
    reg	[63:0] twoWords_W0 [63:0];
    reg	[63:0] twoWords_W1 [63:0];
	wire [63:0] readData64B;

    reg WR_EN_SRAM__;
    assign WR_EN_SRAM = WR_EN_SRAM__;
    reg RD_EN_SRAM__;
    assign RD_EN_SRAM = RD_EN_SRAM__;
    //* * * * * * * * * * *  * * * * * * *
    wire [5:0] index;
    assign index = address[8:3];
    wire [8:0] tag;
    assign tag = address[17:9];
    wire hit0;
    assign hit0 = ((tag_W0[index] == tag) && valid_W0[index]);
    wire hit1;
    assign hit1 = ((tag_W1[index] == tag) && valid_W1[index]);
    wire hit;
    assign hit =   hit0 || hit1 || !(WR_EN || RD_EN);
    wire select ;
    assign select = address[2];
	//* * * * * * * * * * *  * * * * * * *
	assign pause = pause_SRAM && (!hit);
	//* * * * * * * * * * *  * * * * * * *
    assign readData64B = (!rst & RD_EN & hit) ?  
							( (hit1)?  
								twoWords_W1[index]:
								twoWords_W0[index]
							) :
							64'bx ;
							
	assign readData = (!rst & RD_EN & hit) ? 
							( (select)?
								readData64B[63:32] :
								readData64B[31:0]
							) :
							32'bx;
							
    //* * * * * * * * * * *  * * * * * * *
    always @ (posedge clk) begin
        WR_EN_SRAM__ = 1'd1;
        RD_EN_SRAM__ = 1'd1;
        if (rst) begin
			WR_EN_SRAM__ = 1'd1;
            RD_EN_SRAM__ = 1'd1;
        end
        else begin
			if (pause_SRAM) begin
				RD_EN_SRAM__ = 0;
				RD_EN_SRAM__ = 0;
			end
            if (RD_EN) begin
                if(!hit) begin
                    RD_EN_SRAM__ = 1'd0;
                end
            end
            else if(WR_EN)begin
                WR_EN_SRAM__ = 1'd0;
            end
        end
    end
	//
	integer i;
	always @ (posedge clk) begin
        if (rst) begin
            valid_W0 = 64'd0;
            valid_W1 = 64'd0;
            LRU = 64'd0;
			for(i = 0; i < 64; i = i+1) begin
				tag_W0[i] = 10'd0;
				tag_W1[i] = 10'd0;
				twoWords_W0[i] = 64'd0;
				twoWords_W1[i] = 64'd0;
			end

        end
        else begin
			if (RD_EN & hit) begin
				LRU = ~LRU;
			end
            if (readyFlagData64B) begin
    			if (LRU[index] == 1'd0) begin
    				tag_W0[index] = address[17:9];
    				valid_W0[index] = 1'd1;
    				twoWords_W0[index] = outData_SRAM;
    				LRU[index] = 1'd1;
    			end
    			else begin
    				tag_W1[index] = address[17:9];
    				valid_W1[index] = 1'd1;
    				twoWords_W1[index] = outData_SRAM;
    				LRU[index] = 1'd0;
    			end
            end
			if(WR_EN) begin
				valid_W0[index] = 1'd0;
				valid_W1[index] = 1'd0;
            end
        end
    end
endmodule // Cache
