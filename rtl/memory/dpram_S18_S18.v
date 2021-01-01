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


`timescale 1 ns/ 100 ps

module dpram_S18_S18(
// output from MAC
		DOA,
      ADDRA,
      CLKA,
      DIA,
      ENA,
      WEA,

		// input to AC97
      DOB,
		ADDRB,
      CLKB,
      ENB
);

parameter data_width=16,

address_width=10,

mem_depth=1024;

input [data_width-1:0] DIA;

input [address_width-1:0] ADDRA, ADDRB;

input CLKA, CLKB;

input WEA;

input ENA, ENB;

output [data_width-1:0] DOA, DOB;

reg [data_width-1:0] mem[mem_depth-1:0];

reg [address_width - 1:0] addr_reg_a, addr_reg_b;

always @(posedge CLKA)

begin
addr_reg_a <= ADDRA;

if (WEA && ENA) mem[ADDRA] <= DIA;

end

always @(posedge CLKB)

begin

addr_reg_b <= ADDRB;

end

assign DOA = (ENA == 1'b1) ? mem[addr_reg_a]: 0;

assign DOB = (ENB == 1'b1) ? mem[addr_reg_b]: 0;

endmodule 
