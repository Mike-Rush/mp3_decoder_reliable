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

module clock_gen (
	RESETN_I,
	MASTER_CLOCK_I,
//	ALTERNATE_CLOCK_I,
	AC97_BIT_CLOCK_I,
	MASTER_CLOCK_O,
	MAC_CLOCK_O,
	HUFF_CLOCK_O,
	AC97_BIT_CLOCK_O,
	CLOCK_READY_O
);

input RESETN_I;
input MASTER_CLOCK_I;
//input ALTERNATE_CLOCK_I;
input AC97_BIT_CLOCK_I;
output MASTER_CLOCK_O;
output HUFF_CLOCK_O;
output MAC_CLOCK_O;
output AC97_BIT_CLOCK_O;
output CLOCK_READY_O;

wire mac_clock;
wire mac_clock_locked;
wire mac_master_clock;
wire mac_clock_fb;
//output mac_clock_fb;

wire huff_clock;
wire huff_clock_locked;
wire huff_master_clock;
wire huff_clock_fb;
//output huff_clock_fb;

reg [15:0] 	dcm_reset_counter;
reg 		terminal_count;
wire dcm_reset;

//create a reset pulse for the DCM triggered by FPGA DONE
assign enable_reset_counter = !terminal_count;

initial
	begin
		dcm_reset_counter = 16'h0000;
	end

