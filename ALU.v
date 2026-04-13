module ALU(
    input [31:0] a,
    input [31:0] b,
    input [4:0] alu_op,
    output zero,
    output lt,
    output ltu,
    output reg [31:0] result
);

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

assign zero=(a==b);
assign lt=($signed(a)<$signed(b));
assign ltu=(a<b);

wire [63:0] mul_result_signed;
wire [63:0] mul_result_unsigned;

assign mul_result_signed=$signed(a)*$signed(b);
assign mul_result_unsigned=$unsigned(a)*$unsigned(b);

reg [63:0] mulhsu_temp;

always @(*) begin
    mulhsu_temp=0;
    case (alu_op)
        ALU_ADD:result=a+b;
        ALU_SUB:result=a-b;
        ALU_PASS:result=b;
        ALU_SLT:result=($signed(a)<$signed(b))?1:0;
        ALU_SLTU:result=(a<b)?1:0;
        ALU_XOR:result=a^b;
        ALU_OR:result=a|b;
        ALU_AND:result=a&b;
        ALU_SLL:result=a<<b[4:0];
        ALU_SRL:result=a>>b[4:0];
        ALU_SRA:result=$signed(a)>>>b[4:0];
//        ALU_MUL:result=mul_result_signed[31:0];
//        ALU_MULH:result=mul_result_signed[63:32];
//        ALU_MULHSU:begin
//            mulhsu_temp = $signed({{32{a[31]}}, a}) * $unsigned({32'b0, b});
//            result=mulhsu_temp[63:32];
//        end
//        ALU_MULHU:result=mul_result_unsigned[63:32];
//        ALU_DIV:result=(b==32'b0)?32'hFFFFFFFF:
//                        ($signed(a)==32'h80000000&&$signed(b)==32'hFFFFFFFF)?32'h80000000:
//                        $signed(a)/$signed(b);
//        ALU_DIVU:result=(b==32'b0)?32'hFFFFFFFF:$unsigned(a)/$unsigned(b);
//        ALU_REM:result=(b==32'b0)?a:
//                        ($signed(a)==32'h80000000&&$signed(b)==32'hFFFFFFFF)?32'b0:
//                        $signed(a)%$signed(b);
//        ALU_REMU:result=(b==32'b0)?a:$unsigned(a)%$unsigned(b);
        default:result=0;
    endcase
end

endmodule