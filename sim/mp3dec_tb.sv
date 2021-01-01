module mp3dec_tb;


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
			integer realframe;
			initial begin
				realframe = 0;
			end

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
endmodule