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

module mac_unit(
	MAC_CLOCK_I, 
	MAC_RESETN_I,
	CH0_MAC_START_I,
	CH0_MAC_BLOCK_I,
	CH0_MAC_MIXED_I,
	CH0_MAC_SWITCHING_I,
 	CH0_MAC_RAM_DATA_I,
	CH0_MAC_RAM_ADDRESS_O,
	CH0_MAC_RAM_EN_O,
	CH0_PCM_RAM_DATA_O , 
	CH0_PCM_RAM_WE_O, 
	CH0_PCM_RAM_ADDRESS_O, 
	CH1_MAC_START_I,
	CH1_MAC_BLOCK_I,
	CH1_MAC_MIXED_I,
	CH1_MAC_SWITCHING_I,
	CH1_MAC_RAM_DATA_I,
	CH1_MAC_RAM_ADDRESS_O,
	CH1_MAC_RAM_EN_O,
	CH1_PCM_RAM_DATA_O , 
	CH1_PCM_RAM_WE_O, 
	CH1_PCM_RAM_ADDRESS_O, 
	MAC_DONE_O
);				  

//--------------input ports---------------------------------- 
input MAC_CLOCK_I, MAC_RESETN_I ;
input [`DATA_WIDTH-1:0] CH0_MAC_RAM_DATA_I;
input CH0_MAC_START_I;
input [1:0] CH0_MAC_BLOCK_I;
input CH0_MAC_MIXED_I;
input CH0_MAC_SWITCHING_I;

input [`DATA_WIDTH-1:0] CH1_MAC_RAM_DATA_I;
input CH1_MAC_START_I;
input [1:0] CH1_MAC_BLOCK_I;
input CH1_MAC_MIXED_I;
input CH1_MAC_SWITCHING_I;

//--------------output ports--------------------------------- 
output CH0_MAC_RAM_EN_O;
output [`DATA_WIDTH-1:0] CH0_PCM_RAM_DATA_O;
output [`ADDRESS_WIDTH-1:0] CH0_PCM_RAM_ADDRESS_O;
output [`ADDRESS_WIDTH-1:0] CH0_MAC_RAM_ADDRESS_O;
output CH0_PCM_RAM_WE_O;

output CH1_MAC_RAM_EN_O;
output [`DATA_WIDTH-1:0] CH1_PCM_RAM_DATA_O;
output [`ADDRESS_WIDTH-1:0] CH1_PCM_RAM_ADDRESS_O;
output [`ADDRESS_WIDTH-1:0] CH1_MAC_RAM_ADDRESS_O;
output CH1_PCM_RAM_WE_O;

output MAC_DONE_O;

//--------------internal registers---------------------------
reg			CH0_hold, CH0_hold_buffer;
// For short MDCT
//reg [1:0]		CH0_hold_mdct
//reg [1:0]		CH0_hold_buffer;
reg [10:0]	CH0_counter;
reg [3:0]		CH0_psb_write_pointer;
reg [5:0]		CH0_aic_read_pointer;
reg [4:0]		CH0_aic_read_offset;
reg [4:0]		CH0_icg_read_pointer;
reg [1:0]		CH0_antialias_write_pointer;
reg [1:0]		CH0_antialias_read_pointer;
reg [1:0]		CH0_block2_read_pointer;
reg [4:0]		CH0_backup_pointer;
reg [5:0]		CH0_MAC_RAM_pointer;
reg [4:0]		PCM_RAM_pointer;

// internal wires which are used before their equations are written
wire [`DATA_WIDTH-1:0] CH0_acc_out;
reg [`DATA_WIDTH-1:0] CH0_acc_buffer;

// internal signals which are necessary to equalize the pipe depths and adjust memory addressing
wire [3:0] CH0_antialias_rev_counter, CH0_antialias_del_counter, CH0_del2_counter;
// For short MDCT
//wire [3:0] CH0_del_counter;
wire [3:0] CH0_msb1_counter, CH0_msb_counter;
//wire [4:0] CH0_counter_del_mdct, CH0_counter_inc_mdct;
wire [4:0] CH0_aic_read_pointer_rev;
assign CH0_antialias_del_counter = CH0_counter[5:2] - 1;
assign CH0_antialias_rev_counter = 4'h7 - CH0_antialias_del_counter;
assign CH0_del2_counter = CH0_counter[3:0] - 2;
// For short MDCT
//assign CH0_del_counter = CH0_counter[3:0] - 1;
assign CH0_msb1_counter = CH0_counter[6:3] - 1;
assign CH0_msb_counter = CH0_counter[6:3];
assign CH0_aic_read_pointer_rev = 5'h11-CH0_aic_read_pointer[5:1];
// For short MDCT
/*
assign CH0_counter_del_mdct = CH0_counter[5:1] - 1;
assign CH0_counter_inc_mdct = CH0_counter[5:1] + 1;
*/


//states
reg [3:0] CH0_state;

//--------------internal registers---------------------------
reg			CH1_hold;
reg [10:0]	CH1_counter;
reg [5:0]		CH1_aic_read_pointer;
reg [4:0]		CH1_aic_read_offset;
reg [1:0]		CH1_antialias_write_pointer;
reg [1:0]		CH1_antialias_read_pointer;
reg [1:0]		CH1_block2_read_pointer;
reg [4:0]		CH1_backup_pointer;
reg [5:0]		CH1_MAC_RAM_pointer;

//internal wires which are used before their equations are written
wire [`DATA_WIDTH-1:0] CH1_acc_out;
reg [`DATA_WIDTH-1:0] CH1_acc_buffer;

// internal signals which are necessary to equalize the pipe depths and adjust memory addressing
wire [3:0] CH1_antialias_rev_counter, CH1_antialias_del_counter, CH1_del2_counter;
wire [3:0] CH1_msb1_counter, CH1_msb_counter;
assign CH1_antialias_del_counter = CH1_counter[5:2] - 1;
assign CH1_antialias_rev_counter = 4'h7 - CH1_antialias_del_counter;
assign CH1_del2_counter = CH1_counter[3:0] - 2;
assign CH1_msb1_counter = CH1_counter[6:3] - 1;
assign CH1_msb_counter = CH1_counter[6:3];
wire [4:0] CH1_aic_read_pointer_rev;
assign CH1_aic_read_pointer_rev = 5'h11-CH1_aic_read_pointer[5:1];

//states
reg [3:0] CH1_state;

// For short MDCT
//wire[3:0] mdct_level;
//assign mdct_level = CH0_aic_read_offset[3:0]; // reuse the aic_read_offset counter in STATE_POLYPHASE_MDCT

//wire [1:0] whold;
//assign whold[1] = ((mdct_level == 4'h0) && (CH0_counter[5:0] == 6'h3e));
//assign whold[0] = whold[1] ||((mdct_level == 4'h1) && ((CH0_counter[5:0] == 6'h1e) || (CH0_counter[5:0] == 6'h3e)));

always @ (posedge MAC_CLOCK_I or negedge MAC_RESETN_I)
begin
	if (!MAC_RESETN_I)
	begin	  
		CH0_hold <= 1'b0;
		CH0_hold_buffer <= 1'b0;
