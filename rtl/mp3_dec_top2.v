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


//`default_nettype none // disable inference of nets

`timescale 1 ns/ 100 ps

`include "defines.v"
`define GSTAGE_INIT  		0
`define GSTAGE_HUFF  		1
`define GSTAGE_MAC 	 		2
`define GSTAGE_PRE_MAC 		3
module mp3_dec_top2 (
	input MASTER_CLOCK_I,
//	ALTERNATE_CLOCK_I,
	input AC97_BIT_CLOCK_I,
	input global_rst_n,
	input module_en,
	input sample_clk,
	input [15:0] fifo_datain,
    output fifo_ren
//	AC97_SYNCH_O,
//	AC97_DATA_IN_I,
//	AC97_DATA_OUT_O,
//	AC97_BEEP_TONE_O,
//	PAL_NTSC,
//	S_VIDEO,
//	USER_LED0_O,			 
//	USER_LED1_O,
//	STARTUP_O
);

//    input MASTER_CLOCK_I;
//	 input ALTERNATE_CLOCK_I;
//    input AC97_BIT_CLOCK_I;		// AC97 clock
//    output AC97_SYNCH_O;			// AC97 synh output
//    input AC97_DATA_IN_I;			// AC97 data in
//    output AC97_DATA_OUT_O;		// AC97 data out
//    output AC97_BEEP_TONE_O;		// AC97 Beep setting
//    input global_rst_n;			// reset signal
//    input module_en;
//	 input PAL_NTSC;
//	 input S_VIDEO;
//    output USER_LED0_O;
//    output USER_LED1_O;
//    output STARTUP_O;

	// Clock trees
	reg 								Clock_resetn;
	wire 								Clock_ready;
	wire 								MAC_clock;
	wire 								HUFF_clock;
	wire 								AC97_bit_clock;
	wire 								master_clock;
   
	// For memory controller
	reg 								ETH_resetn;
	/*reg 								ETH_start;
	wire 								ETH_done;
	wire [`ADDRESS_WIDTH-1:0] 	ETH_DP_ADDRESS;
	wire [`DATA_WIDTH-1:0] 		ETH_DP_DATA;
	wire 								ETH_DP_WE;
	wire 								ETH_DP_EN;*/

	reg								MP3_end_of_song;
	wire [1:0] 						MP3_Info_Mode;
	reg [1:0] 						MP3_Info_Mode_buffer;
	reg [1:0] 						MP3_Info_Mode_MAC_clock;
	wire [1:0] 						MP3_Info_Frequency;
	reg [1:0] 						MP3_Info_Frequency_buffer;

	// for Huff/Dequantizer
	reg 								HUFF_resetn;
	wire								HUFF_done;
	reg 								MAC_RAM_Idle;

	wire [`DATA_WIDTH-1:0] 		HUFF_DP_DATA;
	wire [`ADDRESS_WIDTH-1:0] 	HUFF_DP_ADDRESS;

	//for REQ RAMs
	wire 								Req_RAM_we;
	wire [`DATA_WIDTH-1:0] 		Req_RAM_write_data;
	wire [`DATA_WIDTH-1:0] 		Req_RAM_read_data;
	wire [`ADDRESS_WIDTH-1:0] 	Req_RAM_address;

	wire 								BR_RAM_we;
	wire [`DATA_WIDTH-1:0] 		BR_RAM_write_data;
	wire [`DATA_WIDTH-1:0] 		BR_RAM_read_data;
	wire [`ADDRESS_WIDTH-3:0] 	BR_RAM_address;
	
	wire [`ADDRESS_WIDTH-1:0] 	MAC_RAM_write_address;
	wire [`DATA_WIDTH-1:0] 		MAC_RAM_write_data;
	wire 								CH0_MAC_RAM_we;
	wire 								CH1_MAC_RAM_we;

	// for MAC
	wire [3:0]						CH0_WBBM;
	reg [1:0] 						MAC_state;
	wire [1:0] 						MP3_Info_CH0_MAC_block_type;
	wire 		 						MP3_Info_CH0_MAC_mixed_block;
	wire 		 						MP3_Info_CH0_MAC_switching;
	reg [1:0] 						MP3_Info_CH0_MAC_block_type_buffer;
	reg 		 						MP3_Info_CH0_MAC_mixed_block_buffer;
	reg 		 						MP3_Info_CH0_MAC_switching_buffer;
	reg [1:0] 						MP3_Info_CH0_MAC_block_type_MAC_clock;
	reg 		 						MP3_Info_CH0_MAC_mixed_block_MAC_clock;
	reg 		 						MP3_Info_CH0_MAC_switching_MAC_clock;

	assign MP3_Info_CH0_MAC_switching = CH0_WBBM[3];
	assign MP3_Info_CH0_MAC_block_type = CH0_WBBM[2:1];
	assign MP3_Info_CH0_MAC_mixed_block = CH0_WBBM[0];

	wire [3:0]						CH1_WBBM;
	wire [1:0] 						MP3_Info_CH1_MAC_block_type;
	wire 		 						MP3_Info_CH1_MAC_mixed_block;
	wire 		 						MP3_Info_CH1_MAC_switching;
	reg [1:0] 						MP3_Info_CH1_MAC_block_type_buffer;
	reg 		 						MP3_Info_CH1_MAC_mixed_block_buffer;
	reg 		 						MP3_Info_CH1_MAC_switching_buffer;
	reg [1:0] 						MP3_Info_CH1_MAC_block_type_MAC_clock;
	reg 		 						MP3_Info_CH1_MAC_mixed_block_MAC_clock;
	reg 		 						MP3_Info_CH1_MAC_switching_MAC_clock;

	assign MP3_Info_CH1_MAC_switching = CH1_WBBM[3];
	assign MP3_Info_CH1_MAC_block_type = CH1_WBBM[2:1];
	assign MP3_Info_CH1_MAC_mixed_block = CH1_WBBM[0];
	reg 								MAC_resetn;

	reg 								CH0_MAC_start;
	wire [`ADDRESS_WIDTH-1:0] 	CH0_MAC_RAM_read_address;
	wire [`DATA_WIDTH-1:0] 		CH0_MAC_RAM_read_data;
	wire 								CH0_MAC_RAM_read_en_MAC_clock;
	reg 								CH0_MAC_RAM_read_en_HUFF_clock;
	reg [`ADDRESS_WIDTH-1:0] 	CH0_PCM_RAM_write_address_buffer;

	wire [`DATA_WIDTH-1:0] 		CH0_PCM_RAM_write_data;
	wire [`ADDRESS_WIDTH-1:0] 	CH0_PCM_RAM_write_address;
	wire 								CH0_PCM_RAM_we;

	reg 								CH1_MAC_start;
	wire [`ADDRESS_WIDTH-1:0] 	CH1_MAC_RAM_read_address;
	wire [`DATA_WIDTH-1:0] 		CH1_MAC_RAM_read_data;
	wire 								CH1_MAC_RAM_read_en_MAC_clock;
	reg 								CH1_MAC_RAM_read_en_HUFF_clock;

	wire [`DATA_WIDTH-1:0] 		CH1_PCM_RAM_write_data;
	wire [`ADDRESS_WIDTH-1:0] 	CH1_PCM_RAM_write_address;
	wire 								CH1_PCM_RAM_we;

	wire 								MAC_done;

	// For AC97
	reg 								AC97_resetn;
	/*reg [1:0] 						sample_frequency;
	wire [`ADDRESS_WIDTH-1:0] 	PCM_RAM_read_address_bit_clock;
	reg [`ADDRESS_WIDTH-1:0] 	PCM_RAM_read_address_MAC_clock;
	wire [`DATA_WIDTH-1:0] 		CH0_PCM_RAM_read_data;
	wire [`DATA_WIDTH-1:0] 		CH1_PCM_RAM_read_data;
	wire 								AC97_source_select;*/

	reg [5:0] GS;

	/*wire [`DATA_WIDTH-1:0] pcm_ch0_data,pcm_ch1_data;
	assign pcm_ch0_data=CH0_PCM_RAM_read_data;
	assign pcm_ch1_data=CH1_PCM_RAM_read_data;*/
	//reg [1:0] AC97_sample_frequency_cur_granule, AC97_sample_frequency_prv_granule;
	
