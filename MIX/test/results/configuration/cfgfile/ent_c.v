// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_c
//
// Generated
//  by:  wig
//  on:  Thu Jun 29 16:41:09 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -conf macro._MP_VHDL_USE_ENTY_MP_=Overwritten vhdl_enty from cmdline -conf macro._MP_VHDL_HOOK_ARCH_BODY_MP_=Use macro vhdl_hook_arch_body -conf macro._MP_ADD_MY_OWN_MP_=overloading my own macro ../../configuration.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_c.v,v 1.1 2006/07/04 09:54:10 wig Exp $
// $Date: 2006/07/04 09:54:10 $
// $Log: ent_c.v,v $
// Revision 1.1  2006/07/04 09:54:10  wig
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
// Start of Generated Module rtl of ent_c
//

// No user `defines in this module
// Generated include statements
`include "include.h" // some include test
`define some_var somevalue
`include "include2.h"


module ent_c
//
// Generated Module inst_c
//
	(
	);

// End of generated module header


	// Internal signals

	//
	// Generated Signal List
	//
		wire		sig_14; 
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
		// Generated Instance Port Map for inst_ca
		ent_ca inst_ca (
			.sig_14(sig_14)	// Create connection for inst_c
		);
		// End of Generated Instance Port Map for inst_ca

		// Generated Instance Port Map for inst_cb
		ent_cb inst_cb (
			.sig_14(sig_14)	// Create connection for inst_c
		);
		// End of Generated Instance Port Map for inst_cb



endmodule
//
// End of Generated Module rtl of ent_c
//

//
//!End of Module/s
// --------------------------------------------------------------
