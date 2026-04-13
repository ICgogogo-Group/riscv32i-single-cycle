module LSU(
    input clk,
    input valid,
    input wen,
    input [31:0] waddr,
    input [31:0] wdata,
    input [31:0] raddr,
    input [2:0] mem_type,

    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output [1:0] mem_mask,
    output mem_valid,
    output mem_wen,
    output is_write,
    input [31:0] mem_rdata,
    output reg [31:0] rdata
);
localparam MEM_LB  = 3'b000;
localparam MEM_LH  = 3'b001;
localparam MEM_LW  = 3'b010;
localparam MEM_LBU = 3'b011;
localparam MEM_LHU = 3'b100;
localparam MEM_SB  = 3'b101;
localparam MEM_SH  = 3'b110;
localparam MEM_SW  = 3'b111;

wire [1:0] offset = waddr[1:0];
reg [31:0] shifted;
reg [1:0] wmask;

assign mem_valid = valid;
assign mem_wen = wen;
assign is_write = wen;
assign mem_addr = wen ? waddr : raddr;
assign mem_wdata = wdata;

always @(*) begin
    case (mem_type)
        MEM_SB:  wmask = 2'b00;
        MEM_SH:  wmask = 2'b01;
        MEM_SW:  wmask = 2'b10;
        default: wmask = 2'b00;
    endcase
end

assign mem_mask = wmask;

always @(*) begin
    shifted = 32'b0;
    rdata = 32'b0;
    if (valid && !wen) begin
        shifted = mem_rdata >> (8 * raddr[1:0]);
        case (mem_type)
            MEM_LW:  rdata = mem_rdata;
            MEM_LB:  rdata = {{24{shifted[7]}}, shifted[7:0]};
            MEM_LBU: rdata = {24'b0, shifted[7:0]};
            MEM_LH:  rdata = {{16{shifted[15]}}, shifted[15:0]};
            MEM_LHU: rdata = {16'b0, shifted[15:0]};
            default: rdata = 32'b0;
        endcase
    end
end

endmodule
