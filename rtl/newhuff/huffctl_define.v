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


  // stages
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
