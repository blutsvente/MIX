// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_b
//
// Generated
//  by:  wig
//  on:  Wed Feb 28 15:34:05 2007
//  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_b.v,v 1.1 2007/03/01 16:26:06 wig Exp $
// $Date: 2007/03/01 16:26:06 $
// $Log: ent_b.v,v $
// Revision 1.1  2007/03/01 16:26:06  wig
// Added emumux/all testcase
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.100 2006/11/21 16:51:10 wig Exp 
//
// Generator: mix_0.pl Revision: 1.47 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of ent_b
//

// No user `defines in this module


module ent_b
//
// Generated Module inst_b
//
	(
		port_b_1,	// Will create p_mix_sig_1_go port
		port_b_3,	// Interhierachy link, will create p_mix_sig_3_go
		port_b_4,	// Interhierachy link, will create p_mix_sig_4_gi
		port_b_5_1,	// Bus, single bits go to outside, will create p_mix_sig_5_2_2_go
		port_b_5_2,	// Bus, single bits go to outside, will create P_MIX_sound_alarm_test5_1_1_GO
		port_b_6i,	// Conflicting definition
		port_b_6o,	// Conflicting definition
		sig_07,	// Conflicting definition, IN false!
		sig_08	// VHDL intermediate needed (port name)
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

	//
	// Generated Signal Assignments
	//




	//
	// Generated Instances and Port Mappings
	//
	`define insert_emu_mux_inst_ba
		// Emulator Data Injection Path, generated by MIX
		wire emu_mux_inst_ba = 1'b0;


	`endif
		// Generated Instance Port Map for inst_ba
		ent_ba inst_ba (

		);
		// End of Generated Instance Port Map for inst_ba

	`define insert_emu_mux_inst_bb
		// Emulator Data Injection Path, generated by MIX
		wire emu_mux_inst_bb = 1'b0;


	`endif
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
