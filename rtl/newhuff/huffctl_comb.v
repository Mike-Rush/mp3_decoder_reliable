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


//    always @(bits_processed)  // for synthesis, just need anything in the sensitivity list
    always @(*)  // for simulation
    begin
      #1;
      // default values to remove latches
      // should be changed for reducing size
      bits_processed <= 0;
      ram_address <= 0;
      ram_datain <= 0;
      ram_we <= 0;
      huffrom_address0 <= 0;
      huffrom_address1 <= 0;
      br_we <= 0;
      brram_address <= br_write_address[11:4];
      br_datain <= {br_dataout[15:8],data[15:8]};
      decoded_sample <= 0;
      decoded_sign <= 0;
      mult_in1 <= REQ_ROM_data_out + is_adj;
      mult_in2 <= 16'h2d41;  // square root 2
//      mult_in2 <= 16'h2d42;  // square root 2      
      //leftchannel_datain <= ram_dataout;
      //rightchannel_datain <= req_buf;
      //leftchannel_address <= shortblock ? short_counter[window] : long_counter; //reordered_address;
      //rightchannel_address <= leftchannel_address;
      //leftchannel_we <= 0;
      //rightchannel_we <= 0;
      mac_datain <= ram_dataout;
      mac_address <= shortblock ? short_counter[window] : long_counter; //reordered_address;
      mac_left_we <= 0;
      mac_right_we <= 0;
      newsfb <= sfb;      
      newreadptr <= readptr + bits_processed;
      
      case (stage)
      `STAGE_INIT:
      begin
        case (state)
        `STATE_INIT_RESET:
        begin
        end
        `STATE_INIT_FILLBUF:
        begin
          bits_processed <= 16;
        end
        endcase
      end  // stage_init
      `STAGE_HEADER:
      begin
        case (state)
        `STATE_HEADER_SYNCWORD:
        begin
          if (data[15:1] == 15'b111111111111101)  // 12-bit syncword, ID and layer 3
          begin
            //if (main_start == 1)
              bits_processed <= 16;  // syncword found, read first half of header info
          end
          else
            bits_processed <= 8;  // syncword not found, skip 1 byte
        end
        `STATE_HEADER_INFO:
        begin
          bits_processed <= 16;
          huffrom_address0 <= 1408 + {data[9],data[11:10],data[15:12]};
        end
        `STATE_HEADER_CRC:
        begin
          if (gpreg[15] == 0)
            bits_processed <= 16;  // skip 16-bit CRC
          // write end of frame pointer
          ram_datain <= {huffrom_dataout0[11:0],3'b0} + readptr[13:0] - 32;
          ram_address <= counter;  // 608
          ram_we <= 1;
        end
        `STATE_HEADER_MAIN_DATA_BEGIN:
        begin
          if (nch == 0)
            bits_processed <= 9 + 5;  // 5-bit private bits
          else
            bits_processed <= 9 + 3;  // 3-bit private bits
          // write main_data_begin
          ram_datain <= data;  // 9-bit MSB
          ram_address <= counter;  // 608 + 1
          ram_we <= 1;
        end
        `STATE_HEADER_SCFSI:
        begin
          if (nch == 1)
            bits_processed <= 8;
          else
            bits_processed <= 4;
          // write scfsi
          ram_datain <= data;  // 4/8-bit MSB
          ram_address <= counter;  // 608 + 2
          ram_we <= 1;
        end
        endcase  // state
      end  // stage_header
      `STAGE_SIDEINFO:
      begin
        // default ram values
        ram_datain <= data;
        ram_address <= counter;
        ram_we <= 1;
        case (state)
        `STATE_SIDEINFO_ADDRESS:
        begin
          
        end
        `STATE_SIDEINFO_PART2_3_LENGTH:
        begin
          bits_processed <= 12;
        end
        `STATE_SIDEINFO_BIG_VALUES:
        begin
          bits_processed <= 9;
        end
        `STATE_SIDEINFO_GLOBAL_GAIN:
        begin
          bits_processed <= 8 + 4;
          // global_gain(8), scalefac_compress(4)
        end
        `STATE_SIDEINFO_BLOCK_TYPE:
        begin
          bits_processed <= data[15] ? 4 : 1;
          // WSF(1), block_type(2), MBF(1) : WSF(1)
          if (data[15] == 0)  // WSF == 0
            ram_datain[14:12] <= 3'b000;
          // set block_type(2) = 0, MBF(1) = 0
        end
        `STATE_SIDEINFO_TABLE_SELECT:
        begin
          bits_processed <= gpreg[15] ? (5 + 5) : (5 + 5 + 5);
          // table_select0,1 (5x2) : table_select0,1,2 (5x3)
        end
        `STATE_SIDEINFO_SUBBLOCK_GAIN:
        begin
          // write subblock_gain if WSF == 1
          // subblock_gain0,1,2 (3x3)
        end
        `STATE_SIDEINFO_REGION_COUNT:
        begin
          if (gpreg[15] == 1)  // WSF == 1
          begin
            bits_processed <= 9 + 1 + 1 + 1;
            // subblock_gain(3x3), preflag(1), scalefac_scale(1), count1table_select(1)
            if (gpreg[2:0] == 3'b100)  // if block_type == 2 and MBF == 0
              ram_datain <= {6'd8,6'd12,data[6:4],1'b0};
            else
              ram_datain <= {6'd7,6'd13,data[6:4],1'd0};
          end
          else
          begin
            bits_processed <= 4 + 3 + 1 + 1 + 1;
            // region0_count(4), region1_count(3), preflag(1), scalefac_scale(1), count1table_select(1)
            ram_datain <= {2'd0,data[15:12],3'd0,data[11:9],data[8:6],1'd0};
          end
        end
        endcase // state
      end // state_sideinfo
      `STAGE_BIT_RESERVOIR_START:
      begin
        //if (`main_data_begin != 0)
		  if (big_values != 0)
        begin
          //if (`main_data_begin <= br_count)  // lteq
			 if (big_values <= br_count)  // lteq
          begin
          case (state)
          0: brram_address <= br_write_address[11:4];  // last byte of bit reservoir
          1: if (br_write_address[3] == 1)  // one of the byte is not written
             begin
               brram_address <= br_write_address[11:4];  // last byte of bit reservoir
               br_we <= 1;
               br_datain <= {br_dataout[15:8],data[15:8]};
               // write one byte from main stream to the last byte of bit reservoir
               bits_processed <= 8;
             end
          2:
          begin
            newreadptr[13:12] <= 0;
            //newreadptr[11:3] <= br_write_address[11:3] - `main_data_begin;
				newreadptr[11:3] <= br_write_address[11:3] - big_values;
            newreadptr[2:0] <= 0;
          end
          3: bits_processed <= 16;  // preread 16-bit for bit reservoir
          endcase  // state
          end
        end
      end
      `STAGE_DECODE:
      begin
        case (state)
        `STATE_DECODE_READ_SIDEINFO:
        begin
          ram_address <= {5'b10010,gr,ch,step[2:0]};
          case (step[2:0])
          3:
          begin
            huffrom_address0 <= {7'b1011111,ram_dataout[7:4]};  // 1520 + scalefac_compress(4)
          end
          7:
          begin
            ram_address <= 608 + 2;  // scfsi
          end
          endcase  // step
        end  // state_decode_read_sideinfo
        `STATE_DECODE_SCALEFAC:
        begin
          case (step[2:0])
          0:
          begin
            
          end
          1:
          begin
            ram_address <= {5'b10110,counter[4:0]};  // 704 + counter;  // scalefac_l
            ram_datain <= data_slen1;
            ram_we <= 1;
            bits_processed <= `slen1;
          end
          2:
          begin
            ram_address <= {4'b1010,region,counter[3:0]};  // 640 + window * 16 + counter;  // scalefac_s
            ram_we <= 1;
            case (counter[3:0])
            0,1,2,3,4,5:
            begin
              ram_datain <= data_slen1;
              bits_processed <= `slen1;
            end
            default:
            begin
              ram_datain <= data_slen2;
              bits_processed <= `slen2;
            end
            endcase
          end
          3:
          begin
            ram_address <= {4'b1011,ch,counter[4:0]};  // 704 + gr * 32 + counter;  // scalefac_l
            case (counter[4:0])
            0,1,2,3,4,5:
              if (gr == 0 || gpreg[3] == 0)  // scfsi[0]
              begin
                ram_datain <= data_slen1;
                ram_we <= 1;
                bits_processed <= `slen1;
              end
            6,7,8,9,10:
              if (gr == 0 || gpreg[2] == 0)  // scfsi[1]
              begin
                ram_datain <= data_slen1;
                ram_we <= 1;
                bits_processed <= `slen1;
              end
            11,12,13,14,15:
              if (gr == 0 || gpreg[1] == 0)  // scfsi[2]
              begin
                ram_datain <= data_slen2;
                ram_we <= 1;
                bits_processed <= `slen2;
              end
            16,17,18,19,20:
              if (gr == 0 || gpreg[0] == 0)  // scfsi[3]
              begin
                ram_datain <= data_slen2;
                ram_we <= 1;
                bits_processed <= `slen2;
              end
            endcase
          end
          4:
          begin
            ram_address <= {5'b10010,gr,ch,3'd6};
          end
          5:
          begin
            // new huffrom with REQ_ROM
            huffrom_address0 <= {3'b111,sample_frequency,2'b00,ram_dataout[13:10]};  // region0_count
            huffrom_address1 <= huffrom_address0 + ram_dataout[6:4] + 1;  // region0_count + region1_count + 1
            //huffrom_address0 <= 1792 + sample_frequency * 64 + ram_dataout[15:12];
            //huffrom_address1 <= 1792 + sample_frequency * 64 + ram_dataout[15:12] + ram_dataout[11:6] + 1;
            // old rom
            //huffrom_address0 <= {4'b1110,sample_frequency,1'b0,ram_dataout[13:10]};  // region0_count
            //huffrom_address1 <= huffrom_address0 + ram_dataout[7:4] + 1;  // region0_count + region1_count + 1
            //huffrom_address0 <= 1792 + sample_frequency * 32 + ram_dataout[15:12];
            //huffrom_address1 <= 1792 + sample_frequency * 32 + ram_dataout[15:12] + ram_dataout[11:6] + 1;
          end
          6:
          begin
            //ram_datain <= (gpreg[15:13] == 3'b110) ? 288 : huffrom_dataout1[9:1];
            ram_datain <= WBBM[3] ? 288 : huffrom_dataout1[9:1];
            ram_address <= 608 + 3;
            ram_we <= 1;
          end
          endcase  // step
        end
        `STATE_DECODE_PART3:
        begin
          case (step[2:0])
          0:
          begin
            ram_address <= {5'b10010,gr,ch,3'd4};  // read table_select
          end
          1:
          begin
            // read table_base
            //huffrom_address0 <= 1728 + table_select;
            huffrom_address0 <= {6'b110110,table_select};  // table_base
            // read valid_base
            //huffrom_address1 <= 1760 + table_select;
            huffrom_address1 <= {6'b110111,table_select};  // valid_base
            ram_address <= 608 + 3;  // region2_start
          end
          2:
          begin
            huffrom_address0 <= huffrom_dataout0[10:0];
            huffrom_address1 <= huffrom_dataout1[10:0];
          end
          3:
          begin
            bits_processed <= 1;
            if (valid_bit == 0)
            begin
              huffrom_address0 <= table_base + (data[15] ? huffrom_dataout0[15:8] : huffrom_dataout0[7:0]);
              huffrom_address1 <= valid_base + (data[15] ? huffrom_dataout0[15:11] : huffrom_dataout0[7:3]);
            end
          end
          4:
          begin
            case (values[7:4])
            0:
              decoded_sample <= 0;
            15:
            begin
              bits_processed <= `linbits + 1;
              decoded_sample <= linbitsdata + values[7:4];
              decoded_sign <= sign;
            end
            default:
            begin
              bits_processed <= 1;
              decoded_sample <= {9'h0,values[7:4]};
              decoded_sign <= data[15];
            end
            endcase
            ram_address <= shortblock ? {4'b1010,window,sfb[3:0]} : {4'b1011,ch,sfb};  // scalefac
          end
          5:
          begin
            //huffrom_address0 <= table_base;
            //huffrom_address1 <= valid_base;
            huffrom_address0 <= 1456;
            huffrom_address1 <= 1364;
          end
          6:
          begin
            if (count1table_select == 0)  // A
            begin
              if (valid_bit == 0)
              begin
                huffrom_address0 <= table_base + (data[15] ? huffrom_dataout0[15:8] : huffrom_dataout0[7:0]);
                huffrom_address1 <= valid_base + (data[15] ? huffrom_dataout0[15:11] : huffrom_dataout0[7:3]);
              end
              bits_processed <= 1;
            end
            else  // B
              bits_processed <= 4;
          end
          7:
          begin
            decoded_sample <= {12'h0,values[region]};
            decoded_sign <= values[region] ? data[15] : 1'b0;
            bits_processed <= values[region];
            ram_address <= shortblock ? {4'b1010,window,sfb[3:0]} : {4'b1011,ch,sfb};  // scalefac
          end
          endcase
        end
        `STATE_DECODE_REQ_STEREO:
        begin
          case (step[2:0])
          0:  // deq
          begin
            decoded_sample <= req_buf[12:0];
            decoded_sign <= req_buf[15];
            ram_address <= counter;  // read requantized left channel
            //scalefac <= ram_dataout[3:0];
            mult_in1 <= REQ_ROM_data_out + is_adj;
            mult_in2 <= correction_factor;
            //case (quad_gain[1:0])  // correction factor
            //0: mult_in2 <= 16'h4000;
            //1: mult_in2 <= 16'h4C1B;
            //2: mult_in2 <= 16'h5A82;
            //default: mult_in2 <= 16'h6BA2;
            //endcase
            ram_we <= ((stereo | js) && (ch == 1)) ? 0 : 1;
            ram_datain <= req_result_signed;
            huffrom_address0 <= {3'b111,sample_frequency,shortblock,nextsfb};
          end
          1:  // ms/is right processing
          begin
            //rightchannel_datain <= req_buf;  // default stereo
            mac_datain <= req_buf;
            // req_buf has the requantized sample on ch1
            //rightchannel_address <= shortblock ? short_counter[window] : long_counter; //reordered_address;
            //rightchannel_we <= 1;
            mac_right_we <= 1;
            if (js && mode_extension[msis])
            begin
              if (msis)  // ms
              begin
                mult_in1 <= ram_dataout - req_buf;
                mult_in2 <= 16'h2d41;  // square root 2
                //mult_in2 <= 16'h2d42;  // square root 2
                //rightchannel_datain <= mult_out;
                mac_datain <= mult_out;
              end
              else  // is
              begin
                mult_in2 <= ispos[0] ? 16'h3279 : 16'h2893;  // K-value
                //mult_in2 <= ispos[0] ? 16'h327A : 16'h2894;  // K-value
                mult_in1 <= ram_dataout;
                case (ispos)
                //0:   rightchannel_datain <= ram_dataout;
                //1,2: rightchannel_datain <= mult_out;
                //3:   rightchannel_datain <= {ram_dataout[15],ram_dataout[15:1]};
                //4,5: rightchannel_datain <= ram_dataout - mult_out;
                //default: rightchannel_datain <= 16'h0000;
                0:   mac_datain <= ram_dataout;
                1,2: mac_datain <= mult_out;
                3:   mac_datain <= {ram_dataout[15],ram_dataout[15:1]};
                4,5: mac_datain <= ram_dataout - mult_out;
                default: mac_datain <= 16'h0000;
                endcase
              end
            end
            ram_address <= counter;  // read requantized left channel
            huffrom_address0 <= {3'b111,sample_frequency,shortblock,nextsfb};
          end
          2:  // ms/is left processing
          begin
            //leftchannel_datain <= ram_dataout;  // default writing what's in the ram
            mac_datain <= ram_dataout;
            // mono and dual: the value has just been requantized
            // stereo: requantized value of ch0
            //leftchannel_address <= shortblock ? short_counter[window] : long_counter; //reordered_address;
            //leftchannel_we <= 1;
            mac_left_we <= (ch || mono || dual);
            if (js && mode_extension[msis])
            begin
              if (msis)  // ms
              begin
                mult_in1 <= ram_dataout + req_buf;
                mult_in2 <= 16'h2d41;  // square root 2
		//mult_in2 <= 16'h2d42;  // square root 2
                //leftchannel_datain <= mult_out;
                mac_datain <= mult_out;
              end
              else  // is
              begin
                //leftchannel_datain <= req_buf;
                mac_datain <= req_buf;
              end
            end
            huffrom_address0 <= table_base;
            huffrom_address1 <= valid_base;
            decoded_sample <= 0;  // for rzero
            if (next_counter == sfb_boundary)
            begin
              if (shortblock)
              begin
                newsfb <= (window == 2) ? sfb + 1 : sfb;
              end
              else
              begin
                newsfb <= sfb + 1;
              end
            end
            ram_address <= shortblock ? {4'b1010,window,newsfb[3:0]} : {4'b1011,ch,newsfb};  // scalefac
            //ram_address <= shortblock ? {4'b1010,window,sfb[3:0]} : {5'b10110,sfb};  // scalefac
          end
          default:  // end of granule
          begin
            // dump remaining bits
            bits_processed <= (|readbits[11:4]) ? 16 : readbits[3:0];
          end
          endcase
        end
        endcase  // state
        // exception when part2_3_length is over during decoding
        if (state != `STATE_DECODE_READ_SIDEINFO && readbits[11:4] == 0 && bits_processed > readbits[3:0])
        begin
          ram_address <= shortblock ? {4'b1010,window,sfb[3:0]} : {4'b1011,ch,sfb};  // scalefac
          newreadptr <= readptr + readbits[3:0];  // dump whatever left in part2_3_length
          decoded_sample <= 0;
        end
      end
      `STAGE_POST_DECODE:
      begin
        ram_address <= 608;  // get end of frame pointer
        case (state)
        `STATE_POST_DECODE_READFRAMEEND:
        begin
          
        end
        `STATE_POST_DECODE_BYTE_ALIGN:
        begin
          // bits_processed <= |readptr[2:0];
          bits_processed <= (|readptr[2:0]) ? 1 : 0;
        end
        `STATE_POST_DECODE_FILL_BIT_RESERVOIR:
        begin
          br_datain <= data;
          brram_address <= br_write_address[11:4];
          br_we <= 1;
          if (|frameend_diff[13:4])
            //bits_processed <= 16;
            bits_processed[4] <= 1;
          else if (frameend_diff[3])
            //bits_processed <= 8;
            bits_processed[3] <= 1;
          else
            br_we <= 0;
        end
        endcase
      end
      endcase  // stage
    end // always
    
    
    
    
