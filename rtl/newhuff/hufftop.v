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

module hufftop(CLK_I,RESETN_I);
  input CLK_I;
  input RESETN_I;
  
  wire huff_done;
  reg mac_ready;
  wire [3:0] WBBM;
  wire [3:0] WBBML;
  
  wire gr;
  wire ch;
  wire nch;
  wire [1:0] sample_frequency;
  wire [1:0] mode;
  wire [1:0] mode_extension;
  
  wire [15:0] ram_dataout;
  wire [15:0] ram_datain;
  wire [9:0] ram_address;
  wire ram_en;
  wire ram_we;
  
  wire [9:0] dpr_address;
  wire [15:0] dpr_dataout;
  wire [14:0] dpw_address;
  wire [15:0] dpw_datain;
  wire dpw_we;
  wire dpw_en;
  
  wire [7:0] br_address;
  wire [15:0] br_datain;
  wire br_we;
  wire [15:0] br_dataout;
    
  //wire [15:0] leftchannel_datain;
  //wire [9:0] leftchannel_address;
  //wire leftchannel_we;
  //wire [15:0] rightchannel_datain;
  //wire [9:0] rightchannel_address;
  //wire rightchannel_we;
  wire [15:0] mac_datain;
  wire [9:0] mac_address;
  wire mac_left_we;
  wire mac_right_we;
  
  reg memfill_start;
  wire memfill_done;
  
  reg dpr_address9_buf;
  reg HUF_resetn;
  
  reg [3:0] state;
  reg [9:0] counter;
  
  /*
  always @(posedge CLK_I or negedge RESETN_I)
  begin
    if (RESETN_I == 0)
    begin
      state <= 0;
      HUF_resetn <= 0;
    end
    else
    begin
      main_start <= 1;
      HUF_resetn <= 1;
    end
  end  // always
  */
    
  always @(posedge CLK_I or negedge RESETN_I)
  begin
    if (RESETN_I == 0)
    begin
      state <= 0;
      HUF_resetn <= 0;
      mac_ready <= 0;
    end
    else
    begin
      case (state)
        0:
        begin
          counter <= 0;
          state <= 1;
        end
        1:
        begin
          memfill_start <= 1;
          if (counter[2:0] == 3)
          begin
            state <= 2;
            counter[2:0] <= 0;
          end
          else
            counter[2:0] <= counter[2:0] + 1;
        end
        2:
        begin
          memfill_start <= 0;
          if (memfill_done == 1)
          begin
            if (counter[3] == 1)
              state <= 3;
            else
              state <= 1;  // do it twice to fill whole ram
            counter[3] <= ~counter[3];
          end
        end
        3:
        begin
          HUF_resetn <= 1;
          //counter <= 0;
          memfill_start <= (dpr_address9_buf != dpr_address[9]);
          if (huff_done == 1)
          begin
            mac_ready <= 0;
            counter <= 0;
          end
          if (mac_ready == 0)
            counter <= counter + 1;
          if (counter == 20)
            mac_ready <= 1;
        end
      endcase
      dpr_address9_buf <= dpr_address[9];
    end
  end // always
    
    
  huffctl HUFFMANDECODER (
    .CLK_I(CLK_I),
    .RESETN_I(HUF_resetn),
    
    .HUFF_DONE_O(huff_done),
    .MAC_READY_I(mac_ready),
    .DUAL_SELECT_I(1'b0),
    .WBBM_O(WBBM),
    .WBBML_O(WBBML),
    
    .GR_O(gr),
    .CH_O(ch),
    .NCH_O(nch),
    .SAMPLE_FREQUENCY_O(sample_frequency),
    .MODE_O(mode),
    .MODE_EXTENSION_O(mode_extension),
    
    .RAM_ADDRESS_O(ram_address),
    .RAM_WE_O(ram_we),
    .RAM_DATAIN_O(ram_datain),
    .RAM_DATAOUT_I(ram_dataout),
    
    .DPR_ADDRESS_O(dpr_address),
    .DPR_DATAOUT_I(dpr_dataout),
    
    .BR_ADDRESS_O(br_address),
    .BR_DATAIN_O(br_datain),
    .BR_WE_O(br_we),
    .BR_DATAOUT_I(br_dataout),
    
    //.RIGHTCHANNEL_DATAIN_O(rightchannel_datain),
    //.RIGHTCHANNEL_ADDRESS_O(rightchannel_address),
    //.RIGHTCHANNEL_WE_O(rightchannel_we),
    //.LEFTCHANNEL_DATAIN_O(leftchannel_datain),
    //.LEFTCHANNEL_ADDRESS_O(leftchannel_address),
    //.LEFTCHANNEL_WE_O(leftchannel_we)
    .MAC_DATAIN_O(mac_datain),
    .MAC_ADDRESS_O(mac_address),
    .MAC_LEFT_WE_O(mac_left_we),
    .MAC_RIGHT_WE_O(mac_right_we)
  );
  /*
  RAMB16_S18 ram0(
    .DO(ram_dataout),
    .DOP(),
    .ADDR(ram_address),
    .CLK(CLK_I),
    .DI(ram_datain),
    .DIP(2'b00),
    //.EN(ram0_en),
    .EN(1'b1),
    .SSR(1'b0),
    .WE(ram_we)
  );
  */
  RAMB16_S18_S18 req_ram(
    .DOA(ram_dataout),
    .DOB(br_dataout),
    .DOPA(),
    .DOPB(),
    .ADDRA(ram_address),
    .ADDRB({2'b11,br_address}),
    .CLKA(CLK_I),
    .CLKB(CLK_I),
    .DIA(ram_datain),
    .DIB(br_datain),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(ram_we),
    .WEB(br_we)
  );
  
  RAMB16_S18_S18 dpram(
    .DOA(dpr_dataout),
    .DOB(),
    .DOPA(),
    .DOPB(),
    .ADDRA(dpr_address),
    .ADDRB(dpw_address[9:0]),
    //.ADDRB(10'h0),
    .CLKA(CLK_I),
    .CLKB(CLK_I),
    .DIA(16'h0),
    .DIB(dpw_datain),
    //.DIB(16'h0),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(dpw_en),
    //.ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(1'b0),
    .WEB(dpw_we)
    //.WEB(1'b0)
  );
  
  memctl32 memfill(
    .CLOCK_I(CLK_I),
    .RESETN_I(RESETN_I),
    .START_I(memfill_start),
    .ADDRESS_O(dpw_address),
    .DATA_O(dpw_datain),
    .WE_O(dpw_we),
    .EN_O(dpw_en),
    .DONE_O(memfill_done)
  );

endmodule


module RAMB16_S18(DO,DOP,ADDR,CLK,DI,DIP,EN,SSR,WE);    // synthesis syn_black_box
  output [15:0] DO;
  output [1:0] DOP;
  input [9:0] ADDR;
  input CLK;
  input [15:0] DI;
  input [1:0] DIP;
  input EN;
  input SSR;
  input WE;
endmodule

module RAMB16_S18_S18(DOA,DOB,DOPA,DOPB,ADDRA,ADDRB,CLKA,CLKB,
  DIA,DIB,DIPA,DIPB,ENA,ENB,SSRA,SSRB,WEA,WEB);    // synthesis syn_black_box
  output [15:0] DOA;
  output [15:0] DOB;
  output [1:0] DOPA;
  output [1:0] DOPB;
  input [9:0] ADDRA;
  input [9:0] ADDRB;
  input CLKA;
  input CLKB;
  input [15:0] DIA;
  input [15:0] DIB;
  input [1:0] DIPA;
  input [1:0] DIPB;
  input ENA;
  input ENB;
  input SSRA;
  input SSRB;
  input WEA;
  input WEB;
endmodule
