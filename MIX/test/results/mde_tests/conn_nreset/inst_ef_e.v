// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_ef_e
//
// Generated
//  by:  wig
//  on:  Mon Mar 22 13:27:29 2004
//  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_ef_e.v,v 1.1 2004/04/06 10:50:31 wig Exp $
// $Date: 2004/04/06 10:50:31 $
// $Log: inst_ef_e.v,v $
// Revision 1.1  2004/04/06 10:50:31  wig
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
// Start of Generated Module rtl of inst_ef_e
//

	// No `defines in this module

module inst_ef_e
	//
	// Generated module inst_ef
	//
		(
		cp_laddro,
		cp_lcmd,
		cpu_scani,
		cpu_scano,
		int23,
		int24,
		int25,
		int26,
		int27,
		nreset,
		nreset_s,
		tap_reset_n,
		tap_reset_n_o
		);
		// Generated Module Inputs:
		input	[7:0]	cpu_scani;
		input		int23;
		input		int24;
		input		int25;
		input		int26;
		input		int27;
		input		nreset;
		input		nreset_s;
		input		tap_reset_n;
		// Generated Module Outputs:
		output	[31:0]	cp_laddro;
		output	[6:0]	cp_lcmd;
		output	[7:0]	cpu_scano;
		output		tap_reset_n_o;
		// Generated Wires:
		wire	[31:0]	cp_laddro;
		wire	[6:0]	cp_lcmd;
		wire	[7:0]	cpu_scani;
		wire	[7:0]	cpu_scano;
		wire		int23;
		wire		int24;
		wire		int25;
		wire		int26;
		wire		int27;
		wire		nreset;
		wire		nreset_s;
		wire		tap_reset_n;
		wire		tap_reset_n_o;
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
// End of Generated Module rtl of inst_ef_e
//
//
//!End of Module/s
// --------------------------------------------------------------