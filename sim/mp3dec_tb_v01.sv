`include "../rtl/defines.v"
`timescale 1 ns / 100 ps
`define p_gclk 10
`define p_sclk (3.7*`p_gclk)
module mp3dec_tb;
integer realframe,mismatch;
reg globalclk,sampleclk;
reg global_rst_n;
reg [15:0] fifo_datain;
wire fifo_ren;
mp3_dec_top2 uut (
	.MASTER_CLOCK_I  (globalclk),
//	ALTERNATE_CLOCK_I,
	.AC97_BIT_CLOCK_I(globalclk),
	.global_rst_n(global_rst_n),
	.module_en(1'b1),
	.sample_clk(sampleclk),
  .fifo_datain     (fifo_datain),
  .fifo_ren        (fifo_ren)
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
///////////////////////////////// Gen&&Dump Data //////////////////////////////////////////
integer fpcm,fmp3,i;
reg [`DATA_WIDTH-1:0] mem[(1<<`ADDRESS_WIDTH)-1:0];
initial begin
  fpcm=$fopen("./out.pcm","wb");
end
initial begin
  fmp3=$fopen("./t01.mp3","rb");
  $fseek(fmp3,0,2);
  mp3_size=$ftell(fmp3);
  $display("mp3 file size=%0d bytes",mp3_size);
  $rewind(fmp3);
  $fread(mem,fmp3);
  for (i=0;i<16;i++) 
  begin
    $display("mp3memory[%0d]=%04x",i,mem[i]);
  end
  fifo_datain=mp3memory[0];
  forever begin
    @(posedge globalclk)
    if (global_rst_n) begin
      if (fifo_ren) begin
        mem_ptr++;
        fifo_datain=mp3memory[mem_ptr];
        if (mem_ptr==mp3_size/4) begin
          $display("mp3 reach end\n");
          fifo_empty=1'b1;
          #(`p_clk*500000);
          $stop;
        end
      end
    end
  end
end
always @(posedge uut.MAC_clock) begin
  if (uut.CH0_PCM_RAM_we == 1'b1) 
  $fwrite(fpcm,"%c%c%c%c",uut.CH0_PCM_RAM_write_data[7:0],uut.CH0_PCM_RAM_write_data[15:8],
    uut.CH1_PCM_RAM_write_data[7:0],uut.CH1_PCM_RAM_write_data[15:8]);
end
///////////////////////////////// Ethernet //////////////////////////////////////////
/*		  always @ (negedge uut.ETH_done) begin
			$write("ETH started...\n");
//			$write("\t\t\t\tAddress[9]=%d buffer=%d...\n", uut.HUFF_DP_ADDRESS[9], uut.HUFF_address_msb_buffer);
		  end

		  always @ (posedge uut.ETH_done) begin
		  	$write("ETH finished...\n");
		  end
*/
/////////////////////////////// Huffman ////////////////////////////////////////////
  		  always @ (posedge uut.HUFF_done) begin
		  	$write("Huffman finish...\n");
		  end

		  always @ (negedge uut.HUFF_done) begin
		  	$write("Huffman started...\n");
		  end
        always @ (posedge uut.HUFFMANDECODER.CLK_I)
        begin
          case (uut.HUFFMANDECODER.stage)
          `STAGE_SIDEINFO:
          begin
            case (uut.HUFFMANDECODER.state)
            `STATE_SIDEINFO_ADDRESS:
            begin
              $write("===================sideinfo gr%d ch%d\n", uut.HUFFMANDECODER.gr, uut.HUFFMANDECODER.ch);
            end
            `STATE_SIDEINFO_PART2_3_LENGTH:
            begin
              $write("part2_3_length: %d\n", uut.HUFFMANDECODER.data[15:4]);
            end
            `STATE_SIDEINFO_BIG_VALUES:
            begin
              $write("big_values: %d -> x2 = %d\n", uut.HUFFMANDECODER.data[15:7], uut.HUFFMANDECODER.data[15:7]*2);
            end
            `STATE_SIDEINFO_GLOBAL_GAIN:
            begin
              $write("global_gain: %d\n",uut.HUFFMANDECODER.data[15:8]);
              $write("scalefac_compress: %d\n",uut.HUFFMANDECODER.data[7:4]);
            end
            `STATE_SIDEINFO_BLOCK_TYPE:
            begin
              $write("WSF: %d\n",uut.HUFFMANDECODER.data[15]);
              if (uut.HUFFMANDECODER.data[15] == 1)  // WSF == 1
              begin
                $write("block_type: %d\n",uut.HUFFMANDECODER.data[14:13]);
                $write("MBF: %d\n",uut.HUFFMANDECODER.data[12]);
              end
              else
              begin
                $write("block_type: 0\n");
                $write("MBF: 0\n");
              end
            end
            `STATE_SIDEINFO_TABLE_SELECT:
            begin
              $write("table_select");
              if (uut.HUFFMANDECODER.gpreg[15] == 1)  // WSF == 1
                $write("0,1: %d %d\n",uut.HUFFMANDECODER.data[15:11],uut.HUFFMANDECODER.data[10:6]);
              else
                $write("0,1,2: %d %d %d\n",uut.HUFFMANDECODER.data[15:11],uut.HUFFMANDECODER.data[10:6],uut.HUFFMANDECODER.data[5:1]);
            end
            `STATE_SIDEINFO_SUBBLOCK_GAIN:
            begin
              if (uut.HUFFMANDECODER.gpreg[15] == 1)
                $write("subblock_gain0,1,2: %d %d %d\n",uut.HUFFMANDECODER.data[15:13],uut.HUFFMANDECODER.data[12:10],uut.HUFFMANDECODER.data[9:7]);
            end
            `STATE_SIDEINFO_REGION_COUNT:
            begin
              if (uut.HUFFMANDECODER.gpreg[15] == 1)
              begin
                if (uut.HUFFMANDECODER.gpreg[2:0] == 3'b100)
                  $write("region0/1count: 8,12\n");
                else
                  $write("region0/1count: 7,13\n");
                $write("preflag, scalefac_scale, count1table_select: %d %d %d\n",uut.HUFFMANDECODER.data[6],uut.HUFFMANDECODER.data[5],uut.HUFFMANDECODER.data[4]);
              end
              else
              begin
              end
            end
            endcase
          end  // stage_sideinfo
          `STAGE_DECODE:
          begin
            case (uut.HUFFMANDECODER.state)
            `STATE_DECODE_SCALEFAC:
            begin
              case (uut.HUFFMANDECODER.step)
              `ifdef MISMATCH_BEFORE_PAUSE
              `else
              0:  mismatch = 0;
              `endif
              1:  // long - mixed
              begin
                `ifdef SHOW_SCALEFAC
                $write("long scalefac %d: %d\n",uut.HUFFMANDECODER.counter[4:0],uut.HUFFMANDECODER.data_slen1);
                `endif
              end
              2:  // short
              begin
                `ifdef SHOW_SCALEFAC
                case (uut.HUFFMANDECODER.counter[3:0])
                0,1,2,3,4,5:
                  $write("short scalefac %d: %d\n",uut.HUFFMANDECODER.counter[3:0],uut.HUFFMANDECODER.data_slen1);
                default:
                  $write("short scalefac %d: %d\n",uut.HUFFMANDECODER.counter[3:0],uut.HUFFMANDECODER.data_slen2);
                endcase
                `endif
              end
              3:  // long
              begin
                `ifdef SHOW_SCALEFAC
                case (uut.HUFFMANDECODER.counter[4:0])
                0,1,2,3,4,5:
                  if (uut.HUFFMANDECODER.gr == 0 || uut.HUFFMANDECODER.gpreg[3] == 0)  // scfsi[0]
                    $write("long scalefac %d: %d\n",uut.HUFFMANDECODER.counter[4:0],uut.HUFFMANDECODER.data_slen1);
                6,7,8,9,10:
                  if (uut.HUFFMANDECODER.gr == 0 || uut.HUFFMANDECODER.gpreg[2] == 0)  // scfsi[1]
                    $write("long scalefac %d: %d\n",uut.HUFFMANDECODER.counter[4:0],uut.HUFFMANDECODER.data_slen1);
                11,12,13,14,15:
                  if (uut.HUFFMANDECODER.gr == 0 || uut.HUFFMANDECODER.gpreg[1] == 0)  // scfsi[2]
                    $write("long scalefac %d: %d\n",uut.HUFFMANDECODER.counter[4:0],uut.HUFFMANDECODER.data_slen2);
                16,17,18,19,20:
                  if (uut.HUFFMANDECODER.gr == 0 || uut.HUFFMANDECODER.gpreg[0] == 0)  // scfsi[3]
                    $write("long scalefac %d: %d\n",uut.HUFFMANDECODER.counter[4:0],uut.HUFFMANDECODER.data_slen2);
                endcase
                `endif
              end  
              endcase
            end
            
            /*
            `STATE_DECODE_PART3:
            begin
              case (uut.HUFFMANDECODER.step)
              0:
                mismatch = 0;
              endcase
            end
            */
            `STATE_DECODE_REQ_STEREO:
            begin
              case (uut.HUFFMANDECODER.step)
              0:
              begin
              `ifdef COMPARE_HUFFMAN
                decoded_sample = uut.HUFFMANDECODER.decoded_sample;
                if (uut.HUFFMANDECODER.decoded_sign)
                  decoded_sample = -decoded_sample;
                $fscanf(dfile,"%d",read_decoded_sample);
                `ifdef MISMATCH_TOLERANCE
                if ((decoded_sample - read_decoded_sample) < -`MISMATCH_TOLERANCE || (decoded_sample - read_decoded_sample) > `MISMATCH_TOLERANCE)
                `else
                if (decoded_sample != read_decoded_sample)
                `endif
                begin
                  mismatch = mismatch + 1;
                  $write("%d: *M* H-%d %d\n", uut.HUFFMANDECODER.counter,decoded_sample,read_decoded_sample);
                  //$stop(3);
                end
                //$write("%d: H-%d %d\n", uut.HUFFMANDECODER.counter,decoded_sample,read_decoded_sample);
                requantized_sample = uut.HUFFMANDECODER.req_result_signed;
                if (uut.HUFFMANDECODER.req_result_signed & 16'h8000)
                  requantized_sample = requantized_sample - 65536;
                $fscanf(rfile,"%d",read_requantized_sample);
                `ifdef MISMATCH_TOLERANCE
                if ((requantized_sample - read_requantized_sample) < -`MISMATCH_TOLERANCE || (requantized_sample - read_requantized_sample) > `MISMATCH_TOLERANCE)
                `else
                if (requantized_sample != read_requantized_sample)
                `endif
                begin
                  mismatch = mismatch + 1;
                  $write("%d: *M* Q-%d %d\n",uut.HUFFMANDECODER.counter,requantized_sample,read_requantized_sample);
                  $write("   H=%d ROM=%d is_adj=%d m1=%x m2=%x mo=%x expo=%d\n",
                    uut.HUFFMANDECODER.decoded_sample,
                    uut.HUFFMANDECODER.REQ_ROM_data_out,
                    uut.HUFFMANDECODER.is_adj,
                    uut.HUFFMANDECODER.mult_in1,
                    uut.HUFFMANDECODER.mult_in2,
                    uut.HUFFMANDECODER.mult_out,
                    uut.HUFFMANDECODER.exp_out
                  );
                  //$stop(3);
                end
                //$write("%d: Q-%d %d\n",uut.HUFFMANDECODER.counter,requantized_sample,read_requantized_sample);
              `endif
              end
              1:
              begin
              //$write("%d: msis = %d\n",uut.HUFFMANDECODER.counter,uut.HUFFMANDECODER.msis);
              `ifdef COMPARE_STEREO
                //stereo_sample = uut.HUFFMANDECODER.rightchannel_datain;
                stereo_sample = uut.HUFFMANDECODER.mac_datain;
                if (stereo_sample > 32767)
                  stereo_sample = stereo_sample - 65536;
                $fscanf(sfile,"%d",read_stereo_sample);
                `ifdef MISMATCH_TOLERANCE
                if ((stereo_sample - read_stereo_sample) < -`MISMATCH_TOLERANCE || (stereo_sample - read_stereo_sample) > `MISMATCH_TOLERANCE)
                `else
                if (stereo_sample != read_stereo_sample)
                `endif
                begin
                  mismatch = mismatch + 1;
                  $write("%d: *M* R-%d %d\n", uut.HUFFMANDECODER.counter, stereo_sample, read_stereo_sample);
                  //$stop(3);
                end
                `ifdef COMPARE_REORDER
                  //rightram[uut.HUFFMANDECODER.rightchannel_address] = stereo_sample;
                  rightram[uut.HUFFMANDECODER.mac_address] = stereo_sample;
                `endif
              `endif
              end
              2:
              begin
/*                $write("c: %d   lc: %d   sc0: %d   sc1: %d   sc2: %d\n",
                  uut.HUFFMANDECODER.counter,
                  uut.HUFFMANDECODER.long_counter,
                  uut.HUFFMANDECODER.short_counter[0],
                  uut.HUFFMANDECODER.short_counter[1],
                  uut.HUFFMANDECODER.short_counter[2]
                );*/
              `ifdef COMPARE_STEREO
                if ((uut.HUFFMANDECODER.js | uut.HUFFMANDECODER.stereo) && uut.HUFFMANDECODER.ch==1)
                begin
                  //stereo_sample = uut.HUFFMANDECODER.leftchannel_datain;
                  stereo_sample = uut.HUFFMANDECODER.mac_datain;
                  if (stereo_sample > 32767)
                    stereo_sample = stereo_sample - 65536;
                  $fscanf(sfile,"%d",read_stereo_sample);
                  `ifdef MISMATCH_TOLERANCE
                  if ((stereo_sample - read_stereo_sample) < -`MISMATCH_TOLERANCE || (stereo_sample - read_stereo_sample) > `MISMATCH_TOLERANCE)
                  `else
                  if (stereo_sample != read_stereo_sample)
                  `endif
                  begin
                    mismatch = mismatch + 1;
                    $write("%d: *M* L-%d %d\n", uut.HUFFMANDECODER.counter, stereo_sample, read_stereo_sample);
                    //$stop(3);
                  end
                end
                `ifdef COMPARE_REORDER
                  //leftram[uut.HUFFMANDECODER.leftchannel_address] = stereo_sample;
                  leftram[uut.HUFFMANDECODER.mac_address] = stereo_sample;
                `endif
              `endif
              `ifdef SHOW_MISMATCH
                if (uut.HUFFMANDECODER.next_counter == 576)
                begin
                  $write("----------mismatch: %d\n", mismatch);
                  `ifdef MISMATCH_BEFORE_PAUSE
                  `else
                  if (mismatch > 0)
                    $stop(1);
                  `endif
                end
              `endif
              `ifdef COMPARE_REORDER
                if (uut.HUFFMANDECODER.next_counter == 576)
                begin
                  if (uut.HUFFMANDECODER.ch == 1)
                  begin
                    $write("----reordered samples:\n");
                    for (i=0;i<576;i=i+1)
                      $write("%d: L: %d R: %d\n",i,leftram[i],rightram[i]);
                  end
                end
              `endif
                if (uut.HUFFMANDECODER.counter > 576)
                begin
                  $write("counter over 576!!\n");
                  $stop(10);
                end
              end
              default:
              begin
              end
              endcase  // step
            end
            endcase  // state
          end  // stage DECODE
          `STAGE_POST_DECODE:
          begin
          end
          endcase  // stage
        end  // always
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