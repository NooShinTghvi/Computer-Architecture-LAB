module Cache (
        input clk,rst,
        // From Memory Stage
        input WR_EN,RD_EN,
        input [31:0] address, writeData,
        //To Next Stage
        output [31:0] readData,
        // For freeze other Stage
        output pause,
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
    //
    reg [31:0] readData__;
    assign  readData = readData__;
    reg WR_EN_SRAM__;
    assign WR_EN_SRAM = WR_EN_SRAM__;
    reg RD_EN_SRAM__;
    assign RD_EN_SRAM = RD_EN_SRAM__;
    //
    assign pause = pause_SRAM && (!hit);
    wire [5:0] index;
    assign index = address[8:3];
    wire [8:0] tag;
    assign tag = address[17:9];
    wire hit0;
    assign hit0 = ((tag_W0[index] == tag) && valid_W0[index]);
    wire hit1;
    assign hit1 = ((tag_W1[index] == tag) && valid_W1[index]);
    wire hit;
    assign hit =  hit0 || hit1;
    wire select ;
    assign select = address[2];
    always @ (posedge clk) begin
        //WR_EN_SRAM__ = 1'd0;
        //RD_EN_SRAM__ = 1'd0;
        if (rst) begin
            valid_W0 = 64'd0;
            valid_W1 = 64'd0;
        end
        else begin
            if (RD_EN && hit1) begin
                if (select) begin
                    readData__ <= twoWords_W1[63:32];
                end
                else begin
                    readData__ <= twoWords_W1[31:0];
                end
            end
            else if (RD_EN && hit0) begin
                if (select) begin
                    readData__ <= twoWords_W0[63:32];
                end
                else begin
                    readData__ <= twoWords_W0[31:0];
                end
            end
            else if (RD_EN && !hit) begin
                RD_EN_SRAM__ = 1'd1;
            end
            else if (!RD_EN && !hit)begin
                WR_EN_SRAM__ = 1'd0;
                RD_EN_SRAM__ = 1'd0;
            end
        end
    end

    always @ ( * ) begin

    end
endmodule // Cache