//	reg [2:0] state;

	// Internal reg
	reg system_ready;
	/*clock_gen clock_module (
		.RESETN_I(Clock_resetn),
		.MASTER_CLOCK_I(MASTER_CLOCK_I),
//		.ALTERNATE_CLOCK_I(ALTERNATE_CLOCK_I),
		.AC97_BIT_CLOCK_I(AC97_BIT_CLOCK_I),
		.MASTER_CLOCK_O(master_clock),
		.MAC_CLOCK_O(MAC_clock),
		.HUFF_CLOCK_O(HUFF_clock),
		.AC97_BIT_CLOCK_O(AC97_bit_clock),
		.CLOCK_READY_O(Clock_ready)
	);*/
	assign AC97_bit_clock=AC97_BIT_CLOCK_I;
	assign master_clock=MASTER_CLOCK_I;
	assign MAC_clock=master_clock;
	assign HUFF_clock=master_clock;
	assign Clock_ready=1'b1;


	/*memctl32 memfill(
    .CLOCK_I(MAC_clock),
    .RESETN_I(ETH_resetn),
    .START_I(ETH_start),
    .ADDRESS_O(ETH_DP_ADDRESS),
    .DATA_O(ETH_DP_DATA),
    .WE_O(ETH_DP_WE),
    .EN_O(ETH_DP_EN),
    .DONE_O(ETH_done)
  );*/    

	// DP RAM between Huffman and Ethernet
  /*RAMB16_S18_S18 HUFF_DP (
		// output from Ethernet
    .DOA(),
    .DOPA(),
    .ADDRA(ETH_DP_ADDRESS),
    .CLKA(MAC_clock),
    .DIA(ETH_DP_DATA),
    .DIPA(2'b00),
    .ENA(ETH_DP_EN),
    .SSRA(1'b0),
    .WEA(ETH_DP_WE),

		// input to HUFF	 
	 .DOB(HUFF_DP_DATA),
    .DOPB(),
    .ADDRB(HUFF_DP_ADDRESS),
    .CLKB(HUFF_clock),
    .DIB(16'h0000),
    .DIPB(2'b00),
    .ENB(1'b1),
    .SSRB(1'b0),
	 .WEB(1'b0)
  );*/

  //wire skipframe4;
	// New huffman and requantizer with one RAM
