// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_a_e
//
// Generated
//  by:  wig
//  on:  Thu Nov  6 15:56:25 2003
//  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\genwidth.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_a_e.v,v 1.1 2004/04/06 11:08:20 wig Exp $
// $Date: 2004/04/06 11:08:20 $
// $Log: inst_a_e.v,v $
// Revision 1.1  2004/04/06 11:08:20  wig
// Adding result/genwidth
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
//
// Generator: mix_0.pl Revision: 1.17 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of inst_a_e
//

	// No `defines in this module

module inst_a_e
	//
	// Generated module inst_a
	//
		(
		);
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire	[width - 1:0]	y_c422444; 
		//
		// End of Generated Signal List
		//


    // %COMPILER_OPTS%

	// Generated Signal Assignments


    //
    // Generated Instances
    // wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_aa
		inst_aa_e inst_aa(
			.y_p_i(y_c422444)
		);
		defparam inst_aa.width = 9;
		// End of Generated Instance Port Map for inst_aa

		// Generated Instance Port Map for inst_ab
		inst_ab_e inst_ab(
			.y_p0_i(y_c422444)
		);
		defparam inst_ab.width = 9;
		// End of Generated Instance Port Map for inst_ab



endmodule
//
// End of Generated Module rtl of inst_a_e
//
//
//!End of Module/s
// --------------------------------------------------------------
