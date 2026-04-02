import "DPI-C" function void cpu_ebreak();

module PC(
    input clk,
    input rst,
    input is_ebreak,
    input [31:0] next_pc,
    output reg [31:0] pc
);

always @(posedge clk) begin
    if(rst)
        pc<=32'h80000000;
    else if(is_ebreak)
        cpu_ebreak();
    else
        pc<=next_pc;
end

endmodule