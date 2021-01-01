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

`include "../defines.v"

module add_accum(clock, resetn, control, add_in1, add_in2, acc_out);

//--------------Input Ports----------------------- 
input clock ,resetn;
input [1:0] control;
input [`DATA_WIDTH-1:0]  add_in1, add_in2 ;

//--------------Output Ports-----------------------
output [`DATA_WIDTH-1:0]  acc_out;

//--------------Internal regs---------------- 
reg [`DATA_WIDTH-1:0] acc_out;


always @ (posedge clock or negedge resetn)
begin
	if(!resetn) acc_out <= 0;
	else
		case (control)
			`ACCUMULATOR_COMPLEMENT : acc_out <= 0-add_in1;	// complement
			`ACCUMULATOR_LOAD :  	 acc_out <= add_in2; 	// load multiplier output
			`ACCUMULATOR_HOLD :		 acc_out <= add_in1;	// hold
			default :  		 	 acc_out <= add_in1+add_in2;  // multiply and accumulate
		endcase
	end

endmodule

