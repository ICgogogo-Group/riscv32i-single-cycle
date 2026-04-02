module top_riscv32e(
    input clk,
    input rst,
    output [31:0] pc
);

reg [31:0] pc_reg;

wire [31:0] next_pc;

assign pc=pc_reg;

wire [4:0] rs1,rs2,rd;
wire [31:0] imm;
wire alu_src;
wire is_jal;
wire is_jalr;
wire is_branch;
wire is_auipc;
wire is_ebreak;

wire [31:0] result;
wire [31:0] rs1_val,rs2_val;
wire [31:0] wdata;

wire [31:0] inst;

wire [3:0] alu_op;
wire mem_write;
wire mem_read;
wire reg_write;
wire [2:0] mem_type;
wire [1:0] wb_sel;
wire [2:0] br_type;

always @(posedge clk) begin
    if (rst) begin
        pc_reg <= 32'h80000000;
    end 
    else if(is_ebreak)
        $finish;
    else begin   
        pc_reg <= next_pc;    
    end
end

RegisterFile rf(
    .clk(clk),
    .raddr1(rs1),
    .raddr2(rs2),
    .rdata1(rs1_val),
    .rdata2(rs2_val),
    .waddr(rd),
    .wdata(wdata),
    .wen(reg_write)
);

IDU idu(
    .inst(inst),
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
    .pc(pc_reg),
    .alu_op(alu_op),
    .br_type(br_type),
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .is_branch(is_branch),
    .is_auipc(is_auipc),
    .alu_src(alu_src),
    .result(result),
    .next_pc(next_pc)
);

wire [31:0] ifu_addr;
wire ifu_valid;
wire [31:0] ifu_rdata;

IFU ifu(
    .clk(clk),
    .pc(pc_reg),
    .mem_addr(ifu_addr),
    .mem_valid(ifu_valid),
    .mem_rdata(mem_rdata),
    .inst(inst)
);

WBU wbu(
    .clk(clk),
    .alu_result(result),
    .mem_data(mem_data),
    .wb_sel(wb_sel),
    .pc(pc_reg),
    .wdata(wdata)
);

wire [31:0] mem_data;
wire [3:0] lsu_wmask;
wire [31:0] lsu_addr,lsu_wdata,lsu_rdata;
wire lsu_valid,lsu_wen;

LSU lsu(
    .clk(clk),
    .valid(mem_write|mem_read),
    .wen(mem_write),
    .waddr(result),
    .wdata(rs2_val),
    .raddr(result),
    .mem_type(mem_type),

    .mem_addr(lsu_addr),
    .mem_wdata(lsu_wdata),
    .mem_valid(lsu_valid),
    .mem_wen(lsu_wen),
    .mem_rdata(mem_rdata),

    .rdata(mem_data)
);

wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wmask;
wire mem_wen;
wire mem_valid;
wire [31:0] mem_rdata;

assign mem_valid=ifu_valid|lsu_valid;
assign mem_wen=lsu_wen;
assign mem_addr=mem_wen?lsu_addr:ifu_addr;
assign mem_wdata=lsu_wdata;
assign mem_wmask=lsu_wmask;

pmem pmem(
    .clk(clk),
    .valid(mem_valid),
    .wen(mem_wen),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .wmask(mem_wmask),
    .rdata(mem_rdata)
);

endmodule