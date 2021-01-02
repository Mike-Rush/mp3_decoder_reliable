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


`ifdef DATA_WIDTH 
`else 
`define DATA_WIDTH 16
`define ADDRESS_WIDTH 10
`define SIM_MP3ROM_DATA_WIDTH 22
`endif

`ifdef LOW
`else 
`define LOW 0
`endif

`ifdef ADDR_BITS 
`else 
`define ADDR_BITS 19
`define DATA_BITS 32
`endif

`ifdef ACCUMULATOR_COMPLEMENT
`else  
`define ACCUMULATOR_COMPLEMENT 2'h0
`define ACCUMULATOR_LOAD 2'h1
`define ACCUMULATOR_HOLD 2'h2
`define ACCUMULATOR_MAC 2'h3
`endif

`ifdef FREQUENCY_48K
`else
`define FREQUENCY_48K 1
`define FREQUENCY_44K 0
`define FREQUENCY_32K 2
`define FREQUENCY_8K 3
`endif

`ifdef STATE_INITIAL
`else
// state for MAC
`define STATE_INITIAL 4'h0
`define STATE_LOAD_HALF_SB 4'h1
`define STATE_ANTIALIAS 4'h2
`define STATE_IMDCT_BLOCK0_CURRENT_GRANULE 4'h3
`define STATE_IMDCT_BLOCK0_PREVIOUS_GRANULE 4'h4
`define STATE_IMDCT_BLOCK2_LOAD_ICG 4'h5
`define STATE_IMDCT_BLOCK2_COMPUTE_FIRST 4'h6
`define STATE_IMDCT_BLOCK2_COMPUTE_SECOND 4'h7
`define STATE_IMDCT_BLOCK2_COMPUTE_THIRD 4'h8
`define STATE_IMDCT_BLOCK2_LOAD_IPG 4'h9
`define STATE_IMDCT_FREQ_INV 4'ha
`define STATE_POLYPHASE_MDCT 4'hb
`define STATE_POLYPHASE_WINDOW 4'hc
`define STATE_WAIT_OTHER_CHANNEL 4'hd
`endif


`ifdef ACCUMULATOR_COMPLEMENT
`else  
`define ACCUMULATOR_COMPLEMENT 2'h0 // accumulator complements its value
`define ACCUMULATOR_LOAD 2'h1 // accumulator loads the value that comes from the multiplier
`define ACCUMULATOR_HOLD 2'h2 // accumulator holds its value
`define ACCUMULATOR_MAC 2'h3  // accumulator adds its value to the value that comes from the multiplier
`endif

`ifdef PWC_SELECT
`else  
`define PMC_SELECT 2'h0 // select polyphase mdct coefficients as first operand to multiplier
`define PWC_SELECT 2'h1 // select polyphase window coefficients as first operand to multiplier
`define AIC_SELECT 2'h2 // select antialias and imdct coefficients as first operand to multiplier
`define CON_SELECT 2'h3 // select constant (zero or one) as first operand to multiplier
`define ICG_SELECT 2'h0 // select imdct current granule values as second operand to multiplier
`define PSB_SELECT 2'h1 // select polyphase samble buffer values as second operand to multiplier
`define DPR_SELECT 2'h2 // select dual port ram (i.e., mac_ram) values as second operand to multiplier
`define ACC_SELECT 2'h3 // select accumulator as second operand to multiplier
`endif

// state for huffman
  // stages
`ifdef STAGE_INIT
`else
  `define STAGE_INIT 0
  `define STAGE_HEADER 1
  `define STAGE_SIDEINFO 2
  `define STAGE_BIT_RESERVOIR_START 3
  `define STAGE_DECODE 4
  `define STAGE_POST_DECODE 5
  
  // states
  // init states
  `define STATE_INIT_RESET 0
  `define STATE_INIT_FILLBUF 1
  // header states
  `define STATE_HEADER_SYNCWORD 0
  `define STATE_HEADER_INFO 1
  `define STATE_HEADER_CRC 2
  `define STATE_HEADER_MAIN_DATA_BEGIN 3
  `define STATE_HEADER_SCFSI 4
  // sideinfo states
  `define STATE_SIDEINFO_ADDRESS 0
  `define STATE_SIDEINFO_PART2_3_LENGTH 1
  `define STATE_SIDEINFO_BIG_VALUES 2
  `define STATE_SIDEINFO_GLOBAL_GAIN 3
  `define STATE_SIDEINFO_BLOCK_TYPE 4
  `define STATE_SIDEINFO_TABLE_SELECT 5
  `define STATE_SIDEINFO_SUBBLOCK_GAIN 6
  `define STATE_SIDEINFO_REGION_COUNT 7
  // bit reservoir states
  // decode states
  `define STATE_DECODE_READ_SIDEINFO 0
  `define STATE_DECODE_SCALEFAC 1
  `define STATE_DECODE_PART3 2
  `define STATE_DECODE_REQ_STEREO 3
  // post-decode states
  `define STATE_POST_DECODE_READFRAMEEND 0
  `define STATE_POST_DECODE_BYTE_ALIGN 1
  `define STATE_POST_DECODE_FILL_BIT_RESERVOIR 2

    // signal aliases  
  `define slen1 gpreg[11:9]
  `define slen2 gpreg[8:7]
  `define linbits gpreg[15:12]
  `define voffset gpreg[11:9]
  `define frameend gpreg[13:0]
  `define main_data_begin big_values
  `define ispos gpreg[14:12]
  `define ispos0 gpreg[12]
`endif

