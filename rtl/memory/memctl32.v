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
`define BIG_ROM_ADDRESS_WIDTH 15

module memctl32 (
	CLOCK_I,
	RESETN_I,
	START_I,
	ADDRESS_O,
	DATA_O,
	WE_O,
	EN_O,
	DONE_O
);

input CLOCK_I;
input RESETN_I;
input START_I;
output [`ADDRESS_WIDTH-1:0] ADDRESS_O;
output [`DATA_WIDTH-1:0] DATA_O;
//reg [`DATA_WIDTH-1:0] DATA_O;
output WE_O;
reg WE_O;
output EN_O;
output DONE_O;
reg DONE_O;

reg [9:0] sample_counter;
reg [`ADDRESS_WIDTH-1:0] logical_address;
reg [`BIG_ROM_ADDRESS_WIDTH-1:0] physical_address;

parameter NUM_SAMPLE = 'd512;

reg [1:0] state;

assign ADDRESS_O = logical_address;

assign EN_O = ~DONE_O;

always @ (posedge CLOCK_I or negedge RESETN_I) begin
	if (RESETN_I == 1'b0) begin
		state <= 'd0;
		DONE_O <= 1'b1;
		WE_O <= 1'b0;
		logical_address <= `ADDRESS_WIDTH'h0;
		physical_address <= `BIG_ROM_ADDRESS_WIDTH'h0;
		sample_counter <= 10'h0;
	end else begin
		case (state)
		'd0: begin
			DONE_O <= 1'b1;
			WE_O <= 1'b0;

			//if (logical_address >= NUM_SAMPLE-1) logical_address <= `ADDRESS_WIDTH'h0;

			if (START_I == 1'b1) state <= 'd1;
		end
		'd1: begin
			DONE_O <= 1'b0;
			WE_O <= 1'b1;

			physical_address <= physical_address + 1;
			state <= 'd2;
		end
		default: begin
			DONE_O <= 1'b0;

			if (sample_counter < NUM_SAMPLE-1) begin
				WE_O <= 1'b1;
				physical_address <= physical_address + 1;
				logical_address <= logical_address + 1;
				sample_counter <= sample_counter + 1;
			end else begin
				WE_O <= 1'b0;
				logical_address <= logical_address + 1;
				sample_counter <= 0;

				 state <= 'd0;
			end
		end
		endcase
	end
end

  /*bigrom bigmp3rom(.clk(CLOCK_I),
   .addressA(physical_address),.dataoutA(DATA_O),
   .addressB(`BIG_ROM_ADDRESS_WIDTH'h0),.dataoutB()
  );*/
  mp3src_rom mp3src_rom_u0(
  	.clk (clk),
  	.addr(physical_address),
  	.data(DATA_O)
  	);

endmodule
