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
    output [3:0] mem_wmask,
    output mem_valid,
    output mem_wen,
    input [31:0] mem_rdata,
    output reg [31:0] rdata


);
wire [1:0] offset=waddr[1:0];

assign mem_valid=valid;
assign mem_wen=wen;
assign mem_addr=wen?waddr:raddr;
assign mem_wdata=wdata;

localparam MEM_LB=3'b000;
localparam MEM_LH=3'b001;
localparam MEM_LW=3'b010;
localparam MEM_LBU=3'b011;
localparam MEM_LHU=3'b100;

localparam MEM_SB=3'b101;
localparam MEM_SH=3'b110;
localparam MEM_SW=3'b111;

always @(*) begin
    case (mem_type)
        MEM_SB:wmask=4'b0001<<offset;
        MEM_SH:wmask=4'b0011<<{offset[1],1'b0};
        MEM_SW:wmask=4'b1111;
        default:wmask=4'b0000;
    endcase
end

assign mem_wmask=wmask;

reg [31:0] shifted;

always @(*) begin
  shifted=0;
  rdata=0;
  if (valid && !wen) begin
    shifted = mem_rdata >> (8 * raddr[1:0]);

    case (mem_type)
      MEM_LW: rdata=mem_rdata;
      MEM_LB: rdata={{24{shifted[7]}},shifted[7:0]};
      MEM_LBU: rdata={24'b0,shifted[7:0]};
      MEM_LH: rdata={{16{shifted[15]}},shifted[15:0]};
      MEM_LHU: rdata={16'b0,shifted[15:0]};
      default: rdata = 0;
    endcase
  end 
  else begin
    rdata = 0;
  end
end

endmodule