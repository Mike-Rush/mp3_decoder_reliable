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

module polyphase_mdct_coefficient (
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
RAMB16_S18 polyphase_mdct_coefficient_RAM (
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

// COS coefficient for MDCT...
// synthesis attribute INIT_00 of polyphase_mdct_coefficient_RAM is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_01 of polyphase_mdct_coefficient_RAM is "256'h4000400040004000400040004000400040004000400040004000400040004000"
// synthesis attribute INIT_02 of polyphase_mdct_coefficient_RAM is "256'h032309640F8C158F1B5D20E7261F2AFA2F6B336736E539DA3C423E143F4E3FEC"
// synthesis attribute INIT_03 of polyphase_mdct_coefficient_RAM is "256'hC013C0B1C1EBC3BDC625C91ACC98D094D505D9E0DF18E4A2EA70F073F69BFCDC"
// synthesis attribute INIT_04 of polyphase_mdct_coefficient_RAM is "256'hC04EC2C1C78ECE86D766E1D4ED6BF9BA064512941E2B2899317938713D3E3FB1"
// synthesis attribute INIT_05 of polyphase_mdct_coefficient_RAM is "256'h3FB13D3E3871317928991E2B12940645F9BAED6BE1D4D766CE86C78EC2C1C04E"
// synthesis attribute INIT_06 of polyphase_mdct_coefficient_RAM is "256'hF69BE4A2D505C91AC1EBC013C3BDCC98D9E0EA70FCDC0F8C20E72F6B39DA3F4E"
// synthesis attribute INIT_07 of polyphase_mdct_coefficient_RAM is "256'hC0B1C625D094DF18F0730323158F261F33673C423FEC3E1436E52AFA1B5D0964"
// synthesis attribute INIT_08 of polyphase_mdct_coefficient_RAM is "256'h3EC53536238E0C7CF383DC71CAC9C13AC13ACAC9DC71F3830C7C238E35363EC5"
// synthesis attribute INIT_09 of polyphase_mdct_coefficient_RAM is "256'h3EC53536238E0C7CF383DC71CAC9C13AC13ACAC9DC71F3830C7C238E35363EC5"
// synthesis attribute INIT_0A of polyphase_mdct_coefficient_RAM is "256'h0F8C2AFA3C423F4E33671B5DFCDCDF18C91AC013C625D9E0F69B158F2F6B3E14"
// synthesis attribute INIT_0B of polyphase_mdct_coefficient_RAM is "256'hC1EBD094EA700964261F39DA3FEC36E520E70323E4A2CC98C0B1C3BDD505F073"
// synthesis attribute INIT_0C of polyphase_mdct_coefficient_RAM is "256'hC2C1D766F9BA1E2B38713FB131791294ED6BCE86C04EC78EE1D4064528993D3E"
// synthesis attribute INIT_0D of polyphase_mdct_coefficient_RAM is "256'h3D3E28990645E1D4C78EC04ECE86ED6B129431783FB138711E2BF9BAD766C2C1"
// synthesis attribute INIT_0E of polyphase_mdct_coefficient_RAM is "256'hEA70C91AC0B1D505FCDC261F3E1439DA1B5DF073CC98C013D094F69B20E73C42"
// synthesis attribute INIT_0F of polyphase_mdct_coefficient_RAM is "256'hC3BDDF1809642F6B3FEC33670F8CE4A2C625C1EBD9E003232AFA3F4E36E5158F"
// synthesis attribute INIT_10 of polyphase_mdct_coefficient_RAM is "256'h3B20187DE782C4DFC4DFE782187D3B203B20187DE782C4DFC4DFE782187D3B20"
// synthesis attribute INIT_11 of polyphase_mdct_coefficient_RAM is "256'h3B20187DE782C4DFC4DFE782187D3B203B20187DE782C4DFC4DFE782187D3B20"
// synthesis attribute INIT_12 of polyphase_mdct_coefficient_RAM is "256'h1B5D3E1433670323D094C0B1DF18158F3C4236E50964D505C013D9E00F8C39DA"
// synthesis attribute INIT_13 of polyphase_mdct_coefficient_RAM is "256'hC625F073261F3FEC2AFAF69BC91AC3BDEA7020E73F4E2F6BFCDCCC98C1EBE4A2"
// synthesis attribute INIT_14 of polyphase_mdct_coefficient_RAM is "256'hC78EF9BA31783D3E1294D766C04EE1D41E2B3FB12899ED6BC2C1CE8606453871"
// synthesis attribute INIT_15 of polyphase_mdct_coefficient_RAM is "256'h38710645CE86C2C1ED6B28993FB11E2BE1D4C04ED76612943D3E3179F9BAC78E"
// synthesis attribute INIT_16 of polyphase_mdct_coefficient_RAM is "256'hDF18C013E4A2261F3F4E158FD505C1EBF0732F6B3C420964CC98C625FCDC36E5"
// synthesis attribute INIT_17 of polyphase_mdct_coefficient_RAM is "256'hC91A032339DA3367F69BC3BDD0940F8C3E142AFAEA70C0B1D9E01B5D3FEC20E7"
// synthesis attribute INIT_18 of polyphase_mdct_coefficient_RAM is "256'h3536F383C13ADC71238E3EC50C7CCAC9CAC90C7C3EC5238EDC71C13AF3833536"
// synthesis attribute INIT_19 of polyphase_mdct_coefficient_RAM is "256'h3536F383C13ADC71238E3EC50C7CCAC9CAC90C7C3EC5238EDC71C13AF3833536"
// synthesis attribute INIT_1A of polyphase_mdct_coefficient_RAM is "256'h261F3C42FCDCC1EBDF182AFA39DAF69BC0B1E4A22F6B36E5F073C013EA703367"
// synthesis attribute INIT_1B of polyphase_mdct_coefficient_RAM is "256'hCC98158F3FEC0F8CC91AD0941B5D3F4E0964C625D50520E73E140323C3BDD9E0"
// synthesis attribute INIT_1C of polyphase_mdct_coefficient_RAM is "256'hCE861E2B3D3EF9BAC04EED6B38712899D766C78E12943FB10645C2C1E1D43179"
// synthesis attribute INIT_1D of polyphase_mdct_coefficient_RAM is "256'h3179E1D4C2C106453FB11294C78ED76628993871ED6BC04EF9BA3D3E1E2BCE87"
// synthesis attribute INIT_1E of polyphase_mdct_coefficient_RAM is "256'hD505CC9820E739DAEA70C1EB09643FEC0323C0B1F0733C421B5DC91AD9E02F6B"
// synthesis attribute INIT_1F of polyphase_mdct_coefficient_RAM is "256'hD094261F36E5E4A2C3BD0F8C3F4EFCDCC013F69B3E14158FC625DF1833672AFA"
// synthesis attribute INIT_20 of polyphase_mdct_coefficient_RAM is "256'h2D41D2BED2BE2D412D41D2BED2BE2D412D41D2BED2BE2D412D41D2BED2BE2D41"
// synthesis attribute INIT_21 of polyphase_mdct_coefficient_RAM is "256'h2D41D2BED2BE2D412D41D2BED2BE2D412D41D2BED2BE2D412D41D2BED2BE2D41"
// synthesis attribute INIT_22 of polyphase_mdct_coefficient_RAM is "256'h2F6B261FC91AE4A23C420F8CC0B1FCDC3FECF69BC1EB158F39DADF18CC982AFA"
// synthesis attribute INIT_23 of polyphase_mdct_coefficient_RAM is "256'hD505336720E7C625EA703E140964C01303233F4EF073C3BD1B5D36E5D9E0D094"
// synthesis attribute INIT_24 of polyphase_mdct_coefficient_RAM is "256'hD76638711294C04E06453D3EE1D4CE8631781E2BC2C1F9BA3FB1ED6BC78E2899"
// synthesis attribute INIT_25 of polyphase_mdct_coefficient_RAM is "256'h2899C78EED6B3FB1F9BAC2C11E2B3179CE86E1D43D3E0645C04E12943871D766"
// synthesis attribute INIT_26 of polyphase_mdct_coefficient_RAM is "256'hCC98EA703FECF073C91A2F6B1B5DC0B1096439DAD505DF183E14FCDCC3BD261F"
// synthesis attribute INIT_27 of polyphase_mdct_coefficient_RAM is "256'hD9E03C420323C1EB20E72AFAC625F69B3F4EE4A2D09436E50F8CC013158F3367"
// synthesis attribute INIT_28 of polyphase_mdct_coefficient_RAM is "256'h238EC13A0C7C3536CAC9F3833EC5DC71DC713EC5F383CAC935360C7CC13A238E"
// synthesis attribute INIT_29 of polyphase_mdct_coefficient_RAM is "256'h238EC13A0C7C3536CAC9F3833EC5DC71DC713EC5F383CAC935360C7CC13A238E"
// synthesis attribute INIT_2A of polyphase_mdct_coefficient_RAM is "256'h36E50323C62533670964C3BD2F6B0F8CC1EB2AFA158FC0B1261F1B5DC01320E7"
// synthesis attribute INIT_2B of polyphase_mdct_coefficient_RAM is "256'hDF183FECE4A2D9E03F4EEA70D5053E14F073D0943C42F69BCC9839DAFCDCC91A"
// synthesis attribute INIT_2C of polyphase_mdct_coefficient_RAM is "256'hE1D43FB1D766ED6B3D3ECE87F9BA3871C78E06453179C2C112942899C04E1E2B"
// synthesis attribute INIT_2D of polyphase_mdct_coefficient_RAM is "256'h1E2BC04E28991294C2C131780645C78E3871F9BACE863D3EED6BD7663FB1E1D4"
// synthesis attribute INIT_2E of polyphase_mdct_coefficient_RAM is "256'hC6250F8C261FC0132AFA0964C91A3C42EA70DF183F4ED094FCDC3367C1EB1B5D"
// synthesis attribute INIT_2F of polyphase_mdct_coefficient_RAM is "256'hE4A23E15CC9803232F6BC0B120E7158FC3BD36E5F69BD5053FECD9E0F07239DA"
// synthesis attribute INIT_30 of polyphase_mdct_coefficient_RAM is "256'h187DC4DF3B20E782E7823B20C4DF187D187DC4DF3B20E782E7823B20C4DF187D"
// synthesis attribute INIT_31 of polyphase_mdct_coefficient_RAM is "256'h187DC4DF3B20E782E7823B20C4DF187D187DC4DF3B20E782E7823B20C4DF187D"
// synthesis attribute INIT_32 of polyphase_mdct_coefficient_RAM is "256'h3C42DF18F69B2F6BC0133367F073E4A239DAC1EB261F0323D5053F4EC91A158F"
// synthesis attribute INIT_33 of polyphase_mdct_coefficient_RAM is "256'hEA7036E5C0B12AFAFCDCD9E03E15C6251B5D0F8CCC983FECD094096320E7C3BD"
// synthesis attribute INIT_34 of polyphase_mdct_coefficient_RAM is "256'hED6B3179C04E3871E1D4F9BA2899C2C13D3ED76606451E2BC78E3FB1CE861294"
// synthesis attribute INIT_35 of polyphase_mdct_coefficient_RAM is "256'h1294CE873FB1C78E1E2B0645D7663D3EC2C12899F9BAE1D43871C04E3178ED6B"
// synthesis attribute INIT_36 of polyphase_mdct_coefficient_RAM is "256'hC1EB2F6BEA70F69B261FC6253FECC91A20E7FCDCE4A23367C0B13C42D5050F8C"
// synthesis attribute INIT_37 of polyphase_mdct_coefficient_RAM is "256'hF0732AFAC3BD3F4ECC981B5D0323DF1836E5C01339DAD9E00964158FD0943E15"
// synthesis attribute INIT_38 of polyphase_mdct_coefficient_RAM is "256'h0C7CDC713536C13A3EC5CAC9238EF383F383238ECAC93EC5C13A3536DC710C7C"
// synthesis attribute INIT_39 of polyphase_mdct_coefficient_RAM is "256'h0C7CDC713536C13A3EC5CAC9238EF383F383238ECAC93EC5C13A3536DC710C7C"
// synthesis attribute INIT_3A of polyphase_mdct_coefficient_RAM is "256'h3F4EC6252F6BDF180F8C0323EA70261FCC983C42C0133E14C91A2AFAE4A20964"
// synthesis attribute INIT_3B of polyphase_mdct_coefficient_RAM is "256'hF69B1B5DD50536E5C1EB3FECC3BD3367D9E0158FFCDCF07220E7D09439DAC0B1"
// synthesis attribute INIT_3C of polyphase_mdct_coefficient_RAM is "256'hF9BA1294E1D42899CE863871C2C13FB1C04E3D3EC78E3178D7661E2BED6B0645"
// synthesis attribute INIT_3D of polyphase_mdct_coefficient_RAM is "256'h0645ED6B1E2BD7663179C78E3D3EC04E3FB1C2C13871CE872899E1D41294F9BA"
// synthesis attribute INIT_3E of polyphase_mdct_coefficient_RAM is "256'hC0133F4EC1EB3C42C62536E5CC982F6BD505261FDF181B5DEA700F8CF69B0323"
// synthesis attribute INIT_3F of polyphase_mdct_coefficient_RAM is "256'hFCDB0964F072158FE4A220E7D9E02AFAD0943367C91A39DAC3BD3E15C0B13FEC"

// synthesis translate_off

defparam polyphase_mdct_coefficient_RAM.INIT_00 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam polyphase_mdct_coefficient_RAM.INIT_01 = 256'h4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000_4000;
defparam polyphase_mdct_coefficient_RAM.INIT_02 = 256'h0323_0964_0F8C_158F_1B5D_20E7_261F_2AFA_2F6B_3367_36E5_39DA_3C42_3E14_3F4E_3FEC;
defparam polyphase_mdct_coefficient_RAM.INIT_03 = 256'hC013_C0B1_C1EB_C3BD_C625_C91A_CC98_D094_D505_D9E0_DF18_E4A2_EA70_F073_F69B_FCDC;
defparam polyphase_mdct_coefficient_RAM.INIT_04 = 256'hC04E_C2C1_C78E_CE86_D766_E1D4_ED6B_F9BA_0645_1294_1E2B_2899_3179_3871_3D3E_3FB1;
defparam polyphase_mdct_coefficient_RAM.INIT_05 = 256'h3FB1_3D3E_3871_3179_2899_1E2B_1294_0645_F9BA_ED6B_E1D4_D766_CE86_C78E_C2C1_C04E;
defparam polyphase_mdct_coefficient_RAM.INIT_06 = 256'hF69B_E4A2_D505_C91A_C1EB_C013_C3BD_CC98_D9E0_EA70_FCDC_0F8C_20E7_2F6B_39DA_3F4E;
defparam polyphase_mdct_coefficient_RAM.INIT_07 = 256'hC0B1_C625_D094_DF18_F073_0323_158F_261F_3367_3C42_3FEC_3E14_36E5_2AFA_1B5D_0964;
defparam polyphase_mdct_coefficient_RAM.INIT_08 = 256'h3EC5_3536_238E_0C7C_F383_DC71_CAC9_C13A_C13A_CAC9_DC71_F383_0C7C_238E_3536_3EC5;
defparam polyphase_mdct_coefficient_RAM.INIT_09 = 256'h3EC5_3536_238E_0C7C_F383_DC71_CAC9_C13A_C13A_CAC9_DC71_F383_0C7C_238E_3536_3EC5;
defparam polyphase_mdct_coefficient_RAM.INIT_0A = 256'h0F8C_2AFA_3C42_3F4E_3367_1B5D_FCDC_DF18_C91A_C013_C625_D9E0_F69B_158F_2F6B_3E14;
defparam polyphase_mdct_coefficient_RAM.INIT_0B = 256'hC1EB_D094_EA70_0964_261F_39DA_3FEC_36E5_20E7_0323_E4A2_CC98_C0B1_C3BD_D505_F073;
defparam polyphase_mdct_coefficient_RAM.INIT_0C = 256'hC2C1_D766_F9BA_1E2B_3871_3FB1_3179_1294_ED6B_CE86_C04E_C78E_E1D4_0645_2899_3D3E;
defparam polyphase_mdct_coefficient_RAM.INIT_0D = 256'h3D3E_2899_0645_E1D4_C78E_C04E_CE86_ED6B_1294_3178_3FB1_3871_1E2B_F9BA_D766_C2C1;
defparam polyphase_mdct_coefficient_RAM.INIT_0E = 256'hEA70_C91A_C0B1_D505_FCDC_261F_3E14_39DA_1B5D_F073_CC98_C013_D094_F69B_20E7_3C42;
defparam polyphase_mdct_coefficient_RAM.INIT_0F = 256'hC3BD_DF18_0964_2F6B_3FEC_3367_0F8C_E4A2_C625_C1EB_D9E0_0323_2AFA_3F4E_36E5_158F;
defparam polyphase_mdct_coefficient_RAM.INIT_10 = 256'h3B20_187D_E782_C4DF_C4DF_E782_187D_3B20_3B20_187D_E782_C4DF_C4DF_E782_187D_3B20;
defparam polyphase_mdct_coefficient_RAM.INIT_11 = 256'h3B20_187D_E782_C4DF_C4DF_E782_187D_3B20_3B20_187D_E782_C4DF_C4DF_E782_187D_3B20;
defparam polyphase_mdct_coefficient_RAM.INIT_12 = 256'h1B5D_3E14_3367_0323_D094_C0B1_DF18_158F_3C42_36E5_0964_D505_C013_D9E0_0F8C_39DA;
defparam polyphase_mdct_coefficient_RAM.INIT_13 = 256'hC625_F073_261F_3FEC_2AFA_F69B_C91A_C3BD_EA70_20E7_3F4E_2F6B_FCDC_CC98_C1EB_E4A2;
defparam polyphase_mdct_coefficient_RAM.INIT_14 = 256'hC78E_F9BA_3178_3D3E_1294_D766_C04E_E1D4_1E2B_3FB1_2899_ED6B_C2C1_CE86_0645_3871;
defparam polyphase_mdct_coefficient_RAM.INIT_15 = 256'h3871_0645_CE86_C2C1_ED6B_2899_3FB1_1E2B_E1D4_C04E_D766_1294_3D3E_3179_F9BA_C78E;
defparam polyphase_mdct_coefficient_RAM.INIT_16 = 256'hDF18_C013_E4A2_261F_3F4E_158F_D505_C1EB_F073_2F6B_3C42_0964_CC98_C625_FCDC_36E5;
defparam polyphase_mdct_coefficient_RAM.INIT_17 = 256'hC91A_0323_39DA_3367_F69B_C3BD_D094_0F8C_3E14_2AFA_EA70_C0B1_D9E0_1B5D_3FEC_20E7;
defparam polyphase_mdct_coefficient_RAM.INIT_18 = 256'h3536_F383_C13A_DC71_238E_3EC5_0C7C_CAC9_CAC9_0C7C_3EC5_238E_DC71_C13A_F383_3536;
defparam polyphase_mdct_coefficient_RAM.INIT_19 = 256'h3536_F383_C13A_DC71_238E_3EC5_0C7C_CAC9_CAC9_0C7C_3EC5_238E_DC71_C13A_F383_3536;
defparam polyphase_mdct_coefficient_RAM.INIT_1A = 256'h261F_3C42_FCDC_C1EB_DF18_2AFA_39DA_F69B_C0B1_E4A2_2F6B_36E5_F073_C013_EA70_3367;
defparam polyphase_mdct_coefficient_RAM.INIT_1B = 256'hCC98_158F_3FEC_0F8C_C91A_D094_1B5D_3F4E_0964_C625_D505_20E7_3E14_0323_C3BD_D9E0;
defparam polyphase_mdct_coefficient_RAM.INIT_1C = 256'hCE86_1E2B_3D3E_F9BA_C04E_ED6B_3871_2899_D766_C78E_1294_3FB1_0645_C2C1_E1D4_3179;
defparam polyphase_mdct_coefficient_RAM.INIT_1D = 256'h3179_E1D4_C2C1_0645_3FB1_1294_C78E_D766_2899_3871_ED6B_C04E_F9BA_3D3E_1E2B_CE87;
defparam polyphase_mdct_coefficient_RAM.INIT_1E = 256'hD505_CC98_20E7_39DA_EA70_C1EB_0964_3FEC_0323_C0B1_F073_3C42_1B5D_C91A_D9E0_2F6B;
defparam polyphase_mdct_coefficient_RAM.INIT_1F = 256'hD094_261F_36E5_E4A2_C3BD_0F8C_3F4E_FCDC_C013_F69B_3E14_158F_C625_DF18_3367_2AFA;
defparam polyphase_mdct_coefficient_RAM.INIT_20 = 256'h2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41;
defparam polyphase_mdct_coefficient_RAM.INIT_21 = 256'h2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41_2D41_D2BE_D2BE_2D41;
defparam polyphase_mdct_coefficient_RAM.INIT_22 = 256'h2F6B_261F_C91A_E4A2_3C42_0F8C_C0B1_FCDC_3FEC_F69B_C1EB_158F_39DA_DF18_CC98_2AFA;
defparam polyphase_mdct_coefficient_RAM.INIT_23 = 256'hD505_3367_20E7_C625_EA70_3E14_0964_C013_0323_3F4E_F073_C3BD_1B5D_36E5_D9E0_D094;
defparam polyphase_mdct_coefficient_RAM.INIT_24 = 256'hD766_3871_1294_C04E_0645_3D3E_E1D4_CE86_3178_1E2B_C2C1_F9BA_3FB1_ED6B_C78E_2899;
defparam polyphase_mdct_coefficient_RAM.INIT_25 = 256'h2899_C78E_ED6B_3FB1_F9BA_C2C1_1E2B_3179_CE86_E1D4_3D3E_0645_C04E_1294_3871_D766;
defparam polyphase_mdct_coefficient_RAM.INIT_26 = 256'hCC98_EA70_3FEC_F073_C91A_2F6B_1B5D_C0B1_0964_39DA_D505_DF18_3E14_FCDC_C3BD_261F;
defparam polyphase_mdct_coefficient_RAM.INIT_27 = 256'hD9E0_3C42_0323_C1EB_20E7_2AFA_C625_F69B_3F4E_E4A2_D094_36E5_0F8C_C013_158F_3367;
defparam polyphase_mdct_coefficient_RAM.INIT_28 = 256'h238E_C13A_0C7C_3536_CAC9_F383_3EC5_DC71_DC71_3EC5_F383_CAC9_3536_0C7C_C13A_238E;
defparam polyphase_mdct_coefficient_RAM.INIT_29 = 256'h238E_C13A_0C7C_3536_CAC9_F383_3EC5_DC71_DC71_3EC5_F383_CAC9_3536_0C7C_C13A_238E;
defparam polyphase_mdct_coefficient_RAM.INIT_2A = 256'h36E5_0323_C625_3367_0964_C3BD_2F6B_0F8C_C1EB_2AFA_158F_C0B1_261F_1B5D_C013_20E7;
defparam polyphase_mdct_coefficient_RAM.INIT_2B = 256'hDF18_3FEC_E4A2_D9E0_3F4E_EA70_D505_3E14_F073_D094_3C42_F69B_CC98_39DA_FCDC_C91A;
defparam polyphase_mdct_coefficient_RAM.INIT_2C = 256'hE1D4_3FB1_D766_ED6B_3D3E_CE87_F9BA_3871_C78E_0645_3179_C2C1_1294_2899_C04E_1E2B;
defparam polyphase_mdct_coefficient_RAM.INIT_2D = 256'h1E2B_C04E_2899_1294_C2C1_3178_0645_C78E_3871_F9BA_CE86_3D3E_ED6B_D766_3FB1_E1D4;
defparam polyphase_mdct_coefficient_RAM.INIT_2E = 256'hC625_0F8C_261F_C013_2AFA_0964_C91A_3C42_EA70_DF18_3F4E_D094_FCDC_3367_C1EB_1B5D;
defparam polyphase_mdct_coefficient_RAM.INIT_2F = 256'hE4A2_3E15_CC98_0323_2F6B_C0B1_20E7_158F_C3BD_36E5_F69B_D505_3FEC_D9E0_F072_39DA;
defparam polyphase_mdct_coefficient_RAM.INIT_30 = 256'h187D_C4DF_3B20_E782_E782_3B20_C4DF_187D_187D_C4DF_3B20_E782_E782_3B20_C4DF_187D;
defparam polyphase_mdct_coefficient_RAM.INIT_31 = 256'h187D_C4DF_3B20_E782_E782_3B20_C4DF_187D_187D_C4DF_3B20_E782_E782_3B20_C4DF_187D;
defparam polyphase_mdct_coefficient_RAM.INIT_32 = 256'h3C42_DF18_F69B_2F6B_C013_3367_F073_E4A2_39DA_C1EB_261F_0323_D505_3F4E_C91A_158F;
defparam polyphase_mdct_coefficient_RAM.INIT_33 = 256'hEA70_36E5_C0B1_2AFA_FCDC_D9E0_3E15_C625_1B5D_0F8C_CC98_3FEC_D094_0963_20E7_C3BD;
defparam polyphase_mdct_coefficient_RAM.INIT_34 = 256'hED6B_3179_C04E_3871_E1D4_F9BA_2899_C2C1_3D3E_D766_0645_1E2B_C78E_3FB1_CE86_1294;
defparam polyphase_mdct_coefficient_RAM.INIT_35 = 256'h1294_CE87_3FB1_C78E_1E2B_0645_D766_3D3E_C2C1_2899_F9BA_E1D4_3871_C04E_3178_ED6B;
defparam polyphase_mdct_coefficient_RAM.INIT_36 = 256'hC1EB_2F6B_EA70_F69B_261F_C625_3FEC_C91A_20E7_FCDC_E4A2_3367_C0B1_3C42_D505_0F8C;
defparam polyphase_mdct_coefficient_RAM.INIT_37 = 256'hF073_2AFA_C3BD_3F4E_CC98_1B5D_0323_DF18_36E5_C013_39DA_D9E0_0964_158F_D094_3E15;
defparam polyphase_mdct_coefficient_RAM.INIT_38 = 256'h0C7C_DC71_3536_C13A_3EC5_CAC9_238E_F383_F383_238E_CAC9_3EC5_C13A_3536_DC71_0C7C;
defparam polyphase_mdct_coefficient_RAM.INIT_39 = 256'h0C7C_DC71_3536_C13A_3EC5_CAC9_238E_F383_F383_238E_CAC9_3EC5_C13A_3536_DC71_0C7C;
defparam polyphase_mdct_coefficient_RAM.INIT_3A = 256'h3F4E_C625_2F6B_DF18_0F8C_0323_EA70_261F_CC98_3C42_C013_3E14_C91A_2AFA_E4A2_0964;
defparam polyphase_mdct_coefficient_RAM.INIT_3B = 256'hF69B_1B5D_D505_36E5_C1EB_3FEC_C3BD_3367_D9E0_158F_FCDC_F072_20E7_D094_39DA_C0B1;
defparam polyphase_mdct_coefficient_RAM.INIT_3C = 256'hF9BA_1294_E1D4_2899_CE86_3871_C2C1_3FB1_C04E_3D3E_C78E_3178_D766_1E2B_ED6B_0645;
defparam polyphase_mdct_coefficient_RAM.INIT_3D = 256'h0645_ED6B_1E2B_D766_3179_C78E_3D3E_C04E_3FB1_C2C1_3871_CE87_2899_E1D4_1294_F9BA;
defparam polyphase_mdct_coefficient_RAM.INIT_3E = 256'hC013_3F4E_C1EB_3C42_C625_36E5_CC98_2F6B_D505_261F_DF18_1B5D_EA70_0F8C_F69B_0323;
defparam polyphase_mdct_coefficient_RAM.INIT_3F = 256'hFCDB_0964_F072_158F_E4A2_20E7_D9E0_2AFA_D094_3367_C91A_39DA_C3BD_3E15_C0B1_3FEC;

// synthesis translate_on

endmodule
