`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 10:51:04
// Design Name: 
// Module Name: myCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module myCPU (
    input  logic         cpu_rst,
    input  logic         cpu_clk,
    output logic [31:0]  irom_addr,
    input  logic [31:0]  irom_data,
    output logic [31:0]  perip_addr,
    output logic         perip_wen,
    output logic [ 1:0]  perip_mask,
    output logic [31:0]  perip_wdata,
    input  logic [31:0]  perip_rdata
);
top_riscv32e u_top (
    .cpu_rst     (cpu_rst),
    .cpu_clk     (cpu_clk),
    .irom_addr   (irom_addr),
    .irom_data   (irom_data),
    .perip_addr  (perip_addr),
    .perip_wen   (perip_wen),
    .perip_mask  (perip_mask),
    .perip_wdata (perip_wdata),
    .perip_rdata (perip_rdata)
);

endmodule
    

