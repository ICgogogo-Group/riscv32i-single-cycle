module IDU(
    input [31:0] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output reg [31:0] imm,
    output reg alu_src, //选择是寄存器还是立即数
    output reg [4:0] alu_op,
    output reg mem_write,
    output reg mem_read,
    output reg [2:0] mem_type,  //byte/word
    output reg reg_write,
    output reg is_jal,
    output reg is_jalr,
    output reg is_auipc,
    output reg is_branch,
    output reg is_ebreak,
    output reg [1:0] wb_sel,  //写回来源,0:alu,1:内存,2:pc+4
    output reg [2:0] br_type
);
wire [6:0] opcode=inst[6:0];
wire [2:0] funct3=inst[14:12];
wire [6:0] funct7=inst[31:25];

assign rs1=inst[19:15];
assign rs2=inst[24:20];
assign rd=inst[11:7];

localparam ALU_ADD=5'b00000;
localparam ALU_SUB=5'b00001;
localparam ALU_PASS=5'b00010;
localparam ALU_SLT=5'b00011;
localparam ALU_SLTU=5'b00100;
localparam ALU_XOR=5'b00101;
localparam ALU_OR=5'b00110;
localparam ALU_AND=5'b00111;
localparam ALU_SLL=5'b01000;
localparam ALU_SRL=5'b01001;
localparam ALU_SRA=5'b01010;
//localparam ALU_MUL=5'b01011;
//localparam ALU_MULH=5'b01100;
//localparam ALU_MULHSU=5'b01101;
//localparam ALU_MULHU=5'b01110;
//localparam ALU_DIV=5'b01111;
//localparam ALU_DIVU=5'b10000;
//localparam ALU_REM=5'b10001;
//localparam ALU_REMU=5'b10010;

localparam IMM_I=3'b000;
localparam IMM_S=3'b001;
localparam IMM_U=3'b010;
localparam IMM_B=3'b011;
localparam IMM_J=3'b100;
reg [2:0] imm_type;

localparam WB_ALU=2'b00;
localparam WB_MEM=2'b01;
localparam WB_PC4=2'b10;

localparam MEM_LB=3'b000;
localparam MEM_LH=3'b001;
localparam MEM_LW=3'b010;
localparam MEM_LBU=3'b011;
localparam MEM_LHU=3'b100;

localparam MEM_SB=3'b101;
localparam MEM_SH=3'b110;
localparam MEM_SW=3'b111;

localparam BR_BEQ=3'b000;
localparam BR_BNE=3'b001;
localparam BR_BLT=3'b010;
localparam BR_BGE=3'b011;
localparam BR_BLTU=3'b100;
localparam BR_BGEU=3'b101;

