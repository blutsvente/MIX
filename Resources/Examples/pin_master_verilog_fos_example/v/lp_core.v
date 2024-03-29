// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of lp_core
//
// Generated
//  by:  lutscher
//  on:  Fri Jun 26 13:24:43 2009
//  cmd: /tools/mix/1.9//mix_1.pl -vinc global_project.i -nodelta LP-blue-pin-list.xls LP-paris-pin-list.xls LP-reallity-pin-list.xls LP-HIER.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author$
// $Id$
// $Date$
// $Log$
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.109 2008/04/01 12:48:34 wig Exp 
//
// Generator: mix_1.pl Revision: 1.3 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of lp_core
//

// No user `defines in this module


module lp_core
//
// Generated Module lp_core_i1
//
	(
		reallity_in2_s,
		blue_out2_s,
		ext0_pad_di,
		vec_in_0_pad_di,
		vec_in_1_pad_di,
		vec_in_2_pad_di,
		vec_in_3_pad_di,
		vec_in_4_pad_di,
		vec_in_5_pad_di,
		vec_in_6_pad_di,
		vec_in_7_pad_di,
		vec_out_0_pad_do,
		vec_out_1_pad_do,
		vec_out_2_pad_do,
		vec_out_3_pad_do,
		tes_s,
		test5_s,
		reallity_test_s,
		reallity_gimick_s,
		bidi_pad_di,
		bidi_pad_do,
		bidi_pad_en
	);

	// Generated Module Inputs:
		input	[31:0]	reallity_in2_s;
		input		ext0_pad_di;
		input		vec_in_0_pad_di;
		input		vec_in_1_pad_di;
		input		vec_in_2_pad_di;
		input		vec_in_3_pad_di;
		input		vec_in_4_pad_di;
		input		vec_in_5_pad_di;
		input		vec_in_6_pad_di;
		input		vec_in_7_pad_di;
		input		reallity_test_s;
		input		reallity_gimick_s;
		input		bidi_pad_di;
	// Generated Module Outputs:
		output		blue_out2_s;
		output		vec_out_0_pad_do;
		output		vec_out_1_pad_do;
		output		vec_out_2_pad_do;
		output		vec_out_3_pad_do;
		output		tes_s;
		output		test5_s;
		output		bidi_pad_do;
		output		bidi_pad_en;
	// Generated Wires:
		wire	[31:0]	reallity_in2_s;
		wire		blue_out2_s;
		wire		ext0_pad_di;
		wire		vec_in_0_pad_di;
		wire		vec_in_1_pad_di;
		wire		vec_in_2_pad_di;
		wire		vec_in_3_pad_di;
		wire		vec_in_4_pad_di;
		wire		vec_in_5_pad_di;
		wire		vec_in_6_pad_di;
		wire		vec_in_7_pad_di;
		wire		vec_out_0_pad_do;
		wire		vec_out_1_pad_do;
		wire		vec_out_2_pad_do;
		wire		vec_out_3_pad_do;
		wire		tes_s;
		wire		test5_s;
		wire		reallity_test_s;
		wire		reallity_gimick_s;
		wire		bidi_pad_di;
		wire		bidi_pad_do;
		wire		bidi_pad_en;
// End of generated module header


	// Internal signals

	//
	// Generated Signal List
	//
		wire		blue_bla_s; 
		wire		blue_blub_s; 
		wire		gh_s; 
		wire		paris_bla10_s; 
		wire		paris_bla1_s; 
		wire		paris_in3_s; 
		wire	[3:0]	paris_in4_s; 
		wire	[12:0]	paris_test1_s; 
		wire		teste_s; 
	//
	// End of Generated Signal List
	//


	// %COMPILER_OPTS%

	//
	// Generated Signal Assignments
	//




	//
	// Generated Instances and Port Mappings
	//
		// Generated Instance Port Map for blue_i1
		blue blue_i1 (	// LP blue
			.bla10_i(paris_bla10_s),	// from paristo blue
			.bla1_i(paris_bla1_s),	// from paristo blue
			.bla_o(blue_bla_s),	// to parisfrom blue
			.blub_o(blue_blub_s),	// to parisfrom blue
			.extin1_i(ext0_pad_di),	// from EXTERNALPAD <-> Iocell connect (IO)
			.extout1_o(),	// to EXTERNAL, to reallity
			.extout2_o(),	// to EXTERNAL, to reallity
			.gh_o(gh_s),	// to parisfrom blue
			.gimick_i(reallity_gimick_s),	// from reallityto blue
			.in2_i(reallity_in2_s),	// from reallity (X4)to blue
			.in2_test_i(reallity_in2_s[15:0]),	// from reallity (X4)to blue
			.in3_i(paris_in3_s),	// from paristo blue
			.in4_i(paris_in4_s),	// from paristo blue
			.out2_o(blue_out2_s),	// to reallityfrom blue
			.sig3_i(reallity_in2_s[5:3]),	// from reallity (X4)to blue
			.sig_i(reallity_in2_s[5]),	// from reallity (X4)to blue
			.tes_o(tes_s),	// to reallityfrom blue
			.test1_i(paris_test1_s),	// from paristo blue
			.test5_o(test5_s),	// to reallityfrom blue
			.test_i(reallity_test_s),	// from reallityto blue
			.teste_o(teste_s),	// to parisfrom blue
			.vec_in_i({ vec_in_7_pad_di, vec_in_6_pad_di, vec_in_5_pad_di, vec_in_4_pad_di, vec_in_3_pad_di, vec_in_2_pad_di, vec_in_1_pad_di, vec_in_0_pad_di }), // __I_BIT_TO_BUSPORT	// testPAD <-> Iocell connect (IO) (x8) // __I_COMBINE_SPLICES
			.vec_out_o({ vec_out_3_pad_do, vec_out_2_pad_do, vec_out_1_pad_do, vec_out_0_pad_do }) // __I_BIT_TO_BUSPORT	// testPAD <-> Iocell connect (IO) (x4) // __I_COMBINE_SPLICES
		);
		// End of Generated Instance Port Map for blue_i1

		// Generated Instance Port Map for paris_i1
		paris paris_i1 (	// LP paris

			.bidictrl_o(bidi_pad_en),	// to EXTERNALPAD <-> Iocell connect (IO)
			.bidiin_i(bidi_pad_di),	// from EXTERNALPAD <-> Iocell connect (IO)
			.bidiout_o(bidi_pad_do),	// to EXTERNALPAD <-> Iocell connect (IO)
			.bla10_o(paris_bla10_s),	// from paristo blue
			.bla1_o(paris_bla1_s),	// from paristo blue
			.bla_i(blue_bla_s),	// to parisfrom blue
			.blub_i(blue_blub_s),	// to parisfrom blue
			.gh_i(gh_s),	// to parisfrom blue
			.in3_o(paris_in3_s),	// from paristo blue
			.in4_o(paris_in4_s),	// from paristo blue
			.test1_o(paris_test1_s),	// from paristo blue
			.teste_i(teste_s)	// to parisfrom blue
		);
		// End of Generated Instance Port Map for paris_i1



endmodule
//
// End of Generated Module rtl of lp_core
//

//
//!End of Module/s
// --------------------------------------------------------------
