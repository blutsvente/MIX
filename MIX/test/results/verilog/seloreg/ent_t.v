// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_t
//
// Generated
//  by:  wig
//  on:  Mon Oct 24 07:40:44 2005
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_t.v,v 1.1 2005/10/24 12:14:02 wig Exp $
// $Date: 2005/10/24 12:14:02 $
// $Log: ent_t.v,v $
// Revision 1.1  2005/10/24 12:14:02  wig
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
// Start of Generated Module rtl of ent_t
//

	// No `defines in this module


module ent_t
//
// Generated module inst_t
//
		(
		sig_i_a,
		sig_i_a2,
		sig_i_ae,
		sig_o_a,
		sig_o_a2,
		sig_o_ae
		);
	// Generated Module Inputs:
		input		sig_i_a;
		input		sig_i_a2;
		input	[6:0]	sig_i_ae;
	// Generated Module Outputs:
		output		sig_o_a;
		output		sig_o_a2;
		output	[7:0]	sig_o_ae;
	// Generated Wires:
		wire		sig_i_a;
		wire		sig_i_a2;
		wire	[6:0]	sig_i_ae;
		wire		sig_o_a;
		wire		sig_o_a2;
		wire	[7:0]	sig_o_ae;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire		sig_01; 
			wire		sig_03; 
			wire		sig_04; 
			wire	[3:0]	sig_05; 
			wire	[3:0]	sig_06; 
			wire	[5:0]	sig_07; 
			wire	[8:2]	sig_08; 
			wire	[4:0]	sig_13; 
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
		ent_a inst_a (

			.p_mix_sig_01_go(sig_01),	// Use internally test1Will create p_mix_sig_1_go port
			.p_mix_sig_03_go(sig_03),	// Interhierachy link, will create p_mix_sig_3_go
			.p_mix_sig_04_gi(sig_04),	// Interhierachy link, will create p_mix_sig_4_gi
			.p_mix_sig_05_2_1_go(sig_05[2:1]),	// Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			.p_mix_sig_06_gi(sig_06),	// Conflicting definition (X2)
			.p_mix_sig_i_ae_gi(sig_i_ae),	// Input Bus
			.p_mix_sig_o_ae_go(sig_o_ae),	// Output Bus
			.port_i_a(sig_i_a),	// Input Port
			.port_o_a(sig_o_a),	// Output Port
			.sig_07(sig_07),	// Conflicting definition, IN false!
			.sig_08(sig_08),	// VHDL intermediate needed (port name)
			.sig_13(sig_13),	// Create internal signal name
			.sig_i_a2(sig_i_a2),	// Input Port
			.sig_o_a2(sig_o_a2)	// Output Port
		);
		// End of Generated Instance Port Map for inst_a

		// Generated Instance Port Map for inst_b
		ent_b inst_b (

			.port_b_1(sig_01),	// Use internally test1Will create p_mix_sig_1_go port
			.port_b_3(sig_03),	// Interhierachy link, will create p_mix_sig_3_go
			.port_b_4(sig_04),	// Interhierachy link, will create p_mix_sig_4_gi
			.port_b_5_1(sig_05[2]),	// Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			.port_b_5_2(sig_05[1]),	// Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			.port_b_6i(sig_06),	// Conflicting definition (X2)
			.port_b_6o(sig_06),	// Conflicting definition (X2)
			.sig_07(sig_07),	// Conflicting definition, IN false!
			.sig_08(sig_08)	// VHDL intermediate needed (port name)
		);
		// End of Generated Instance Port Map for inst_b



endmodule
//
// End of Generated Module rtl of ent_t
//
//
//!End of Module/s
// --------------------------------------------------------------
