// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_t_e
//
// Generated
//  by:  wig
//  on:  Mon Mar 22 12:42:23 2004
//  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../io.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_t_e.v,v 1.1 2004/04/06 11:05:05 wig Exp $
// $Date: 2004/04/06 11:05:05 $
// $Log: inst_t_e.v,v $
// Revision 1.1  2004/04/06 11:05:05  wig
// Adding result/io
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
// Start of Generated Module rtl of inst_t_e
//

	// No `defines in this module

module inst_t_e
	//
	// Generated module inst_t
	//
		(
		sig_in_01,
		sig_in_03,
		sig_io_05,
		sig_io_06,
		sig_out_02,
		sig_out_04
		);
		// Generated Module Inputs:
		input		sig_in_01;
		input	[7:0]	sig_in_03;
		// Generated Module In/Outputs:
		inout	[5:0]	sig_io_05;
		inout	[6:0]	sig_io_06;
		// Generated Module Outputs:
		output		sig_out_02;
		output	[7:0]	sig_out_04;
		// Generated Wires:
		wire		sig_in_01;
		wire	[7:0]	sig_in_03;
		wire	[5:0]	sig_io_05;
		wire	[6:0]	sig_io_06;
		wire		sig_out_02;
		wire	[7:0]	sig_out_04;
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
		// Generated Instance Port Map for inst_a
		inst_a_e inst_a(
			.p_mix_sig_in_01_gi(sig_in_01),
			.p_mix_sig_in_03_gi(sig_in_03),
			.p_mix_sig_io_05_gc(sig_io_05),
			.p_mix_sig_io_06_gc(sig_io_06),
			.p_mix_sig_out_02_go(sig_out_02),
			.p_mix_sig_out_04_go(sig_out_04)
		);
		// End of Generated Instance Port Map for inst_a



endmodule
//
// End of Generated Module rtl of inst_t_e
//
//
//!End of Module/s
// --------------------------------------------------------------