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

`include "defines.v"

module mult_accum(clock, resetn, control, data_a, data_b, acc_out);

//--------------Input Ports----------------------- 
input clock, resetn;
input [1:0] control;
input [`DATA_WIDTH-1:0]  data_a, data_b;

//--------------Output Ports-----------------------
output [`DATA_WIDTH-1:0]  acc_out;

//--------------Internal signals---------------- 
wire [`DATA_WIDTH-1:0] mult_out, add_in1, add_in2;

// Instantiate the module
mult_16 mult16_module (
    .data_a(data_a), 
    .data_b(data_b), 
    .mult_out(mult_out)
    );

assign add_in1 = acc_out;
assign add_in2 = mult_out;

add_accum add_accum_module  (
    .clock(clock), 
    .resetn(resetn),
    .control(control),
    .add_in1(add_in1), 
    .add_in2(add_in2), 
    .acc_out(acc_out)
    );

endmodule
