`include "../defines.v"
module mp3src_rom(
	input clk,
	input [`ADDRESS_WIDTH-1:0] addr,
	output reg [`DATA_WIDTH-1:0] data
	);
reg [`DATA_WIDTH-1:0] mem[(1<<`ADDRESS_WIDTH)-1:0];
integer fmp3,i,mp3_size;
initial begin
	fmp3=$fopen("./mp3_src.mp3","rb");
	$fseek(fmp3,0,2);
	mp3_size=$ftell(fmp3);
	$display("mp3 file size=%0d bytes",mp3_size);
	$rewind(fmp3);
	$fread(mem,fmp3);
	for (i=0;i<10;i++) 
	begin
		$display("mp3memory[%0d]=%08x",i,mem[i]);
	end
end
always @(posedge clk)
begin
	data<=mem[addr];
end
endmodule