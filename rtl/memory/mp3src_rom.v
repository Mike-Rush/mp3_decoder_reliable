`include "defines.v"
module mp3src_rom(
	input clk,
	input [`ADDRESS_WIDTH-1:0] addr,
	output [`DATA_WIDTH-1:0] data
	);
reg [`DATA_WIDTH-1:0] mem[(1<<`ADDRESS_WIDTH)-1:0];
integer fmp3;
initial begin
	fmp3=$fopen("./mp3_src.bin","rb");
	$fseek(fmp3,0,2);
	mp3_size=$ftell(fmp3);
	$display("mp3 file size=%0d bytes",mp3_size);
	$rewind(fmp3);
	$fread(mem,fmp3);
end
always @(posedge clk)
begin
	data<=mem[addr];
end
endmodule