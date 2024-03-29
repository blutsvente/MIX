// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_eg_e
//
// Generated
//  by:  wig
//  on:  Mon Mar 22 13:27:29 2004
//  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_eg_e.v,v 1.1 2004/04/06 10:50:32 wig Exp $
// $Date: 2004/04/06 10:50:32 $
// $Log: inst_eg_e.v,v $
// Revision 1.1  2004/04/06 10:50:32  wig
// Adding result/mde_tests
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
//
// Generator: mix_0.pl Revision: 1.26 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of inst_eg_e
//

	// No `defines in this module

module inst_eg_e
	//
	// Generated module inst_eg
	//
		(
		acg_systime_init,
		adp_scani,
		adp_scano,
		nreset,
		nreset_s
		);
		// Generated Module Inputs:
		input	[6:0]	adp_scani;
		input		nreset;
		input		nreset_s;
		// Generated Module Outputs:
		output	[30:0]	acg_systime_init;
		output	[6:0]	adp_scano;
		// Generated Wires:
		wire	[30:0]	acg_systime_init;
		wire	[6:0]	adp_scani;
		wire	[6:0]	adp_scano;
		wire		nreset;
		wire		nreset_s;
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
// End of Generated Module rtl of inst_eg_e
//
//
//!End of Module/s
// --------------------------------------------------------------
