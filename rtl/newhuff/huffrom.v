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

module huffrom(clk,addressA,dataoutA,addressB,dataoutB);
  input clk;
  input [10:0] addressA;
  output [15:0] dataoutA;
  input [10:0] addressB;
  output [15:0] dataoutB;

  reg addrmuxA;
  reg addrmuxB;
  //wire addrmuxA;
  //wire addrmuxB;
  wire [15:0] memdataA [1:0];
  wire [15:0] memdataB [1:0];
  
  //assign addrmuxA = addressA[10];
  //assign addrmuxB = addressB[10];
  assign dataoutA = memdataA[addrmuxA];
  assign dataoutB = memdataB[addrmuxB];
  
  always @ (posedge clk)
  begin
    addrmuxA <= addressA[10];
    addrmuxB <= addressB[10];
  end
  
  RAMB16_S18_S18 romblock0 (
    .DOA(memdataA[0]),
    .DOB(memdataB[0]),
    .DOPA(),
    .DOPB(),
    .ADDRA(addressA[9:0]),
    .ADDRB(addressB[9:0]),
    .CLKA(clk),
    .CLKB(clk),
    .DIA(16'h0000),
    .DIB(16'h0000),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(1'b0),
    .WEB(1'b0)
  );
  
  RAMB16_S18_S18 romblock1 (
    .DOA(memdataA[1]),
    .DOB(memdataB[1]),
    .DOPA(),
    .DOPB(),
    .ADDRA(addressA[9:0]),
    .ADDRB(addressB[9:0]),
    .CLKA(clk),
    .CLKB(clk),
    .DIA(16'h0000),
    .DIB(16'h0000),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(1'b0),
    .WEB(1'b0)
  );

// synthesis attribute INIT_00 of romblock0 is "256'h1004000111030201022220211207060510011104030200010111100200010000"
// synthesis attribute INIT_01 of romblock0 is "256'h320e200221120d0c310b0a090807060510011104030200010222202112070605"
// synthesis attribute INIT_02 of romblock0 is "256'h230e022231130d0c2021120b0a09001001080706051104030201233322300313"
// synthesis attribute INIT_03 of romblock0 is "256'h20021214131211100f0e0d210c0b0a0911080706100105040302000103333032"
// synthesis attribute INIT_04 of romblock0 is "256'h4435222103322304422420501f51151e1d1c223031131b1a4041141918171615"
// synthesis attribute INIT_05 of romblock0 is "256'h100f0e0d0c0b0a09211208071001060500041103020153544555334334055225"
// synthesis attribute INIT_06 of romblock0 is "256'h30033113322340041442241f1e51151d1c1b1a19181741161514131220022211"
// synthesis attribute INIT_07 of romblock0 is "256'h0c0b001001110a09080706050403020154554435452233504334055225215320"
// synthesis attribute INIT_08 of romblock0 is "256'h1f1e1d1c3003322341141b1a19181716022215311314131211102021120f0e0d"
// synthesis attribute INIT_09 of romblock0 is "256'h0706100105040302000105544555045015522544225335214033422420433451"
// synthesis attribute INIT_0A of romblock0 is "256'h2221201f1e1d1c1b1a19181720022112161514131211100f0e0d0c0b0a091108"
// synthesis attribute INIT_0B of romblock0 is "256'h333231300332234041142f2e2d6061162c2b2a71172928272625242322303113"
// synthesis attribute INIT_0C of romblock0 is "256'h467337655674473d3c3b0433422450053a511539263638063762703672273534"
// synthesis attribute INIT_0D of romblock0 is "256'h100111080706000504030201545566755776677743345225445335450764633e"
// synthesis attribute INIT_0E of romblock0 is "256'h2120221f31131e1d1c1b1a191817161520022114131211100f0e0d120c0b0a09"
// synthesis attribute INIT_0F of romblock0 is "256'h633670173372273231302f2e300332232d2c2b2a296116286227262524712322"
// synthesis attribute INIT_10 of romblock0 is "256'h0552254407643d3c4673373b3a39383740044114422436503451062615353460"
// synthesis attribute INIT_11 of romblock0 is "256'h1001110b0a09080706050403020155575335544565563e744766757667773343"
// synthesis attribute INIT_12 of romblock0 is "256'h232221201f1e1d1c20022231131b1a191817161514130012211211100f0e0d0c"
// synthesis attribute INIT_13 of romblock0 is "256'h2436433451153534336162263231302f2e2d2c2b2a2930283223413327262524"
// synthesis attribute INIT_14 of romblock0 is "256'h04505225533560163d44544563363c7117644672273b37563a39383703401442"
// synthesis attribute INIT_15 of romblock0 is "256'h0c0b01110a09080710060504030200016777050670075573657447667557763e"
// synthesis attribute INIT_16 of romblock0 is "256'h2827262524232221201f200221121e1d1c1b1a191817161514131211100f0e0d"
// synthesis attribute INIT_17 of romblock0 is "256'h4241403f3e3d3c3b3a3938373635343332312230033113302f412e2d2c2b2a29"
// synthesis attribute INIT_18 of romblock0 is "256'h5a595857565554535251504f4e4d32234004144c4b4a51154948474645814443"
// synthesis attribute INIT_19 of romblock0 is "256'h6006611680086d6c6b6a69711768188228676665911964636261605f5e5d5c5b"
// synthesis attribute INIT_1A of romblock0 is "256'h84838281807f7e7d7c7b7a797877767574737271706f3342245043340552256e"
// synthesis attribute INIT_1B of romblock0 is "256'h92728448900991908f83388e92298d8c938ba08aa11aa22a89888786b11bb285"
// synthesis attribute INIT_1C of romblock0 is "256'ha4a3a2a1a09f9e9d9c9b9a999897969594934453356226544563367007552737"
// synthesis attribute INIT_1D of romblock0 is "256'h4a96b00bb394b2a4b12bb0b33bafaec0adc11cac5bc22c3cabaaa9a8d1a7a6a5"
// synthesis attribute INIT_1E of romblock0 is "256'hbdbcbbbab9b8b7b6b5b464467365567447667557678558394986680a9559a33a"
// synthesis attribute INIT_1F of romblock0 is "256'h4bcfc3cecdb71dd22dcc3dc6cbcac9c8c7c6e11ec5e2c4c3c2f0f11fc1c0bfbe"
// synthesis attribute INIT_20 of romblock0 is "256'hd7d6d5d4d3d2d1d07677877869a55a8879a66ab40c9889b5b66bc44ca88ad00d"
// synthesis attribute INIT_21 of romblock0 is "256'h7cd55de00e2ee36d8ce4e5bae3b93ee24ee1abe00fdff22fde3fdddcdbdad9d8"
// synthesis attribute INIT_22 of romblock0 is "256'h6ff0efdaf7eeedecebeae9e8e7e6e5e497a77a99c55c7bd36ca99ad4b88b4dc7"
// synthesis attribute INIT_23 of romblock0 is "256'hddecf7f6f5f4f3f2aa9bd6c8d77d5ec99c6ed88df3f1f44fbbace7f5d99d5fe8"
// synthesis attribute INIT_24 of romblock0 is "256'hfcdccefbbfdecfeedfeffffbe6caf6cbbcadfa8ef9ccf88fdbbdeaf99febbef8"
// synthesis attribute INIT_25 of romblock0 is "256'h100f0e0d000c110b0a090807060504030201fcfefdfee9afedfd7e7f9eaecdfa"
// synthesis attribute INIT_26 of romblock0 is "256'h2928272620022112222524232221201f1e1d1c1b1a1918171001161514131211"
// synthesis attribute INIT_27 of romblock0 is "256'h434241403f3e3031133d32233c413b3a393837363534333231302f2e2d2c2b2a"
// synthesis attribute INIT_28 of romblock0 is "256'h511552255e615d5c5b5a595857565554535251504f4e4d4c4b4a494847464544"
// synthesis attribute INIT_29 of romblock0 is "256'h7574737271706f6e6d6c6b6a696867666564636261600340041433422443345f"
// synthesis attribute INIT_2A of romblock0 is "256'h7155176472278a8988878118822886858483829181807f7e7d7c7b7a79787776"
// synthesis attribute INIT_2B of romblock0 is "256'h9e9d9c9b9a999897969594939291908f8e8d50054453358c166226544563368b"
// synthesis attribute INIT_2C of romblock0 is "256'h9559a3b7b6b5b4b1b3b2b2b1b3b0afaeadacabc2aaa9a8a7a6a5a4a3a2a1a09f"
// synthesis attribute INIT_2D of romblock0 is "256'h5680087447668338755784489019927667298558b9933994498668b8a11aa22a"
// synthesis attribute INIT_2E of romblock0 is "256'hd1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbba6006700746733765"
// synthesis attribute INIT_2F of romblock0 is "256'hc33ce1b66bc44ca88ac5e0d1b77b1ddfd2d3dedddcd4dbdad9d8d7d6d5d4d3d2"
// synthesis attribute INIT_30 of romblock0 is "256'ha00a3a8778a44a9669b01ba55a2b8897793b6ab44bc198891cb55b2ce2a6a77a"
// synthesis attribute INIT_31 of romblock0 is "256'h3ff44ff5bbcaace77ef5f4f3f6cbf2f1f0efeeedecebeae9e8e7e6e5e4e30977"
// synthesis attribute INIT_32 of romblock0 is "256'hf7e11ee2aa2eb99be3d66d3ec88ce44ed77de5baab5ec99cf11ff6f22fe6d8f3"
// synthesis attribute INIT_33 of romblock0 is "256'hbefaafddfdfbfcfbfaeef9f80bc00c99d05c0d2d3dc66ca99ab88b4dc77cd55d"
// synthesis attribute INIT_34 of romblock0 is "256'hefffe00ef06e8dd99d5fe88efe6fbcdaadf77fe99eccf88fdbbdeaf99fdccdeb"
// synthesis attribute INIT_35 of romblock0 is "256'h100f0e0d0c0b01110a09080710060504030200010faeeccebfeddefccffddffe"
// synthesis attribute INIT_36 of romblock0 is "256'h2c2b2a292827262524232221201f200221121e1d1c1b1a191817161514131211"
// synthesis attribute INIT_37 of romblock0 is "256'h4544434241403f3e3d3c3bf11f3af2393837ff363534223331133231302f2e2d"
// synthesis attribute INIT_38 of romblock0 is "256'h5af0f3f44f595857565554533003322352411451504f4e514d4c4b4a49484746"
// synthesis attribute INIT_39 of romblock0 is "256'h7675747117737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b0f2f"
// synthesis attribute INIT_3A of romblock0 is "256'hf55ff66ff77f8f7e7daf7c7b7a79400433422450433405155225785377611662"
// synthesis attribute INIT_3B of romblock0 is "256'h92299998971aa2969594939291908f8e8d8c8b8a898887868584838281807f3f"
// synthesis attribute INIT_3C of romblock0 is "256'hfeef4435600626544563367007a27227a17337a08081189f829e9d9c9b91199a"
// synthesis attribute INIT_3D of romblock0 is "256'h1db6b5b4b3e2b2b1b0afaeadacabaaa9a8a7a6a5a4a3f8f99ffafbbffccffddf"
// synthesis attribute INIT_3E of romblock0 is "256'h85589339a00a67c594c4a1c32ac2a3c1c0bfbeb11bb22bbdb3bcbbbab92cb8b7"
// synthesis attribute INIT_3F of romblock0 is "256'hd3d2d1d0cfcecdcccbcac9c8c7c6556446655608744728668338758448900976"
// synthesis attribute INIT_00 of romblock1 is "256'hb5c2a7c36bc4e13bd1d22dd31e2ee0c01cdf3cdedddc0ddbdad9d8d7d6d5e3d4"
// synthesis attribute INIT_01 of romblock1 is "256'hbde8e7e6e5e4e3e2574977866895593a8778a44a9669b00ba55aa66ab44b0cc1"
// synthesis attribute INIT_02 of romblock1 is "256'h6c9a8b4dc77cd55de00ef47bf3d4e1f2f16d3ec8f04eefee9ce6edecebeae99e"
// synthesis attribute INIT_03 of romblock1 is "256'hcbbc5efbcafaf9ccaef8cdbef7eef6f588977998895b7ab64c99a88ac55c3dc6"
// synthesis attribute INIT_04 of romblock1 is "256'hdaaddbdcebedfde9defcd0b7a9b8aab99bd68ce4d7e5baab6ed88dbbe79de88e"
// synthesis attribute INIT_05 of romblock1 is "256'h15141312ff11100f0e0d0c0b0a090807060504030201ddecd9eafece7dc9ac7e"
// synthesis attribute INIT_06 of romblock1 is "256'h2f2e2d21122c2b2a292827262524232221201f1e1d1c1b1a0010011119181716"
// synthesis attribute INIT_07 of romblock1 is "256'h4f4e4d4c4b4a494847464544434241403f3e3d3c3b3a39383736353433323130"
// synthesis attribute INIT_08 of romblock1 is "256'h5b5a595857f1f22ff33ff44ff55ff66ff756f8f955fa54535251200222503113"
// synthesis attribute INIT_09 of romblock1 is "256'h7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c"
// synthesis attribute INIT_0A of romblock1 is "256'h838281807f7ef01f7f8f9faffbbffccffddffeef300332237d41143342247c51"
// synthesis attribute INIT_0B of romblock1 is "256'ha3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584"
// synthesis attribute INIT_0C of romblock1 is "256'h5225445335b061166226544563367155644672af73aeadacabaaa9a8a7a6a5a4"
// synthesis attribute INIT_0D of romblock1 is "256'hcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b20f40044334b115"
// synthesis attribute INIT_0E of romblock1 is "256'h87e3a496e2e1b2e088b3dfdeddb4dcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccb"
// synthesis attribute INIT_0F of romblock1 is "256'h18822866833875578448911992766729855893399449778668a1a22a9559a33a"
// synthesis attribute INIT_10 of romblock1 is "256'he6f6f5f4f3f2f1f0efeeedecebeae9e8e7e6500560062737e5176556e4817447"
// synthesis attribute INIT_11 of romblock1 is "256'h6ca99ad4b88b4dc77cd55de11ee2aab99be3d66d3ef9c88ce4d7f8e5ba5ec9f7"
// synthesis attribute INIT_12 of romblock1 is "256'h4bc198891cb55bc22ca77ac33cfab66bc44c99a88ac55cd1b77b1dd22dd33dc6"
// synthesis attribute INIT_13 of romblock1 is "256'hdccdebbeddecceeddeee70078008784a69b11ba55a2b90fd9779a66a1afc3bfb"
// synthesis attribute INIT_14 of romblock1 is "256'h0cd02e4e7dab9c6e0dfed88dbbcaace77ed99de88ecbbcdaade99eccdbbdeaae"
// synthesis attribute INIT_15 of romblock1 is "256'hffffffffffffffffffffffffffffffffffffffff3ff8f002e00e09a00ab00bc0"
// synthesis attribute INIT_16 of romblock1 is "256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
// synthesis attribute INIT_17 of romblock1 is "256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
// synthesis attribute INIT_18 of romblock1 is "256'h00000414034302db0272020a01a1016d0139010500d000b6009c008200680000"
// synthesis attribute INIT_19 of romblock1 is "256'h000003c0030002a0024001e001800150012000f000c000a80090007800600000"
// synthesis attribute INIT_1A of romblock1 is "256'h000005a0048003f0036002d0024001f801b00168012000fc00d800b400900000"
// synthesis attribute INIT_1B of romblock1 is "256'h000005070e0d0f0b0c0a0306090e0d0c080401020b0a09080706050403020001"
// synthesis attribute INIT_1C of romblock1 is "256'h00000415034402dc0273020b01a2016e013a010600d100b7009d008300690000"
// synthesis attribute INIT_1D of romblock1 is "256'h000003c1030102a1024101e101810151012100f100c100a90091007900610000"
// synthesis attribute INIT_1E of romblock1 is "256'h000005a1048103f1036102d1024101f901b10169012100fd00d900b500910000"
// synthesis attribute INIT_1F of romblock1 is "256'h0403040203030302030102030202020101030102010103000003000200010000"
// synthesis attribute INIT_20 of romblock1 is "256'hf98083803328003ffcfd63ce0e0108c23ef38e103fbc80e2f8b8f8e2003a0003"
// synthesis attribute INIT_21 of romblock1 is "256'h0e203ffffbf8fdb5b03f1c603c003c0008c2003ff6f70fc0d8383c00003efebf"
// synthesis attribute INIT_22 of romblock1 is "256'h30823fffbfdf7ec3ef1c00bc003e00b038003fdfffce0fdf9f60f06842c00e01"
// synthesis attribute INIT_23 of romblock1 is "256'hf5596f0800003fff7c6caf0e000003fefc1b8c000003e30400003e40003c0000"
// synthesis attribute INIT_24 of romblock1 is "256'h28003bbf7fefd7fec0fffbff9800fffffff6ab4000ffffffa7b03470003fffff"
// synthesis attribute INIT_25 of romblock1 is "256'hffffdfbf852040000000fbfbf0f0400000000ffbd00000000ed000003e000300"
// synthesis attribute INIT_26 of romblock1 is "256'h30823fffffdfffffd13ffffdffffff7fbf30000fffffffdf7f7b1000000003ff"
// synthesis attribute INIT_27 of romblock1 is "256'h40003fffffb6e86c6000001fe43ffd718000003780f6100001a22c00003c0000"
// synthesis attribute INIT_28 of romblock1 is "256'h00003dffdbfffffe9b4ffffffd674c180fffffffdfda2020003fffffeaa1e848"
// synthesis attribute INIT_29 of romblock1 is "256'h00001f7efffa000000000000ffffdf4000000001ffed0ec00000000600003c02"
// synthesis attribute INIT_2A of romblock1 is "256'hffff3fffefffffffffffbebffefffffffffef7a0000fddffffffffecb1000000"
// synthesis attribute INIT_2B of romblock1 is "256'h000d000b000900080007000600050004000d000a000800060004000300020001"
// synthesis attribute INIT_2C of romblock1 is "256'h025700000158011900da009b007800550032002300140000000c000400010000"
// synthesis attribute INIT_2D of romblock1 is "256'hd455b455945584557455645554554455d356a356835663564356335623561356"
// synthesis attribute INIT_2E of romblock1 is "256'h064f0600062f0627061f06170612060d06080606060406000603060206010600"
// synthesis attribute INIT_2F of romblock1 is "256'h068f068f068f068f068f068f068f068f066f066f066f066f066f066f066f066f"
// synthesis attribute INIT_30 of romblock1 is "256'h20A21086106E105A104A003E0034002C0024001E001800140010000C00080004"
// synthesis attribute INIT_31 of romblock1 is "256'h0000000000000000000000000000000000000000024021A23156312030EE20C4"
// synthesis attribute INIT_32 of romblock1 is "256'h00000000000038C01E88166A12540E420C340A28081E06160410040C04080404"
// synthesis attribute INIT_33 of romblock1 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_34 of romblock1 is "256'h209C1080106A10581048003C0032002A0024001E001800140010000C00080004"
// synthesis attribute INIT_35 of romblock1 is "256'h000000000000000000000000000000000000000002402180314A311430E620BE"
// synthesis attribute INIT_36 of romblock1 is "256'h00000000000042C01A7E146410500E400C320A26061C06160410040C04080404"
// synthesis attribute INIT_37 of romblock1 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_38 of romblock1 is "256'h20C2109C107E1066105200420036002C0024001E001800140010000C00080004"
// synthesis attribute INIT_39 of romblock1 is "256'h00000000000000000000000000000000000000000240222631C0316C312820F0"
// synthesis attribute INIT_3A of romblock1 is "256'h0000000000000CC02AB4228A1A68144E103A0C2A081E06160410040C04080404"
// synthesis attribute INIT_3B of romblock1 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis translate_off
defparam romblock0.INIT_00 = 256'h1004000111030201022220211207060510011104030200010111100200010000;
defparam romblock0.INIT_01 = 256'h320e200221120d0c310b0a090807060510011104030200010222202112070605;
defparam romblock0.INIT_02 = 256'h230e022231130d0c2021120b0a09001001080706051104030201233322300313;
defparam romblock0.INIT_03 = 256'h20021214131211100f0e0d210c0b0a0911080706100105040302000103333032;
defparam romblock0.INIT_04 = 256'h4435222103322304422420501f51151e1d1c223031131b1a4041141918171615;
defparam romblock0.INIT_05 = 256'h100f0e0d0c0b0a09211208071001060500041103020153544555334334055225;
defparam romblock0.INIT_06 = 256'h30033113322340041442241f1e51151d1c1b1a19181741161514131220022211;
defparam romblock0.INIT_07 = 256'h0c0b001001110a09080706050403020154554435452233504334055225215320;
defparam romblock0.INIT_08 = 256'h1f1e1d1c3003322341141b1a19181716022215311314131211102021120f0e0d;
defparam romblock0.INIT_09 = 256'h0706100105040302000105544555045015522544225335214033422420433451;
defparam romblock0.INIT_0A = 256'h2221201f1e1d1c1b1a19181720022112161514131211100f0e0d0c0b0a091108;
defparam romblock0.INIT_0B = 256'h333231300332234041142f2e2d6061162c2b2a71172928272625242322303113;
defparam romblock0.INIT_0C = 256'h467337655674473d3c3b0433422450053a511539263638063762703672273534;
defparam romblock0.INIT_0D = 256'h100111080706000504030201545566755776677743345225445335450764633e;
defparam romblock0.INIT_0E = 256'h2120221f31131e1d1c1b1a191817161520022114131211100f0e0d120c0b0a09;
defparam romblock0.INIT_0F = 256'h633670173372273231302f2e300332232d2c2b2a296116286227262524712322;
defparam romblock0.INIT_10 = 256'h0552254407643d3c4673373b3a39383740044114422436503451062615353460;
defparam romblock0.INIT_11 = 256'h1001110b0a09080706050403020155575335544565563e744766757667773343;
defparam romblock0.INIT_12 = 256'h232221201f1e1d1c20022231131b1a191817161514130012211211100f0e0d0c;
defparam romblock0.INIT_13 = 256'h2436433451153534336162263231302f2e2d2c2b2a2930283223413327262524;
defparam romblock0.INIT_14 = 256'h04505225533560163d44544563363c7117644672273b37563a39383703401442;
defparam romblock0.INIT_15 = 256'h0c0b01110a09080710060504030200016777050670075573657447667557763e;
defparam romblock0.INIT_16 = 256'h2827262524232221201f200221121e1d1c1b1a191817161514131211100f0e0d;
defparam romblock0.INIT_17 = 256'h4241403f3e3d3c3b3a3938373635343332312230033113302f412e2d2c2b2a29;
defparam romblock0.INIT_18 = 256'h5a595857565554535251504f4e4d32234004144c4b4a51154948474645814443;
defparam romblock0.INIT_19 = 256'h6006611680086d6c6b6a69711768188228676665911964636261605f5e5d5c5b;
defparam romblock0.INIT_1A = 256'h84838281807f7e7d7c7b7a797877767574737271706f3342245043340552256e;
defparam romblock0.INIT_1B = 256'h92728448900991908f83388e92298d8c938ba08aa11aa22a89888786b11bb285;
defparam romblock0.INIT_1C = 256'ha4a3a2a1a09f9e9d9c9b9a999897969594934453356226544563367007552737;
defparam romblock0.INIT_1D = 256'h4a96b00bb394b2a4b12bb0b33bafaec0adc11cac5bc22c3cabaaa9a8d1a7a6a5;
defparam romblock0.INIT_1E = 256'hbdbcbbbab9b8b7b6b5b464467365567447667557678558394986680a9559a33a;
defparam romblock0.INIT_1F = 256'h4bcfc3cecdb71dd22dcc3dc6cbcac9c8c7c6e11ec5e2c4c3c2f0f11fc1c0bfbe;
defparam romblock0.INIT_20 = 256'hd7d6d5d4d3d2d1d07677877869a55a8879a66ab40c9889b5b66bc44ca88ad00d;
defparam romblock0.INIT_21 = 256'h7cd55de00e2ee36d8ce4e5bae3b93ee24ee1abe00fdff22fde3fdddcdbdad9d8;
defparam romblock0.INIT_22 = 256'h6ff0efdaf7eeedecebeae9e8e7e6e5e497a77a99c55c7bd36ca99ad4b88b4dc7;
defparam romblock0.INIT_23 = 256'hddecf7f6f5f4f3f2aa9bd6c8d77d5ec99c6ed88df3f1f44fbbace7f5d99d5fe8;
defparam romblock0.INIT_24 = 256'hfcdccefbbfdecfeedfeffffbe6caf6cbbcadfa8ef9ccf88fdbbdeaf99febbef8;
defparam romblock0.INIT_25 = 256'h100f0e0d000c110b0a090807060504030201fcfefdfee9afedfd7e7f9eaecdfa;
defparam romblock0.INIT_26 = 256'h2928272620022112222524232221201f1e1d1c1b1a1918171001161514131211;
defparam romblock0.INIT_27 = 256'h434241403f3e3031133d32233c413b3a393837363534333231302f2e2d2c2b2a;
defparam romblock0.INIT_28 = 256'h511552255e615d5c5b5a595857565554535251504f4e4d4c4b4a494847464544;
defparam romblock0.INIT_29 = 256'h7574737271706f6e6d6c6b6a696867666564636261600340041433422443345f;
defparam romblock0.INIT_2A = 256'h7155176472278a8988878118822886858483829181807f7e7d7c7b7a79787776;
defparam romblock0.INIT_2B = 256'h9e9d9c9b9a999897969594939291908f8e8d50054453358c166226544563368b;
defparam romblock0.INIT_2C = 256'h9559a3b7b6b5b4b1b3b2b2b1b3b0afaeadacabc2aaa9a8a7a6a5a4a3a2a1a09f;
defparam romblock0.INIT_2D = 256'h5680087447668338755784489019927667298558b9933994498668b8a11aa22a;
defparam romblock0.INIT_2E = 256'hd1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbba6006700746733765;
defparam romblock0.INIT_2F = 256'hc33ce1b66bc44ca88ac5e0d1b77b1ddfd2d3dedddcd4dbdad9d8d7d6d5d4d3d2;
defparam romblock0.INIT_30 = 256'ha00a3a8778a44a9669b01ba55a2b8897793b6ab44bc198891cb55b2ce2a6a77a;
defparam romblock0.INIT_31 = 256'h3ff44ff5bbcaace77ef5f4f3f6cbf2f1f0efeeedecebeae9e8e7e6e5e4e30977;
defparam romblock0.INIT_32 = 256'hf7e11ee2aa2eb99be3d66d3ec88ce44ed77de5baab5ec99cf11ff6f22fe6d8f3;
defparam romblock0.INIT_33 = 256'hbefaafddfdfbfcfbfaeef9f80bc00c99d05c0d2d3dc66ca99ab88b4dc77cd55d;
defparam romblock0.INIT_34 = 256'hefffe00ef06e8dd99d5fe88efe6fbcdaadf77fe99eccf88fdbbdeaf99fdccdeb;
defparam romblock0.INIT_35 = 256'h100f0e0d0c0b01110a09080710060504030200010faeeccebfeddefccffddffe;
defparam romblock0.INIT_36 = 256'h2c2b2a292827262524232221201f200221121e1d1c1b1a191817161514131211;
defparam romblock0.INIT_37 = 256'h4544434241403f3e3d3c3bf11f3af2393837ff363534223331133231302f2e2d;
defparam romblock0.INIT_38 = 256'h5af0f3f44f595857565554533003322352411451504f4e514d4c4b4a49484746;
defparam romblock0.INIT_39 = 256'h7675747117737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b0f2f;
defparam romblock0.INIT_3A = 256'hf55ff66ff77f8f7e7daf7c7b7a79400433422450433405155225785377611662;
defparam romblock0.INIT_3B = 256'h92299998971aa2969594939291908f8e8d8c8b8a898887868584838281807f3f;
defparam romblock0.INIT_3C = 256'hfeef4435600626544563367007a27227a17337a08081189f829e9d9c9b91199a;
defparam romblock0.INIT_3D = 256'h1db6b5b4b3e2b2b1b0afaeadacabaaa9a8a7a6a5a4a3f8f99ffafbbffccffddf;
defparam romblock0.INIT_3E = 256'h85589339a00a67c594c4a1c32ac2a3c1c0bfbeb11bb22bbdb3bcbbbab92cb8b7;
defparam romblock0.INIT_3F = 256'hd3d2d1d0cfcecdcccbcac9c8c7c6556446655608744728668338758448900976;
defparam romblock1.INIT_00 = 256'hb5c2a7c36bc4e13bd1d22dd31e2ee0c01cdf3cdedddc0ddbdad9d8d7d6d5e3d4;
defparam romblock1.INIT_01 = 256'hbde8e7e6e5e4e3e2574977866895593a8778a44a9669b00ba55aa66ab44b0cc1;
defparam romblock1.INIT_02 = 256'h6c9a8b4dc77cd55de00ef47bf3d4e1f2f16d3ec8f04eefee9ce6edecebeae99e;
defparam romblock1.INIT_03 = 256'hcbbc5efbcafaf9ccaef8cdbef7eef6f588977998895b7ab64c99a88ac55c3dc6;
defparam romblock1.INIT_04 = 256'hdaaddbdcebedfde9defcd0b7a9b8aab99bd68ce4d7e5baab6ed88dbbe79de88e;
defparam romblock1.INIT_05 = 256'h15141312ff11100f0e0d0c0b0a090807060504030201ddecd9eafece7dc9ac7e;
defparam romblock1.INIT_06 = 256'h2f2e2d21122c2b2a292827262524232221201f1e1d1c1b1a0010011119181716;
defparam romblock1.INIT_07 = 256'h4f4e4d4c4b4a494847464544434241403f3e3d3c3b3a39383736353433323130;
defparam romblock1.INIT_08 = 256'h5b5a595857f1f22ff33ff44ff55ff66ff756f8f955fa54535251200222503113;
defparam romblock1.INIT_09 = 256'h7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c;
defparam romblock1.INIT_0A = 256'h838281807f7ef01f7f8f9faffbbffccffddffeef300332237d41143342247c51;
defparam romblock1.INIT_0B = 256'ha3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584;
defparam romblock1.INIT_0C = 256'h5225445335b061166226544563367155644672af73aeadacabaaa9a8a7a6a5a4;
defparam romblock1.INIT_0D = 256'hcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b20f40044334b115;
defparam romblock1.INIT_0E = 256'h87e3a496e2e1b2e088b3dfdeddb4dcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccb;
defparam romblock1.INIT_0F = 256'h18822866833875578448911992766729855893399449778668a1a22a9559a33a;
defparam romblock1.INIT_10 = 256'he6f6f5f4f3f2f1f0efeeedecebeae9e8e7e6500560062737e5176556e4817447;
defparam romblock1.INIT_11 = 256'h6ca99ad4b88b4dc77cd55de11ee2aab99be3d66d3ef9c88ce4d7f8e5ba5ec9f7;
defparam romblock1.INIT_12 = 256'h4bc198891cb55bc22ca77ac33cfab66bc44c99a88ac55cd1b77b1dd22dd33dc6;
defparam romblock1.INIT_13 = 256'hdccdebbeddecceeddeee70078008784a69b11ba55a2b90fd9779a66a1afc3bfb;
defparam romblock1.INIT_14 = 256'h0cd02e4e7dab9c6e0dfed88dbbcaace77ed99de88ecbbcdaade99eccdbbdeaae;
defparam romblock1.INIT_15 = 256'hffffffffffffffffffffffffffffffffffffffff3ff8f002e00e09a00ab00bc0;
defparam romblock1.INIT_16 = 256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
defparam romblock1.INIT_17 = 256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
defparam romblock1.INIT_18 = 256'h00000414034302db0272020a01a1016d0139010500d000b6009c008200680000;
defparam romblock1.INIT_19 = 256'h000003c0030002a0024001e001800150012000f000c000a80090007800600000;
defparam romblock1.INIT_1A = 256'h000005a0048003f0036002d0024001f801b00168012000fc00d800b400900000;
defparam romblock1.INIT_1B = 256'h000005070e0d0f0b0c0a0306090e0d0c080401020b0a09080706050403020001;
defparam romblock1.INIT_1C = 256'h00000415034402dc0273020b01a2016e013a010600d100b7009d008300690000;
defparam romblock1.INIT_1D = 256'h000003c1030102a1024101e101810151012100f100c100a90091007900610000;
defparam romblock1.INIT_1E = 256'h000005a1048103f1036102d1024101f901b10169012100fd00d900b500910000;
defparam romblock1.INIT_1F = 256'h0403040203030302030102030202020101030102010103000003000200010000;
defparam romblock1.INIT_20 = 256'hf98083803328003ffcfd63ce0e0108c23ef38e103fbc80e2f8b8f8e2003a0003;
defparam romblock1.INIT_21 = 256'h0e203ffffbf8fdb5b03f1c603c003c0008c2003ff6f70fc0d8383c00003efebf;
defparam romblock1.INIT_22 = 256'h30823fffbfdf7ec3ef1c00bc003e00b038003fdfffce0fdf9f60f06842c00e01;
defparam romblock1.INIT_23 = 256'hf5596f0800003fff7c6caf0e000003fefc1b8c000003e30400003e40003c0000;
defparam romblock1.INIT_24 = 256'h28003bbf7fefd7fec0fffbff9800fffffff6ab4000ffffffa7b03470003fffff;
defparam romblock1.INIT_25 = 256'hffffdfbf852040000000fbfbf0f0400000000ffbd00000000ed000003e000300;
defparam romblock1.INIT_26 = 256'h30823fffffdfffffd13ffffdffffff7fbf30000fffffffdf7f7b1000000003ff;
defparam romblock1.INIT_27 = 256'h40003fffffb6e86c6000001fe43ffd718000003780f6100001a22c00003c0000;
defparam romblock1.INIT_28 = 256'h00003dffdbfffffe9b4ffffffd674c180fffffffdfda2020003fffffeaa1e848;
defparam romblock1.INIT_29 = 256'h00001f7efffa000000000000ffffdf4000000001ffed0ec00000000600003c02;
defparam romblock1.INIT_2A = 256'hffff3fffefffffffffffbebffefffffffffef7a0000fddffffffffecb1000000;
defparam romblock1.INIT_2B = 256'h000d000b000900080007000600050004000d000a000800060004000300020001;
defparam romblock1.INIT_2C = 256'h025700000158011900da009b007800550032002300140000000c000400010000;
defparam romblock1.INIT_2D = 256'hd455b455945584557455645554554455d356a356835663564356335623561356;
defparam romblock1.INIT_2E = 256'h064f0600062f0627061f06170612060d06080606060406000603060206010600;
defparam romblock1.INIT_2F = 256'h068f068f068f068f068f068f068f068f066f066f066f066f066f066f066f066f;
/*
defparam romblock1.INIT_30 = 256'h20a21086106e105a104a003e0034002c0024001e001800140010000c00080004;
defparam romblock1.INIT_31 = 256'h0000000000000000000000000000000000000000024021a23156312030ee20c4;
defparam romblock1.INIT_32 = 256'h209c1080106a10581048003c0032002a0024001e001800140010000c00080004;
defparam romblock1.INIT_33 = 256'h000000000000000000000000000000000000000002402180314a311430e620be;
defparam romblock1.INIT_34 = 256'h20c2109c107e1066105200420036002c0024001e001800140010000c00080004;
defparam romblock1.INIT_35 = 256'h00000000000000000000000000000000000000000240222631c0316c312820f0;
defparam romblock1.INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam romblock1.INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam romblock1.INIT_38 = 256'h00000000000038c01e88166a12540e420c340a28081e06160410040c04080404;
defparam romblock1.INIT_39 = 256'h00000000000042c01a7e146410500e400c320a26061c06160410040c04080404;
defparam romblock1.INIT_3A = 256'h0000000000000cc02ab4228a1a68144e103a0c2a081e06160410040c04080404;
*/
defparam romblock1.INIT_30 = 256'h20A2_1086_106E_105A_104A_003E_0034_002C_0024_001E_0018_0014_0010_000C_0008_0004;//fs=44.1
defparam romblock1.INIT_31 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_21A2_3156_3120_30EE_20C4;
defparam romblock1.INIT_32 = 256'h0000_0000_0000_38C0_1E88_166A_1254_0E42_0C34_0A28_081E_0616_0410_040C_0408_0404;
//fparam romblock1.INIT_30 = 256'h20C4_20A2_1086_106E_105A_104A_003E_0034_002C_0024_001E_0018_0014_0010_000C_0008;//fs=44.1
//fparam romblock1.INIT_31 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_21A2_3156_3120_30EE;
//fparam romblock1.INIT_32 = 256'h0000_0000_0000_0000_38C0_1E88_166A_1254_0E42_0C34_0A28_081E_0616_0410_040C_0408;
defparam romblock1.INIT_33 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam romblock1.INIT_34 = 256'h209C_1080_106A_1058_1048_003C_0032_002A_0024_001E_0018_0014_0010_000C_0008_0004;//fs=48
defparam romblock1.INIT_35 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_2180_314A_3114_30E6_20BE;
defparam romblock1.INIT_36 = 256'h0000_0000_0000_42C0_1A7E_1464_1050_0E40_0C32_0A26_061C_0616_0410_040C_0408_0404;
//fparam romblock1.INIT_34 = 256'h20BE_209C_1080_106A_1058_1048_003C_0032_002A_0024_001E_0018_0014_0010_000C_0008;//fs=48
//fparam romblock1.INIT_35 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_2180_314A_3114_30E6;
//fparam romblock1.INIT_36 = 256'h0000_0000_0000_0000_42C0_1A7E_1464_1050_0E40_0C32_0A26_061C_0616_0410_040C_0408;
defparam romblock1.INIT_37 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam romblock1.INIT_38 = 256'h20C2_109C_107E_1066_1052_0042_0036_002C_0024_001E_0018_0014_0010_000C_0008_0004;//fs=32
defparam romblock1.INIT_39 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_2226_31C0_316C_3128_20F0;
defparam romblock1.INIT_3A = 256'h0000_0000_0000_0CC0_2AB4_228A_1A68_144E_103A_0C2A_081E_0616_0410_040C_0408_0404;
//fparam romblock1.INIT_38 = 256'h20F0_20C2_109C_107E_1066_1052_0042_0036_002C_0024_001E_0018_0014_0010_000C_0008;//fs=32
//fparam romblock1.INIT_39 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0240_2226_31C0_316C_3128;
//fparam romblock1.INIT_3A = 256'h0000_0000_0000_0000_0CC0_2AB4_228A_1A68_144E_103A_0C2A_081E_0616_0410_040C_0408;
defparam romblock1.INIT_3B = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
// synthesis translate_on
endmodule

/*
module RAMB16_S18_S18(DOA,DOB,DOPA,DOPB,ADDRA,ADDRB,CLKA,CLKB,
  DIA,DIB,DIPA,DIPB,ENA,ENB,SSRA,SSRB,WEA,WEB);    // synthesis syn_black_box
  output [15:0] DOA;
  output [15:0] DOB;
  output [1:0] DOPA;
  output [1:0] DOPB;
  input [9:0] ADDRA;
  input [9:0] ADDRB;
  input CLKA;
  input CLKB;
  input [15:0] DIA;
  input [15:0] DIB;
  input [1:0] DIPA;
  input [1:0] DIPB;
  input ENA;
  input ENB;
  input SSRA;
  input SSRB;
  input WEA;
  input WEB;
endmodule
*/
