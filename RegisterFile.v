module RegisterFile #(
    parameter ADDR_WIDTH = 5, 
    parameter DATA_WIDTH = 32
) 
(
  input clk,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input wen,

  output [DATA_WIDTH-1:0] rdata1,
  input [ADDR_WIDTH-1:0] raddr1,

  output [DATA_WIDTH-1:0] rdata2,
  input [ADDR_WIDTH-1:0] raddr2
);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
  always @(posedge clk) begin
    if (wen&&waddr!=0) rf[waddr] <= wdata;
    // $display("x0=%d x1=%d x2=%d x3=%d x4=%d\n", rf[0], rf[1], rf[2], rf[3],rf[4]);
    // $display("x1(ra)=%d x10(a0)=%d\n", rf[1], rf[10]);
  end

  integer i;

//   always @(posedge clk) begin
//     if (wen && waddr != 0) begin 
//         $display("==== REG WRITE ====");
//         $display("x%0d <= 0x%08x", waddr, wdata);
//         $display("---- ALL REGS ----");
//         for (i = 0; i < 32; i = i + 1) begin
//             $display("x%0d = 0x%08x", i, rf[i]);
//         end
//         $display("==================\n");
//     end
// end

// always @(posedge clk) begin
//   if (wen && waddr != 0) begin
//     $display("PC??? REG WRITE: x%0d <= 0x%08x", waddr, wdata);

//     if (waddr == 10) begin
//       $display(">>> a0 UPDATED: 0x%08x (%c)", wdata, wdata[7:0]);
//     end

//     if (waddr == 1) begin
//       $display(">>> ra UPDATED: 0x%08x", wdata);
//     end
//   end
// end

  assign rdata1=(raddr1==0)?0:rf[raddr1];
  assign rdata2=(raddr2==0)?0:rf[raddr2];
endmodule