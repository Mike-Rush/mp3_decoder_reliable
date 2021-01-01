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

module streamer(clk,resetn,source,data,
 readptr,newreadptr,oldreadptr,
 brram_address,br_dataout,br_address,
 dpr_address,dpr_dataout,
 br_update,br_count_is_zero
);
  input clk;
  input resetn;
  input source;  // 0 = main stream, 1 = bit reservoir
  output [15:0] data;
  input [13:0] readptr;
  input [13:0] newreadptr;
  input [13:0] oldreadptr;
  
  input [7:0] brram_address;
  
  input [15:0] br_dataout;
  output [7:0] br_address;
  
  output [9:0] dpr_address;
  input [15:0] dpr_dataout;

  output br_update;
  input br_count_is_zero;

  wire [15:0] ms_dataout;
  wire [15:0] br_dataout;
  reg [15:0] ms_data;
  reg [15:0] br_data;
  reg [15:0] data;
  wire [31:0] ms_databuf;
  wire [31:0] br_databuf;
  reg [15:0] ms_buffer;
  reg [15:0] br_buffer;
  reg [13:0] ms_newreadptr;
  //reg [13:0] ms_oldreadptr;
  reg [13:0] ms_readptr;
  reg [13:0] br_newreadptr;
  //reg [13:0] br_oldreadptr;
  reg [13:0] br_readptr;
  
  reg ms_readptr4_buf;
  reg br_readptr4_buf;
  
  wire br_update;  // for updating br_count
  assign br_update = (source == 1 && (br_newreadptr[4] != br_readptr4_buf));
  
  //assign brram_dataout = br_dataout;
  
  assign ms_databuf = {ms_buffer,ms_dataout};
  //assign br_readptr = readptr;
  
  assign br_databuf = {br_buffer,((source && br_count_is_zero) ? ms_data : br_dataout)};
  
    
  always @(source, readptr, newreadptr, oldreadptr, ms_data, br_data,brram_address)
  begin
    if (source == 0)
    begin
      ms_readptr <= readptr;
      ms_newreadptr <= newreadptr;
      br_readptr <= 0;
      br_newreadptr <= {2'b00,brram_address,4'b0000};
      data <= ms_data;
    end
    else
    begin
      ms_readptr <= oldreadptr;
      ms_newreadptr <= oldreadptr;
      br_readptr <= readptr;
      br_newreadptr <= {2'h0,newreadptr[11:0]};
      data <= br_data;
    end
  end  // always
  
  assign dpr_address = ms_newreadptr[13:4];
  assign ms_dataout = dpr_dataout;
  
  assign br_address = br_newreadptr[11:4];
  //mp3file testram(.clk(clk), .address(ms_newreadptr[13:4]), .dataout(ms_dataout));
  //bitreversoir testbr(.clk(clk), .address(br_newreadptr[13:4]), .dataout(br_dataout));
  /*
  // Bit Reversoir
  RAMB16_S18 brram(
    .DO(br_dataout),
    .DOP(),
    .ADDR(br_newreadptr[13:4]),
    .CLK(clk),
    .DI(brram_datain),
    .DIP(2'b00),
    .EN(1'b1),
    .SSR(1'b0),
    .WE(brram_we)
  );
  */
  always @(ms_readptr,ms_databuf,ms_readptr4_buf)
  begin
    case (ms_readptr[3:0])
    0:
    begin
      if (ms_readptr[4] != ms_readptr4_buf)
        ms_data <= ms_databuf[15:0];
      else
        ms_data <= ms_databuf[31:16];
    end
    1: ms_data <= ms_databuf[30:15];
    2: ms_data <= ms_databuf[29:14];
    3: ms_data <= ms_databuf[28:13];
    4: ms_data <= ms_databuf[27:12];
    5: ms_data <= ms_databuf[26:11];
    6: ms_data <= ms_databuf[25:10];
    7: ms_data <= ms_databuf[24:9];
    8: ms_data <= ms_databuf[23:8];
    9: ms_data <= ms_databuf[22:7];
    10: ms_data <= ms_databuf[21:6];
    11: ms_data <= ms_databuf[20:5];
    12: ms_data <= ms_databuf[19:4];
    13: ms_data <= ms_databuf[18:3];
    14: ms_data <= ms_databuf[17:2];
    15: ms_data <= ms_databuf[16:1];
    endcase  
  end
  
  always @(br_readptr,br_databuf,br_readptr4_buf)
  begin
    case (br_readptr[3:0])
    0:
    begin
      if (br_readptr[4] != br_readptr4_buf)
        br_data <= br_databuf[15:0];
      else
        br_data <= br_databuf[31:16];
    end
    1: br_data <= br_databuf[30:15];
    2: br_data <= br_databuf[29:14];
    3: br_data <= br_databuf[28:13];
    4: br_data <= br_databuf[27:12];
    5: br_data <= br_databuf[26:11];
    6: br_data <= br_databuf[25:10];
    7: br_data <= br_databuf[24:9];
    8: br_data <= br_databuf[23:8];
    9: br_data <= br_databuf[22:7];
    10: br_data <= br_databuf[21:6];
    11: br_data <= br_databuf[20:5];
    12: br_data <= br_databuf[19:4];
    13: br_data <= br_databuf[18:3];
    14: br_data <= br_databuf[17:2];
    15: br_data <= br_databuf[16:1];
    endcase  
  end
  
  always @(posedge clk or negedge resetn)
  begin
    if (resetn == 0)
    begin
      ms_readptr4_buf <= 0;
      br_readptr4_buf <= 0;
      ms_buffer <= 0;
      br_buffer <= 0;
    end
    else
    begin
      if (source == 0)
      begin
        if (ms_newreadptr[4] != ms_readptr4_buf)  // out of buffer, read 16-bit data
        begin  // also means address is updated
          ms_readptr4_buf <= ms_newreadptr[4];  // update out of buffer indicator
          //databuf[31:16] <= databuf[15:0];  // shift the data to the data buffer
          ms_buffer <= ms_dataout;  // read new data
        end
      end
      else
      begin
        if (br_newreadptr[4] != br_readptr4_buf)  // out of buffer, read 16-bit data
        begin  // also means address is updated
          br_readptr4_buf <= br_newreadptr[4];  // update out of buffer indicator
          //databuf[31:16] <= databuf[15:0];  // shift the data to the data buffer
          br_buffer <= br_dataout;  // read new data
        end
      end
    end  // if resetn
  end // always
  

endmodule
