// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_a_e
//
// Generated
//  by:  wig
//  on:  Mon Apr 10 13:26:55 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bitsplice.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_a_e.v,v 1.1 2006/04/10 15:42:10 wig Exp $
// $Date: 2006/04/10 15:42:10 $
// $Log: inst_a_e.v,v $
// Revision 1.1  2006/04/10 15:42:10  wig
// Updated testcase (__TOP__)
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
//
// Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of inst_a_e
//

	// No user `defines in this module


module inst_a_e
//
// Generated module inst_a
//
		(
		widesig_o,
		widesig_r_0,
		widesig_r_1,
		widesig_r_2,
		widesig_r_3,
		widesig_r_4,
		widesig_r_5,
		widesig_r_6,
		widesig_r_7,
		widesig_r_8,
		widesig_r_9,
		widesig_r_10,
		widesig_r_11,
		widesig_r_12,
		widesig_r_13,
		widesig_r_14,
		widesig_r_15,
		widesig_r_16,
		widesig_r_17,
		widesig_r_18,
		widesig_r_19,
		widesig_r_20,
		widesig_r_21,
		widesig_r_22,
		widesig_r_23,
		widesig_r_24,
		widesig_r_25,
		widesig_r_26,
		widesig_r_27,
		widesig_r_28,
		widesig_r_29,
		widesig_r_30,
		unsplice_a1_no3,	// leaves 3 unconnected
		unsplice_a2_all128,	// full 128 bit port
		unsplice_a3_up100,	// connect 100 bits from 0
		unsplice_a4_mid100,	// connect mid 100 bits
		unsplice_a5_midp100,	// connect mid 100 bits
		unsplice_bad_a,
		unsplice_bad_b,
		widemerge_a1,
		p_mix_test1_go
		);
	// Generated Module Outputs:
		output	[31:0]	widesig_o;
		output		widesig_r_0;
		output		widesig_r_1;
		output		widesig_r_2;
		output		widesig_r_3;
		output		widesig_r_4;
		output		widesig_r_5;
		output		widesig_r_6;
		output		widesig_r_7;
		output		widesig_r_8;
		output		widesig_r_9;
		output		widesig_r_10;
		output		widesig_r_11;
		output		widesig_r_12;
		output		widesig_r_13;
		output		widesig_r_14;
		output		widesig_r_15;
		output		widesig_r_16;
		output		widesig_r_17;
		output		widesig_r_18;
		output		widesig_r_19;
		output		widesig_r_20;
		output		widesig_r_21;
		output		widesig_r_22;
		output		widesig_r_23;
		output		widesig_r_24;
		output		widesig_r_25;
		output		widesig_r_26;
		output		widesig_r_27;
		output		widesig_r_28;
		output		widesig_r_29;
		output		widesig_r_30;
		output	[127:0]	unsplice_a1_no3;
		output	[127:0]	unsplice_a2_all128;
		output	[127:0]	unsplice_a3_up100;
		output	[127:0]	unsplice_a4_mid100;
		output	[127:0]	unsplice_a5_midp100;
		output	[127:0]	unsplice_bad_a;
		output	[127:0]	unsplice_bad_b;
		output	[31:0]	widemerge_a1;
		output		p_mix_test1_go;
	// Generated Wires:
		wire	[31:0]	widesig_o;
		wire		widesig_r_0;
		wire		widesig_r_1;
		wire		widesig_r_2;
		wire		widesig_r_3;
		wire		widesig_r_4;
		wire		widesig_r_5;
		wire		widesig_r_6;
		wire		widesig_r_7;
		wire		widesig_r_8;
		wire		widesig_r_9;
		wire		widesig_r_10;
		wire		widesig_r_11;
		wire		widesig_r_12;
		wire		widesig_r_13;
		wire		widesig_r_14;
		wire		widesig_r_15;
		wire		widesig_r_16;
		wire		widesig_r_17;
		wire		widesig_r_18;
		wire		widesig_r_19;
		wire		widesig_r_20;
		wire		widesig_r_21;
		wire		widesig_r_22;
		wire		widesig_r_23;
		wire		widesig_r_24;
		wire		widesig_r_25;
		wire		widesig_r_26;
		wire		widesig_r_27;
		wire		widesig_r_28;
		wire		widesig_r_29;
		wire		widesig_r_30;
		wire	[127:0]	unsplice_a1_no3;
		wire	[127:0]	unsplice_a2_all128;
		wire	[127:0]	unsplice_a3_up100;
		wire	[127:0]	unsplice_a4_mid100;
		wire	[127:0]	unsplice_a5_midp100;
		wire	[127:0]	unsplice_bad_a;
		wire	[127:0]	unsplice_bad_b;
		wire	[31:0]	widemerge_a1;
		wire		p_mix_test1_go;
// End of generated module header




	// Internal signals

		//
		// Generated Signal List
		//
			wire	[7:0]	s_port_offset_01; 
			wire	[7:0]	s_port_offset_02; 
			wire	[1:0]	s_port_offset_02b; 
			wire  test1; // __W_PORT_SIGNAL_MAP_REQ
			wire	[4:0]	test2; 
			wire	[3:0]	test3; 
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	p_mix_test1_go = test1;  // __I_O_BIT_PORT




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_aa
		ent_aa inst_aa (
			.port_1(test1),	// Use internally test1
			.port_2(test2[0]),	// Bus with hole in the middleNeeds input to be happy
			.port_3(test3[0]),	// Bus combining o.k.
			.port_o(s_port_offset_01),
			.port_o02[10:3](s_port_offset_02),  // __W_PORT// __E_CANNOT_COMBINE_SPLICES
			.port_o02[1:0](s_port_offset_02b)  // __W_PORT// __E_CANNOT_COMBINE_SPLICES
		);
		// End of Generated Instance Port Map for inst_aa

		// Generated Instance Port Map for inst_ab
		ent_ab inst_ab (
			.port_2(test2[1]),	// Bus with hole in the middleNeeds input to be happy
			.port_3(test3[1]),	// Bus combining o.k.
			.port_ab_1(test1),	// Use internally test1
			.port_i(s_port_offset_01),
			.port_i02[10:3](s_port_offset_02),  // __W_PORT// __E_CANNOT_COMBINE_SPLICES
			.port_i02[2:1](s_port_offset_02b)  // __W_PORT// __E_CANNOT_COMBINE_SPLICES
		);
		// End of Generated Instance Port Map for inst_ab

		// Generated Instance Port Map for inst_ac
		ent_ac inst_ac (
			.port_2(test2[3]),	// Bus with hole in the middleNeeds input to be happy
			.port_3(test3[2])	// Bus combining o.k.
		);
		// End of Generated Instance Port Map for inst_ac

		// Generated Instance Port Map for inst_ad
		ent_ad inst_ad (
			.port_2(test2[4]),	// Bus with hole in the middleNeeds input to be happy
			.port_3(test3[3])	// Bus combining o.k.
		);
		// End of Generated Instance Port Map for inst_ad

		// Generated Instance Port Map for inst_ae
		ent_ae inst_ae (
			.port_2(test2),	// Bus with hole in the middleNeeds input to be happy
			.port_3(test3)	// Bus combining o.k.
		);
		// End of Generated Instance Port Map for inst_ae



endmodule
//
// End of Generated Module rtl of inst_a_e
//

//
//!End of Module/s
// --------------------------------------------------------------
