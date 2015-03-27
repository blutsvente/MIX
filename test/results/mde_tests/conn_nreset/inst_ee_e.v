// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_ee_e
//
// Generated
//  by:  wig
//  on:  Mon Mar 22 13:27:29 2004
//  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_ee_e.v,v 1.1 2004/04/06 10:50:31 wig Exp $
// $Date: 2004/04/06 10:50:31 $
// $Log: inst_ee_e.v,v $
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
// Start of Generated Module rtl of inst_ee_e
//

	// No `defines in this module

module inst_ee_e
	//
	// Generated module inst_ee
	//
		(
		cgs_ramclk,
		itm_scani,
		nreset,
		nreset_s,
		si_vclkx2,
		tmi_sbist_fail,
		tmi_scano
		);
		// Generated Module Inputs:
		input		cgs_ramclk;
		input		nreset;
		input		nreset_s;
		input		si_vclkx2;
		input	[12:0]	tmi_sbist_fail;
		input	[70:0]	tmi_scano;
		// Generated Module Outputs:
		output	[70:0]	itm_scani;
		// Generated Wires:
		wire		cgs_ramclk;
		wire	[70:0]	itm_scani;
		wire		nreset;
		wire		nreset_s;
		wire		si_vclkx2;
		wire	[12:0]	tmi_sbist_fail;
		wire	[70:0]	tmi_scano;
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
// End of Generated Module rtl of inst_ee_e
//
//
//!End of Module/s
// --------------------------------------------------------------