//		CH0_hold_buffer <= 2'b00;
//		CH0_hold_mdct <= 2'b00;
		CH0_counter <= 11'h000;
		CH0_psb_write_pointer <= 4'h0;
		CH0_aic_read_pointer <= 6'h00;
		CH0_aic_read_offset <= 5'h00;
		CH0_icg_read_pointer <= 5'h00;
		CH0_antialias_write_pointer <= 2'h0;
		CH0_antialias_read_pointer <= 2'h0;
		CH0_block2_read_pointer <= 2'h0;
		CH0_backup_pointer <= 5'h00;
		CH0_MAC_RAM_pointer <= 6'h00; 
		PCM_RAM_pointer <= 5'h12; // start writing in PCM memory at location 576
		CH0_state <= `STATE_INITIAL;
	end
	else 
	begin
		// !!!!!!!!!!!!! //
//		CH0_hold_buffer <= {CH0_hold_buffer[0],CH0_hold};
		CH0_hold <= ((CH0_state == `STATE_POLYPHASE_MDCT) && (CH0_counter[4:0]==5'h1e) && (!CH0_hold)) ||
								((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) && (CH0_counter[2:0]==3'h6) && (!CH0_hold));
		CH0_hold_buffer <= CH0_hold;
/*
		// For short MDCT
		if (CH0_state == `STATE_POLYPHASE_MDCT) 
			if (CH0_hold)
			begin
				CH0_hold <= CH0_hold_mdct[0];
				CH0_hold_mdct <= {1'b0,CH0_hold_mdct[1]};
			end
			else
			begin
				CH0_hold <=  (((mdct_level == 4'h0) && 
						    ((CH0_counter[5:0] == 6'h3c) || 
						     (CH0_counter[5:0] == 6'h3a))) ||
						    ((mdct_level == 4'h2) && 
						    ((CH0_counter[5:0] == 6'h0e) || 
						     (CH0_counter[5:0] == 6'h1e) || 
						     (CH0_counter[5:0] == 6'h2e) || 
						     (CH0_counter[5:0] == 6'h3e))) ||
							whold[0]);
				CH0_hold_mdct <= whold;
			end
*/			
		if  (!CH0_hold) CH0_counter <= CH0_counter + 1;
		// !!!!!!!!!!!!! //
		case (CH0_state)
			`STATE_INITIAL: 
			begin
				CH0_counter <= 11'h000;
				CH0_block2_read_pointer <= 2'h0;
				CH0_aic_read_offset <= 5'h00;
				CH0_aic_read_pointer <= 6'h00;
				CH0_icg_read_pointer <= 5'h00;
				CH0_antialias_write_pointer <= 2'h0;
				CH0_antialias_read_pointer <= 2'h0;
				CH0_backup_pointer <= 5'h00;
				if (CH0_MAC_START_I == 1'b1) 
				begin
					CH0_MAC_RAM_pointer <= 6'h00;
					if ((CH0_MAC_BLOCK_I == 2'h2) &&  
					    (CH0_MAC_MIXED_I == 1'b0) && 
					    (CH0_MAC_SWITCHING_I == 1'b1))
						CH0_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
					else CH0_state <= `STATE_LOAD_HALF_SB;
				end
			end
			`STATE_LOAD_HALF_SB:  
			begin
				if (CH0_counter[3:0] == 4'hb)      // spend 12 clock cycles in this CH0_state
				begin
					CH0_counter[3:0] <= 4'h0;
					CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer + 1;
					CH0_antialias_write_pointer <= CH0_antialias_write_pointer + 1;
					if ((CH0_MAC_RAM_pointer == 6'h3f) ||
					   ((CH0_MAC_RAM_pointer == 6'h03) && 
					    (CH0_MAC_MIXED_I == 1'b1) && 
					    (CH0_MAC_SWITCHING_I == 1'b1) &&
					    (CH0_MAC_BLOCK_I == 2'h2))) 
					begin
						CH0_backup_pointer <= CH0_MAC_RAM_pointer[5:1];
						CH0_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
					end
					else	
						CH0_state <= `STATE_ANTIALIAS;
				end
			end			   
			`STATE_ANTIALIAS:  
			begin
				if (CH0_MAC_RAM_pointer[0]) 
				begin
					CH0_backup_pointer <= CH0_MAC_RAM_pointer[5:1];
					CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer + 1;
				end
				else  CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer - 1;
				if (CH0_counter[5:0] == 6'h26)     // spend 39 clock cycles in this CH0_state
				begin
					CH0_counter[5:0] <= 6'h0;
					CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer + 2;
					CH0_antialias_write_pointer <= CH0_antialias_write_pointer + 2;
					CH0_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
				end
			end
			`STATE_IMDCT_BLOCK0_CURRENT_GRANULE:  
			begin
				CH0_aic_read_offset <= CH0_aic_read_offset + 1;
				if (CH0_aic_read_offset == 5'h13) CH0_acc_buffer <= 16'h0000 - CH0_acc_out;
				if (CH0_aic_read_offset == 5'h18) // spend 25 clock cycles in this CH0_state
				begin
					CH0_counter[4:0] <= 5'h00;
					CH0_aic_read_offset <= 5'h00;
					CH0_aic_read_pointer <= CH0_aic_read_pointer + 1;
					CH0_antialias_read_pointer <= CH0_antialias_read_pointer + 2;
					CH0_state <= `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE;
				end
				else
				begin
					if (CH0_counter[3:0] == 4'h8)
					begin
						CH0_counter[3:0] <= 4'h0;
						CH0_counter[4] <= ~CH0_counter[4];
						CH0_antialias_read_pointer <= CH0_antialias_read_pointer + 1;
					end
				end
			end
			`STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE:  
			begin
				CH0_aic_read_offset <= CH0_aic_read_offset + 1;
				if (CH0_aic_read_offset == 5'h13) CH0_acc_buffer <= CH0_acc_out;
				if (CH0_aic_read_offset == 5'h15) // spend 22 clock cycles in this CH0_state
				begin
					CH0_counter[4:0] <= 5'h00;
					CH0_aic_read_offset <= 5'h00;
					CH0_aic_read_pointer <= CH0_aic_read_pointer + 1;
					if (CH0_aic_read_pointer == 6'h11)
					begin
						CH0_aic_read_pointer <= 6'h00;
						if (CH0_MAC_RAM_pointer == 6'h00) 
						begin
							CH0_antialias_write_pointer <= 2'h0;
							CH0_state <= `STATE_WAIT_OTHER_CHANNEL;
						end
						else	
						if ((CH0_MAC_RAM_pointer == 6'h04) && 
						    (CH0_MAC_MIXED_I == 1'b1) && 
						    (CH0_MAC_SWITCHING_I == 1'b1) &&
						    (CH0_MAC_BLOCK_I == 2'h2)) 
						begin
							CH0_antialias_write_pointer <= 2'h0;
							CH0_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
							CH0_MAC_RAM_pointer <= 6'h02;
						end
						else
						begin
							if ((CH0_MAC_RAM_pointer == 6'h3f) ||
							   ((CH0_MAC_RAM_pointer == 6'h03) && 
							    (CH0_MAC_MIXED_I == 1'b1) && 
							    (CH0_MAC_SWITCHING_I == 1'b1) &&
							    (CH0_MAC_BLOCK_I == 2'h2))) 
								CH0_state <= `STATE_LOAD_HALF_SB;
							else 
								CH0_state <= `STATE_ANTIALIAS; 
						end
					end
					else 
					begin
						CH0_antialias_read_pointer <= CH0_antialias_read_pointer + 2;
						CH0_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
					end
				end
				else
				begin
					if (CH0_counter[3:0] == 4'h8)
					begin
						CH0_counter[3:0] <= 4'h0;
						CH0_counter[4] <= ~CH0_counter[4];
						CH0_antialias_read_pointer <= CH0_antialias_read_pointer + 1;
					end
				end
			end
			`STATE_IMDCT_BLOCK2_LOAD_ICG:  
			begin
				if (CH0_counter[3:0] == 4'h7)
				begin
					CH0_counter[3:0] <= 4'h0;
					CH0_block2_read_pointer <= 2'h0;
					CH0_state <= `STATE_IMDCT_BLOCK2_COMPUTE_FIRST;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_FIRST:  
			begin
				if (CH0_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH0_state
				begin
					CH0_counter[6:0] <= 7'h00;
					CH0_block2_read_pointer <= CH0_block2_read_pointer + 1;
					CH0_state <= `STATE_IMDCT_BLOCK2_COMPUTE_SECOND;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_SECOND:  
			begin
				if (CH0_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH0_state
				begin								// this CH0_state also has 12 CH0_hold cycles
					CH0_counter[6:0] <= 7'h00;
					CH0_block2_read_pointer <= CH0_block2_read_pointer + 1;
					CH0_state <= `STATE_IMDCT_BLOCK2_COMPUTE_THIRD;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_THIRD:  
			begin
				if (CH0_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH0_state
				begin
					CH0_counter[6:0] <= 7'h00;
					CH0_block2_read_pointer <= CH0_block2_read_pointer + 1;
					CH0_state <= `STATE_IMDCT_BLOCK2_LOAD_IPG;
				end
			end
			`STATE_IMDCT_BLOCK2_LOAD_IPG:  
			begin
				if (CH0_counter[3:0] == 4'h7)
				begin
					CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer + 1;
					CH0_counter[3:0] <= 4'h0;
					CH0_block2_read_pointer <= 2'h0;
					if (CH0_MAC_RAM_pointer[4:0] == 5'h1f)
					begin
						CH0_counter[3:0] <= 4'h0;
						CH0_aic_read_offset <= 5'h01;		// need to start on odd samples
						CH0_MAC_RAM_pointer <= 6'h01;		// need to start on odd sub-bands
						CH0_state <= `STATE_WAIT_OTHER_CHANNEL;
					end
					else 
						CH0_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
				end
			end
			`STATE_WAIT_OTHER_CHANNEL:
			begin
				if (CH1_state == `STATE_WAIT_OTHER_CHANNEL || CH1_state == `STATE_INITIAL) begin
					CH0_block2_read_pointer <= 2'h0;
					CH0_counter <= 11'h0;
					CH0_aic_read_offset <= 5'h01;
					CH0_MAC_RAM_pointer <= 6'h01;
					CH0_state <= `STATE_IMDCT_FREQ_INV;
				end
			end
			`STATE_IMDCT_FREQ_INV:  
			begin
				if (CH0_counter[3:0] == 4'h4)
				begin
					CH0_counter[3:0] <= 4'h0;
					CH0_MAC_RAM_pointer <= CH0_MAC_RAM_pointer + 2;
					if (CH0_MAC_RAM_pointer == 6'h1f)
					begin
						if (CH0_aic_read_offset == 5'h11)
						begin
							CH0_aic_read_offset <= 5'h00;
							CH0_MAC_RAM_pointer <= 6'h00;
							CH0_state <= `STATE_POLYPHASE_MDCT;
						end
						else
						begin
							CH0_aic_read_offset <= CH0_aic_read_offset + 2;
							CH0_MAC_RAM_pointer <= 6'h01;
						end
					end
				end
			end	
			`STATE_POLYPHASE_MDCT:  // Long MDCT
			begin
				if (CH0_counter[4:0] == 5'h1f)
					CH0_backup_pointer <= CH0_counter[9:5];
				if (CH0_counter == 11'h402) 
				begin
					CH0_state <= `STATE_POLYPHASE_WINDOW;
					CH0_counter <= 11'h000;
					CH0_backup_pointer <= 5'h00;
				end
			end
			// !!!!!!!!!!!!!!! //
/*    
			`STATE_POLYPHASE_MDCT:  // Short MDCT			
			begin
				if (CH0_counter[6:0] == 7'h41) // spend 66 clock cycles for each level 
				begin
					CH0_counter <= 11'h000;
					CH0_aic_read_offset <= CH0_aic_read_offset + 1;
					if (mdct_level == 4'h9) 
					begin
						CH0_aic_read_offset <= 5'h00;
						CH0_state <= `STATE_POLYPHASE_WINDOW;
					end
				end
			end
*/
			// !!!!!!!!!!!!!!! //
			`STATE_POLYPHASE_WINDOW: 
			begin 
				if (CH0_counter[3:0] == 4'hf)
					CH0_backup_pointer <= CH0_counter[8:4];

				if (CH0_counter == 11'h201) 
				begin
					CH0_counter <= 11'h000;
					CH0_psb_write_pointer <= CH0_psb_write_pointer - 1;
					CH0_icg_read_pointer <= CH0_icg_read_pointer + 1;
					PCM_RAM_pointer <= PCM_RAM_pointer + 1;
					CH0_backup_pointer <= 5'h00;
					if (CH0_icg_read_pointer == 5'h11) 
					begin
						CH0_icg_read_pointer <= 5'h00;
						CH0_state <= `STATE_INITIAL;
					end
					else
						CH0_state <= `STATE_POLYPHASE_MDCT; 
				end
			end
			default: CH0_state <= `STATE_INITIAL; 
		endcase
	end
end

always @ (posedge MAC_CLOCK_I or negedge MAC_RESETN_I)
begin
	if (!MAC_RESETN_I)
	begin	  
		CH1_hold <= 1'b0;
		CH1_counter <= 11'h000;
		CH1_aic_read_pointer <= 6'h00;
		CH1_aic_read_offset <= 5'h00;
		CH1_antialias_write_pointer <= 2'h0;
		CH1_antialias_read_pointer <= 2'h0;
		CH1_block2_read_pointer <= 2'h0;
		CH1_backup_pointer <= 5'h00;
		CH1_MAC_RAM_pointer <= 6'h00; 
		CH1_state <= `STATE_INITIAL;
	end
	else 
	begin
		CH1_hold <= ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) && (CH1_counter[2:0]==3'h6) && (!CH1_hold)) ;
		if  (!(CH1_hold && (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)))
			CH1_counter <= CH1_counter + 1;
		case (CH1_state)
			`STATE_INITIAL: 
			begin
				CH1_counter <= 11'h000;
				CH1_aic_read_pointer <= 6'h00;
				CH1_aic_read_offset <= 5'h00;
				CH1_antialias_write_pointer <= 2'h0;
				CH1_antialias_read_pointer <= 2'h0;
				CH1_block2_read_pointer <= 2'h0;
				CH1_backup_pointer <= 5'h00;

				if (CH1_MAC_START_I == 1'b1) 
				begin
					CH1_MAC_RAM_pointer <= 6'h00;
					if ((CH1_MAC_BLOCK_I == 2'h2) &&  
					    (CH1_MAC_MIXED_I == 1'b0) && 
					    (CH1_MAC_SWITCHING_I == 1'b1))
						CH1_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
					else 
						CH1_state <= `STATE_LOAD_HALF_SB;
				end
			end
			`STATE_LOAD_HALF_SB:  
			begin
				if (CH1_counter[3:0] == 4'hb)      // spend 12 clock cycles in this CH1_state
				begin
					CH1_counter[3:0] <= 4'h0;
					CH1_MAC_RAM_pointer <= CH1_MAC_RAM_pointer + 1;
					CH1_antialias_write_pointer <= CH1_antialias_write_pointer + 1;
					if ((CH1_MAC_RAM_pointer == 6'h3f) ||
					   ((CH1_MAC_RAM_pointer == 6'h03) && 
					    (CH1_MAC_MIXED_I == 1'b1) && 
					    (CH1_MAC_SWITCHING_I == 1'b1) &&
					    (CH1_MAC_BLOCK_I == 2'h2))) 
					begin
						CH1_backup_pointer <= CH1_MAC_RAM_pointer[5:1];
						CH1_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
					end
					else	
						CH1_state <= `STATE_ANTIALIAS;
				end
			end			   
			`STATE_ANTIALIAS:  
			begin
				if (CH1_MAC_RAM_pointer[0]) 
				begin
					CH1_backup_pointer <= CH1_MAC_RAM_pointer[5:1];
					CH1_MAC_RAM_pointer <= CH1_MAC_RAM_pointer + 1;
				end
				else  CH1_MAC_RAM_pointer <= CH1_MAC_RAM_pointer - 1;
				if (CH1_counter[5:0] == 6'h26)     // spend 39 clock cycles in this CH1_state
				begin
					CH1_counter[5:0] <= 6'h0;
					CH1_MAC_RAM_pointer <= CH1_MAC_RAM_pointer + 2;
					CH1_antialias_write_pointer <= CH1_antialias_write_pointer + 2;
					CH1_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
				end
			end
			`STATE_IMDCT_BLOCK0_CURRENT_GRANULE:  
			begin
				CH1_aic_read_offset <= CH1_aic_read_offset + 1;
				if (CH1_aic_read_offset == 5'h13) CH1_acc_buffer <= 16'h0000 - CH1_acc_out;
				if (CH1_aic_read_offset == 5'h18) // spend 23 clock cycles in this CH1_state
				begin
					CH1_counter[4:0] <= 5'h00;
					CH1_aic_read_offset <= 5'h00;
					CH1_aic_read_pointer <= CH1_aic_read_pointer + 1;
					CH1_antialias_read_pointer <= CH1_antialias_read_pointer + 2;
					CH1_state <= `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE;
				end
				else
				begin
					if (CH1_counter[3:0] == 4'h8)
					begin
						CH1_counter[3:0] <= 4'h0;
						CH1_counter[4] <= ~CH1_counter[4];
						CH1_antialias_read_pointer <= CH1_antialias_read_pointer + 1;
					end
				end
			end
			`STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE:  
			begin
				CH1_aic_read_offset <= CH1_aic_read_offset + 1;
				if (CH1_aic_read_offset == 5'h13) CH1_acc_buffer <= CH1_acc_out;
				if (CH1_aic_read_offset == 5'h15) // spend 22 clock cycles in this CH1_state
				begin
					CH1_counter[4:0] <= 5'h0;
					CH1_aic_read_offset <= 5'h00;
					CH1_aic_read_pointer <= CH1_aic_read_pointer + 1;
					if (CH1_aic_read_pointer == 6'h11)
					begin
						CH1_aic_read_pointer <= 6'h00;
						if (CH1_MAC_RAM_pointer == 6'h00) 
						begin
							CH1_antialias_write_pointer <= 2'h0;
							CH1_state <= `STATE_WAIT_OTHER_CHANNEL;
						end
						else	
						if ((CH1_MAC_RAM_pointer == 6'h04) && 
						    (CH1_MAC_MIXED_I == 1'b1) && 
						    (CH1_MAC_SWITCHING_I == 1'b1) &&
						    (CH1_MAC_BLOCK_I == 2'h2)) 
						begin
							CH1_antialias_write_pointer <= 2'h0;
							CH1_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
							CH1_MAC_RAM_pointer <= 6'h02;
						end
						else
						begin
							if ((CH1_MAC_RAM_pointer == 6'h3f) ||
							   ((CH1_MAC_RAM_pointer == 6'h03) && 
							    (CH1_MAC_MIXED_I == 1'b1) && 
							    (CH1_MAC_SWITCHING_I == 1'b1) &&
							    (CH1_MAC_BLOCK_I == 2'h2))) 
								CH1_state <= `STATE_LOAD_HALF_SB;
							else 
								CH1_state <= `STATE_ANTIALIAS; 
						end
					end
					else 
					begin
						CH1_antialias_read_pointer <= CH1_antialias_read_pointer + 2;
						CH1_state <= `STATE_IMDCT_BLOCK0_CURRENT_GRANULE;
					end
				end
				else
				begin
					if (CH1_counter[3:0] == 4'h8)
					begin
						CH1_counter[3:0] <= 4'h0;
						CH1_counter[4] <= ~CH1_counter[4];
						CH1_antialias_read_pointer <= CH1_antialias_read_pointer + 1;
					end
				end
			end
			`STATE_IMDCT_BLOCK2_LOAD_ICG:  
			begin
				if (CH1_counter[3:0] == 4'h7)
				begin
					CH1_counter[3:0] <= 4'h0;
					CH1_block2_read_pointer <= 2'h0;
					CH1_state <= `STATE_IMDCT_BLOCK2_COMPUTE_FIRST;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_FIRST:  
			begin
				if (CH1_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH1_state
				begin
					CH1_counter[6:0] <= 7'h00;
					CH1_block2_read_pointer <= CH1_block2_read_pointer + 1;
					CH1_state <= `STATE_IMDCT_BLOCK2_COMPUTE_SECOND;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_SECOND:  
			begin
				if (CH1_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH1_state
				begin							// this CH1_state also has 12 CH1_hold cycles
					CH1_counter[6:0] <= 7'h00;
					CH1_block2_read_pointer <= CH1_block2_read_pointer + 1;
					CH1_state <= `STATE_IMDCT_BLOCK2_COMPUTE_THIRD;
				end
			end
			`STATE_IMDCT_BLOCK2_COMPUTE_THIRD:  
			begin
				if (CH1_counter[6:0] == 7'h62)			// spend 99 clock cycles in this CH1_state
				begin
					CH1_counter[6:0] <= 7'h00;
					CH1_block2_read_pointer <= CH1_block2_read_pointer + 1;
					CH1_state <= `STATE_IMDCT_BLOCK2_LOAD_IPG;
				end
			end
			`STATE_IMDCT_BLOCK2_LOAD_IPG:  
			begin
				if (CH1_counter[3:0] == 4'h7)
				begin
					CH1_MAC_RAM_pointer <= CH1_MAC_RAM_pointer + 1;
					CH1_counter[3:0] <= 4'h0;
					CH1_block2_read_pointer <= 2'h0;
					if (CH1_MAC_RAM_pointer[4:0] == 5'h1f)
					begin
						CH1_counter[3:0] <= 4'h0;
						CH1_aic_read_offset <= 5'h01;		// need to start on odd samples
						CH1_MAC_RAM_pointer <= 6'h01;		// need to start on odd sub-bands
						CH1_state <= `STATE_WAIT_OTHER_CHANNEL;
					end
					else 
						CH1_state <= `STATE_IMDCT_BLOCK2_LOAD_ICG;
				end
			end
			`STATE_WAIT_OTHER_CHANNEL: begin
				if (CH0_state == `STATE_INITIAL) begin
					CH1_state <= `STATE_INITIAL;
				end
			end
			default: CH1_state <= `STATE_INITIAL; 
		endcase
	end
end

// !!!!!!!!!!!!!!!!!!!!!!! //
// polyphase mdct coefficient (pmc) memory

wire pmc_mem_en;
wire [`DATA_WIDTH-1:0] pmc_data_out;
wire [`ADDRESS_WIDTH-1:0] pmc_address;

assign pmc_address = CH0_counter[9:0];
assign pmc_mem_en = (CH0_state == `STATE_POLYPHASE_MDCT);

polyphase_mdct_coefficient instance_polyphase_mdct_coefficient (
    .clock(MAC_CLOCK_I), 
    .mem_en(pmc_mem_en), 
    .address(pmc_address), 
    .data_out(pmc_data_out)
    );

// polyphase window coefficient (pwc) memory
wire pwc_mem_en ;
wire [`DATA_WIDTH-1:0] pwc_data_out;
wire [`ADDRESS_WIDTH-1:0] pwc_address;

// For short MDCT
//always @(CH0_counter, CH0_state, mdct_level)
//begin
//	pwc_address = {1'b0, CH0_counter[3:0], CH0_counter[8:4]}; 
//	if (CH0_state == `STATE_POLYPHASE_MDCT)
//		pwc_address = {1'b1, mdct_level[2:0] ^ {3{mdct_level[3]}}, CH0_counter[5:0]}; 
//end
//assign pwc_mem_en = ((CH0_state == `STATE_POLYPHASE_WINDOW) || (CH0_state == `STATE_POLYPHASE_MDCT));

// For long MDCT
assign pwc_address = {1'b0, CH0_counter[3:0], CH0_counter[8:4]}; 
assign pwc_mem_en = (CH0_state == `STATE_POLYPHASE_WINDOW);

polyphase_window_coefficient instance_polyphase_window_coefficient (
    .clock(MAC_CLOCK_I), 
    .mem_en(pwc_mem_en), 
    .address(pwc_address), 
    .data_out(pwc_data_out)
);

// !!!!!!!!!!!!!!!!!!!!!!! //

// antialias and IMDCT coefficient (aic) memory
wire CH0_aic_mem_en;
wire [`DATA_WIDTH-1:0] CH0_aic_data_out;
reg [`ADDRESS_WIDTH-1:0] CH0_aic_address;
reg [3:0] CH0_aic_window013_pointer;
wire [9:0] CH0_aic_imdct013_address;
wire [6:0] CH0_aic_imdct2_address;

assign CH0_aic_mem_en = (CH0_state == `STATE_ANTIALIAS) || 
				(CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
				(CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD);

always  @(CH0_state, CH0_counter, 
		CH0_aic_read_pointer, CH0_aic_read_offset, 
		CH0_aic_window013_pointer, CH0_aic_imdct013_address,
		CH0_aic_imdct2_address, CH0_aic_read_pointer_rev)
begin
	CH0_aic_address <= 10'h000; 
	if (CH0_state == `STATE_ANTIALIAS)
		CH0_aic_address <= {5'h1f,CH0_counter[1]^CH0_counter[0],(!CH0_counter[1])|CH0_counter[0],CH0_counter[4:2]}; 
	if ((CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) || 
	    (CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE))
		if (CH0_aic_read_offset[4:0] == 5'h12) 
			CH0_aic_address <= {CH0_aic_window013_pointer,CH0_aic_read_pointer}; 
		else if (((CH0_aic_read_offset[4:0] == 5'h14) && (CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)) ||
			    ((CH0_aic_read_offset[4:0] == 5'h13) && (CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE)))
			CH0_aic_address <= {CH0_aic_window013_pointer,CH0_aic_read_pointer_rev,CH0_aic_read_pointer[0]}; 
		else	CH0_aic_address <= CH0_aic_imdct013_address;
	if ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) || 
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD)) 
		if (CH0_counter[2:0] == 3'h6) CH0_aic_address <= {6'h29,CH0_counter[6:3]}; 
		else	CH0_aic_address <= {3'h7,CH0_aic_imdct2_address};
end

always @(CH0_MAC_BLOCK_I)
begin
	CH0_aic_window013_pointer <= 4'hb;
	if (CH0_MAC_BLOCK_I == 2'h0) CH0_aic_window013_pointer <= 4'hb;
	if (CH0_MAC_BLOCK_I == 2'h1) CH0_aic_window013_pointer <= 4'hc;
	if (CH0_MAC_BLOCK_I == 2'h3) CH0_aic_window013_pointer <= 4'hd;
end

wire [3:0] CH0_tmp013_adder;
assign CH0_tmp013_adder = {1'b0,CH0_aic_read_pointer[2:0]} + {1'b0,CH0_aic_read_offset[3:1]};
assign CH0_aic_imdct013_address[0] = CH0_aic_read_offset[0];
assign CH0_aic_imdct013_address[3:1] = CH0_tmp013_adder[2:0];
assign CH0_aic_imdct013_address[9:4] = CH0_aic_read_pointer[5:0] + {{3{1'b0}},CH0_aic_read_pointer[5:3]} 
							 + (CH0_tmp013_adder[3]|CH0_aic_read_offset[4]);

assign CH0_aic_imdct2_address[0] = CH0_counter[0];
assign CH0_aic_imdct2_address[1] = CH0_counter[1]^CH0_counter[3];
assign CH0_aic_imdct2_address[6:2] = CH0_counter[6:3] + {1'b0,CH0_counter[6:4]} 
					     + (CH0_counter[2] || (CH0_counter[1] && CH0_counter[3]));
					     
// next channel
wire CH1_aic_mem_en;
wire [`DATA_WIDTH-1:0] CH1_aic_data_out;
reg [`ADDRESS_WIDTH-1:0] CH1_aic_address;
reg [3:0] CH1_aic_window013_pointer;
wire [9:0] CH1_aic_imdct013_address;
wire [6:0] CH1_aic_imdct2_address;

assign CH1_aic_mem_en = (CH1_state == `STATE_ANTIALIAS) || 
				(CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
				(CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD);

always  @(CH1_state, CH1_counter, 
		CH1_aic_read_pointer, CH1_aic_read_offset, 
		CH1_aic_window013_pointer, CH1_aic_imdct013_address,
		CH1_aic_imdct2_address, CH1_aic_read_pointer_rev)
begin
	CH1_aic_address <= 10'h000; 
	if (CH1_state == `STATE_ANTIALIAS)
		CH1_aic_address <= {5'h1f,CH1_counter[1]^CH1_counter[0],(!CH1_counter[1])|CH1_counter[0],CH1_counter[4:2]}; 
	if ((CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) || 
	    (CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE))
		if (CH1_aic_read_offset[4:0] == 5'h12) CH1_aic_address <= {CH1_aic_window013_pointer,CH1_aic_read_pointer}; 
		else if (((CH1_aic_read_offset[4:0] == 5'h14) && (CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)) ||
			    ((CH1_aic_read_offset[4:0] == 5'h13) && (CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE)))
			CH1_aic_address <= {CH1_aic_window013_pointer,CH1_aic_read_pointer_rev,CH1_aic_read_pointer[0]}; 
		else	CH1_aic_address <= CH1_aic_imdct013_address;
	if ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) || 
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD)) 
		if (CH1_counter[2:0] == 3'h6) CH1_aic_address <= {6'h29,CH1_counter[6:3]}; 
		else	CH1_aic_address <= {3'h7,CH1_aic_imdct2_address};
end

always @(CH1_MAC_BLOCK_I)
begin
	CH1_aic_window013_pointer <= 4'hb;
	if (CH1_MAC_BLOCK_I == 2'h0) CH1_aic_window013_pointer <= 4'hb;
	if (CH1_MAC_BLOCK_I == 2'h1) CH1_aic_window013_pointer <= 4'hc;
	if (CH1_MAC_BLOCK_I == 2'h3) CH1_aic_window013_pointer <= 4'hd;
end

wire [3:0] CH1_tmp013_adder;
assign CH1_tmp013_adder = {1'b0,CH1_aic_read_pointer[2:0]} + {1'b0,CH1_aic_read_offset[3:1]};
assign CH1_aic_imdct013_address[0] = CH1_aic_read_offset[0];
assign CH1_aic_imdct013_address[3:1] = CH1_tmp013_adder[2:0];
assign CH1_aic_imdct013_address[9:4] = CH1_aic_read_pointer[5:0] + {{3{1'b0}},CH1_aic_read_pointer[5:3]} 
							 + (CH1_tmp013_adder[3]|CH1_aic_read_offset[4]);

assign CH1_aic_imdct2_address[0] = CH1_counter[0];
assign CH1_aic_imdct2_address[1] = CH1_counter[1]^CH1_counter[3];
assign CH1_aic_imdct2_address[6:2] = CH1_counter[6:3] + {1'b0,CH1_counter[6:4]} 
					     + (CH1_counter[2] || (CH1_counter[1] && CH1_counter[3]));

antialias_imdct_coefficient instance_antialias_imdct_coefficient (
    .clock(MAC_CLOCK_I), 
    .CH0_mem_en(CH0_aic_mem_en), 
    .CH0_address(CH0_aic_address), 
    .CH0_data_out(CH0_aic_data_out),
    .CH1_mem_en(CH1_aic_mem_en), 
    .CH1_address(CH1_aic_address), 
    .CH1_data_out(CH1_aic_data_out)
);

// polyphase sample buffer (psb) memory 
wire CH0_psb_mem_en, CH0_psb_wr_en; 
wire [`DATA_WIDTH-1:0] CH0_psb_data_out;
wire [`DATA_WIDTH-1:0] CH0_psb_data_in;
// For short MDCT
//reg [`ADDRESS_WIDTH-1:0] CH0_psb_address; 
wire [`ADDRESS_WIDTH-1:0] CH0_psb_address; 
wire [3:0] CH0_psb_tmp;

// !!!!!!!!!!!!!! //
// For short MDCT
/*
assign CH0_psb_wr_en = ((CH0_state == `STATE_POLYPHASE_MDCT) && (mdct_level[3:0] == 4'h9) && (CH0_counter[6:1] != 6'h00));
// !!!!!!!!!!!!!! //
assign CH0_psb_mem_en = (CH0_psb_wr_en) || (CH0_state == `STATE_POLYPHASE_WINDOW);
assign CH0_psb_data_in = CH0_acc_out;
// !!!!!!!!!!!!!! //
always @ (CH0_psb_write_pointer, pwc_address, CH0_state, mdct_level, CH0_counter_del_mdct, CH0_counter) 
begin
	CH0_psb_address <= {CH0_psb_write_pointer + pwc_address[8:5], pwc_address[5:0]};
	if ((CH0_state == `STATE_POLYPHASE_MDCT) && (mdct_level == 4'h9))
		CH0_psb_address <= {CH0_psb_write_pointer[3:0],CH0_counter_del_mdct[4:0],CH0_counter[0]};
end
// !!!!!!!!!!!!!! //
*/

// For long MDCT
assign CH0_psb_wr_en =  (CH0_counter[4:1] == 4'h0) && 
				(CH0_counter[10:5] != 6'h00) && 
				(CH0_state == `STATE_POLYPHASE_MDCT);
assign CH0_psb_mem_en = (CH0_psb_wr_en) || (CH0_state == `STATE_POLYPHASE_WINDOW);
assign CH0_psb_data_in = CH0_acc_out;
assign CH0_psb_tmp = CH0_psb_write_pointer + pwc_address[8:5];
/*
assign CH0_psb_address = (CH0_state == `STATE_POLYPHASE_WINDOW) ? 
				 {CH0_psb_tmp, pwc_address[5:0]} : 
				 {CH0_psb_write_pointer[3:0], 
				  CH0_backup_pointer[4], 
				  CH0_backup_pointer[4]^CH0_counter[0], 
				  CH0_backup_pointer[3:0]^{4{CH0_counter[0]}}};
*/
assign CH0_psb_address= (CH0_state == `STATE_POLYPHASE_WINDOW) ?
				 {CH0_psb_tmp, pwc_address[5:0]} : 
				 {CH0_psb_write_pointer[3:0], 
				 !CH0_backup_pointer[4],
				 CH0_counter[0],
				 CH0_backup_pointer[3:0]^{4{~(CH0_backup_pointer[4]^CH0_counter[0])}}
				 };

polyphase_sample_buffer instance_CH0_polyphase_sample_buffer (
    .clock(MAC_CLOCK_I), 
    .mem_en(CH0_psb_mem_en), 
    .wr_en(CH0_psb_wr_en), 
    .address(CH0_psb_address), 
    .data_in(CH0_psb_data_in), 
    .data_out(CH0_psb_data_out)
    );
    
// next channel
wire CH1_psb_mem_en, CH1_psb_wr_en; 
wire [`DATA_WIDTH-1:0] CH1_psb_data_out;
wire [`DATA_WIDTH-1:0] CH1_psb_data_in;
wire [`ADDRESS_WIDTH-1:0] CH1_psb_address; 

assign CH1_psb_wr_en =  (CH0_psb_wr_en && (CH1_state == `STATE_WAIT_OTHER_CHANNEL));
assign CH1_psb_mem_en = (CH0_psb_mem_en && (CH1_state == `STATE_WAIT_OTHER_CHANNEL));
assign CH1_psb_data_in = CH1_acc_out;
assign CH1_psb_address = CH0_psb_address;

polyphase_sample_buffer instance_CH1_polyphase_sample_buffer (
    .clock(MAC_CLOCK_I), 
    .mem_en(CH1_psb_mem_en), 
    .wr_en(CH1_psb_wr_en), 
    .address(CH1_psb_address), 
    .data_in(CH1_psb_data_in), 
    .data_out(CH1_psb_data_out)
    );

// imdct previous granule (ipg) memory
wire CH0_ipg_mem_en, CH0_ipg_wr_en; 
wire [`DATA_WIDTH-1:0] CH0_ipg_data_out;
wire [`DATA_WIDTH-1:0] CH0_ipg_data_in;
reg [`ADDRESS_WIDTH-1:0] CH0_ipg_address; 

assign CH0_ipg_wr_en =  ((CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) &&
				 ((CH0_aic_read_offset == 5'h14) || (CH0_aic_read_offset == 5'h15))) ||
				(((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
				  (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)) &&
				 (CH0_counter[2:0] == 3'h1) && (CH0_counter[6] || (CH0_counter[6:3] == 4'h7))) ||
				((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD) &&
				 (CH0_counter[2:0] == 3'h1) && (CH0_counter[6:3] != 4'h0)) ||
				((CH0_state == `STATE_IMDCT_BLOCK2_LOAD_IPG) &&
				((CH0_counter[2:0] != 3'h0) && (CH0_counter[2:0] != 3'h1)));
				// For short MDCT
/*				|| 
				// !!!!!!!!!!!!! //
				((CH0_state == `STATE_POLYPHASE_MDCT) && 
				 (!mdct_level[0]) && CH0_counter[0] && (CH0_counter[6:1] != 6'h00) &&
				 (CH0_hold_buffer == 2'b00));
				// !!!!!!!!!!!!! //
*/				
assign CH0_ipg_mem_en = CH0_ipg_wr_en || 
				(CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD);
				// For short MDCT
/*				||
				// !!!!!!!!!!!!! //
				(CH0_state == `STATE_POLYPHASE_MDCT);
				// !!!!!!!!!!!!! //
*/				
assign CH0_ipg_data_in = CH0_acc_out;

always @(CH0_state, CH0_aic_read_pointer, CH0_backup_pointer, CH0_MAC_RAM_pointer, 
	    CH0_counter, CH0_msb_counter, CH0_msb1_counter, CH0_del2_counter, CH0_hold,
	    CH0_aic_read_pointer_rev, CH0_aic_read_offset, CH0_backup_pointer)
	    // For short MDCT
/*
			,
	    mdct_level, CH0_counter_del_mdct, CH0_del_counter, CH0_counter_inc_mdct)
*/	    
begin
	CH0_ipg_address <= {CH0_aic_read_pointer[5:1],CH0_backup_pointer};
	if (((CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
	    ((CH0_aic_read_offset == 5'h15) || (CH0_aic_read_offset == 5'h17))) ||
	    ((CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) && (CH0_aic_read_offset == 5'h15)))
		CH0_ipg_address <= {CH0_aic_read_pointer_rev,CH0_backup_pointer};
	if (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) 
		CH0_ipg_address <= {{1'b0,CH0_counter[3:0]},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST)	   
		if ((CH0_counter[5:3] == 3'h7) || (CH0_counter[6] == 1'b1))
			CH0_ipg_address <= {{1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
		else
			CH0_ipg_address <= {5'h06 + {1'b0,CH0_msb_counter},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)
		if (CH0_counter[2:0] == 3'h7) 
			if (CH0_hold)
				CH0_ipg_address <= {5'h06 + {1'b0,CH0_msb_counter},CH0_MAC_RAM_pointer[4:0]};
			else 
				CH0_ipg_address <= {5'h0c + {1'b0,CH0_msb_counter},CH0_MAC_RAM_pointer[4:0]};
		else	
			CH0_ipg_address <= {5'h06 + {1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD)
		if ((CH0_counter[5:3] == 3'h7) || (CH0_counter[6] == 1'b1))
			CH0_ipg_address <= {{1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
		else
			if (CH0_counter[2:0] == 3'h7)
				CH0_ipg_address <= {5'h0c + {1'b0,CH0_msb_counter},CH0_MAC_RAM_pointer[4:0]};
			else
				CH0_ipg_address <= {{1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
	if (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_IPG)
		CH0_ipg_address <= {5'h0c + {1'b0,CH0_del2_counter},CH0_MAC_RAM_pointer[4:0]};
	
	// For short MDCT
/*	
	if (CH0_state == `STATE_POLYPHASE_MDCT)
		if ((mdct_level == 'h0) || (mdct_level == 'h2) || (mdct_level == 'h4)) // writing
			CH0_ipg_address <= {5'h1f, CH0_counter_del_mdct};
		else	if (mdct_level == 'h1) // reading
			CH0_ipg_address <= {5'h1f, CH0_counter[5], !CH0_counter[0], CH0_counter[3:1] ^ {3{!CH0_counter[0]}}};
		else if (mdct_level == 'h3) // reading
			CH0_ipg_address <= {5'h1f, CH0_counter[5:3], !CH0_counter[0],  CH0_counter[1] ^ (!CH0_counter[0])};
		else if ((mdct_level == 'h5) || (mdct_level == 'h7)) // reading
			CH0_ipg_address <= {5'h1f, CH0_counter[0] ? CH0_counter_inc_mdct[4:0] : CH0_counter[5:1]};
		else if (mdct_level == 'h6) // writing
			CH0_ipg_address <= {5'h1f, CH0_counter_del_mdct[4:3], CH0_counter_del_mdct[1:0], CH0_counter_del_mdct[2]};
		else if (mdct_level == 'h8) // writing
			CH0_ipg_address <= {5'h1f, CH0_counter_del_mdct[3:0], CH0_counter_del_mdct[4]};
		else	// reading in level 9 when writing into psb
			if (CH0_counter[5] == CH0_counter[4]) CH0_ipg_address <= {5'h1f, !CH0_counter[5], CH0_counter[3:0]};
			else CH0_ipg_address <= {5'h1f, CH0_counter[4] || (~|CH0_counter[3:0]),CH0_del_counter[3:0] ^ 4'hf};
*/			
end

imdct_previous_granule instance_CH0_imdct_previous_granule(
    .clock(MAC_CLOCK_I), 
    .mem_en(CH0_ipg_mem_en), 
    .wr_en(CH0_ipg_wr_en), 
    .address(CH0_ipg_address), 
    .data_in(CH0_ipg_data_in), 
    .data_out(CH0_ipg_data_out)
    );
    
// next channel
// imdct previous granule (ipg) memory
wire CH1_ipg_mem_en, CH1_ipg_wr_en; 
wire [`DATA_WIDTH-1:0] CH1_ipg_data_out;
wire [`DATA_WIDTH-1:0] CH1_ipg_data_in;
reg [`ADDRESS_WIDTH-1:0] CH1_ipg_address; 

assign CH1_ipg_wr_en =  ((CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) &&
				 ((CH1_aic_read_offset == 5'h14) || (CH1_aic_read_offset == 5'h15))) ||
				(((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
				  (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)) &&
				 (CH1_counter[2:0] == 3'h1) && (CH1_counter[6] || (CH1_counter[6:3] == 4'h7))) ||
				((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD) &&
				 (CH1_counter[2:0] == 3'h1) && (CH1_counter[6:3] != 4'h0)) ||
				((CH1_state == `STATE_IMDCT_BLOCK2_LOAD_IPG) &&
				((CH1_counter[2:0] != 3'h0) && (CH1_counter[2:0] != 3'h1)));
				// For short MDCT
/*
				||
				(CH0_ipg_wr_en && 
				(CH0_state == `STATE_POLYPHASE_MDCT) && 
				(CH1_state == `STATE_WAIT_OTHER_CHANNEL));
*/				
assign CH1_ipg_mem_en = CH1_ipg_wr_en || 
				(CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD);
				// For short MDCT
/*
				||
			    ((CH0_state == `STATE_POLYPHASE_MDCT) && 
				(CH1_state == `STATE_WAIT_OTHER_CHANNEL));
*/
assign CH1_ipg_data_in = CH1_acc_out;

always @(CH1_state, CH1_aic_read_pointer, CH1_backup_pointer, CH1_MAC_RAM_pointer, 
	    CH1_counter, CH1_msb_counter, CH1_msb1_counter, CH1_del2_counter, CH1_hold, 
	    CH1_aic_read_pointer_rev, CH1_aic_read_offset, CH1_backup_pointer, CH0_state, CH0_ipg_address)
begin
	CH1_ipg_address <= {CH1_aic_read_pointer[5:1],CH1_backup_pointer};

	if (((CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
	    ((CH1_aic_read_offset == 5'h15) || (CH1_aic_read_offset == 5'h17))) ||
	    ((CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) && (CH1_aic_read_offset == 5'h15)))
		CH1_ipg_address <= {CH1_aic_read_pointer_rev,CH1_backup_pointer};

	if (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) 
		CH1_ipg_address <= {{1'b0,CH1_counter[3:0]}, CH1_MAC_RAM_pointer[4:0]};

     if (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST)	   
		if ((CH1_counter[5:3] == 3'h7) || (CH1_counter[6] == 1'b1))
			CH1_ipg_address <= {{1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};
		else
			CH1_ipg_address <= {5'h06 + {1'b0,CH1_msb_counter},CH1_MAC_RAM_pointer[4:0]};

     if (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)
		if (CH1_counter[2:0] == 3'h7) 
			if (CH1_hold)
				CH1_ipg_address <= {5'h06 + {1'b0,CH1_msb_counter},CH1_MAC_RAM_pointer[4:0]};
			else 
				CH1_ipg_address <= {5'h0c + {1'b0,CH1_msb_counter},CH1_MAC_RAM_pointer[4:0]};
		else	
			CH1_ipg_address <= {5'h06 + {1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};

     if (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD)
		if ((CH1_counter[5:3] == 3'h7) || (CH1_counter[6] == 1'b1))
			CH1_ipg_address <= {{1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};
		else
			if (CH1_counter[2:0] == 3'h7)
				CH1_ipg_address <= {5'h0c + {1'b0,CH1_msb_counter},CH1_MAC_RAM_pointer[4:0]};
			else
				CH1_ipg_address <= {{1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};

	if (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_IPG)
		CH1_ipg_address <= {5'h0c + {1'b0,CH1_del2_counter},CH1_MAC_RAM_pointer[4:0]};

	/*
	// For short MDCT
	if ((CH0_state == `STATE_POLYPHASE_MDCT) && (CH1_state == `STATE_WAIT_OTHER_CHANNEL))
		CH1_ipg_address <= CH0_ipg_address;
	*/
end

imdct_previous_granule instance_CH1_imdct_previous_granule(
    .clock(MAC_CLOCK_I), 
    .mem_en(CH1_ipg_mem_en), 
    .wr_en(CH1_ipg_wr_en), 
    .address(CH1_ipg_address), 
    .data_in(CH1_ipg_data_in), 
    .data_out(CH1_ipg_data_out)
    );

// imdct current granule (icg) memory
wire CH0_icg_mem_en, CH0_icg_wr_en; 
wire [`DATA_WIDTH-1:0] CH0_icg_data_out;
wire [`DATA_WIDTH-1:0] CH0_icg_data_in;
reg  [`ADDRESS_WIDTH-1:0] CH0_icg_address; 

assign CH0_icg_wr_en =  ((CH0_state == `STATE_LOAD_HALF_SB) && (CH0_counter[3:0] > 1) && (CH0_counter[3:0] < 11)) ||
				((CH0_state == `STATE_ANTIALIAS) && CH0_counter[0] && (CH0_counter[5:1] != 5'h00)) ||
				((CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
				((CH0_aic_read_offset == 5'h15) || (CH0_aic_read_offset == 5'h17))) ||
     		    (((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
			      (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)) &&
 			      (CH0_counter[2:0] == 3'h1) && (CH0_counter[6] == 1'b0) &&
				((CH0_counter[6:3]!=4'h0) && (CH0_counter[6:3]!=4'h7))) ||
				((CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) &&
				((CH0_counter[2:0] != 3'h0) && (CH0_counter[2:0] != 3'h1))) ||
				((CH0_state == `STATE_IMDCT_FREQ_INV) && (CH0_counter[3:0] == 4'h3));
				// For short MDCT
/*				
				||
				// !!!!!!!!!!!!! //
				((CH0_state == `STATE_POLYPHASE_MDCT) && mdct_level[0] && 
				 (mdct_level[3:0] != 4'h9) && CH0_counter[0] && (CH0_counter[6:1] != 6'h00) &&
				 (CH0_hold_buffer == 2'b00));
				 // !!!!!!!!!!!!! //
*/
assign CH0_icg_mem_en = CH0_icg_wr_en || 
				(CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) || 
				(CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH0_state == `STATE_POLYPHASE_MDCT) ||
				(CH0_state == `STATE_IMDCT_FREQ_INV);
assign CH0_icg_data_in = CH0_acc_out;

always @(CH0_state, CH0_counter, CH0_icg_read_pointer, CH0_antialias_rev_counter,
	    CH0_antialias_write_pointer, CH0_antialias_read_pointer, 
	    CH0_antialias_del_counter, CH0_del2_counter, CH0_hold, 
	    CH0_aic_read_offset, CH0_MAC_RAM_pointer, CH0_msb_counter, CH0_msb1_counter, CH0_ipg_address,
		CH0_aic_read_pointer, CH0_backup_pointer)
	    // For short MDCT
/*
	    CH0_counter_inc_mdct,
	    , mdct_level, CH0_counter_del_mdct)
*/	    
begin 
	CH0_icg_address <= 10'h000;
	if (CH0_state == `STATE_LOAD_HALF_SB) CH0_icg_address <= {4'hf,CH0_antialias_write_pointer,CH0_del2_counter};
	if (CH0_state == `STATE_ANTIALIAS)
		if (CH0_counter[1] == 1'b0) CH0_icg_address <= {4'hf,CH0_antialias_write_pointer[1:0]^2'b11,CH0_antialias_del_counter};
		else	CH0_icg_address <= {4'hf,CH0_antialias_write_pointer,CH0_antialias_rev_counter};
	if (CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) 
		if (CH0_aic_read_offset == 5'h15) CH0_icg_address <= {CH0_aic_read_pointer[5:1],CH0_backup_pointer};
		else if (CH0_aic_read_offset == 5'h17) CH0_icg_address <= CH0_ipg_address;
		else CH0_icg_address <= {4'hf,CH0_antialias_read_pointer,CH0_counter[3:0]};
	if (CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) 
		CH0_icg_address <= {4'hf,CH0_antialias_read_pointer,CH0_counter[3:0]};
	if (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) 
		CH0_icg_address <= {{1'b0,CH0_del2_counter},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST)	   
		if (!((CH0_counter[5:3] == 3'h7) || (CH0_counter[6] == 1'b1)))
			CH0_icg_address <= {5'h06 + {1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)
		if (!((CH0_counter[5:3] == 3'h7) || (CH0_counter[6] == 1'b1)))
			CH0_icg_address <= {5'h0c + {1'b0,CH0_msb1_counter},CH0_MAC_RAM_pointer[4:0]};
     if (CH0_state == `STATE_IMDCT_FREQ_INV)
		CH0_icg_address <= {CH0_aic_read_offset[4:0],CH0_MAC_RAM_pointer[4:0]};

	// For long MDCT
	if (CH0_state == `STATE_POLYPHASE_MDCT)
		CH0_icg_address <= {CH0_icg_read_pointer[4:0],CH0_counter[4:0]};

	// For short MDCT
/*	
	// !!!!!!!!!!!!! //
	if (CH0_state == `STATE_POLYPHASE_MDCT)
		if (mdct_level == 4'h0) // reading the original sample
			CH0_icg_address <= {CH0_icg_read_pointer[4:0], !CH0_counter[0], CH0_counter[4:1] ^ {4{!CH0_counter[0]}}};
		else	if ((mdct_level == 'h1) || (mdct_level == 'h3)) // writing
			CH0_icg_address <= {5'h1f, CH0_counter_del_mdct};
		else	if (mdct_level == 'h2) // reading
			CH0_icg_address <= {5'h1f, CH0_counter[5:4], !CH0_counter[0], CH0_counter[2:1] ^ {2{!CH0_counter[0]}}};
		else if (mdct_level == 'h4) //reading
			CH0_icg_address <= {5'h1f, CH0_counter[5:2], !CH0_counter[0]};
		else if (mdct_level == 'h5) // writing
			CH0_icg_address <= {5'h1f, CH0_counter_del_mdct[4:2], CH0_counter_del_mdct[0], CH0_counter_del_mdct[1]};
		else if (mdct_level == 'h7) // writing
			CH0_icg_address <= {5'h1f, CH0_counter_del_mdct[4], CH0_counter_del_mdct[2:0], CH0_counter_del_mdct[3]};
		else // reading in 6, 8
			CH0_icg_address <= {5'h1f, CH0_counter[0] ? CH0_counter_inc_mdct[4:0] : CH0_counter[5:1]};
	// !!!!!!!!!!!!! //
*/	
end

imdct_current_granule instance_CH0_imdct_current_granule(
    .clock(MAC_CLOCK_I), 
    .mem_en(CH0_icg_mem_en), 
    .wr_en(CH0_icg_wr_en), 
    .address(CH0_icg_address), 
    .data_in(CH0_icg_data_in), 
    .data_out(CH0_icg_data_out)
    );
    
// next channel
// imdct current granule (icg) memory
wire CH1_icg_mem_en, CH1_icg_wr_en; 
wire [`DATA_WIDTH-1:0] CH1_icg_data_out;
wire [`DATA_WIDTH-1:0] CH1_icg_data_in;
reg  [`ADDRESS_WIDTH-1:0] CH1_icg_address; 

assign CH1_icg_wr_en =  ((CH1_state == `STATE_LOAD_HALF_SB) && (CH1_counter[3:0] > 1) && (CH1_counter[3:0] < 11)) ||
				((CH1_state == `STATE_ANTIALIAS) && CH1_counter[0] && (CH1_counter[5:1] != 5'h00)) ||
				((CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
				((CH1_aic_read_offset == 5'h15) || (CH1_aic_read_offset == 5'h17))) ||
     		    (((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
			      (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)) &&
 			      (CH1_counter[2:0] == 3'h1) && (CH1_counter[6] == 1'b0) &&
				((CH1_counter[6:3]!=4'h0) && (CH1_counter[6:3]!=4'h7))) ||
				((CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) &&
				((CH1_counter[2:0] != 3'h0) && (CH1_counter[2:0] != 3'h1))) ||
				// For short MDCT
/*				
				(CH0_icg_wr_en && 
				((CH0_state == `STATE_POLYPHASE_MDCT) || (CH0_state == `STATE_IMDCT_FREQ_INV)) && 
				(CH1_state == `STATE_WAIT_OTHER_CHANNEL));
*/
				(CH0_icg_wr_en && (CH0_state == `STATE_IMDCT_FREQ_INV) && (CH1_state == `STATE_WAIT_OTHER_CHANNEL));

assign CH1_icg_mem_en = CH1_icg_wr_en || 
				(CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) || 
				(CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
				(CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
				(CH0_icg_mem_en && 
				((CH0_state == `STATE_POLYPHASE_MDCT) || (CH0_state == `STATE_IMDCT_FREQ_INV)) && 
				(CH1_state == `STATE_WAIT_OTHER_CHANNEL));
assign CH1_icg_data_in = CH1_acc_out;

always @(CH1_state, CH1_counter, CH1_antialias_rev_counter,
	    CH1_antialias_write_pointer, CH1_antialias_read_pointer, 
	    CH1_antialias_del_counter, CH1_del2_counter, CH1_hold,
	    CH1_aic_read_offset, CH1_MAC_RAM_pointer, CH1_msb_counter, CH1_msb1_counter,
	    CH0_state, CH0_icg_address, CH1_ipg_address, CH1_aic_read_pointer, CH1_backup_pointer)
begin 
	CH1_icg_address <= 10'h000;

	if (CH1_state == `STATE_LOAD_HALF_SB) 
		CH1_icg_address <= {4'hf,CH1_antialias_write_pointer,CH1_del2_counter};

	if (CH1_state == `STATE_ANTIALIAS)
		if (CH1_counter[1] == 1'b0) CH1_icg_address <= {4'hf,CH1_antialias_write_pointer[1:0]^2'b11,CH1_antialias_del_counter};
		else	CH1_icg_address <= {4'hf,CH1_antialias_write_pointer,CH1_antialias_rev_counter};

	if (CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) 
		if (CH1_aic_read_offset == 5'h15) CH1_icg_address <= {CH1_aic_read_pointer[5:1],CH1_backup_pointer};
		else if (CH1_aic_read_offset == 5'h17) CH1_icg_address <= CH1_ipg_address;
			else CH1_icg_address <= {4'hf,CH1_antialias_read_pointer,CH1_counter[3:0]};

	if (CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE) 
		CH1_icg_address <= {4'hf,CH1_antialias_read_pointer,CH1_counter[3:0]};

	if (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) 
		CH1_icg_address <= {{1'b0,CH1_del2_counter},CH1_MAC_RAM_pointer[4:0]};

     if (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST)	   
		if (!((CH1_counter[5:3] == 3'h7) || (CH1_counter[6] == 1'b1)))
			CH1_icg_address <= {5'h06 + {1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};

     if (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND)
		if (!((CH1_counter[5:3] == 3'h7) || (CH1_counter[6] == 1'b1)))
			CH1_icg_address <= {5'h0c + {1'b0,CH1_msb1_counter},CH1_MAC_RAM_pointer[4:0]};

     if (((CH0_state == `STATE_POLYPHASE_MDCT) || (CH0_state == `STATE_IMDCT_FREQ_INV)) && CH1_state == `STATE_WAIT_OTHER_CHANNEL)
		CH1_icg_address <= CH0_icg_address;
end

imdct_current_granule instance_CH1_imdct_current_granule(
    .clock(MAC_CLOCK_I), 
    .mem_en(CH1_icg_mem_en), 
    .wr_en(CH1_icg_wr_en), 
    .address(CH1_icg_address), 
    .data_in(CH1_icg_data_in), 
    .data_out(CH1_icg_data_out)
    );

// multiply and accumulate block
reg [1:0] CH0_add_accum_control;
reg [1:0] CH0_control_mux_a, CH0_control_mux_b;
reg [`DATA_WIDTH-1:0] CH0_mult_accum_data_a, CH0_mult_accum_data_b;
wire CH0_bypass_mult, CH0_constant_mult;

always @(CH0_state, CH0_counter, CH0_backup_pointer, CH0_aic_read_offset, 
	    CH0_aic_read_pointer, CH0_hold,
		// For long MDCT
		CH0_hold_buffer)
	    // For short MDCT
/*	    
	    , CH0_hold_buffer, mdct_level)
*/	    
begin
	CH0_add_accum_control <= `ACCUMULATOR_HOLD;

	// For short MDCT
/*	
	// !!!!!!!!!!!!!! //
	if (CH0_state == `STATE_POLYPHASE_MDCT)
	begin
		if ((CH0_counter[0]) || (mdct_level == 4'h9)) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else	CH0_add_accum_control <= `ACCUMULATOR_MAC;
		if (CH0_hold_buffer[1]) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else if (CH0_hold_buffer[0]) CH0_add_accum_control <= `ACCUMULATOR_MAC;
	end
	// !!!!!!!!!!!!!! //
*/	
	// For long MDCT
	if (CH0_state == `STATE_POLYPHASE_MDCT)
		if (CH0_counter[4:0] == 5'h00)
			if (CH0_backup_pointer[4]) CH0_add_accum_control <= `ACCUMULATOR_COMPLEMENT;
			else CH0_add_accum_control <= `ACCUMULATOR_HOLD;
		else if (CH0_counter[4:0] == 5'h01) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
			else if (CH0_hold_buffer && !CH0_backup_pointer[4]) CH0_add_accum_control <= `ACCUMULATOR_COMPLEMENT;
			else CH0_add_accum_control <= `ACCUMULATOR_MAC;
/*
	if (CH0_state == `STATE_POLYPHASE_MDCT)
		if (CH0_counter[4:0] == 5'h00)
			if (!CH0_backup_pointer[4]) CH0_add_accum_control <= `ACCUMULATOR_COMPLEMENT;
			else CH0_add_accum_control <= `ACCUMULATOR_HOLD;
		else if (CH0_counter[4:0] == 5'h01) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
			else CH0_add_accum_control <= `ACCUMULATOR_MAC;
*/			
	else	
	if (CH0_state == `STATE_POLYPHASE_WINDOW)
		if (CH0_counter[3:0] == 4'h1) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else CH0_add_accum_control <= `ACCUMULATOR_MAC;
	if (CH0_state == `STATE_LOAD_HALF_SB)
		if ((CH0_counter[3:0] > 0) && (CH0_counter[3:0] < 10))
			CH0_add_accum_control <= `ACCUMULATOR_LOAD;
	if (CH0_state == `STATE_ANTIALIAS)
		if (CH0_counter[5:0] < 34)
			if (CH0_counter[0]) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
			else if (CH0_counter[5:0] != 0) CH0_add_accum_control <= `ACCUMULATOR_MAC;
				else;
		else if (CH0_counter[5:0]==6'h24) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
	if (CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)
		if ((CH0_aic_read_offset == 5'h01) || (CH0_aic_read_offset == 5'h13) || (CH0_aic_read_offset == 5'h15)) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else CH0_add_accum_control <= `ACCUMULATOR_MAC;
	if (CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE)
		if ((CH0_aic_read_offset == 5'h01) || (CH0_aic_read_offset == 5'h13) || (CH0_aic_read_offset == 5'h14)) CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else CH0_add_accum_control <= `ACCUMULATOR_MAC;
	if ((CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) || 
	    (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_IPG))
		CH0_add_accum_control <= `ACCUMULATOR_LOAD;
	if ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD))
	begin
		if ((CH0_counter[2:0] == 3'h1) || (CH0_counter[2:0] == 3'h7)) 
			CH0_add_accum_control <= `ACCUMULATOR_LOAD;
		else 
			CH0_add_accum_control <= `ACCUMULATOR_MAC;
 	     if ((CH0_counter[2:0] == 3'h0) || (CH0_counter[2:0] == 3'h7 && 
			(!CH0_hold)) && (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND))
			if ((CH0_counter[6:3] == 4'h7) || (CH0_counter[6:0] == 7'h37) || (CH0_counter[6] == 1'b1))
				CH0_add_accum_control <= `ACCUMULATOR_HOLD;
			else 
				CH0_add_accum_control <= `ACCUMULATOR_MAC;
	end
	if (CH0_state == `STATE_IMDCT_FREQ_INV)
		if (CH0_counter[3:0] == 4'h2) CH0_add_accum_control <= `ACCUMULATOR_COMPLEMENT;
		else CH0_add_accum_control <= `ACCUMULATOR_LOAD;
end

wire CH0_acc_select;
assign CH0_acc_select = ((CH0_aic_read_offset == 5'h15) && 
                         (CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)) || 
					((CH0_aic_read_offset == 5'h14) && 
					(CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE));

always @(CH0_state, CH0_counter, CH0_aic_read_offset, 
	    CH0_acc_select, CH0_bypass_mult)
	    // For short MDCT
/*
			, mdct_level, CH0_hold_buffer) 
*/			
begin
	// For short MDCT
//	CH0_control_mux_a <= `PWC_SELECT;
	CH0_control_mux_a <= `PMC_SELECT;
	CH0_control_mux_b <= `ICG_SELECT;
	if (CH0_state == `STATE_LOAD_HALF_SB)
	begin
		CH0_control_mux_a <= `CON_SELECT;
		CH0_control_mux_b <= `DPR_SELECT;
	end
	if (CH0_state == `STATE_ANTIALIAS)
	begin
		CH0_control_mux_a <= `AIC_SELECT;
		if (CH0_counter == 6'h21 || CH0_counter == 6'h24)
			CH0_control_mux_a <= `CON_SELECT;
		CH0_control_mux_b <= `DPR_SELECT;
	end
	if  ((CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
	     (CH0_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE))
	begin
		CH0_control_mux_a <= `AIC_SELECT;
		if ((CH0_aic_read_offset == 5'h13) || CH0_acc_select)
		   CH0_control_mux_b <= `ACC_SELECT;
		else CH0_control_mux_b <= `ICG_SELECT;
	end
	if ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
	    (CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD))
	begin
		CH0_control_mux_a <= `AIC_SELECT;
		if (CH0_counter[2:0] == 3'h7) CH0_control_mux_b <= `ACC_SELECT;
		else CH0_control_mux_b <= `DPR_SELECT;
	end
	if (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_IPG)
		CH0_control_mux_a <= `CON_SELECT;
	if (CH0_state == `STATE_IMDCT_FREQ_INV)
		CH0_control_mux_a <= `CON_SELECT;

	// !!!!!!!!!!!!!! //
	// For short MDCT
/*	
	if (CH0_state == `STATE_POLYPHASE_MDCT)
	begin
		if (mdct_level == 4'h0 || mdct_level == 4'h1 || mdct_level == 4'h2 || 
		    mdct_level == 4'h3 || mdct_level == 4'h4 || mdct_level == 4'h9)
			CH0_control_mux_a <= `PWC_SELECT;
		else	CH0_control_mux_a <= `CON_SELECT;
		if (CH0_hold_buffer[1]) CH0_control_mux_b <= `ACC_SELECT;
		else	CH0_control_mux_b <= `ICG_SELECT;
	end
*/	
	// !!!!!!!!!!!!!! //
	// For long MDCT
	if (CH0_state == `STATE_POLYPHASE_MDCT)
	begin
		CH0_control_mux_a <= `PMC_SELECT;
		CH0_control_mux_b <= `ICG_SELECT;
	end
	if (CH0_state == `STATE_POLYPHASE_WINDOW)
	begin
		CH0_control_mux_a <= `PWC_SELECT;
		CH0_control_mux_b <= `PSB_SELECT;
	end
	if (CH0_bypass_mult)
		CH0_control_mux_a <= `CON_SELECT;
end

always  @(CH0_control_mux_a, CH0_control_mux_b, 
		pwc_data_out, CH0_aic_data_out,
		CH0_icg_data_out, CH0_psb_data_out, CH0_MAC_RAM_DATA_I, CH0_acc_out,
		CH0_ipg_data_out, CH0_constant_mult, CH0_acc_select, CH0_bypass_mult,
		CH0_state, CH0_acc_buffer,
		// For long MDCT
		pmc_data_out)
		// For short MDCT
/*		
		mdct_level) // 
*/		
begin
	case (CH0_control_mux_a)
			// For long MDCT
		 `PMC_SELECT: CH0_mult_accum_data_a <= pmc_data_out;
		 `PWC_SELECT: CH0_mult_accum_data_a <= pwc_data_out;
		 `AIC_SELECT: CH0_mult_accum_data_a <= CH0_aic_data_out;
		 default : CH0_mult_accum_data_a <= {1'b0,CH0_constant_mult,14'h0000}; 
	endcase
	case (CH0_control_mux_b)
		  // !!!!!!!!!!!!!!!! //
		  // For short MDCT
//		 `ICG_SELECT: CH0_mult_accum_data_b <= ((mdct_level[0]) && (CH0_state == `STATE_POLYPHASE_MDCT)) ? 
//		 								CH0_ipg_data_out : CH0_icg_data_out;
		 `ICG_SELECT: CH0_mult_accum_data_b <= CH0_icg_data_out;
		 `PSB_SELECT: CH0_mult_accum_data_b <= CH0_psb_data_out;
		 `DPR_SELECT: CH0_mult_accum_data_b <= CH0_MAC_RAM_DATA_I;
		 default : CH0_mult_accum_data_b <= CH0_acc_select ? CH0_acc_buffer : CH0_acc_out; 
	endcase
	if (CH0_bypass_mult) CH0_mult_accum_data_b <= CH0_ipg_data_out;
	// !!!!!!!!!!!!!!!! //
end

assign CH0_constant_mult = (CH0_state == `STATE_LOAD_HALF_SB) || (CH0_state == `STATE_ANTIALIAS) ||
				   (CH0_state == `STATE_IMDCT_FREQ_INV) || CH0_bypass_mult;
				   // For short MDCT
/*				   
				   ||
				   ((CH0_state == `STATE_POLYPHASE_MDCT) && 
				  (((mdct_level == 4'h5) && ((CH0_counter[0]) || (CH0_counter[2:0] == 3'h6))) || 
				   ((mdct_level == 4'h6) && ((CH0_counter[0]) || (CH0_counter[3] && !CH0_counter[0] && (CH0_counter[2:1] != 2'b00)))) ||
				   ((mdct_level == 4'h7) && ((CH0_counter[0]) || (CH0_counter[4] && !CH0_counter[0] && (CH0_counter[3:1] != 3'b000)))) ||
				   ((mdct_level == 4'h8) && ((CH0_counter[0]) || (CH0_counter[5] && !CH0_counter[0] && (CH0_counter[4:1] != 4'b0000))))));
*/				   
assign CH0_bypass_mult = (CH0_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) ||
				 ((CH0_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
				  ((CH0_aic_read_offset == 5'h14) || (CH0_aic_read_offset == 5'h16))) ||
				 ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) &&
				  (CH0_counter[2:0] == 3'h0) && (CH0_counter[6:3] != 4'h0)) ||				  
				 ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) &&
				(((CH0_counter[2:0] == 3'h0) && (CH0_counter[6:3] != 4'h0)) ||
				 ((CH0_counter[2:0] == 3'h7) && (!CH0_hold)))) || 
				  ((CH0_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD) &&
				   (CH0_counter[2:0] == 3'h0) && (CH0_counter[6:3] != 4'h0));

mult_accum instance_CH0_mult_accum (
    .clock(MAC_CLOCK_I), 
    .resetn(MAC_RESETN_I), 
    .control(CH0_add_accum_control),
    .data_a(CH0_mult_accum_data_a), 
    .data_b(CH0_mult_accum_data_b), 
    .acc_out(CH0_acc_out)
    );

// next channel
// multiply and accumulate block
reg [1:0] CH1_add_accum_control;
reg [1:0] CH1_control_mux_a, CH1_control_mux_b;
reg [`DATA_WIDTH-1:0] CH1_mult_accum_data_a, CH1_mult_accum_data_b;
wire CH1_bypass_mult, CH1_constant_mult;

always @(CH1_state, CH1_counter, CH1_backup_pointer, CH1_aic_read_offset, CH1_aic_read_pointer, CH1_hold,
				CH0_state, CH0_add_accum_control)
begin
	CH1_add_accum_control <= `ACCUMULATOR_HOLD;

	if (CH1_state == `STATE_LOAD_HALF_SB)
		if ((CH1_counter[3:0] > 0) && (CH1_counter[3:0] < 10))
			CH1_add_accum_control <= `ACCUMULATOR_LOAD;
	if (CH1_state == `STATE_ANTIALIAS)
		if (CH1_counter[5:0] < 34)
			if (CH1_counter[0]) CH1_add_accum_control <= `ACCUMULATOR_LOAD;
			else if (CH1_counter[5:0] != 0) CH1_add_accum_control <= `ACCUMULATOR_MAC;
				else;
		else if (CH1_counter[5:0]==6'h24) CH1_add_accum_control <= `ACCUMULATOR_LOAD;
	if (CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)
		if ((CH1_aic_read_offset == 5'h01) || (CH1_aic_read_offset == 5'h13) || (CH1_aic_read_offset == 5'h15)) CH1_add_accum_control <= `ACCUMULATOR_LOAD;
		else CH1_add_accum_control <= `ACCUMULATOR_MAC;
	if (CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE)
		if ((CH1_aic_read_offset == 5'h01) || (CH1_aic_read_offset == 5'h13) || (CH1_aic_read_offset == 5'h14)) CH1_add_accum_control <= `ACCUMULATOR_LOAD;
		else CH1_add_accum_control <= `ACCUMULATOR_MAC;
	if ((CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) || 
	    (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_IPG))
		CH1_add_accum_control <= `ACCUMULATOR_LOAD;
	if ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) || 
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD))
	begin
		if ((CH1_counter[2:0] == 3'h1) || (CH1_counter[2:0] == 3'h7)) 
			CH1_add_accum_control <= `ACCUMULATOR_LOAD;
		else 
			CH1_add_accum_control <= `ACCUMULATOR_MAC;
 	     if ((CH1_counter[2:0] == 3'h0) || (CH1_counter[2:0] == 3'h7 && 
			(!CH1_hold)) && (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND))
			if ((CH1_counter[6:3] == 4'h7) || (CH1_counter[6:0] == 7'h37) || (CH1_counter[6] == 1'b1))
				CH1_add_accum_control <= `ACCUMULATOR_HOLD;
			else 
				CH1_add_accum_control <= `ACCUMULATOR_MAC;
	end

	if (((CH0_state == `STATE_IMDCT_FREQ_INV) || 
	     (CH0_state == `STATE_POLYPHASE_MDCT) || 
		(CH0_state == `STATE_POLYPHASE_WINDOW)) && 
		(CH1_state == `STATE_WAIT_OTHER_CHANNEL))
		CH1_add_accum_control <= CH0_add_accum_control;
end

wire CH1_acc_select;
assign CH1_acc_select = ((CH1_aic_read_offset == 5'h15) && 
                         (CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE)) || 
					((CH1_aic_read_offset == 5'h14) && 
					(CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE));

always @(CH1_state, CH1_counter, CH1_aic_read_offset, CH0_state, 
	    CH0_control_mux_a, CH0_control_mux_b, CH1_acc_select, CH1_bypass_mult)
begin
	CH1_control_mux_a <= `PMC_SELECT;
	CH1_control_mux_b <= `ICG_SELECT;
	if (CH1_state == `STATE_LOAD_HALF_SB)
	begin
		CH1_control_mux_a <= `CON_SELECT;
		CH1_control_mux_b <= `DPR_SELECT;
	end
	if (CH1_state == `STATE_ANTIALIAS)
	begin
		CH1_control_mux_a <= `AIC_SELECT;
		if (CH1_counter == 6'h21 || CH1_counter == 6'h24)
			CH1_control_mux_a <= `CON_SELECT;
		CH1_control_mux_b <= `DPR_SELECT;
	end
	if  ((CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) ||
	     (CH1_state == `STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE))
	begin
		CH1_control_mux_a <= `AIC_SELECT;
		if ((CH1_aic_read_offset == 5'h13) || CH1_acc_select)
		   CH1_control_mux_b <= `ACC_SELECT;
		else CH1_control_mux_b <= `ICG_SELECT;
	end
	if ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) ||
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) ||
	    (CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD))
	begin
		CH1_control_mux_a <= `AIC_SELECT;
		if (CH1_counter[2:0] == 3'h7) CH1_control_mux_b <= `ACC_SELECT;
		else CH1_control_mux_b <= `DPR_SELECT;
	end
	if (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_IPG)
		CH1_control_mux_a <= `CON_SELECT;

	if (((CH0_state == `STATE_POLYPHASE_MDCT) || 
		(CH0_state == `STATE_IMDCT_FREQ_INV) ||
		(CH0_state == `STATE_POLYPHASE_WINDOW)) && 
		(CH1_state == `STATE_WAIT_OTHER_CHANNEL))
	begin
		CH1_control_mux_a <= CH0_control_mux_a;
		CH1_control_mux_b <= CH0_control_mux_b;
	end

	if (CH1_bypass_mult)
		CH1_control_mux_a <= `CON_SELECT;
end

always  @(CH1_control_mux_a, CH1_control_mux_b, 
		pwc_data_out, CH1_aic_data_out,
		CH1_icg_data_out, CH1_psb_data_out, CH1_MAC_RAM_DATA_I, CH1_acc_out,
		CH1_ipg_data_out, CH1_constant_mult, CH1_acc_select, CH1_bypass_mult, CH1_acc_buffer, 
		CH0_state, CH1_state,
		// For long MDCT
		pmc_data_out)
		// For short MDCT
/*		
		mdct_level)
*/		
begin
	case (CH1_control_mux_a)
		 `PMC_SELECT: CH1_mult_accum_data_a <= pmc_data_out;
		 `PWC_SELECT: CH1_mult_accum_data_a <= pwc_data_out;
		 `AIC_SELECT: CH1_mult_accum_data_a <= CH1_aic_data_out;
		 default : CH1_mult_accum_data_a <= {1'b0,CH1_constant_mult,14'h0000}; 
	endcase
	case (CH1_control_mux_b)
			// For short MDCT
//		 `ICG_SELECT: CH1_mult_accum_data_b <= ((mdct_level[0]) && (CH0_state == `STATE_POLYPHASE_MDCT) && CH1_state == `STATE_WAIT_OTHER_CHANNEL) ? 
//		 								CH1_ipg_data_out : CH1_icg_data_out;
		 `ICG_SELECT: CH1_mult_accum_data_b <= CH1_icg_data_out;
		 `PSB_SELECT: CH1_mult_accum_data_b <= CH1_psb_data_out;
		 `DPR_SELECT: CH1_mult_accum_data_b <= CH1_MAC_RAM_DATA_I;
		 default : CH1_mult_accum_data_b <= CH1_acc_select ? CH1_acc_buffer : CH1_acc_out; 
	endcase
	if (CH1_bypass_mult) CH1_mult_accum_data_b <= CH1_ipg_data_out;
end

assign CH1_constant_mult = (CH1_state == `STATE_LOAD_HALF_SB) || (CH1_state == `STATE_ANTIALIAS) ||
				   	  (CH0_constant_mult && 
				   	  // For short MDCT
//					 ((CH0_state == `STATE_POLYPHASE_MDCT) || 
//					  (CH0_state == `STATE_IMDCT_FREQ_INV)) && 
						(CH0_state == `STATE_IMDCT_FREQ_INV) &&
					  (CH1_state == `STATE_WAIT_OTHER_CHANNEL)) || 
					   CH1_bypass_mult;

assign CH1_bypass_mult = (CH1_state == `STATE_IMDCT_BLOCK2_LOAD_ICG) ||
				    ((CH1_state == `STATE_IMDCT_BLOCK0_CURRENT_GRANULE) && 
				  ((CH1_aic_read_offset == 5'h14) || (CH1_aic_read_offset == 5'h16))) ||
				 ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_FIRST) &&
				  (CH1_counter[2:0] == 3'h0) && (CH1_counter[6:3] != 4'h0)) ||				  
				 ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_SECOND) &&
				(((CH1_counter[2:0] == 3'h0) && (CH1_counter[6:3] != 4'h0)) ||
				 ((CH1_counter[2:0] == 3'h7) && (!CH1_hold)))) || 
				  ((CH1_state == `STATE_IMDCT_BLOCK2_COMPUTE_THIRD) &&
				   (CH1_counter[2:0] == 3'h0) && (CH1_counter[6:3] != 4'h0));

mult_accum instance_CH1_mult_accum (
    .clock(MAC_CLOCK_I), 
    .resetn(MAC_RESETN_I), 
    .control(CH1_add_accum_control),
    .data_a(CH1_mult_accum_data_a), 
    .data_b(CH1_mult_accum_data_b), 
    .acc_out(CH1_acc_out)
    );

// outputs to the dual port PCM RAM from which AC97 controller is reading
assign CH0_PCM_RAM_WE_O = (CH0_counter[3:0] == 4'h1) && (CH0_counter[10:4] != 7'h00) && 
				  (CH0_state == `STATE_POLYPHASE_WINDOW);
assign CH0_PCM_RAM_DATA_O = CH0_acc_out; 
assign CH0_PCM_RAM_ADDRESS_O = {PCM_RAM_pointer[4:0], CH0_backup_pointer[4:0]}; 

assign CH1_PCM_RAM_WE_O = CH0_PCM_RAM_WE_O;
assign CH1_PCM_RAM_DATA_O = CH1_acc_out & {16{(CH1_state == `STATE_WAIT_OTHER_CHANNEL)}};  // write zero to DP_RAM if mono
assign CH1_PCM_RAM_ADDRESS_O = CH0_PCM_RAM_ADDRESS_O;

// outputs to the dual port MAC RAM to which Huffman/Dequantizer unit is writing
reg [3:0] CH0_MAC_RAM_offset;

always @(CH0_state, CH0_counter, CH0_antialias_rev_counter)
begin
	if (CH0_state == `STATE_ANTIALIAS)
		if (CH0_counter[0]) CH0_MAC_RAM_offset <= CH0_counter[5:2];
		else CH0_MAC_RAM_offset <= CH0_antialias_rev_counter;
	else	CH0_MAC_RAM_offset <= CH0_counter[3:0];
end

assign CH0_MAC_RAM_ADDRESS_O = (CH0_state == `STATE_ANTIALIAS) || (CH0_state == `STATE_LOAD_HALF_SB) ?
					  {CH0_MAC_RAM_pointer, CH0_MAC_RAM_offset} :
					  {CH0_MAC_RAM_pointer[4:0], CH0_block2_read_pointer, CH0_counter[2:0]};
assign CH0_MAC_RAM_EN_O = ~(CH0_state == `STATE_INITIAL 
					|| CH0_state == `STATE_POLYPHASE_MDCT 
					|| CH0_state == `STATE_POLYPHASE_WINDOW);

reg [3:0] CH1_MAC_RAM_offset;

always @(CH1_state, CH1_counter, CH1_antialias_rev_counter)
begin
	if (CH1_state == `STATE_ANTIALIAS)
		if (CH1_counter[0]) CH1_MAC_RAM_offset <= CH1_counter[5:2];
		else CH1_MAC_RAM_offset <= CH1_antialias_rev_counter;
	else	CH1_MAC_RAM_offset <= CH1_counter[3:0];
end

assign CH1_MAC_RAM_ADDRESS_O = (CH1_state == `STATE_ANTIALIAS) || (CH1_state == `STATE_LOAD_HALF_SB) ?
					  {CH1_MAC_RAM_pointer, CH1_MAC_RAM_offset} :
					  {CH1_MAC_RAM_pointer[4:0], CH1_block2_read_pointer, CH1_counter[2:0]};

assign CH1_MAC_RAM_EN_O = CH0_MAC_RAM_EN_O;

// outputs to the global controller which will decide when to turn again the MAC unit
assign MAC_DONE_O = (CH0_state == `STATE_INITIAL && CH1_state == `STATE_INITIAL);

endmodule