reg [`ADDRESS_WIDTH-1:0] HUFF_DP_ADDRESS_BUF;
always @(posedge HUFF_clock or negedge global_rst_n)
begin
	if (!global_rst_n) HUFF_DP_ADDRESS_BUF<=0;
	else HUFF_DP_ADDRESS_BUF<=HUFF_DP_ADDRESS;
end
assign fifo_ren=(HUFF_DP_ADDRESS[0]!=HUFF_DP_ADDRESS_BUF[0]);
assign HUFF_DP_DATA=fifo_datain;
	huffctl HUFFMANDECODER (
	 //.skipframe4(skipframe4),
    .CLK_I(HUFF_clock),
    .RESETN_I(HUFF_resetn),
    
    .HUFF_DONE_O(HUFF_done),
    .MAC_READY_I(MAC_RAM_Idle),
    .DUAL_SELECT_I(1'b0),
    .WBBM_O(CH1_WBBM),
    .WBBML_O(CH0_WBBM),
    
    .GR_O(),
    .CH_O(),
    .NCH_O(),
    .SAMPLE_FREQUENCY_O(MP3_Info_Frequency),
    .MODE_O(MP3_Info_Mode),
    .MODE_EXTENSION_O(),
    
    .RAM_ADDRESS_O(Req_RAM_address),
    .RAM_WE_O(Req_RAM_we),
    .RAM_DATAIN_O(Req_RAM_write_data),
    .RAM_DATAOUT_I(Req_RAM_read_data),
    
    .DPR_ADDRESS_O(HUFF_DP_ADDRESS),
    .DPR_DATAOUT_I(HUFF_DP_DATA),
    
    .BR_ADDRESS_O(BR_RAM_address),
    .BR_DATAIN_O(BR_RAM_write_data),
    .BR_WE_O(BR_RAM_we),
    .BR_DATAOUT_I(BR_RAM_read_data),
    
    //.RIGHTCHANNEL_DATAIN_O(rightchannel_datain),
    //.RIGHTCHANNEL_ADDRESS_O(rightchannel_address),
    //.RIGHTCHANNEL_WE_O(rightchannel_we),
    //.LEFTCHANNEL_DATAIN_O(leftchannel_datain),
    //.LEFTCHANNEL_ADDRESS_O(leftchannel_address),
    //.LEFTCHANNEL_WE_O(leftchannel_we)
    .MAC_DATAIN_O(MAC_RAM_write_data),
    .MAC_ADDRESS_O(MAC_RAM_write_address),
    .MAC_LEFT_WE_O(CH0_MAC_RAM_we),
    .MAC_RIGHT_WE_O(CH1_MAC_RAM_we)
  );

  RAMB16_S18_S18 Req_RAM (
    .DOA(Req_RAM_read_data),
    .DOB(BR_RAM_read_data),
    .DOPA(),
    .DOPB(),
    .ADDRA(Req_RAM_address),
    .ADDRB({2'b11,BR_RAM_address}),
    .CLKA(HUFF_clock),
    .CLKB(HUFF_clock),
    .DIA(Req_RAM_write_data),
    .DIB(BR_RAM_write_data),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(Req_RAM_we),
    .WEB(BR_RAM_we)
  );

	// DP RAM between Huffman and MAC
	RAMB16_S18_S18 CH0_MAC_RAM (
		// output from Huffman
    .DOA(),
    .DOPA(),
    .ADDRA(MAC_RAM_write_address),
    .CLKA(HUFF_clock),
    .DIA(MAC_RAM_write_data),
    .DIPA(2'b00),
    .ENA(CH0_MAC_RAM_we),
    .SSRA(1'b0),
    .WEA(CH0_MAC_RAM_we),
	 
		// input to MAC
	 .DOB(CH0_MAC_RAM_read_data),
    .DOPB(),
    .ADDRB(CH0_MAC_RAM_read_address),
    .CLKB(MAC_clock),
    .DIB(16'h0000),
    .DIPB(2'b00),
    .ENB(CH0_MAC_RAM_read_en_MAC_clock),
    .SSRB(1'b0),
	 .WEB(1'b0)
  );

  RAMB16_S18_S18 CH1_MAC_RAM (
		// output from Huffman
    .DOA(),
    .DOPA(),
    .ADDRA(MAC_RAM_write_address),
    .CLKA(HUFF_clock),
    .DIA(MAC_RAM_write_data),
    .DIPA(2'b00),
    .ENA(CH1_MAC_RAM_we),
    .SSRA(1'b0),
    .WEA(CH1_MAC_RAM_we),
	 
		// input to MAC
	 .DOB(CH1_MAC_RAM_read_data),
    .DOPB(),
    .ADDRB(CH1_MAC_RAM_read_address),
    .CLKB(MAC_clock),
    .DIB(16'h0000),
    .DIPB(2'b00),
    .ENB(CH1_MAC_RAM_read_en_MAC_clock),
    .SSRB(1'b0),
	 .WEB(1'b0)
  );


	// MAC
	mac_unit MAC_module (
		.MAC_CLOCK_I(MAC_clock), 
		.MAC_RESETN_I(MAC_resetn),

		.CH0_MAC_START_I(CH0_MAC_start),
		.CH0_MAC_BLOCK_I(MP3_Info_CH0_MAC_block_type_MAC_clock),
		.CH0_MAC_MIXED_I(MP3_Info_CH0_MAC_mixed_block_MAC_clock),
		.CH0_MAC_SWITCHING_I(MP3_Info_CH0_MAC_switching_MAC_clock),
		.CH0_MAC_RAM_DATA_I(CH0_MAC_RAM_read_data),
		.CH0_MAC_RAM_ADDRESS_O(CH0_MAC_RAM_read_address),
		.CH0_MAC_RAM_EN_O(CH0_MAC_RAM_read_en_MAC_clock),
		.CH0_PCM_RAM_DATA_O(CH0_PCM_RAM_write_data),
		.CH0_PCM_RAM_WE_O(CH0_PCM_RAM_we),
		.CH0_PCM_RAM_ADDRESS_O(CH0_PCM_RAM_write_address),

		.CH1_MAC_START_I(CH1_MAC_start),
		.CH1_MAC_BLOCK_I(MP3_Info_CH1_MAC_block_type_MAC_clock),
		.CH1_MAC_MIXED_I(MP3_Info_CH1_MAC_mixed_block_MAC_clock),
		.CH1_MAC_SWITCHING_I(MP3_Info_CH1_MAC_switching_MAC_clock),
		.CH1_MAC_RAM_DATA_I(CH1_MAC_RAM_read_data),
		.CH1_MAC_RAM_ADDRESS_O(CH1_MAC_RAM_read_address),
		.CH1_MAC_RAM_EN_O(CH1_MAC_RAM_read_en_MAC_clock),
		.CH1_PCM_RAM_DATA_O(CH1_PCM_RAM_write_data),
		.CH1_PCM_RAM_WE_O(CH1_PCM_RAM_we),
		.CH1_PCM_RAM_ADDRESS_O(CH1_PCM_RAM_write_address),

		.MAC_DONE_O(MAC_done)
	);

 	// DP RAM between MAC and AC97
 	/*
	RAMB16_S18_S18 CH0_PCM_RAM (
		// output from MAC
    .DOA(),
    .DOPA(),
    .ADDRA(CH0_PCM_RAM_write_address),
    .CLKA(MAC_clock),
    .DIA(CH0_PCM_RAM_write_data),
    .DIPA(2'b00),
    .ENA(CH0_PCM_RAM_we),
    .SSRA(1'b0),
    .WEA(CH0_PCM_RAM_we),

		// input to AC97	 
	 .DOB(CH0_PCM_RAM_read_data),
    .DOPB(),
    .ADDRB(PCM_RAM_read_address_bit_clock),
    .CLKB(AC97_bit_clock),
    .DIB(16'h0000),
    .DIPB(2'b00),
    .ENB(1'b1),
    .SSRB(1'b0),
	 .WEB(1'b0)
  );
	dout_monitor dout_monitor_u0(
		.clk       (AC97_bit_clock),
		.rst_n     (AC97_resetn),
		.sample_clk(sample_clk),
		.addr      (PCM_RAM_read_address_bit_clock),
		.d_ch0     (CH0_PCM_RAM_read_data),
		.d_ch1     (CH1_PCM_RAM_read_data)
	);

	RAMB16_S18_S18 CH1_PCM_RAM (
		// output from MAC
    .DOA(),
    .DOPA(),
    .ADDRA(CH1_PCM_RAM_write_address),
    .CLKA(MAC_clock),
    .DIA(CH1_PCM_RAM_write_data),
    .DIPA(2'b00),
    .ENA(CH1_PCM_RAM_we),
    .SSRA(1'b0),
    .WEA(CH1_PCM_RAM_we),

		// input to AC97	 
	 .DOB(CH1_PCM_RAM_read_data),
    .DOPB(),
    .ADDRB(PCM_RAM_read_address_bit_clock),
    .CLKB(AC97_bit_clock),
    .DIB(16'h0000),
    .DIPB(2'b00),
    .ENB(1'b1),
    .SSRB(1'b0),
	 .WEB(1'b0)
  );*/

	/*ac97_ctr ac97_module (
		.BIT_CLOCK_I(AC97_bit_clock),
		.SAMPLE_FREQUENCY_I(sample_frequency),
		.AC97_RESETN_I(AC97_resetn),
		.SOURCE_SELECT_I(AC97_source_select),
		.AC97_SYNCH_O(AC97_SYNCH_O),
		.AC97_DATA_IN_I(AC97_DATA_IN_I),
		.AC97_DATA_OUT_O(AC97_DATA_OUT_O),
		.AC97_BEEP_TONE_O(AC97_BEEP_TONE_O),
		.PCM_READ_ADDRESS_0(PCM_RAM_read_address_bit_clock),
		.CH0_PCM_DATA_I(CH0_PCM_RAM_read_data),
		.CH1_PCM_DATA_I(CH1_PCM_RAM_read_data),
		.STARTUP_O(STARTUP_O)
	); */

	// For debugging
	parameter counter_width = 5;	
	parameter counter1_width = 5;	
	reg [counter_width-1:0] counter;
	reg [counter1_width-1:0] counter1;
				
	//assign USER_LED0_O = counter[counter_width-1];
	//assign USER_LED1_O = counter1[counter1_width-1];
	//assign USER_LED1_O = skipframe4;

	always @ (posedge CH0_MAC_start or negedge HUFF_resetn) begin
		if (HUFF_resetn == 1'b0) counter <= 0;
		else counter <= counter + 1;
	end

	always @ (posedge HUFF_done or negedge MAC_resetn) begin
		if (MAC_resetn == 1'b0) counter1 <= 0;
		else counter1 <= counter1 + 1;
	end

	always @ (posedge master_clock or negedge global_rst_n) begin
		if (global_rst_n == 1'b0) begin
			system_ready <= 1'b0;
			Clock_resetn <= 1'b0;
		end else begin
			system_ready <= (Clock_ready | system_ready);
			Clock_resetn <= 1'b1;
		end
	end

	always @ (system_ready or module_en) begin
		if (system_ready == 1'b0) begin
			// reset the whole FPGA while DCM is not locked
			AC97_resetn <= 1'b0;
			ETH_resetn <= 1'b0;
			MAC_resetn <= 1'b0;
			HUFF_resetn<=1'b0;
		end else begin
			AC97_resetn <= module_en;
			ETH_resetn <= module_en;
			MAC_resetn <= module_en;
			HUFF_resetn<=module_en;
		end
	end
	/*
	always @ (posedge MAC_clock) begin
		// buffer read address across bit clock domain
		PCM_RAM_read_address_MAC_clock <= PCM_RAM_read_address_bit_clock;
		MP3_Info_Mode_MAC_clock <= MP3_Info_Mode_buffer;

//		if (CH0_MAC_RAM_read_en_MAC_clock == 1'b0) begin
			MP3_Info_CH0_MAC_block_type_MAC_clock <= MP3_Info_CH0_MAC_block_type_buffer;
			MP3_Info_CH0_MAC_mixed_block_MAC_clock <= MP3_Info_CH0_MAC_mixed_block_buffer;
			MP3_Info_CH0_MAC_switching_MAC_clock <= MP3_Info_CH0_MAC_switching_buffer;
//		end
		
//		if (CH1_MAC_RAM_read_en_MAC_clock == 1'b0) begin
			MP3_Info_CH1_MAC_block_type_MAC_clock <= MP3_Info_CH1_MAC_block_type_buffer;
			MP3_Info_CH1_MAC_mixed_block_MAC_clock <= MP3_Info_CH1_MAC_mixed_block_buffer;
			MP3_Info_CH1_MAC_switching_MAC_clock <= MP3_Info_CH1_MAC_switching_buffer;
//		end
	end


	always @ (posedge MAC_clock or negedge MAC_resetn) begin
		if (MAC_resetn == 1'b0) begin
			MAC_state <= 'd0;
			CH0_MAC_start <= 1'b0;
			CH1_MAC_start <= 1'b0;
			CH0_PCM_RAM_write_address_buffer <= 'd500;
		end else begin
			case (MAC_state) 
			'd0: begin
				if ((MAC_done == 1'b1) && (PCM_RAM_read_address_MAC_clock == CH0_PCM_RAM_write_address_buffer)) begin
					CH0_PCM_RAM_write_address_buffer <= 'd0;

					MAC_state <= 'd1;
				end		
			end
			'd1: begin
				// start MAC unit according to read address from AC97
				if ((CH0_MAC_start == 1'b0) && (MAC_done == 1'b1)
				 && (PCM_RAM_read_address_MAC_clock == CH0_PCM_RAM_write_address_buffer)) begin
					// start the MAC
					CH0_MAC_start <= 1'b1;
					if ((MP3_Info_Mode_MAC_clock == 2'b00) || (MP3_Info_Mode_MAC_clock == 2'b01)) CH1_MAC_start <= 1'b1;
					else CH1_MAC_start <= 1'b0;

					MAC_state <= 'd2;
				end
			end
			'd2: begin
				// de-assert the start signal
				if ((CH0_MAC_start == 1'b1) && (MAC_done == 1'b0)) begin
					CH0_MAC_start <= 1'b0;
					CH1_MAC_start <= 1'b0;

					CH0_PCM_RAM_write_address_buffer <= CH0_PCM_RAM_write_address;

					MAC_state <= 'd1;
				end
			end
			endcase
		end
	end
	*/
	//reg [2:0] ETH_state;
	//reg HUFF_address_msb_buffer;

	//always @ (posedge MAC_clock) begin
	//	HUFF_address_msb_buffer <= HUFF_DP_ADDRESS[9];
	//end

	/*always @ (posedge MAC_clock or negedge ETH_resetn) begin
		if (ETH_resetn == 1'b0) begin
			ETH_state <= 'd0;
			ETH_start <= 1'b0;
			HUFF_resetn <= 1'b0;
		end else begin
			case (ETH_state) 
			'd0: begin
				// start ethernet at the same time as MAC
				if ((ETH_start == 1'b0) && (ETH_done == 1'b1)
				 && (PCM_RAM_read_address_MAC_clock == CH0_PCM_RAM_write_address_buffer)) begin
				//) begin
					// start the Ethernet
					ETH_start <= 1'b1;

					ETH_state <= 'd1;
				end
			end
			'd1: begin
				// de-assert the start signal
				if ((ETH_start == 1'b1) && (ETH_done == 1'b0)) begin
					ETH_start <= 1'b0;

					ETH_state <= 'd2;
				end
			end
			'd2: begin
				// start ethernet to fill the second half of the DP RAM
				if ((ETH_start == 1'b0) && (ETH_done == 1'b1)) begin
					// start the Ethernet
					ETH_start <= 1'b1;

					ETH_state <= 'd3;

					HUFF_resetn <= 1'b1;
				end
			end
			'd3: begin
				// de-assert the start signal
				if ((ETH_start == 1'b1) && (ETH_done == 1'b0)) begin
					ETH_start <= 1'b0;

					ETH_state <= 'd4;
				end
			end
			'd4: begin
				if ((HUFF_address_msb_buffer != HUFF_DP_ADDRESS[9]) && (ETH_done == 1'b1)) begin
					ETH_start <= 1'b1;

					ETH_state <= 'd3;
				end
			end
			endcase
		end
	end*/

	//reg [1:0] MP3_state;

	/*always @ (posedge HUFF_clock) begin
		CH0_MAC_RAM_read_en_HUFF_clock <= CH0_MAC_RAM_read_en_MAC_clock;
		CH1_MAC_RAM_read_en_HUFF_clock <= CH1_MAC_RAM_read_en_MAC_clock;
	end
	
	assign MAC_RAM_Idle = ~(CH0_MAC_RAM_read_en_HUFF_clock || CH1_MAC_RAM_read_en_HUFF_clock);*/

	// state machine for handshaking with huffman
	/*always @ (posedge HUFF_done or negedge MAC_resetn) begin
		if (MAC_resetn == 1'b0) begin
			MP3_Info_Frequency_buffer <= 2'd0;
			MP3_Info_Mode_buffer <= 2'd0;

			MP3_Info_CH0_MAC_block_type_buffer <= 2'b00;
			MP3_Info_CH0_MAC_mixed_block_buffer <= 1'b0;
			MP3_Info_CH0_MAC_switching_buffer <= 1'b0;

			MP3_Info_CH1_MAC_block_type_buffer <= 2'b00;
			MP3_Info_CH1_MAC_mixed_block_buffer <= 1'b0;
			MP3_Info_CH1_MAC_switching_buffer <= 1'b0;
		end else begin
//			if (HUFF_done == 1'b1) begin
				MP3_Info_Frequency_buffer <= MP3_Info_Frequency;
				MP3_Info_Mode_buffer <= MP3_Info_Mode;

				MP3_Info_CH0_MAC_block_type_buffer <= MP3_Info_CH0_MAC_block_type;
				MP3_Info_CH0_MAC_mixed_block_buffer <= MP3_Info_CH0_MAC_mixed_block;
				MP3_Info_CH0_MAC_switching_buffer <= MP3_Info_CH0_MAC_switching;

				MP3_Info_CH1_MAC_block_type_buffer <= MP3_Info_CH1_MAC_block_type;
				MP3_Info_CH1_MAC_mixed_block_buffer <= MP3_Info_CH1_MAC_mixed_block;
				MP3_Info_CH1_MAC_switching_buffer <= MP3_Info_CH1_MAC_switching;
//			end
		end
	end*/
reg [7:0] dummy_cycle_cnt;
	always @(posedge master_clock or negedge MAC_resetn) begin
		if (!MAC_resetn) begin
			MP3_Info_CH0_MAC_block_type_MAC_clock <= 0;
			MP3_Info_CH0_MAC_mixed_block_MAC_clock <= 0;
			MP3_Info_CH0_MAC_switching_MAC_clock <= 0;
			MP3_Info_CH1_MAC_block_type_MAC_clock <= 0;
			MP3_Info_CH1_MAC_mixed_block_MAC_clock <= 0;
			MP3_Info_CH1_MAC_switching_MAC_clock <= 0;
			MP3_Info_Mode_MAC_clock<=0;
			GS<=`GSTAGE_INIT;
			MAC_RAM_Idle<=0;
			CH0_MAC_start<=0;
			CH1_MAC_start<=0;
			dummy_cycle_cnt<=0;
			//HUFF_resetn<=1'b0;
		end else begin
			case (GS)
			`GSTAGE_INIT:begin
				GS<=`GSTAGE_HUFF;
				MAC_RAM_Idle<=1;
				//HUFF_resetn<=1'b1;
			end
			`GSTAGE_HUFF:begin
				if (HUFF_done) begin
					$display("GLOBAL:HUFF_DONE");
					MP3_Info_CH0_MAC_block_type_MAC_clock<=MP3_Info_CH0_MAC_block_type;
					MP3_Info_CH0_MAC_mixed_block_MAC_clock<=MP3_Info_CH0_MAC_mixed_block;
					MP3_Info_CH0_MAC_switching_MAC_clock<=MP3_Info_CH0_MAC_switching;
					MP3_Info_CH1_MAC_block_type_MAC_clock<=MP3_Info_CH1_MAC_block_type;
					MP3_Info_CH1_MAC_mixed_block_MAC_clock<=MP3_Info_CH1_MAC_mixed_block;
					MP3_Info_CH1_MAC_switching_MAC_clock<=MP3_Info_CH1_MAC_switching;
					MP3_Info_Mode_MAC_clock<=MP3_Info_Mode;
					//HUFF_resetn<=1'b0;
					MAC_RAM_Idle<=0;
					CH0_MAC_start <= 1'b1;
					if ((MP3_Info_Mode == 2'b00) || (MP3_Info_Mode == 2'b01)) CH1_MAC_start <= 1'b1;
					else CH1_MAC_start <= 1'b0;
					GS<=`GSTAGE_PRE_MAC;dummy_cycle_cnt<=0;
				end
			end
			`GSTAGE_PRE_MAC:begin
				CH0_MAC_start<=1'b0;
				CH1_MAC_start<=1'b0;
				dummy_cycle_cnt<=dummy_cycle_cnt+1'b1;
				if (dummy_cycle_cnt==10) GS<=`GSTAGE_MAC;
				else GS<=`GSTAGE_PRE_MAC;
			end
			`GSTAGE_MAC:begin
				CH0_MAC_start<=1'b0;
				CH1_MAC_start<=1'b0;
				if (MAC_done) begin
					$display("GLOBAL:MAC_DONE");
					MAC_RAM_Idle<=1'b1;
					GS<=`GSTAGE_INIT;
				end
			end
			default:GS<=`GSTAGE_INIT;
			endcase
		end
	end
endmodule
