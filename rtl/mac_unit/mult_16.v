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


`timescale 1 ns / 100 ps

`include "defines.v"

module mult_16(data_a, data_b, mult_out);

//--------------Input Ports----------------------- 
input [`DATA_WIDTH-1:0]  data_a, data_b ;

//--------------Output Ports-----------------------
output [`DATA_WIDTH-1:0]  mult_out;

//wires
wire [17:0] mult_in_a;
wire [17:0] mult_in_b;
wire [35:0] mult_result;

assign mult_in_a = {data_a[15], data_a[15], data_a};
assign mult_in_b = {data_b[15], data_b[15], data_b};

assign mult_out[`DATA_WIDTH-1:0]= mult_result [29:14];

MULT18X18 mac_multiplier(.P(mult_result),.A(mult_in_a), .B(mult_in_b));

endmodule
