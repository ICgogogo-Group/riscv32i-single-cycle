module pmem(
    input clk,
    input valid,
    input wen,
    input [31:0] addr,
    input [31:0] wdata,
    input [3:0] wmask,
    output reg [31:0] rdata
);

parameter PMEM_BAE=32'h80000000;
parameter PMEM_SIZE=1024*1024;

reg [7:0] mem [0:PMEM_SIZE-1];

wire [31:0] offset=addr-PMEM_BASE;

always @(*) begin
    rdata=0;
    if(valid&&!wen) begin
        rdata={
            mem[offset+3],
            mem[offset+2],
            mem[offset+1],
            mem[offset+0],
        };
    end
end

always @(posedge clk) begin
    if(valid&&wen) begin
        if(wmask[0]) mem[offset+0]<=wdata[7:0];
        if(wmask[1]) mem[offset+1]<=wdata[15:8];
        if(wmask[2]) mem[offset+2]<=wdata[23:16];
        if(wmask[3]) mem[offset+3]<=wdata[31:24];
    end
end

endmodule