// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_a_e
//
// Generated
//  by:  wig
//  on:  Mon Jun 26 16:30:00 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../../genwidth.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_a_e.v,v 1.4 2006/07/04 09:54:11 wig Exp $
// $Date: 2006/07/04 09:54:11 $
// $Log: inst_a_e.v,v $
// Revision 1.4  2006/07/04 09:54:11  wig
// Update more testcases, add configuration/cfgfile
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.90 2006/06/22 07:13:21 wig Exp 
//
// Generator: mix_0.pl Revision: 1.46 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of inst_a_e
//

// No user `defines in this module


module inst_a_e
//
// Generated Module inst_a
//
	(
	);

// End of generated module header


	// Internal signals

	//
	// Generated Signal List
	//
		wire	[width - 1:0]	y_c422444; 
		// __I_NODRV_I wire	[`dwidth - 1:0]	y_defwidth;  // __W_BAD_BRANCH
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
		// Generated Instance Port Map for inst_aa
		inst_aa_e inst_aa (
	.y_p_i(y_c422444)
		);
		defparam inst_aa.width = 9;
		// End of Generated Instance Port Map for inst_aa

		// Generated Instance Port Map for inst_ab
		inst_ab_e inst_ab (
	.y_p0_i(y_c422444)
		);
		defparam inst_ab.width = 9;
		// End of Generated Instance Port Map for inst_ab

		// Generated Instance Port Map for inst_ac
		inst_ac_e inst_ac (
	// __I_NODRV_I .defwidth(y_defwidth/__nodrv__)
		);
		// End of Generated Instance Port Map for inst_ac



endmodule
//
// End of Generated Module rtl of inst_a_e
//

//
//!End of Module/s
// --------------------------------------------------------------