wire [31:0] imm_I = {{20{inst[31]}}, inst[31:20]};
wire [31:0] imm_S = {{20{inst[31]}}, inst[31:25], inst[11:7]};
wire [31:0] imm_U = {inst[31:12], 12'b0};
wire [31:0] imm_B = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
wire [31:0] imm_J = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

wire is_alu_imm=(opcode==7'b0010011);
wire is_alu_reg=(opcode==7'b0110011);
wire is_alu=is_alu_imm|is_alu_reg;

wire is_sub=(funct7==7'b0100000);

always @(*) begin
    imm_type = IMM_I;
    case (opcode)
        7'b0010011,
        7'b0000011,
        7'b1100111:begin
            imm_type=IMM_I;
        end
        7'b0100011:begin
            imm_type=IMM_S;
        end
        7'b0010111,
        7'b0110111:begin
            imm_type=IMM_U;
        end
        7'b1100011:begin
            imm_type=IMM_B;
        end
        7'b1101111:begin
            imm_type=IMM_J;
        end
        default: begin
            imm_type = IMM_I;
        end
    endcase
end

always @(*) begin
    alu_op=ALU_ADD;
    alu_src=0;
    reg_write=0;
    mem_read=0;
    mem_write=0;
    mem_type=0;
    wb_sel=WB_ALU;
    br_type=0;
    imm=0;
    is_jal=0;
    is_jalr=0;
    is_branch=0;
    is_auipc=0;
    is_ebreak=0;
    
    case (imm_type)
        IMM_I:imm=imm_I;
        IMM_S:imm=imm_S;
        IMM_U:imm=imm_U;
        IMM_B:imm=imm_B;
        IMM_J:imm=imm_J;
        default:imm=0;
    endcase

    case (opcode)
        7'b1100011:begin
            alu_op=ALU_PASS;
            alu_src=0;
            is_branch=1;
            case (funct3)
                3'b000:br_type=BR_BEQ;  //beq
                3'b001:br_type=BR_BNE;  //bne
                3'b100:br_type=BR_BLT;  //blt
                3'b101:br_type=BR_BGE;  //bge
                3'b110:br_type=BR_BLTU;  //bltu
                3'b111:br_type=BR_BGEU;  //bgeu
                default:br_type=0;
            endcase
        end
        7'b1101111:begin  //jal
            reg_write=1;
            wb_sel=WB_PC4;
            is_jal=1;
        end
        7'b0110111:begin  //lui
            alu_op=ALU_PASS;
            reg_write=1;
            wb_sel=WB_ALU;
            alu_src=1;
        end
        7'b0010111:begin  //auipc
            reg_write=1;
            alu_op=ALU_ADD;
            wb_sel=WB_ALU;
            alu_src=1;
            is_auipc=1;
        end
        7'b0000011:begin
            alu_op=ALU_ADD;
            mem_read=1;
            wb_sel=WB_MEM;
            reg_write=1;
            alu_src=1;
            case (funct3)
                3'b000:mem_type=MEM_LB;  //lb
                3'b001:mem_type=MEM_LH;  //lh
                3'b010:mem_type=MEM_LW;  //lw
                3'b100:mem_type=MEM_LBU;  //lbu
                3'b101:mem_type=MEM_LHU;  //lhu
                default: mem_type = MEM_LW; 
            endcase
        end
        7'b0100011:begin
            alu_op=ALU_ADD;
            mem_write=1;
            alu_src=1;
            case (funct3)
                3'b000:mem_type=MEM_SB;  //sb
                3'b001:mem_type=MEM_SH;  //sh
                3'b010:mem_type=MEM_SW;  //sw
                default: mem_type = MEM_SW; 
            endcase
        end
        7'b1100111:begin  //jalr
            alu_op=ALU_ADD;
            reg_write=1;
            wb_sel=WB_PC4;
            alu_src=1;
            is_jalr=1;
        end
        7'b1110011:begin
            is_ebreak=1;
        end
        default:begin
            if(is_alu) begin  //I or R
                reg_write=1;
                wb_sel=WB_ALU;
                alu_src=is_alu_imm;
//                if(funct7==7'b0000001&&opcode==7'b0110011) begin
//                    case (funct3)
//                        3'b000:alu_op=ALU_MUL;
//                        3'b001:alu_op=ALU_MULH;
//                        3'b010:alu_op=ALU_MULHSU;
//                        3'b011:alu_op=ALU_MULHU;
//                        3'b100:alu_op=ALU_DIV;
//                        3'b101:alu_op=ALU_DIVU;
//                        3'b110:alu_op=ALU_REM;
//                        3'b111:alu_op=ALU_REMU;
//                        default:alu_op=ALU_ADD;
//                    endcase
//                end
//                else begin
                    case (funct3)
                        3'b000:begin
                            if(is_alu_reg&&is_sub)
                                alu_op=ALU_SUB;
                            else
                                alu_op=ALU_ADD;
                        end
                        3'b001:begin
                            alu_op=ALU_SLL;
                        end
                        3'b010:begin
                            alu_op=ALU_SLT;
                        end
                        3'b011:begin
                            alu_op=ALU_SLTU;
                        end
                        3'b100:begin
                            alu_op=ALU_XOR;
                        end
                        3'b101:begin
                            if(funct7 == 7'b0100000)
                                alu_op=ALU_SRA;
                            else
                                alu_op=ALU_SRL;
                        end
                        3'b110:begin
                            alu_op=ALU_OR;
                        end
                        3'b111:begin
                            alu_op=ALU_AND;
                        end
                    endcase
                end
            end
//        end
    endcase
end
endmodule
