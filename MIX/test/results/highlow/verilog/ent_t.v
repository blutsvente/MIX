// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_t
//
// Generated
//  by:  wig
//  on:  Thu Nov  6 15:54:28 2003
//  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\highlow.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_t.v,v 1.1 2004/04/06 11:07:31 wig Exp $
// $Date: 2004/04/06 11:07:31 $
// $Log: ent_t.v,v $
// Revision 1.1  2004/04/06 11:07:31  wig
// Adding result/highlow
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
// Start of Generated Module rtl of ent_t
//

	// No `defines in this module

module ent_t
	//
	// Generated module inst_t
	//
		(
		);
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire		mix_logic0; 
		//
		// End of Generated Signal List
		//


    // %COMPILER_OPTS%

	// Generated Signal Assignments
			assign mix_logic0 = 1'b0;


    //
    // Generated Instances
    // wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_a
		ent_a inst_a(
			.low_bit_a(mix_logic0) // Ground bit port
		);
		// End of Generated Instance Port Map for inst_a

		// Generated Instance Port Map for inst_b
		ent_b inst_b(

		);
		// End of Generated Instance Port Map for inst_b



endmodule
//
// End of Generated Module rtl of ent_t
//
//
//!End of Module/s
// --------------------------------------------------------------
