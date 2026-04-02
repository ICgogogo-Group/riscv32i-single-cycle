module EXU(
    input [31:0] rs1_val,
    input [31:0] rs2_val,
    input [31:0] imm,
    input alu_src,
    input [3:0] alu_op,
    input [2:0] br_type,

    input [31:0] pc,
    input is_jal,
    input is_jalr,
    input is_auipc,
    input is_branch,

    output [31:0] result,
    output [31:0] next_pc
);

localparam BR_BEQ=3'b000;
localparam BR_BNE=3'b001;
localparam BR_BLT=3'b010;
localparam BR_BGE=3'b011;
localparam BR_BLTU=3'b100;
localparam BR_BGEU=3'b101;

reg br_taken;

wire [31:0] src1;
wire [31:0] src2; //操作数2
wire zero, lt, ltu;
assign src1=is_auipc==1?pc:rs1_val;
assign src2=alu_src==1?imm:rs2_val;

ALU alu(
    .a(src1),
    .b(src2),
    .alu_op(alu_op),
    .result(result),
    .zero(zero),
    .lt(lt),
    .ltu(ltu)
);

always @(*) begin
    br_taken=0;
    if(is_branch) begin
        case (br_type)
            BR_BEQ:br_taken=zero;
            BR_BNE:br_taken=!zero;
            BR_BLT:br_taken=lt;
            BR_BGE:br_taken=!lt;
            BR_BLTU:br_taken=ltu;
            BR_BGEU:br_taken=!ltu;
            default:br_taken=0;
        endcase
    end
end

assign next_pc=
    is_jal?pc+imm:
    is_jalr?((rs1_val+imm)&~1):
    (is_branch&&br_taken)?pc+imm:
    pc+4;

endmodule