module WBU(
    input clk,
    input [31:0] pc,
    input [31:0] alu_result,
    input [31:0] mem_data,
    input [1:0] wb_sel,

    output reg [31:0] wdata
);

localparam WB_ALU = 2'b00;
localparam WB_MEM = 2'b01;
localparam WB_PC4 = 2'b10;

always @(*) begin
    case (wb_sel)
        WB_ALU:wdata=alu_result;
        WB_MEM:wdata=mem_data;
        WB_PC4:wdata=pc+4;
        default:wdata=0;
    endcase
end

endmodule