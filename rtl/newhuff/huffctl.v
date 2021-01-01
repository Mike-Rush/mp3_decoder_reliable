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
`include "../defines.v"

module huffctl(
/*
	skipframe4,
   skipframe,
   br_count,
   big_values,
   stage,
   state,
   step,
   counter,
   readptr,
   newreadptr,
	readbits,
   data,
   source,
   frame,
   bits_processed,
	br_update,
*/
    CLK_I,RESETN_I,
    HUFF_DONE_O, MAC_READY_I, DUAL_SELECT_I, WBBM_O, WBBML_O,
    GR_O, CH_O, NCH_O, SAMPLE_FREQUENCY_O, MODE_O, MODE_EXTENSION_O,
    RAM_ADDRESS_O, RAM_WE_O, RAM_DATAIN_O, RAM_DATAOUT_I,
    DPR_ADDRESS_O, DPR_DATAOUT_I,
    BR_ADDRESS_O, BR_DATAIN_O, BR_WE_O, BR_DATAOUT_I,
    //RIGHTCHANNEL_DATAIN_O, RIGHTCHANNEL_ADDRESS_O, RIGHTCHANNEL_WE_O,
    //LEFTCHANNEL_DATAIN_O, LEFTCHANNEL_ADDRESS_O, LEFTCHANNEL_WE_O
    MAC_DATAIN_O, MAC_ADDRESS_O, MAC_LEFT_WE_O, MAC_RIGHT_WE_O
  );
  
  // port declarations

  /*
  output skipframe4;
  output [4:0] skipframe;
  output [9:0] br_count;
  output [8:0] big_values;
  output [2:0] stage;
  output [2:0] state;
  output [2:0] step;
  output [9:0] counter;
  output [13:0] readptr;
  output [13:0] newreadptr;
  output [11:0] readbits;
  output [15:0] data;
  output source;
  output [9:0] frame;
  output [4:0] bits_processed;
  output br_update; 
  */

  input CLK_I;
  input RESETN_I;
  output HUFF_DONE_O;
  input MAC_READY_I;
  input DUAL_SELECT_I;
  output [3:0] WBBM_O;
  output [3:0] WBBML_O;
  
  output GR_O;
  output CH_O;
  output NCH_O;
  output [1:0] SAMPLE_FREQUENCY_O;
  output [1:0] MODE_O;
  output [1:0] MODE_EXTENSION_O;
  
  output [9:0] RAM_ADDRESS_O;
  output RAM_WE_O;
  output [15:0] RAM_DATAIN_O;
  input [15:0] RAM_DATAOUT_I;
  
  output [9:0] DPR_ADDRESS_O;
  input [15:0] DPR_DATAOUT_I;
  
  output [7:0] BR_ADDRESS_O;
  output [15:0] BR_DATAIN_O;
  output BR_WE_O;
  input [15:0] BR_DATAOUT_I;
  
  //output [15:0] RIGHTCHANNEL_DATAIN_O;
  //output [9:0] RIGHTCHANNEL_ADDRESS_O;
  //output RIGHTCHANNEL_WE_O;
  //output [15:0] LEFTCHANNEL_DATAIN_O;
  //output [9:0] LEFTCHANNEL_ADDRESS_O;
  //output LEFTCHANNEL_WE_O;
  output [15:0] MAC_DATAIN_O;
  output [9:0] MAC_ADDRESS_O;
  output MAC_RIGHT_WE_O;
  output MAC_LEFT_WE_O;
  
  reg huff_done;
  reg mac_timeout;
  wire mac_ready;
  wire dual_select;
  reg [3:0] WBBM;
  reg [3:0] WBBML;
  
  reg [1:0] sample_frequency;
  reg [1:0] mode;
  reg [1:0] mode_extension;
  wire mono;
  assign mono = (mode == 2'b11);
  wire nch;
  //assign nch = (mode != 2'b11);
  assign nch = !mono;
  //wire dch;
  //assign dch = (mode == 2'b10);
  wire dual;
  assign dual = (mode == 2'b10);
  wire js;
  assign js = (mode == 2'b01 && mode_extension != 2'b00);
  wire stereo;
  //assign stereo = (mode == 2'b00 || (mode == 2'b01 && mode_extension == 2'b00));
  assign stereo = (mode[1] == 0 && js == 0);
  reg ch;
  reg gr;  
  
  wire [15:0] ram_dataout;
  reg [15:0] ram_datain;
  reg [9:0] ram_address;
  reg ram_we;
  
  wire [9:0] dpr_address;
  wire [15:0] dpr_dataout;
  
  wire [7:0] br_address;
  reg [15:0] br_datain;
  reg br_we;
  wire [15:0] br_dataout;
  
  //reg [15:0] leftchannel_datain;
  //reg [9:0] leftchannel_address;
  //reg leftchannel_we;
  //reg [15:0] rightchannel_datain;
  //reg [9:0] rightchannel_address;
  //reg rightchannel_we;
  reg [15:0] mac_datain;
  reg [9:0] mac_address;
  reg mac_left_we;
  reg mac_right_we;
  
  reg [2:0] ispos;

  assign HUFF_DONE_O = huff_done;
  assign mac_ready = MAC_READY_I;
  assign dual_select = DUAL_SELECT_I;
  assign WBBM_O = WBBM;
  assign WBBML_O = WBBML;
  
  assign GR_O = gr;
  assign CH_O = ch;
  assign NCH_O = nch;
  assign SAMPLE_FREQUENCY_O = sample_frequency;
  assign MODE_O = mode;
  assign MODE_EXTENSION_O = mode_extension;

  assign RAM_ADDRESS_O = ram_address;
  assign RAM_WE_O = ram_we;
  assign RAM_DATAIN_O = ram_datain;
  assign ram_dataout = RAM_DATAOUT_I;
  
  assign DPR_ADDRESS_O = dpr_address;
  assign dpr_dataout = DPR_DATAOUT_I;
  
  assign BR_ADDRESS_O = br_address;
  assign BR_DATAIN_O = br_datain;
  assign BR_WE_O = br_we;
  assign br_dataout = BR_DATAOUT_I;
  
  //assign RIGHTCHANNEL_DATAIN_O = rightchannel_datain;
  //assign RIGHTCHANNEL_ADDRESS_O = rightchannel_address;
  //assign RIGHTCHANNEL_WE_O = rightchannel_we;
  //assign LEFTCHANNEL_DATAIN_O = leftchannel_datain;
  //assign LEFTCHANNEL_ADDRESS_O = leftchannel_address;
  //assign LEFTCHANNEL_WE_O = leftchannel_we;
  assign MAC_DATAIN_O = mac_datain;
  assign MAC_ADDRESS_O = mac_address;
  assign MAC_LEFT_WE_O = mac_left_we;
  assign MAC_RIGHT_WE_O = mac_right_we;
 
  wire [15:0] data;
  reg [13:0] readptr;
  reg [13:0] oldreadptr;
  reg [13:0] newreadptr;
  reg [4:0] bits_processed;
  reg [9:0] counter;
  reg [15:0] gpreg;
  //reg [31:0] gpreg2;
  reg source;
  reg [9:0] long_counter;
  reg [9:0] short_counter[2:0];
  
  reg [2:0] stage;
  reg [2:0] state;
  reg [2:0] step;
  reg [1:0] decodestage;
  
  reg [10:0] huffrom_address0;  // 2k x 16-bit rom
  reg [10:0] huffrom_address1;  // 2k x 16-bit rom
  wire [15:0] huffrom_dataout0;
  wire [15:0] huffrom_dataout1;
  
  reg [7:0] brram_address;
  reg [11:0] br_write_address;
  reg [9:0] br_count;
  wire br_count_is_zero;
  wire br_update;
  wire [13:0] frameend_diff;
  assign frameend_diff = `frameend - readptr;
  assign br_count_is_zero = (br_count == 0);
  
  reg msis;
  //wire msis;
  //assign msis = !(decodestage == 2 && ch == 1);  // 0 = is, 1 = ms
  
  reg [11:0] readbits;
  reg [8:0] big_values;
  reg [1:0] region;
  reg [8:0] values;
  reg [10:0] table_base;
  reg [10:0] valid_base;
  reg count1table_select;

  wire [9:0] next_counter;
  assign next_counter = counter + 1;
  wire valid_bit;
  assign valid_bit = huffrom_dataout1[{gpreg[11:9],data[15]}];
  reg [3:0] data_slen1;
  reg [2:0] data_slen2;
  always @(`slen1,`slen2,data)
  begin
    case (`slen1)
    1: data_slen1 <= {3'b000,data[15]};
    2: data_slen1 <= {2'b00,data[15:14]};
    3: data_slen1 <= {1'b0,data[15:13]};
    4: data_slen1 <= data[15:12];
    default: data_slen1 <= 4'b0000;
    endcase
    case (`slen2)
    1: data_slen2 <= {2'b00,data[15]};
    2: data_slen2 <= {1'b0,data[15:14]};
    3: data_slen2 <= data[15:13];
    default: data_slen2 <= 3'b000;
    endcase
  end
  reg [4:0] table_select;  
  always @(region,ram_dataout)
  begin
    case (region)
    0: table_select <= ram_dataout[15:11];
    1: table_select <= ram_dataout[10:6];
    2: table_select <= ram_dataout[5:1];
    default: table_select <= 0;
    endcase
  end
  
  reg [12:0] linbitsdata;
  reg sign;
  always @(`linbits,data)
  begin
    case (`linbits)
    //0: linbitsdata <= 0;
    1: begin linbitsdata <= {12'h000,data[15]}; sign <= data[14]; end
    2: begin linbitsdata <= {11'h000,data[15:14]}; sign <= data[13]; end
    3: begin linbitsdata <= {10'h000,data[15:13]}; sign <= data[12]; end
    4: begin linbitsdata <= {9'h000,data[15:12]}; sign <= data[11]; end
    5: begin linbitsdata <= {8'h00,data[15:11]}; sign <= data[10]; end
    6: begin linbitsdata <= {7'h00,data[15:10]}; sign <= data[9]; end
    7: begin linbitsdata <= {6'h00,data[15:9]}; sign <= data[8]; end
    8: begin linbitsdata <= {5'h00,data[15:8]}; sign <= data[7]; end
    9: begin linbitsdata <= {4'h0,data[15:7]}; sign <= data[6]; end
    10: begin linbitsdata <= {3'h0,data[15:6]}; sign <= data[5]; end
    11: begin linbitsdata <= {2'h0,data[15:5]}; sign <= data[4]; end
    12: begin linbitsdata <= {1'h0,data[15:4]}; sign <= data[3]; end
    13: begin linbitsdata <= data[15:3]; sign <= data[2]; end
    default: begin linbitsdata <= 0; sign <= data[15]; end
    endcase
  end // always

  // REQ DATA
  reg preflag;
  reg scalefac_scale;
  reg [8:0] subblock_gain;
  reg [7:0] global_gain;
  reg [4:0] sfb;
  reg [9:0] sfb_boundary;
  reg [5:0] sfb_width;
  reg [1:0] window;
  reg [1:0] pretab;
  reg [15:0] req_buf;
  reg [12:0] decoded_sample;
  reg decoded_sign;
  reg sfb_update;
  reg [4:0] newsfb;
  wire [4:0] nextsfb;
  assign nextsfb = sfb + 1;
    
  // REQ ROM coeffecient
  //`define DATA_WIDTH 16
  //`define ADDRESS_WIDTH 10
  wire [`DATA_WIDTH-1:0] REQ_ROM_data_out;   
  wire [`ADDRESS_WIDTH-1:0] REQ_ROM_address;
  reg [`DATA_WIDTH-1:0] mult_in1;
  reg [`DATA_WIDTH-1:0] mult_in2; 
  wire [`DATA_WIDTH-1:0] mult_out;
  //wire [`DATA_WIDTH-1:0] Req_result;
  
  wire shortblock;
  assign shortblock = (WBBM[3:1] == 3'b110 && (WBBM[0] == 0 || (WBBM[0] == 1 && (|counter[9:6] || (counter[5] == 1 && |counter[4:2])))));
  //assign shortblock = (WBBM == 4'b1100 || (WBBM == 4'b1101 && counter > 35));
  
  reg [2:0] subblock_gain_win;
  always @(subblock_gain, window)
  begin
    case (window)
    0: subblock_gain_win <= subblock_gain[8:6];
    1: subblock_gain_win <= subblock_gain[5:3];
    default: subblock_gain_win <= subblock_gain[2:0];
    endcase
  end  // always
  
wire [4:0] exp_LUT;
wire [8:0] global_gain_sub;
wire [8:0] quad_global_gain_exp;
wire [3:0] adjust_gain;
wire [5:0] quad_adjust_gain_exp;
wire [8:0] quad_gain;
wire [6:0] exp_out;
reg [3:0] exp_in;
wire [15:0] req_result;
wire [15:0] req_result_signed;
reg [6:0] is_adj;
reg [15:0] correction_factor;

wire [3:0] scalefac;
assign scalefac = ram_dataout[3:0];

assign REQ_ROM_address = (|decoded_sample[12:10]) ? decoded_sample[12:3]: decoded_sample[9:0];

assign global_gain_sub = {1'b0,global_gain[7:0]} - 9'd210;   // global_gain - 210
assign quad_global_gain_exp = shortblock ? global_gain_sub - {subblock_gain_win,3'd0} : global_gain_sub;

assign adjust_gain = (!shortblock && preflag) ? scalefac + pretab : scalefac;
assign quad_adjust_gain_exp = scalefac_scale ? {adjust_gain,2'b0} : {adjust_gain,1'b0};

assign quad_gain = quad_global_gain_exp - quad_adjust_gain_exp;
//assign exp_LUT = (|decoded_sample[12:10]) ? exp_in + 4 : exp_in;
//assign exp_LUT = exp_in + ((|decoded_sample[12:10]) ? 4 + 3 : 3);  // with exponent adjustment
// by Henry
assign exp_LUT = exp_in + ((|decoded_sample[12:10]) ? 4 : 0);  // without exponent adjustment
assign exp_out = quad_gain[8:2] + exp_LUT;

//assign req_result = |exp_out[5:4] ? 0: (exp_out[6] ? mult_out >> -exp_out[3:0] : mult_out << exp_out[3:0]);
assign req_result = (exp_out[5]==exp_out[6] && exp_out[4]==exp_out[6]) ? (exp_out[6] ? ((|exp_out[3:0]) ? mult_out >> -exp_out[3:0] : 0): mult_out << exp_out[3:0]) : 0;
assign req_result_signed = decoded_sign ? 0 - req_result : req_result;

always @(quad_gain)  // correction factor
begin
  case (quad_gain[1:0])
  0: correction_factor <= 16'h4000;
  1: correction_factor <= 16'h4C1B;
  2: correction_factor <= 16'h5A82;
  default: correction_factor <= 16'h6BA2;
  endcase
end  // always

always @(decoded_sample,exp_in)
begin
  is_adj <= 7'b0;
  if (|decoded_sample[12:10])
  begin
    case (exp_in)
    10: is_adj <= {decoded_sample[2:0],4'b0};
    11: is_adj <= {decoded_sample[2:0],3'b0};
    12: is_adj <= {decoded_sample[2:0],2'b0};
    13: is_adj <= {decoded_sample[2:0],1'b0};
    default: is_adj <= decoded_sample[2:0];  // 14
    endcase
  end
end  // always

  streamer inputstream(.clk(CLK_I), .resetn(RESETN_I), .source(source), .data(data),
    .readptr(readptr), .newreadptr(newreadptr), .oldreadptr(oldreadptr),
    .brram_address(brram_address), .br_dataout(br_dataout), .br_address(br_address),
    .dpr_address(dpr_address), .dpr_dataout(dpr_dataout),
    .br_update(br_update),.br_count_is_zero(br_count_is_zero)
  );
  huffrom huffman_rom(.clk(CLK_I),
    .addressA(huffrom_address0), .dataoutA(huffrom_dataout0),
    .addressB(huffrom_address1), .dataoutB(huffrom_dataout1)
  );
  reg [9:0] frame;
  //reg [4:0] skipframe;
  //assign skipframe4 = skipframe[4];
  
  always @(posedge CLK_I or negedge RESETN_I)
  begin
    if (RESETN_I == 0)
    begin
      stage <= `STAGE_INIT;
      state <= `STATE_INIT_RESET;
      step <= 4'd0;
      readptr <= 14'd0;
      counter <= 10'd0;
      source <= 0;
      br_write_address <= 12'd0;
      br_count <= 10'd0;
      mac_timeout <= 1;
      frame <= 0;
		//skipframe <= 0;
    end
    else
    begin
      readptr <= newreadptr;
      if (!mac_ready && !mac_timeout)
        mac_timeout <= 1;
      case (stage)
      `STAGE_INIT:
      begin
        case (state)
        `STATE_INIT_RESET:
        begin
          state <= `STATE_INIT_FILLBUF;
        end
        `STATE_INIT_FILLBUF:
        begin
          stage <= `STAGE_HEADER;
          state <= `STATE_HEADER_SYNCWORD;
        end
        endcase  // state
      end  // stage_init
      `STAGE_HEADER:
      begin
        state <= state + 1;
        counter <= counter + 1;
        case (state)
        `STATE_HEADER_SYNCWORD:
        begin
          state <= state;
          if (data[15:1] == 15'b111111111111101)  // 12-bit syncword, ID and layer 3
          begin
            //if (main_start == 1)
              //state <= `STATE_HEADER_INFO;  // if valid process remaining header
              state <= state + 1;
          end  
          gpreg[15] <= data[0];  // protection bit
          gpreg[13:0] <= readptr;
          //if (main_start == 1)
          //  main_done <= 0;
        end
        `STATE_HEADER_INFO:
        begin
          sample_frequency <= data[11:10];
          mode <= data[7:6];
          mode_extension <= data[5:4];
          counter <= 608;  // ram write pointer
          state <= `STATE_HEADER_CRC;
          //$write("mode=%d, mode_ext=%d\n",data[7:6],data[5:4]);
        end
        `STATE_HEADER_CRC:
        begin
          // skip 16-bits CRC
          //state <= `STATE_HEADER_MAIN_DATA_BEGIN;
          //counter <= counter + 1;
          frame <= frame + 1;
          $write("*************************************************************frame: %d\n",frame);
          $write("framesize: %d\n",huffrom_dataout0[11:0]);
        end
        `STATE_HEADER_MAIN_DATA_BEGIN:
        begin
          //`main_data_begin <= data[15:7];
			 big_values <= data[15:7];
          //state <= `STATE_HEADER_SCFSI;
          //counter <= counter + 1;
          $write("main_data_begin = %d, br_count = %d\n",data[15:7],br_count);
        end
        `STATE_HEADER_SCFSI:
        begin
          stage <= `STAGE_SIDEINFO;
          state <= `STATE_SIDEINFO_ADDRESS;
          ch <= 0;
          gr <= 0;
        end
        endcase  // state
      end  // stage_header
      `STAGE_SIDEINFO:
      begin
        counter <= counter + 1;
        state <= state + 1;
        case (state)
        `STATE_SIDEINFO_ADDRESS:
        begin
          counter <= {5'b10010,gr,ch,3'b000}; //576 + {gr,ch} * 8;
          //state <= `STATE_SIDEINFO_PART2_3_LENGTH;
        end
        `STATE_SIDEINFO_PART2_3_LENGTH:
        begin
          //state <= `STATE_SIDEINFO_BIG_VALUES;
          //counter <= counter + 1;
        end
        `STATE_SIDEINFO_BIG_VALUES:
        begin
          //state <= `STATE_SIDEINFO_GLOBAL_GAIN;
          //counter <= counter + 1;
        end
        `STATE_SIDEINFO_GLOBAL_GAIN:
        begin
          //state <= `STATE_SIDEINFO_BLOCK_TYPE;
          //counter <= counter + 1;
        end
        `STATE_SIDEINFO_BLOCK_TYPE:
        begin
          //state <= `STATE_SIDEINFO_TABLE_SELECT;
          //counter <= counter + 1;
          gpreg[15] <= data[15];  // WSF
          gpreg[14:12] <= data[15] ? data[14:12] : 3'b000;
        end
        `STATE_SIDEINFO_TABLE_SELECT:
        begin
          //state <= `STATE_SIDEINFO_SUBBLOCK_GAIN;
          //counter <= counter + 1;
        end
        `STATE_SIDEINFO_SUBBLOCK_GAIN:
        begin
          //state <= `STATE_SIDEINFO_REGION_COUNT;
          //counter <= counter + 1;
        end
        `STATE_SIDEINFO_REGION_COUNT:
        begin
          //counter <= counter + 1;
          if (nch == 1)
            ch <= ~ch;
          if (ch == nch)
            gr <= ~gr;
          if (gr == 1 && ch == nch)
          begin
            stage <= `STAGE_BIT_RESERVOIR_START;
            state <= 0;
          end
          //else
            //state <= `STATE_SIDEINFO_ADDRESS;
        end
        endcase // state
      end // state_sideinfo
      `STAGE_BIT_RESERVOIR_START:
      begin
        //if (`main_data_begin != 0)
		  if (big_values != 0)
        begin
          //if (`main_data_begin <= br_count && frame >= 28)  // lteq
          //if (`main_data_begin <= br_count)  // lteq
			 if ({1'b0,big_values} <= br_count)  // lteq
          begin
            state <= state + 1;
            case (state)
            //0: br_count <= `main_data_begin;
				0: br_count <= big_values;
            1:
            begin
              if (br_write_address[3] == 1)  // one of the byte is not written
              begin
                br_count <= br_count + 1;
              end
              oldreadptr <= newreadptr;
              source <= 1;  // change source to bit reservoir
            end
            2: 
            begin
              if (br_write_address[3] == 1)  // one of the byte is not written
                br_write_address <= br_write_address + 8;  // just write one byte in br
            end
            3:
            begin
              stage <= `STAGE_DECODE;
              state <= `STATE_DECODE_READ_SIDEINFO;
              step <= 0;
              br_count <= br_count - (readptr[3] ? 1 : 2);  // preread 16-bit for bit reservoir
            end
            endcase  // state
          end
          else
          begin
            // jump to bit reservoir
            stage <= `STAGE_POST_DECODE;
            state <= `STATE_POST_DECODE_READFRAMEEND;
            readbits <= 0;
            $write("skipping this frame...\n");
				//skipframe <= skipframe + 1;
          end
        end
        else
        begin
          stage <= `STAGE_DECODE;
          state <= `STATE_DECODE_READ_SIDEINFO;
          step <= 0;
        end
      end
      `STAGE_DECODE:
      begin
        // update readbits (part2_3_length)
        readbits <= readbits - bits_processed;
        // update br_count
        br_count <= br_update ? br_count - 2 : br_count;
		  //br_count <= br_count - ((br_update && !br_count_is_zero) 2 : 0);
        // when end of bit reservoir
        if (br_count_is_zero && br_update)
        begin
          readptr <= oldreadptr + newreadptr[3:0];  // restore main stream address
          source <= 0;
          br_count <= br_count;
        end
        case (state)
        `STATE_DECODE_READ_SIDEINFO:
        begin
          step <= step + 1;
          case (step[2:0])
          0:
          begin
            $write("==================decoding gr%d ch%d fr%d\n",gr,ch,frame);
            huff_done <= 0;
          end
          1:
          begin
            readbits <= ram_dataout[15:4];  // part2_3_length(12)
            //$write("RS0--part2_3_length: %d\n",ram_dataout[15:4]);
          end
          2:
          begin
            big_values <= ram_dataout[15:7];  // big_values(9)
            //$write("RS1--big_values: %d\n",ram_dataout[15:7]);
          end
          3:
          begin
            global_gain <= ram_dataout[15:8];
          end
          4:
          begin
            WBBM <= ram_dataout[15:12];  // WSF(1), block_type(2), MBF(1)
            `slen1 <= huffrom_dataout0[10:8];  // slen1(3)
            `slen2 <= huffrom_dataout0[1:0];  // slen2(2)
            //$write("slen1,2: %d, %d\n",huffrom_dataout0[10:8],huffrom_dataout0[1:0]);
          end
          5:
          begin
            // read table_select
          end
          6:
          begin
            subblock_gain <= ram_dataout[15:7];
          end
          7:
          begin
            preflag <= ram_dataout[3];
            scalefac_scale <= ram_dataout[2];
            count1table_select <= ram_dataout[1];
            // jump to end of granule if dual channel and 
            //   the current channel is not the selected channel
            if (dual && dual_select != ch)
            begin
              state <= `STATE_DECODE_REQ_STEREO;
              step <= 3;
            end
            else
              state <= `STATE_DECODE_SCALEFAC;
          end
          endcase  // step
        end
        `STATE_DECODE_SCALEFAC:
        begin
          step <= step + 1;
          case (step[2:0])
          0:
          begin
            if (!ch || dual)
              WBBML <= WBBM;
            region <= 0;
            counter <= 0;
            gpreg[3:0] <= (ch == 0) ? ram_dataout[15:12] : ram_dataout[11:8];  // scfsi
            //$write("scfsi: %b\n",((ch == 0) ? ram_dataout[15:12] : ram_dataout[11:8]));
            if (WBBM[3:1] == 3'b110)  // WSF == 1 && block_type == 2
              step <= WBBM[0] ? 1 : 2;
            else
              step <= 3;
          end
          1:  // long - mixed
          begin
            counter <= (counter != 7) ? counter + 1 : 3;
            step <= (counter != 7) ? step : step + 1;
          end
          2:  // short
          begin
            region <= (region != 2) ? region + 1 : 0;  // window
            counter <= (region != 2) ? counter : counter + 1;
            step <= (counter != 11 || region != 2) ? step : 4;
          end
          3:  // long
          begin
            counter <= counter + 1;
            step <= step;
            case (counter[4:0])
            0,1,2,3,4,5:
              if (gr == 0 || gpreg[3] == 0)  // scfsi[0]
                ;
              else
                counter <= 6;
            6,7,8,9,10:
              if (gr == 0 || gpreg[2] == 0)  // scfsi[1]
                ;
              else
                counter <= 11;
            11,12,13,14,15:
              if (gr == 0 || gpreg[1] == 0)  // scfsi[2]
                ;
              else
                counter <= 16;
            16,17,18,19,20:
            begin
              //if (frame == 53)
              //  $write("gr=%d gpreg=%b counter=%d ram_address=%d\n",gr,gpreg[3:0],counter[4:0],ram_address);
              if (gr == 0 || gpreg[0] == 0)  // scfsi[3]
                ;
              else
                step <= step + 1;
            end
            default:
              step <= step + 1;
            endcase
          end
          // step4-6 prepare region1,2start
          // region1start at gpreg[8:0]
          // region2start at ram[608 + 3]
          4:
          begin
            if ((js || stereo) && !ch)  // no mac ram writing
              step <= step + 1;
            else if (mac_ready && mac_timeout)  // mac ram is ready for writing
            begin
              mac_timeout <= 0;
              step <= step + 1;
            end
            else  // hold here until mac ram is ready
              step <= step;
          end
          5:
          begin
            //$write("region0count: %d\n", ram_dataout[13:10]);
            //$write("region1count: %d\n", ram_dataout[6:4]);
            //$write("huffrom_address0: %d\n", huffrom_address0);
            //$write("huffrom_address1: %d\n", huffrom_address1);
          end
          6:
          begin
            gpreg[8:0] <= (gpreg[15:13] == 3'b110) ? 18 : huffrom_dataout0[9:1];
          end
          7:
          begin
            //$write("region1_start: %d\n", gpreg[8:0]*2);
            //$write("region2_start: %d\n", ram_dataout*2);
            state <= `STATE_DECODE_PART3;
            counter <= 0;
            long_counter <= 0;
            short_counter[0] <= 0;
            short_counter[1] <= 8;
            short_counter[2] <= 16;
          end
          endcase  // step
        end
        `STATE_DECODE_PART3:
        begin
          step <= step + 1;
          case (step[2:0])
          0:  // big_values samples decoding
          begin
            decodestage <= 0;  // big_values
            if (region == 0)
            begin
              sfb <= 5'd0;
              sfb_boundary <= 10'd4;
              sfb_width <= 6'd4;
              window <= 2'd0;
              pretab <= 2'd0;
            end
            if (big_values == 0)
              step <= 5;  // go to count1
          end
          1:
          begin
          end
          2:
          begin
            // region0 is set initially
            case (region)
            1: gpreg[8:0] <= ram_dataout[8:0];  // region1
            2: gpreg[8:0] <= 288;  // all remaining samples - region2
            endcase
            table_base <= huffrom_dataout0[10:0];
            valid_base <= huffrom_dataout1[10:0];
            `linbits <= huffrom_dataout0[15:12];
            //$write("table_base: %h\n", huffrom_dataout0[10:0]);
            //$write("valid_base: %h\n", huffrom_dataout1[10:0]);
            //$write("linbits: %h\n", huffrom_dataout0[15:12]);
            `voffset <= 0;
            values <= 0;
            if (huffrom_dataout0[3:0] == 0) // table_select == 0
              step <= 4;
          end
          3:
          begin
            if (valid_bit == 1)
              // end of codeword
              values[7:0] <= data[15] ? huffrom_dataout0[15:8] : huffrom_dataout0[7:0];
            else
            begin
              // update validbit offet
              `voffset <= data[15] ? huffrom_dataout0[10:8] : huffrom_dataout0[2:0];
              // redo this step until valid_bit == 1
              step <= step;
            end
          end
          4:
          begin
            values[7:4] <= values[3:0];
            `voffset <= 0;
            req_buf <= {decoded_sign,2'b00,decoded_sample};
            state <= `STATE_DECODE_REQ_STEREO;
            step <= 0;
          end
          5:  // count1 samples decoding
          begin
            decodestage <= 1;  // count1
            table_base <= 1456;
            valid_base <= 1364;
            `voffset <= 0;
            values <= 0;
            region <= 3;
            //$write("count1table_select: %d\n", count1table_select);
          end
          6:
          begin
            if (count1table_select == 0)  // A
            begin
              if (valid_bit == 1)
                // end of codeword
                values[3:0] <= data[15] ? huffrom_dataout0[11:8] : huffrom_dataout0[3:0];
              else
              begin
                // update validbit offet
                `voffset <= data[15] ? huffrom_dataout0[10:8] : huffrom_dataout0[2:0];
                // redo this step until valid_bit == 1
                step <= step;
              end
            end
            else  // B
              values[3:0] <= ~data[15:12];
          end
          7:
          begin
            `voffset <= 0;
            req_buf <= {decoded_sign,2'b00,decoded_sample};
            state <= `STATE_DECODE_REQ_STEREO;
            step <= 0;
          end
          endcase
          //
        end
        `STATE_DECODE_REQ_STEREO:
        begin
          step <= step + 1;
          case (step[2:0])
          0:  // deq
          begin
            //if (mode[0] == 1'b0 && ch == nch)  // stereo or joint stereo
            //$write("stereo=%d js=%d ch=%d    \n",stereo,js,ch);
            //req_buf <= (decodestage == 2) ? 0 : req_result_signed;
            req_buf <= req_result_signed;
            if ((stereo | js) && (ch == 1))
              ;  
            else  // dual or mono or first channel of stereo or joint stereo
              step <= 2;
            ispos <= scalefac[2:0];
            //assign msis = !(decodestage == 2 && ch == 1);  // 0 = is, 1 = ms
            if (sfb_update)
              msis <= !(decodestage == 2 && ch == 1);  // 0 = is, 1 = ms
            //if (counter == 62)
              //$write("scalefac: %d\n",scalefac);
              
            //  $write("%d: sfb=%d\n",counter,sfb);
              //  $write("preflag,pretab,scalefac_scale: %d %d %d\n",preflag,pretab,scalefac_scale);
              /*
              if (counter == 172)
              begin
              $write("shortblock?: %d\n", shortblock);
              $write("counter,sfb,sfb_boundary,sfb_width,window: %d %d %d %d %d\n", counter, sfb, sfb_boundary, sfb_width, window);
              $write("huffrom_address0: %x\n",huffrom_address0);
              $write("REQ_ROM_address: %d\n",REQ_ROM_address);
              $write("global_gain_sub: %d\n",global_gain_sub);
              $write("subblock_gain_win: %d\n",subblock_gain_win);
              $write("adjust_gain: %d\n",adjust_gain);
              $write("scalefac: %d\n",scalefac);
              $write("preflag,pretab,scalefac_scale: %d %d %d\n",preflag,pretab,scalefac_scale);
              
              $write("quad_adjust_gain_exp: %d\n",quad_adjust_gain_exp);
              $write("quad_gain: %d\n",quad_gain);
              $write("exp_LUT,exp_out: %d %d\n",exp_LUT,exp_out);
              
              $write("REQ_ROM_data_out,is_adj: %d %d\n",REQ_ROM_data_out,is_adj);
              $write("mult_in1, mult_in2, mult_out: %x %x %x\n",mult_in1,mult_in2,mult_out);
              $write("exp_out: %d\n",exp_out);
              //if (!(req_result == 0 && req_result_signed == 0))
              //begin
              $write("req_result: %d\n",req_result);
              $write("req_result_signed: %d\n",req_result_signed);
              //end
              //$stop;
              end
              */
//               $write("stereo=%d,ram_we=%d,ram_datain=%x\n",stereo,ram_we,ram_datain);
          end
          1:  // ms/is right processing
          begin
            // save left channel into buffer(req_buf) for is
            if (js && mode_extension[msis])
            //if (stereo)
            begin
              if (msis)  // ms
                ;
              else  // is
              begin
                case (ispos)
                0:   req_buf <= 16'h0000;
                1,2: req_buf <= ram_dataout - mult_out;
                3:   req_buf <= {ram_dataout[15],ram_dataout[15:1]};
                4,5: req_buf <= mult_out;
                default: req_buf <= ram_dataout;
                endcase
              end
            end
          end
          2:  // ms/is left processing
          begin
            // update sfb and pretab if reaching boundary
            sfb_update <= 0;
            if (next_counter == sfb_boundary)
            begin
              if (shortblock)
              begin
                sfb_boundary <= sfb_boundary + sfb_width;
                sfb_width <= (window == 1) ? huffrom_dataout0[13:8] : sfb_width;
                sfb <= (window == 2) ? sfb + 1: sfb;
                window <= (window == 2) ? 0 : window + 1;
                sfb_update <= (window == 2);
              end
              else
              begin
                sfb <= sfb + 1;
                sfb_boundary <= huffrom_dataout0[9:0];
                pretab <= huffrom_dataout0[13:12];
                sfb_update <= 1;
              end
            end
            // increase write counter for long block
            long_counter <= long_counter + ((long_counter[3:0] == 8) ? 8 : 1);
            // increase write counter for short block
            short_counter[window] <= short_counter[window] + ((short_counter[window][2:0] == 5) ? 27 : 1);
            if (next_counter == 36 && WBBM == 4'b1101)  // mixed block
            begin
              short_counter[0] <= 64;
              short_counter[1] <= 72;
              short_counter[2] <= 80;
            end
            // increase counter
            counter <= counter + 1;
            // jump back to decode
            case (decodestage)
            0:  // big_values
            begin
              //$write("%d: %d %d\n",counter,ram_dataout[15],ram_dataout[13:0]);
              values[8] <= ~values[8];
              state <= `STATE_DECODE_PART3;
              if (big_values == next_counter[9:1])  // reach big_values
              begin
                step <= 5;
                $write("...end of big_values decoding\n");
              end
              else if (gpreg[8:0] == next_counter[9:1])  // reach region boundary
              begin
                step <= 0;
                region <= region + 1;
              end
              else
                step <= (values[8] && |table_base[3:0]) ? 3 : 4;
            end
            1:  // count1
            begin
              //$write("%d: %d %d\n",counter,ram_dataout[15],ram_dataout[0]);
              region <= region - 1;
              if (counter[9:2] == 143 && region == 0)
              begin
                $write("... end of count1 decoding\n");
                req_buf <= 0;
                step <= 0;
              end
              else
              begin
                state <= `STATE_DECODE_PART3;
                step <= (region == 0) ? 6 : 7;
              end
            end
            default:  // rzero
            begin
              // cannot read correct scalefac because ram busy
              // but since sample = 0 requ_result is always 0
              //$write("%d: 0\n",counter);
              req_buf <= 0;
              step <= 0;
            end
            endcase  // decodestage
            // if 576 samples are decoded, it's end of granule
            if (next_counter == 576)
            begin
              state <= `STATE_DECODE_REQ_STEREO;
              step <= 3;
            end
          end
          default:  // end of granule
          begin
            step <= step;
            if (!(|readbits[11:4]))  // < 16
            begin
              $write("... end of granule\n");
              if (nch == 1)
                ch <= ~ch;
              if (ch == nch)
                gr <= ~gr;
              if (gr == 1 && ch == nch)
              begin
                stage <= `STAGE_POST_DECODE;
                state <= `STATE_POST_DECODE_READFRAMEEND;
              end
              else
              begin
                state <= `STATE_DECODE_READ_SIDEINFO;
              end
              if (ch == nch)
                huff_done <= 1;
              step <= 0;
              counter <= 0;
              region <= 0;
            end
            readbits <= readbits - bits_processed;
          end
          endcase  // step
        end
        endcase  // state
        // exception when part2_3_length is over during decoding
        if (state != `STATE_DECODE_READ_SIDEINFO && readbits[11:4] == 0 && bits_processed > readbits[3:0])
        begin
          readptr <= readptr + readbits[3:0];  // dump whatever left in part2_3_length
          readbits <= 0;
          state <= `STATE_DECODE_REQ_STEREO;
          step <= 0;
          decodestage <= 2;
          req_buf <= 0;
          $write("...end of part2_3_length\n");
        end
        //exception when mac unit is busy before decoding is done
        //if ((state == `STATE_DECODE_PART3 || state == `STATE_DECODE_REQ_STEREO) && mac_timeout)
        //begin
        //  state <= `STATE_DECODE_REQ_STEREO;
        //  step <= 3;
        //end
      end
      `STAGE_POST_DECODE:
      begin
        if (source == 1)
        begin
          br_count <= br_count + (|readptr[2:0] ? (readptr[3] ? 0 : 1) : (readptr[3] ? 1 : 2));  // restore loaded word in br
          /*
          if (readptr[3:0] == 4'b0000)
            br_count <= br_count + 2;
          else if (readptr[3:0] <= 4'd8)//(readptr[3] && |readptr[2:0])
            br_count <= br_count + 1;
          else
            br_count <= br_count;
          */
          readptr <= oldreadptr;
          source <= 0;
        end
        case (state)
        `STATE_POST_DECODE_READFRAMEEND:
        begin
          if (source == 1)
          begin
            br_count <= br_count + (|readptr[2:0] ? (readptr[3] ? 0 : 1) : (readptr[3] ? 1 : 2));  // restore loaded word in br
            readptr <= oldreadptr;
          end
          source <= 0;
          huff_done <= 0;
          state <= state + 1;
        end
        `STATE_POST_DECODE_BYTE_ALIGN:
        begin
          //state <= state + |readptr[2:0];
          state <= (|readptr[2:0]) ? state : state + 1;
          // get end of frame pointer
          `frameend <= ram_dataout[13:0];
        end
        `STATE_POST_DECODE_FILL_BIT_RESERVOIR:
        begin
          if (|frameend_diff[13:4])
          begin
            br_count <= (br_count == 510 || br_count == 511) ? 511 : br_count + 2;
            br_write_address <= br_write_address + 16;
          end
          else if (frameend_diff[3])
          begin
            br_count <= (br_count == 511) ? 511 : br_count + 1;
            br_write_address <= br_write_address + 8;
          end
          else
          begin
            // next frame
            stage <= `STAGE_HEADER;
            state <= `STATE_HEADER_SYNCWORD;
            //main_done <= 1;
          end
        end
        endcase  // state
      end
      endcase  // stage
    end  // if resetn
  end  // always
  
  `include "./huffctl_comb.v"
    
// Instantiate Mult_Requan module
Mult_Requan Mult_Requan_module (
    .data_a(mult_in1), 
    .data_b(mult_in2), 
    .mult_out(mult_out)
    );

// Instantiate Requantizer_coefficient ROM
requantizer_coefficient instance_REQ_ROM (
    .clock(CLK_I), 
    .mem_en(1'b1),  
    .address(REQ_ROM_address), 
    .data_out(REQ_ROM_data_out)
    );

/*
////////////////////////////////////////////////////////////////////////////////////////
// LUT for the exponents associated with each value in Requan_ROM 
always @(REQ_ROM_address)
begin
  exp_in <= 5'h00;
//  if(state ==`State_ROM_Addr_comp)begin
    if (REQ_ROM_address >= 0 && REQ_ROM_address < 2 )begin
        exp_in <= 5'h00;
    end
    if (REQ_ROM_address == 2)begin
        exp_in <= 5'h02;
    end
    if (REQ_ROM_address >= 3 && REQ_ROM_address < 5 )begin
        exp_in <= 5'h03;
    end
    if (REQ_ROM_address >= 5 && REQ_ROM_address < 9 )begin
        exp_in <= 5'h04;
    end
    if (REQ_ROM_address >= 9 && REQ_ROM_address < 14 )begin
        exp_in <= 5'h05;
    end
    if (REQ_ROM_address >= 14 && REQ_ROM_address < 23 )begin
        exp_in <= 5'h06;
    end
    if (REQ_ROM_address >= 23 && REQ_ROM_address < 39 )begin
        exp_in <= 5'h07;
    end
    if (REQ_ROM_address >= 39 && REQ_ROM_address < 65 )begin
        exp_in <= 5'h08;
    end
    if (REQ_ROM_address >= 65 && REQ_ROM_address < 108 )begin
        exp_in <= 5'h09;
    end
    if (REQ_ROM_address >= 108 && REQ_ROM_address < 182 )begin
        exp_in <= 5'h0A;
    end
    if (REQ_ROM_address >= 182 && REQ_ROM_address < 305 )begin
        exp_in <= 5'h0B;
    end
    if (REQ_ROM_address >= 305 && REQ_ROM_address < 513 )begin
        exp_in <= 5'h0C;
    end
    if (REQ_ROM_address >= 513 && REQ_ROM_address < 862 )begin
        exp_in <= 5'h0D;
    end
    if (REQ_ROM_address >= 862 && REQ_ROM_address < 1024 )begin
        exp_in <= 5'h0E;
    end
//  end
end
*/
    

// need to change REQ_ROM item 1(4000->1000),8(4000->2000),64(4000->2000),512(4001->2000) before activate this code

wire [9:0] R;
reg [3:0] e;
assign R = REQ_ROM_address;

always @(R,e)
begin
  exp_in <= e;  
  if (R[9] == 0)
  begin
    case (R[8:6])
    3'b000:
    begin
      case (R[5:3])
      3'b000:
      begin
        case (R[2:0])
        0,1,2: e <= 2;    // 0-2 = 2
        3,4:   e <= 3;    // 3-4 = 3
        default: e <= 4;  // 5-7 = 4
        endcase
      end
      3'b001: if (&R[2:1]) e <= 6; else e <= 5;  //  8-13 = 5, 14-15 = 6
      3'b010: if (&R[2:0]) e <= 7; else e <= 6;  // 16-22 = 6,    23 = 7
      3'b011: e <= 7;                            // 24-31 = 7
      3'b100: if (&R[2:0]) e <= 8; else e <= 7;  // 32-39 = 7,    40 = 8
      default: e <= 8;                           // 41-63 = 8
      endcase
    end
    3'b001: if (R[5:2] == 4'b1011 || &R[5:4]) e <= 10; else e <= 9;    //  64-107 =  9, 108-127 = 10
    3'b010: if (R[5:1] == 5'b11011 || &R[5:3]) e <= 11; else e <= 10;  // 128-181 = 10, 182-191 = 11
    3'b011: e <= 11;                                                   // 192-255 = 11
    3'b100: if (&R[5:4] && |R[3:0]) e <= 12; else e <= 11;             // 256-304 = 11, 305-319 = 12
    default: e <= 12;                                                  // 320-511 = 12
    endcase
  end
  else
  begin
    case (R[8:6])
    0,1,2,3,4: e <= 13;                             // 512-831 = 13
    5: if (R[5] || &R[4:1]) e <= 14; else e <= 13;  // 832-861 = 13 , 862-895 = 14
    default: e <= 14;                               // 896-1023 = 14
    endcase
  end
end // always

endmodule
