// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_ae
//
// Generated
//  by:  wig
//  on:  Mon Oct 24 05:49:44 2005
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_ae.v,v 1.1 2005/10/24 12:14:01 wig Exp $
// $Date: 2005/10/24 12:14:01 $
// $Log: ent_ae.v,v $
// Revision 1.1  2005/10/24 12:14:01  wig
// added output.language.verilog = ansistyle,2001param
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.62 2005/10/19 15:40:06 wig Exp 
//
// Generator: mix_0.pl Revision: 1.38 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of ent_ae
//

	// No `defines in this module


module ent_ae
//
// Generated module inst_ae
//
		(
		port_ae_2,	// Use internally test2, no port generated
		port_ae_5,	// Bus, single bits go to outside
		port_ae_6,	// Conflicting definition
		sig_07,	// Conflicting definition, IN false!
		sig_08,	// VHDL intermediate needed (port name)
		sig_i_ae,	// Input Bus
		sig_o_ae	// Output Bus
		);
	// Generated Module Inputs:
		input	[4:0]	port_ae_2;
		input	[3:0]	port_ae_5;
		input	[3:0]	port_ae_6;
		input	[5:0]	sig_07;
		input	[8:2]	sig_08;
		input	[6:0]	sig_i_ae;
	// Generated Module Outputs:
		output	[7:0]	sig_o_ae;
	// Generated Wires:
		wire	[4:0]	port_ae_2;
		wire	[3:0]	port_ae_5;
		wire	[3:0]	port_ae_6;
		wire	[5:0]	sig_07;
		wire	[8:2]	sig_08;
		wire	[6:0]	sig_i_ae;
		reg	[7:0]	sig_o_ae;
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
// End of Generated Module rtl of ent_ae
//
//
//!End of Module/s
// --------------------------------------------------------------
