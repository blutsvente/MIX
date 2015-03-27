// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_ab
//
// Generated
//  by:  wig
//  on:  Mon Oct 24 15:17:36 2005
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_ab.v,v 1.2 2005/10/24 15:50:24 wig Exp $
// $Date: 2005/10/24 15:50:24 $
// $Log: ent_ab.v,v $
// Revision 1.2  2005/10/24 15:50:24  wig
// added 'reg detection to ::out column
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.64 2005/10/20 17:28:26 lutscher Exp 
//
// Generator: mix_0.pl Revision: 1.38 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of ent_ab
//

	// No `defines in this module


module ent_ab
//
// Generated module inst_ab
//
		(
		port_ab_1,	// Use internally test1
		port_ab_2,	// Use internally test2, no port generated
		sig_13,	// Create internal signal name
		sig_14,	// Multiline comment 1
				// Multiline comment 2
				// Multiline comment 3
		sig_17	// reg in inst_a, ab and aa
		);
	// Generated Module Inputs:
		input		port_ab_1;
		input	[4:0]	sig_13;
		input	[6:0]	sig_14;
	// Generated Module Outputs:
		output		port_ab_2;
		output		sig_17;
	// Generated Wires:
		wire		port_ab_1;
		reg		port_ab_2;
		wire	[4:0]	sig_13;
		wire	[6:0]	sig_14;
		wire		sig_17;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings


endmodule
//
// End of Generated Module rtl of ent_ab
//
//
//!End of Module/s
// --------------------------------------------------------------