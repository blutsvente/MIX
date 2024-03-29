// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_eb_e
//
// Generated
//  by:  wig
//  on:  Tue Mar 30 18:39:52 2004
//  cmd: H:\work\mix_new\MIX\mix_0.pl -strip -nodelta ../../autoopen.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_eb_e.v,v 1.2 2006/01/19 08:50:42 wig Exp $
// $Date: 2006/01/19 08:50:42 $
// $Log: inst_eb_e.v,v $
// Revision 1.2  2006/01/19 08:50:42  wig
// Updated testcases, left 6 failing now (constant, bitsplice/X, ...)
//
// Revision 1.1  2004/04/06 11:19:55  wig
// Adding result/autoopen
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.39 2004/03/30 11:05:58 wig Exp 
//
// Generator: mix_0.pl Revision: 1.28 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps

//
//
// Start of Generated Module rtl of inst_eb_e
//

	// No `defines in this module

module inst_eb_e
	//
	// Generated module inst_eb
	//
		(
		p_mix_s_eo2_gi
		);
		// Generated Module Inputs:
		input		p_mix_s_eo2_gi;
		// Generated Wires:
		wire		p_mix_s_eo2_gi;
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire  s_eo2; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


    // %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	s_eo2 = p_mix_s_eo2_gi;  // __I_I_BIT_PORT


    //
    // Generated Instances
    // wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_eba
		inst_eba_e inst_eba(
			.s_eo2(s_eo2)
		);
		// End of Generated Instance Port Map for inst_eba



endmodule
//
// End of Generated Module rtl of inst_eb_e
//
//
//!End of Module/s
// --------------------------------------------------------------
