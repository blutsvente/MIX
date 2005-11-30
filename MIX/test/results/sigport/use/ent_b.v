// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_b
//
// Generated
//  by:  wig
//  on:  Fri Jul 15 16:37:11 2005
//  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../sigport.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_b.v,v 1.4 2005/11/30 14:04:15 wig Exp $
// $Date: 2005/11/30 14:04:15 $
// $Log: ent_b.v,v $
// Revision 1.4  2005/11/30 14:04:15  wig
// Updated testcase references
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.55 2005/07/13 15:38:34 wig Exp 
//
// Generator: mix_0.pl Revision: 1.36 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps

//
//
// Start of Generated Module rtl of ent_b
//

	// No `defines in this module
// Generated include statements
use_b.c_b1 use_b.c_b2


module ent_b
	//
	// Generated module inst_b
	//
		(
		port_b_1,
		port_b_3,
		port_b_4,
		port_b_5_1,
		port_b_5_2,
		port_b_6i,
		port_b_6o,
		sig_07,
		sig_08
		);
		// Generated Module Inputs:
		input		port_b_1;
		input		port_b_3;
		input		port_b_5_1;
		input		port_b_5_2;
		input	[3:0]	port_b_6i;
		input	[5:0]	sig_07;
		input	[8:2]	sig_08;
		// Generated Module Outputs:
		output		port_b_4;
		output	[3:0]	port_b_6o;
		// Generated Wires:
		wire		port_b_1;
		wire		port_b_3;
		wire		port_b_4;
		wire		port_b_5_1;
		wire		port_b_5_2;
		wire	[3:0]	port_b_6i;
		wire	[3:0]	port_b_6o;
		wire	[5:0]	sig_07;
		wire	[8:2]	sig_08;
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
		// Generated Instance Port Map for inst_ba
		ent_ba inst_ba (

		);
		// End of Generated Instance Port Map for inst_ba

		// Generated Instance Port Map for inst_bb
		ent_bb inst_bb (

		);
		// End of Generated Instance Port Map for inst_bb



endmodule
//
// End of Generated Module rtl of ent_b
//
//
//!End of Module/s
// --------------------------------------------------------------