always @ (posedge MASTER_CLOCK_O or negedge RESETN_I) begin
	if (RESETN_I == 1'b0) dcm_reset_counter <= 16'h0;
	else
		if (enable_reset_counter) begin
			dcm_reset_counter <= dcm_reset_counter +1;
		end
end

always @ (dcm_reset_counter) begin
	if (dcm_reset_counter == 16'hFFFF)begin
		terminal_count = 1'b1;
	end
	else begin
		terminal_count = 1'b0;
	end
end

assign dcm_reset = !dcm_reset_counter[15];

assign CLOCK_READY_O = mac_clock_locked & huff_clock_locked;

/*
always @ (posedge alternate_clock) begin
	if (counter < 'd10) counter <= counter + 1;
	else counter <= 'd0;

	if (counter < 5) MAC_clock <= 1'b0;
	else MAC_clock <= 1'b1;
end
*/
	 IBUFG BIT_CLOCK (
	.I(AC97_BIT_CLOCK_I), 
	.O(AC97_BIT_CLOCK_O)
    );

	 BUFG MAC_CLOCK (
	.I(mac_clock), 
	.O(MAC_CLOCK_O)
    );

	 BUFG HUFF_CLOCK (
	.I(huff_clock), 
	.O(HUFF_CLOCK_O)
    );
		
	 IBUF MASTER_CLOCK (
	.I(MASTER_CLOCK_I), 
	.O(MASTER_CLOCK_O)
    );
/*
	 IBUF ALTERNATE_CLOCK (
	.I(ALTERNATE_CLOCK_I), 
	.O(alternate_clock)
    );
*/
	 // DCM: Digital Clock Manager Circuit for Virtex-II/II-Pro and Spartan-3
   // Xilinx HDL Language Template version 6.3.1i
	DCM MAC_DCM (
		.CLKFB(mac_clock_fb), 
		.CLKIN(MASTER_CLOCK_O), 
		.DSSEN(1'b0), 
		.PSCLK(1'b0), 
		.PSEN(1'b0), 
		.PSINCDEC(1'b0), 
		.RST(dcm_reset),
		.CLK0(mac_master_clock), 
		.CLK90(), 
		.CLK180(), 
		.CLK270(), 
		.CLK2X(), 
		.CLK2X180(),
		.CLKDV(mac_clock), 
		.CLKFX(), 
		.CLKFX180(), 
		.LOCKED(mac_clock_locked), 
		.PSDONE(), 
		.STATUS()
	);

	BUFG MAC_FB_CLOCK (
	.I(mac_master_clock), 
	.O(mac_clock_fb)
    );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the DCM. If the instance name is changed, these defparams need to be updated accordingly.
// synthesis attribute DLL_FREQUENCY_MODE of MAC_DCM is "LOW";
// synthesis attribute DUTY_CYCLE_CORRECTION of MAC_DCM is "TRUE";
// synthesis attribute STARTUP_WAIT of MAC_DCM is "FALSE";
// synthesis attribute DFS_FREQUENCY_MODE of MAC_DCM is "LOW";
// synthesis attribute CLKFX_DIVIDE of MAC_DCM is 1;
// synthesis attribute CLKFX_MULTIPLY of MAC_DCM is 2;
// synthesis attribute CLK_FEEDBACK of MAC_DCM is "1X";
// synthesis attribute CLKOUT_PHASE_SHIFT of MAC_DCM is "NONE";
// synthesis attribute PHASE_SHIFT of MAC_DCM is 0;

// synthesis attribute CLKDV_DIVIDE of MAC_DCM is 7;
// synthesis attribute CLKIN_DIVIDE_BY_2 of MAC_DCM is "FALSE";
// synthesis attribute CLKIN_PERIOD of MAC_DCM is 3.7;

// synthesis translate_off

   defparam MAC_DCM.CLKDV_DIVIDE = 7;  // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                           //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   defparam MAC_DCM.CLKFX_DIVIDE = 1;    // Can be any interger from 1 to 32
   defparam MAC_DCM.CLKFX_MULTIPLY = 4;  // Can be any integer from 2 to 32
   defparam MAC_DCM.CLKIN_DIVIDE_BY_2 = "FALSE"; // TRUE/FALSE to enable CLKIN divide by two feature
   defparam MAC_DCM.CLKIN_PERIOD = 37.0;  // Specify period of input clock
   defparam MAC_DCM.CLKOUT_PHASE_SHIFT = "NONE"; // Specify phase shift of NONE, FIXED or VARIABLE
   defparam MAC_DCM.CLK_FEEDBACK = "1X";  // Specify clock feedback of NONE, 1X or 2X
   defparam MAC_DCM.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS"; // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                                            //   an integer from 0 to 15
   defparam MAC_DCM.DFS_FREQUENCY_MODE = "LOW";  // HIGH or LOW frequency mode for frequency synthesis
   defparam MAC_DCM.DLL_FREQUENCY_MODE = "LOW";  // HIGH or LOW frequency mode for DLL
   defparam MAC_DCM.DUTY_CYCLE_CORRECTION = "TRUE"; // Duty cycle correction, TRUE or FALSE
   defparam MAC_DCM.FACTORY_JF = 16'hC080;   // FACTORY JF Values
   defparam MAC_DCM.PHASE_SHIFT = 0;     // Amount of fixed phase shift from -255 to 255
   defparam MAC_DCM.STARTUP_WAIT = "FALSE";   // Delay configuration DONE until DCM LOCK, TRUE/FALSE

   // End of DCM_inst instantiation
// synthesis translate_on

	 // DCM: Digital Clock Manager Circuit for Virtex-II/II-Pro and Spartan-3
   // Xilinx HDL Language Template version 6.3.1i
	DCM HUFF_DCM (
		.CLKFB(huff_clock_fb), 
		.CLKIN(MASTER_CLOCK_O), 
		.DSSEN(1'b0), 
		.PSCLK(1'b0), 
		.PSEN(1'b0), 
		.PSINCDEC(1'b0), 
		.RST(dcm_reset),
		.CLK0(huff_master_clock), 
		.CLK90(), 
		.CLK180(), 
		.CLK270(), 
		.CLK2X(), 
		.CLK2X180(),
		.CLKDV(huff_clock), 
		.CLKFX(), 
		.CLKFX180(), 
		.LOCKED(huff_clock_locked), 
		.PSDONE(), 
		.STATUS()
	);

	BUFG HUFF_FB_CLOCK (
	.I(huff_master_clock), 
	.O(huff_clock_fb)
    );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the DCM. If the instance name is changed, these defparams need to be updated accordingly.
// synthesis attribute DLL_FREQUENCY_MODE of HUFF_DCM is "LOW";
// synthesis attribute DUTY_CYCLE_CORRECTION of HUFF_DCM is "TRUE";
// synthesis attribute STARTUP_WAIT of HUFF_DCM is "FALSE";
// synthesis attribute DFS_FREQUENCY_MODE of HUFF_DCM is "LOW";
// synthesis attribute CLKFX_DIVIDE of HUFF_DCM is 1;
// synthesis attribute CLKFX_MULTIPLY of HUFF_DCM is 2;
// synthesis attribute CLK_FEEDBACK of HUFF_DCM is "1X";
// synthesis attribute CLKOUT_PHASE_SHIFT of HUFF_DCM is "NONE";
// synthesis attribute PHASE_SHIFT of HUFF_DCM is 0;

// synthesis attribute CLKDV_DIVIDE of HUFF_DCM is 16;
// synthesis attribute CLKIN_DIVIDE_BY_2 of HUFF_DCM is "FALSE";
// synthesis attribute CLKIN_PERIOD of HUFF_DCM is 3.7;

// synthesis translate_off

   defparam HUFF_DCM.CLKDV_DIVIDE = 16;  // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                           //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   defparam HUFF_DCM.CLKFX_DIVIDE = 1;    // Can be any interger from 1 to 32
   defparam HUFF_DCM.CLKFX_MULTIPLY = 4;  // Can be any integer from 2 to 32
   defparam HUFF_DCM.CLKIN_DIVIDE_BY_2 = "FALSE"; // TRUE/FALSE to enable CLKIN divide by two feature
   defparam HUFF_DCM.CLKIN_PERIOD = 37.0;  // Specify period of input clock
   defparam HUFF_DCM.CLKOUT_PHASE_SHIFT = "NONE"; // Specify phase shift of NONE, FIXED or VARIABLE
   defparam HUFF_DCM.CLK_FEEDBACK = "1X";  // Specify clock feedback of NONE, 1X or 2X
   defparam HUFF_DCM.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS"; // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                                            //   an integer from 0 to 15
   defparam HUFF_DCM.DFS_FREQUENCY_MODE = "LOW";  // HIGH or LOW frequency mode for frequency synthesis
   defparam HUFF_DCM.DLL_FREQUENCY_MODE = "LOW";  // HIGH or LOW frequency mode for DLL
   defparam HUFF_DCM.DUTY_CYCLE_CORRECTION = "TRUE"; // Duty cycle correction, TRUE or FALSE
   defparam HUFF_DCM.FACTORY_JF = 16'hC080;   // FACTORY JF Values
   defparam HUFF_DCM.PHASE_SHIFT = 0;     // Amount of fixed phase shift from -255 to 255
   defparam HUFF_DCM.STARTUP_WAIT = "FALSE";   // Delay configuration DONE until DCM LOCK, TRUE/FALSE

   // End of DCM_inst instantiation

// synthesis translate_on

endmodule
