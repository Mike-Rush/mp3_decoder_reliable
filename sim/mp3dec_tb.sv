`include "defines.v"
`define DEBUG_HUFF
`define p_gclk 10
`define p_sclk 3.7*p_gclk;
module mp3dec_tb;
integer realframe;
reg globalclk,sampleclk;
mp3_dec_top uut (
	.MASTER_CLOCK_I  (globalclk),
//	ALTERNATE_CLOCK_I,
	.AC97_BIT_CLOCK_I(globalclk),
	.global_rst_n(global_rst_n),
	.module_en(1'b1),
	.sample_clk(sampleclk)
//	AC97_SYNCH_O,
//	AC97_DATA_IN_I,
//	AC97_DATA_OUT_O,
//	AC97_BEEP_TONE_O,
//	PAL_NTSC,
//	S_VIDEO,
//	USER_LED0_O,			 
//	USER_LED1_O,
//	STARTUP_O
);
///////////////////////////////// Ethernet //////////////////////////////////////////
		  always @ (negedge uut.ETH_done) begin
			$write("ETH started...\n");
//			$write("\t\t\t\tAddress[9]=%d buffer=%d...\n", uut.HUFF_DP_ADDRESS[9], uut.HUFF_address_msb_buffer);
		  end

		  always @ (posedge uut.ETH_done) begin
		  	$write("ETH finished...\n");
		  end

/////////////////////////////// Huffman ////////////////////////////////////////////
  		  always @ (posedge uut.HUFF_done) begin
		  	$write("Huffman finish...\n");
		  end

		  always @ (negedge uut.HUFF_done) begin
		  	$write("Huffman started...\n");
		  end
	`ifdef DEBUG_HUFF

			always @ (posedge uut.HUFF_clock) begin
				if (uut.HUFFMANDECODER.state == 6)
				begin
					realframe = realframe + 1;
					$write("===========================================================\t\t\t\t\tcurrent frame: %d\n",realframe);
				end
			end

		  always @ (posedge uut.HUFF_clock) begin
			  if (uut.HUFFMANDECODER.state == 11) begin
			    $write("HUFF write %d: \tglobal_gain = %d \tscalefac_compress = %d \tWSF = %d\n",
				   uut.HUFFMANDECODER.ram0_address,
				   uut.HUFFMANDECODER.ram0_datain[15:8],
				   uut.HUFFMANDECODER.ram0_datain[7:4],
					uut.HUFFMANDECODER.ram0_datain[3]
				 );
			    if ( uut.HUFFMANDECODER.ram0_datain[3] == 1)
				   $write("Block_type = %d \tMBF = %d\n",
					  uut.HUFFMANDECODER.ram0_datain[2:1],
					  uut.HUFFMANDECODER.ram0_datain[0]
				   );
			  end
		  end
`endif
always #(`p_gclk/2.0) globalclk=~globalclk;
always #(`p_sclk/2.0) sampleclk=~sampleclk;
initial begin
	realframe=0;
	globalclk=0;
	sampleclk=0;
	global_rst_n=0;
	#(`p_gclk*100)
	global_rst_n=1;
end
endmodule