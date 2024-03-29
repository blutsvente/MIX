// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of lp_stdby
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


`include "global_project.i"

//
//
// Start of Generated Module rtl of lp_stdby
//

// No user `defines in this module


module lp_stdby
//
// Generated Module lp_stdby_i1
//
	(
		reallity_in2_s,
		blue_out2_s,
		tes_s,
		test5_s,
		reallity_test_s,
		reallity_gimick_s,
		ext1_pad_do,
		ext2_pad_do
	);

	// Generated Module Inputs:
		input		blue_out2_s;
		input		tes_s;
		input		test5_s;
		input		ext1_pad_do;
		input		ext2_pad_do;
	// Generated Module Outputs:
		output	[31:0]	reallity_in2_s;
		output		reallity_test_s;
		output		reallity_gimick_s;
	// Generated Wires:
		wire	[31:0]	reallity_in2_s;
		wire		blue_out2_s;
		wire		tes_s;
		wire		test5_s;
		wire		reallity_test_s;
		wire		reallity_gimick_s;
		wire		ext1_pad_do;
		wire		ext2_pad_do;
// End of generated module header


	// Internal signals

	//
	// Generated Signal List
	//
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
		// Generated Instance Port Map for reallity_i1
		reallity reallity_i1 (	// LP reallity

			.extout1_i(ext1_pad_do),	// from bluePAD <-> Iocell connect (IO)
			.extout2_i(ext2_pad_do),	// from bluePAD <-> Iocell connect (IO)
			.gimick_o(reallity_gimick_s),	// from reallityto blue
			.in2_o(reallity_in2_s),	// from reallity (X4)to blue
			.out2_i(blue_out2_s),	// to reallityfrom blue
			.sig_o(),	// to blue
			.tes_i(tes_s),	// to reallityfrom blue
			.test5_i(test5_s),	// to reallityfrom blue
			.test_o(reallity_test_s)	// from reallityto blue
		);
		// End of Generated Instance Port Map for reallity_i1



endmodule
//
// End of Generated Module rtl of lp_stdby
//

//
//!End of Module/s
// --------------------------------------------------------------
