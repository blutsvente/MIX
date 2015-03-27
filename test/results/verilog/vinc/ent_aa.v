// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_aa
//
// Generated
//  by:  wig
//  on:  Tue Jun 27 05:12:12 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_aa.v,v 1.1 2006/11/15 16:04:10 wig Exp $
// $Date: 2006/11/15 16:04:10 $
// $Log: ent_aa.v,v $
// Revision 1.1  2006/11/15 16:04:10  wig
// Added Files: Testcase for verilog include import
//  	ent_a.v ent_aa.v ent_ab.v ent_ac.v ent_ad.v ent_ae.v ent_b.v
//  	ent_ba.v ent_bb.v ent_t.v mix.cfg mix.log vinc_def.i
//
// Revision 1.6  2006/07/04 09:54:11  wig
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
// Start of Generated Module rtl of ent_aa
//

// No user `defines in this module


module ent_aa
//
// Generated Module inst_aa
//
	(
		port_aa_1,	// Use internally test1
		port_aa_2,	// Use internally test2, no port generated
		port_aa_3,	// Interhierachy link, will create p_mix_sig_3_go
		port_aa_4,	// Interhierachy link, will create p_mix_sig_4_gi
		port_aa_5,	// Bus, single bits go to outside
		port_aa_6,	// Conflicting definition
		sig_07,	// Conflicting definition, IN false!
		sig_08,	// VHDL intermediate needed (port name)
		sig_13,	// Create internal signal name
		sig_14	// Multiline comment 1
				// Multiline comment 2
				// Multiline comment 3
	);

	// Generated Module Inputs:
		input		port_aa_4;
	// Generated Module Outputs:
		output		port_aa_1;
		output		port_aa_2;
		output		port_aa_3;
		output	[3:0]	port_aa_5;
		output	[3:0]	port_aa_6;
		output	[5:0]	sig_07;
		output	[8:2]	sig_08;
		output	[4:0]	sig_13;
		output	[6:0]	sig_14;
	// Generated Wires:
		wire		port_aa_1;
		wire		port_aa_2;
		wire		port_aa_3;
		wire		port_aa_4;
		wire	[3:0]	port_aa_5;
		wire	[3:0]	port_aa_6;
		wire	[5:0]	sig_07;
		wire	[8:2]	sig_08;
		wire	[4:0]	sig_13;
		wire	[6:0]	sig_14;
// End of generated module header


	// Internal signals

	//
	// Generated Signal List
	//
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


endmodule
//
// End of Generated Module rtl of ent_aa
//

//
//!End of Module/s
// --------------------------------------------------------------