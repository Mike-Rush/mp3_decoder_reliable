// 
//  MAC_MP3: A Low Energy Implementation of an Audio Decoder
//
//  Copyright (C) 2007 McMaster University
// 
//==============================================================================
// 
// This file is part of MAC_MP3
// 
// MAC_MP3 is distributed in the hope that it will be useful for further research,
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. MAC_MP3 is free; you can redistribute it
// and/or modify it provided that proper reference is provided to the authors. See
// the documents included in the "doc" folder for further details.
//
//==============================================================================


`timescale 1ns / 100ps

module hufftop_hufftop_tb_v_tf();

// DATE:     18:04:51 09/19/2005 
// MODULE:   hufftop
// DESIGN:   hufftop
// FILENAME: hufftop_tb.v
// PROJECT:  2_mp3dec
// VERSION:  


// Inputs
    reg CLK_I;
    reg RESETN_I;


// Outputs


// Bidirs


// Instantiate the UUT
    hufftop uut (
        .CLK_I(CLK_I), 
        .RESETN_I(RESETN_I)
        );

        integer i;
        integer endsim;
        integer dfile,rfile,sfile;
        integer mismatch;
        integer decoded_sample;
        integer read_decoded_sample;
        integer requantized_sample;
        integer read_requantized_sample;
        integer stereo_sample;
        integer read_stereo_sample;
        integer leftram[576];
        integer rightram[576];
        
        initial begin
            mismatch = 0;
            endsim = 0;
            CLK_I = 0;
            forever #50 CLK_I = ~CLK_I;
        end

        initial begin
            dfile = $fopen("decoded_samples.txt","r");
            rfile = $fopen("requantized_samples.txt","r");
            sfile = $fopen("stereo_samples.txt","r");
            
            RESETN_I = 0;
            #500 RESETN_I = 1;
        end
        
        `include "huffctl_define.v"
        
        `define COMPARE_HUFFMAN 1
        `define COMPARE_STEREO 1
        `define SHOW_MISMATCH 1
        //`define SHOW_SCALEFAC 1
        //`define COMPARE_REORDER 1
        `define MISMATCH_BEFORE_PAUSE 4
        `define MISMATCH_TOLERANCE 1
        
        always @ (posedge CLK_I)
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
        
/*        always @(uut.HUFFMANDECODER.frame)
        begin
          if (uut.HUFFMANDECODER.frame == 100)
            $stop(2);
        end*/
        
        always @(uut.dpw_address)
        begin
          /*
          if (uut.main_start == 1 && uut.dpw_address < 3)
          begin
            $write("\n---------------END OF SIMULATION... almost-----------------\n\n");
            $stop(2);
          end
          */
          if (uut.dpw_address == 513)
          begin
            if (endsim == 1)
            begin
              $write("\n---------------END OF SIMULATION-----------------\n\n");
              $stop(2);
            end
            else
              endsim = 1;
          end
        end
        
        `ifdef MISMATCH_BEFORE_PAUSE
        always @(mismatch)
        begin
          if (mismatch >= `MISMATCH_BEFORE_PAUSE)
          begin
            $stop(3);
            mismatch = 0;
          end
        end
        `endif


endmodule

