// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of paris
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
// Start of Generated Module rtl of paris
//

// No user `defines in this module


module paris
//
// Generated Module paris_i1
//
	(
		test1_o,	// to blue
		bla_i,	// from blue
		in3_o,	// to blue
		in4_o,	// to blue
		bla10_o,	// to blue
		teste_i,	// from blue
		gh_i,	// from blue
		bla1_o,	// to blue
		blub_i,	// from blue
		bidiin_i,	// from EXTERNAL
		bidiout_o,	// to EXTERNAL
		bidictrl_o	// to EXTERNAL
	);

	// Generated Module Inputs:
		input		bla_i;
		input		teste_i;
		input		gh_i;
		input		blub_i;
		input		bidiin_i;
	// Generated Module Outputs:
		output	[12:0]	test1_o;
		output		in3_o;
		output	[3:0]	in4_o;
		output		bla10_o;
		output		bla1_o;
		output		bidiout_o;
		output		bidictrl_o;
	// Generated Wires:
		wire	[12:0]	test1_o;
		wire		bla_i;
		wire		in3_o;
		wire	[3:0]	in4_o;
		wire		bla10_o;
		wire		teste_i;
		wire		gh_i;
		wire		bla1_o;
		wire		blub_i;
		wire		bidiin_i;
		wire		bidiout_o;
		wire		bidictrl_o;
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


endmodule
//
// End of Generated Module rtl of paris
//

//
//!End of Module/s
// --------------------------------------------------------------
