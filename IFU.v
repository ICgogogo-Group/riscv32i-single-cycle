module IFU(
    input clk,
    input [31:0] pc,

    output [31:0] mem_addr,
    output mem_valid,
    input [31:0] mem_rdata,

    output [31:0] inst
);

assign mem_addr=pc;
assign mem_valid=1'b1;
assign inst=mem_rdata;

endmodule
