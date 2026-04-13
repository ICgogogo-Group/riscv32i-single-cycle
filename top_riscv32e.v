`timescale 1ns / 1ps

module top_riscv32e(
    input cpu_rst,
    input cpu_clk,
    output [31:0] irom_addr,
    input [31:0] irom_data,
    output [31:0] perip_addr,
    output perip_wen,
    output [1:0] perip_mask,
    output [31:0] perip_wdata,
    input [31:0] perip_rdata
);

localparam MEM_SH = 3'b110;
localparam MEM_SW = 3'b111;

reg [31:0] pc_reg;

wire [31:0] next_pc;

assign irom_addr = pc_reg;

wire [4:0] rs1, rs2, rd;
wire [31:0] imm;
wire alu_src;
wire is_jal;
wire is_jalr;
wire is_branch;
wire is_auipc;
wire is_ebreak;

wire [31:0] result;
wire [31:0] rs1_val, rs2_val;
wire [31:0] wdata;
wire [31:0] mem_data;

wire [4:0] alu_op;
wire mem_write;
wire mem_read;
wire reg_write;
wire [2:0] mem_type;
wire [1:0] wb_sel;
wire [2:0] br_type;

wire [31:0] lsu_addr;
wire [31:0] lsu_wdata;
wire [1:0]  lsu_mask;
wire        lsu_valid;
wire        lsu_wen;

always @(posedge cpu_clk) begin
    if (cpu_rst) begin
        pc_reg <= 32'h8000_0000;
    end else begin
        // Treat SYSTEM instructions as no-ops in the contest template.
        pc_reg <= next_pc;
    end
end

RegisterFile rf(
    .clk(cpu_clk),
    .raddr1(rs1),
    .raddr2(rs2),
    .rdata1(rs1_val),
    .rdata2(rs2_val),
    .waddr(rd),
    .wdata(wdata),
    .wen(reg_write)
);

IDU idu(
    .inst(irom_data),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .imm(imm),
    .alu_src(alu_src),
    .reg_write(reg_write),
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .is_branch(is_branch),
    .is_auipc(is_auipc),
    .is_ebreak(is_ebreak),
    .alu_op(alu_op),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .wb_sel(wb_sel),
    .mem_type(mem_type),
    .br_type(br_type)
);

EXU exu(
    .rs1_val(rs1_val),
    .rs2_val(rs2_val),
    .imm(imm),
    .alu_src(alu_src),
    .alu_op(alu_op),
    .br_type(br_type),
    .pc(pc_reg),
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .is_branch(is_branch),
    .is_auipc(is_auipc),
    .result(result),
    .next_pc(next_pc)
);

LSU lsu(
    .clk(cpu_clk),
    .valid(mem_write | mem_read),
    .wen(mem_write),
    .waddr(result),
    .wdata(rs2_val),
    .raddr(result),
    .mem_type(mem_type),
    .mem_addr(lsu_addr),
    .mem_wdata(lsu_wdata),
    .mem_mask(lsu_mask),
    .mem_valid(lsu_valid),
    .mem_wen(lsu_wen),
    .is_write(),
    .mem_rdata(perip_rdata),
    .rdata(mem_data)
);

WBU wbu(
    .clk(cpu_clk),
    .alu_result(result),
    .mem_data(mem_data),
    .wb_sel(wb_sel),
    .pc(pc_reg),
    .wdata(wdata)
);

assign perip_addr = lsu_valid ? lsu_addr : 32'h0000_0000;
assign perip_wen = lsu_valid && lsu_wen;
assign perip_wdata = lsu_wdata;

// Always read full 32-bit words from the template bridge and let LSU do
// the narrow-load extraction exactly once.
assign perip_mask = mem_read ? 2'b10 :
                    (mem_type == MEM_SW ? 2'b10 :
                    (mem_type == MEM_SH ? 2'b01 : 2'b00));

endmodule
