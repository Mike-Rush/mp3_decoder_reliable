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

module polyphase_window_coefficient(
	clock,
	mem_en,
	address,
	data_out
);

input clock;
input mem_en;
input [`ADDRESS_WIDTH-1:0] address;
output [`DATA_WIDTH-1:0] data_out;

// Instantiate the RAM
RAMB16_S18 instance_polyphase_window_coefficient_RAMB16_S18 (
	.DO(data_out),
	.DOP(),
	.ADDR(address),
	.CLK(clock),
	.DI(16'h0),
	.DIP(2'b00),
	.EN(mem_en),
	.SSR(1'b0),
	.WE(1'b0)
);

// synthesis attribute INIT_00 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000"
// synthesis attribute INIT_01 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFF9FFFAFFFAFFFBFFFBFFFCFFFCFFFCFFFDFFFDFFFDFFFEFFFEFFFEFFFEFFFE"
// synthesis attribute INIT_02 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFE7FFE9FFEAFFECFFEDFFEFFFF0FFF1FFF2FFF3FFF4FFF5FFF6FFF7FFF8FFF8"
// synthesis attribute INIT_03 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFCCFFCDFFCFFFD0FFD2FFD4FFD5FFD7FFD9FFDBFFDDFFDFFFE0FFE2FFE4FFE6"
// synthesis attribute INIT_04 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0028002C002F0032003300350037003800380039003900380038003700360035"
// synthesis attribute INIT_05 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFF9BFFA9FFB6FFC3FFCEFFD9FFE4FFEEFFF7FFFF0007000E0014001A001F0024"
// synthesis attribute INIT_06 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFE89FE9BFEADFEBFFED1FEE3FEF6FF08FF1AFF2CFF3DFF4EFF5EFF6EFF7EFF8D"
// synthesis attribute INIT_07 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFDFCFDF8FDF6FDF6FDF9FDFDFE04FE0BFE15FE20FE2CFE39FE48FE57FE67FE78"
// synthesis attribute INIT_08 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h002E0064009700C600F2011A01400161017F019A01B201C701D901E701F301FD"
// synthesis attribute INIT_09 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFB53FBADFC08FC61FCBAFD11FD66FDB9FE0AFE59FEA5FEEEFF34FF77FFB8FFF4"
// synthesis attribute INIT_0A of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hF6A3F6CEF6FFF736F773F7B5F7FBF846F894F8E6F93AF990F9E8FA42FA9CFAF7"
// synthesis attribute INIT_0B of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hF908F88AF819F7B5F75EF713F6D4F6A2F67AF65EF64CF644F646F651F664F680"
// synthesis attribute INIT_0C of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hF7A9F903FA51FB92FCC7FDEDFF060011010E01FD02DD03AF0474052A05D1066B"
// synthesis attribute INIT_0D of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hDD32DF00E0CDE298E45FE623E7E2E99BEB4EECFAEE9EF039F1CBF353F4D0F642"
// synthesis attribute INIT_0E of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hC2C9C425C590C708C88DCA1DCBB8CD5CCF09D0BED279D43AD600D7CAD996DB63"
// synthesis attribute INIT_0F of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hB6C4B6E6B71EB76DB7D3B84EB8DFB985BA41BB10BBF4BCEBBDF4BF10C03DC17B"
// synthesis attribute INIT_10 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h3FC240EF420B4314440B44EF45BF467A472047B1482C489248E14919493B4947"
// synthesis attribute INIT_11 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h266A283529FF2BC52D862F4130F632A3344735E2377238F73A6F3BDA3D373E84"
// synthesis attribute INIT_12 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0B2F0CAC0E340FC61161130514B11664181D19DC1BA01D671F3220FF22CD249C"
// synthesis attribute INIT_13 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFA2EFAD6FB8BFC50FD22FE02FEF1FFEE00F902120339046D05AE06FC085709BD"
// synthesis attribute INIT_14 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h099B09AE09B909BB09B309A10985095E092B08EC08A1084B07E6077506F7066B"
// synthesis attribute INIT_15 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h056305BD0617066F06C50719076B07B90804084A088C08C909000932095C097F"
// synthesis attribute INIT_16 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0047008800CB0111015A01A601F50246029902EE0345039E03F7045204AC0508"
// synthesis attribute INIT_17 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFE0CFE18FE26FE38FE4DFE65FE80FE9EFEC0FEE5FF0DFF39FF68FF9BFFD1000B"
// synthesis attribute INIT_18 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h019801A801B701C601D301DF01EA01F401FB02020206020902090207020301FD"
// synthesis attribute INIT_19 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0081009100A100B100C200D300E500F7010A011C012E01400153016501760187"
// synthesis attribute INIT_1A of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFE0FFE5FFEBFFF1FFF8000000080012001B00260031003D0049005600640072"
// synthesis attribute INIT_1B of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hFFC9FFC8FFC7FFC7FFC7FFC7FFC7FFC8FFC8FFCAFFCCFFCEFFD0FFD3FFD7FFDB"
// synthesis attribute INIT_1C of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h001B001D001F00200022002400260028002A002C002D002F0031003200330035"
// synthesis attribute INIT_1D of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h000700080009000A000B000C000D000E000F0011001200130015001600180019"
// synthesis attribute INIT_1E of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0001000100010001000200020002000300030004000400040005000600060007"
// synthesis attribute INIT_1F of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000010001"
// Printing coefficient for fast mdct (512-832)
// synthesis attribute INIT_20 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_21 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_22 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h2B30D4CF27D7D828254EDAB12366DC9921FCDE0320FDDF022059DFA62009DFF6"
// synthesis attribute INIT_23 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h72588DA7762489DB5BCEA4315EFCA1034AD8B5273E3EC1C135B7CA482FA6D059"
// synthesis attribute INIT_24 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_25 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6E2B91D46E3C91C343E2BC1D3271CD8E2965D69A2448DBB72170DE8F2027DFD8"
// synthesis attribute INIT_26 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_27 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6E2B91D46E3C91C343E2BC1D3271CD8E2965D69A2448DBB72170DE8F2027DFD8"
// synthesis attribute INIT_28 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6675998A3999C666267CD98320A0DF5F40004000400040004000400040004000"
// synthesis attribute INIT_29 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6675998A3999C666267CD98320A0DF5F40004000400040004000400040004000"
// synthesis attribute INIT_2A of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6675998A3999C666267CD98320A0DF5F40004000400040004000400040004000"
// synthesis attribute INIT_2B of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h6675998A3999C666267CD98320A0DF5F40004000400040004000400040004000"
// synthesis attribute INIT_2C of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h539EAC6122A2DD5D4000400040004000539EAC6122A2DD5D4000400040004000"
// synthesis attribute INIT_2D of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h539EAC6122A2DD5D4000400040004000539EAC6122A2DD5D4000400040004000"
// synthesis attribute INIT_2E of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h539EAC6122A2DD5D4000400040004000539EAC6122A2DD5D4000400040004000"
// synthesis attribute INIT_2F of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h539EAC6122A2DD5D4000400040004000539EAC6122A2DD5D4000400040004000"
// synthesis attribute INIT_30 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h2D41D2BE400040002D41D2BE400040002D41D2BE400040002D41D2BE40004000"
// synthesis attribute INIT_31 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h2D41D2BE400040002D41D2BE400040002D41D2BE400040002D41D2BE40004000"
// synthesis attribute INIT_32 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h2D41D2BE400040002D41D2BE400040002D41D2BE400040002D41D2BE40004000"
// synthesis attribute INIT_33 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h2D41D2BE400040002D41D2BE400040002D41D2BE400040002D41D2BE40004000"
// Printing dummy to fill the ram zeros (832-895)
// synthesis attribute INIT_34 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_35 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_36 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_37 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// Constant coefficient for extending 32 MDCT samples to 64 samples (896-959)
// synthesis attribute INIT_38 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_39 of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hC000C000C000C000C000C000C000C000C000C000C000C000C000C000C0000000"
// synthesis attribute INIT_3A of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hC000C000C000C000C000C000C000C000C000C000C000C000C000C000C000C000"
// synthesis attribute INIT_3B of instance_polyphase_window_coefficient_RAMB16_S18 is "256'hC000C000C000C000C000C000C000C000C000C000C000C000C000C000C000C000"
// Printing dummy to fill the ram zeros (960-1023)
// synthesis attribute INIT_3C of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3D of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3E of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3F of instance_polyphase_window_coefficient_RAMB16_S18 is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis translate_off

defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_00 = 256'hFFFE_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_01 = 256'hFFF9_FFFA_FFFA_FFFB_FFFB_FFFC_FFFC_FFFC_FFFD_FFFD_FFFD_FFFE_FFFE_FFFE_FFFE_FFFE;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_02 = 256'hFFE7_FFE9_FFEA_FFEC_FFED_FFEF_FFF0_FFF1_FFF2_FFF3_FFF4_FFF5_FFF6_FFF7_FFF8_FFF8;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_03 = 256'hFFCC_FFCD_FFCF_FFD0_FFD2_FFD4_FFD5_FFD7_FFD9_FFDB_FFDD_FFDF_FFE0_FFE2_FFE4_FFE6;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_04 = 256'h0028_002C_002F_0032_0033_0035_0037_0038_0038_0039_0039_0038_0038_0037_0036_0035;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_05 = 256'hFF9B_FFA9_FFB6_FFC3_FFCE_FFD9_FFE4_FFEE_FFF7_FFFF_0007_000E_0014_001A_001F_0024;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_06 = 256'hFE89_FE9B_FEAD_FEBF_FED1_FEE3_FEF6_FF08_FF1A_FF2C_FF3D_FF4E_FF5E_FF6E_FF7E_FF8D;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_07 = 256'hFDFC_FDF8_FDF6_FDF6_FDF9_FDFD_FE04_FE0B_FE15_FE20_FE2C_FE39_FE48_FE57_FE67_FE78;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_08 = 256'h002E_0064_0097_00C6_00F2_011A_0140_0161_017F_019A_01B2_01C7_01D9_01E7_01F3_01FD;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_09 = 256'hFB53_FBAD_FC08_FC61_FCBA_FD11_FD66_FDB9_FE0A_FE59_FEA5_FEEE_FF34_FF77_FFB8_FFF4;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0A = 256'hF6A3_F6CE_F6FF_F736_F773_F7B5_F7FB_F846_F894_F8E6_F93A_F990_F9E8_FA42_FA9C_FAF7;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0B = 256'hF908_F88A_F819_F7B5_F75E_F713_F6D4_F6A2_F67A_F65E_F64C_F644_F646_F651_F664_F680;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0C = 256'hF7A9_F903_FA51_FB92_FCC7_FDED_FF06_0011_010E_01FD_02DD_03AF_0474_052A_05D1_066B;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0D = 256'hDD32_DF00_E0CD_E298_E45F_E623_E7E2_E99B_EB4E_ECFA_EE9E_F039_F1CB_F353_F4D0_F642;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0E = 256'hC2C9_C425_C590_C708_C88D_CA1D_CBB8_CD5C_CF09_D0BE_D279_D43A_D600_D7CA_D996_DB63;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_0F = 256'hB6C4_B6E6_B71E_B76D_B7D3_B84E_B8DF_B985_BA41_BB10_BBF4_BCEB_BDF4_BF10_C03D_C17B;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_10 = 256'h3FC2_40EF_420B_4314_440B_44EF_45BF_467A_4720_47B1_482C_4892_48E1_4919_493B_4947;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_11 = 256'h266A_2835_29FF_2BC5_2D86_2F41_30F6_32A3_3447_35E2_3772_38F7_3A6F_3BDA_3D37_3E84;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_12 = 256'h0B2F_0CAC_0E34_0FC6_1161_1305_14B1_1664_181D_19DC_1BA0_1D67_1F32_20FF_22CD_249C;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_13 = 256'hFA2E_FAD6_FB8B_FC50_FD22_FE02_FEF1_FFEE_00F9_0212_0339_046D_05AE_06FC_0857_09BD;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_14 = 256'h099B_09AE_09B9_09BB_09B3_09A1_0985_095E_092B_08EC_08A1_084B_07E6_0775_06F7_066B;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_15 = 256'h0563_05BD_0617_066F_06C5_0719_076B_07B9_0804_084A_088C_08C9_0900_0932_095C_097F;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_16 = 256'h0047_0088_00CB_0111_015A_01A6_01F5_0246_0299_02EE_0345_039E_03F7_0452_04AC_0508;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_17 = 256'hFE0C_FE18_FE26_FE38_FE4D_FE65_FE80_FE9E_FEC0_FEE5_FF0D_FF39_FF68_FF9B_FFD1_000B;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_18 = 256'h0198_01A8_01B7_01C6_01D3_01DF_01EA_01F4_01FB_0202_0206_0209_0209_0207_0203_01FD;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_19 = 256'h0081_0091_00A1_00B1_00C2_00D3_00E5_00F7_010A_011C_012E_0140_0153_0165_0176_0187;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1A = 256'hFFE0_FFE5_FFEB_FFF1_FFF8_0000_0008_0012_001B_0026_0031_003D_0049_0056_0064_0072;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1B = 256'hFFC9_FFC8_FFC7_FFC7_FFC7_FFC7_FFC7_FFC8_FFC8_FFCA_FFCC_FFCE_FFD0_FFD3_FFD7_FFDB;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1C = 256'h001B_001D_001F_0020_0022_0024_0026_0028_002A_002C_002D_002F_0031_0032_0033_0035;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1D = 256'h0007_0008_0009_000A_000B_000C_000D_000E_000F_0011_0012_0013_0015_0016_0018_0019;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1E = 256'h0001_0001_0001_0001_0002_0002_0002_0003_0003_0004_0004_0004_0005_0006_0006_0007;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_1F = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0001;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_20 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_21 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_22 = 256'h2B30_D4CF_27D7_D828_254E_DAB1_2366_DC99_21FC_DE03_20FD_DF02_2059_DFA6_2009_DFF6;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_23 = 256'h7258_8DA7_7624_89DB_5BCE_A431_5EFC_A103_4AD8_B527_3E3E_C1C1_35B7_CA48_2FA6_D059;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_24 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_25 = 256'h6E2B_91D4_6E3C_91C3_43E2_BC1D_3271_CD8E_2965_D69A_2448_DBB7_2170_DE8F_2027_DFD8;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_26 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_27 = 256'h6E2B_91D4_6E3C_91C3_43E2_BC1D_3271_CD8E_2965_D69A_2448_DBB7_2170_DE8F_2027_DFD8;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_28 = 256'h6675_998A_3999_C666_267C_D983_20A0_DF5F_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_29 = 256'h6675_998A_3999_C666_267C_D983_20A0_DF5F_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2A = 256'h6675_998A_3999_C666_267C_D983_20A0_DF5F_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2B = 256'h6675_998A_3999_C666_267C_D983_20A0_DF5F_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2C = 256'h539E_AC61_22A2_DD5D_4000_4000_4000_4000_539E_AC61_22A2_DD5D_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2D = 256'h539E_AC61_22A2_DD5D_4000_4000_4000_4000_539E_AC61_22A2_DD5D_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2E = 256'h539E_AC61_22A2_DD5D_4000_4000_4000_4000_539E_AC61_22A2_DD5D_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_2F = 256'h539E_AC61_22A2_DD5D_4000_4000_4000_4000_539E_AC61_22A2_DD5D_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_30 = 256'h2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_31 = 256'h2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_32 = 256'h2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_33 = 256'h2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000_2D41_D2BE_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_34 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_35 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_36 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_37 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_38 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_39 = 256'hC000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3A = 256'hC000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3B = 256'hC000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000_C000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3C = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3D = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3E = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam instance_polyphase_window_coefficient_RAMB16_S18.INIT_3F = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

// synthesis translate_on

endmodule

