`include "defines.v"
module dout_monitor(
input clk,rst_n,
input [`ADDRESS_WIDTH-1:0] addr,
input [`DATA_WIDTH-1:0] d_ch0,
input [`DATA_WIDTH-1:0] d_ch1,
input sample_clk
);
always @(posedge clk)
begin
	sample_clk_t<=sample_clk;
end
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		addr<=10'd448;
	end else begin
		if (sample_clk_t == 1'b0 && sample_clk == 1'b1)
		begin
			addr <= addr + 10'd1;
		end
	end
end
endmodule