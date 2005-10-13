// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of ent_a
//
// Generated
//  by:  wig
//  on:  Tue Mar 23 10:47:28 2004
//  cmd: H:\work\mix_new\mix\mix_0.pl -sheet HIER=HIER_UAMN -strip -nodelta ../../verilog.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_a.v,v 1.2 2005/10/13 09:09:43 wig Exp $
// $Date: 2005/10/13 09:09:43 $
// $Log: ent_a.v,v $
// Revision 1.2  2005/10/13 09:09:43  wig
// Added intermediate CONN sheet split
//
// Revision 1.1  2004/04/06 10:15:26  wig
// Adding result/verilog testcase, again
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
//
// Generator: mix_0.pl Revision: 1.26 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of ent_a
//


`ifdef MAGMA
    `define ent_aa_inst_name ent_aa
`else
    `define ent_aa_inst_name ent_aa_rtl_conf
`endif

`ifdef MAGMA
    `define ent_ad_inst_name ent_ad
`else
    `define ent_ad_inst_name ent_ad_rtl_conf
`endif


module ent_a
	//
	// Generated module inst_a
	//
		(
		p_mix_sig_01_go,
		p_mix_sig_03_go,
		p_mix_sig_04_gi,
		p_mix_sig_05_2_1_go,
		p_mix_sig_06_gi,
		p_mix_sig_i_ae_gi,
		p_mix_sig_o_ae_go,
		port_i_a,
		port_o_a,
		sig_07,
		sig_08,
		sig_13,
		sig_i_a2,
		sig_o_a2
		);
		// Generated Module Inputs:
		input		p_mix_sig_04_gi;
		input	[3:0]	p_mix_sig_06_gi;
		input	[6:0]	p_mix_sig_i_ae_gi;
		input		port_i_a;
		input	[5:0]	sig_07;
		input		sig_i_a2;
		// Generated Module Outputs:
		output		p_mix_sig_01_go;
		output		p_mix_sig_03_go;
		output	[1:0]	p_mix_sig_05_2_1_go;
		output	[7:0]	p_mix_sig_o_ae_go;
		output		port_o_a;
		output	[8:2]	sig_08;
		output	[4:0]	sig_13;
		output		sig_o_a2;
		// Generated Wires:
		wire		p_mix_sig_01_go;
		wire		p_mix_sig_03_go;
		wire		p_mix_sig_04_gi;
		wire	[1:0]	p_mix_sig_05_2_1_go;
		wire	[3:0]	p_mix_sig_06_gi;
		wire	[6:0]	p_mix_sig_i_ae_gi;
		wire	[7:0]	p_mix_sig_o_ae_go;
		wire		port_i_a;
		wire		port_o_a;
		wire	[5:0]	sig_07;
		wire	[8:2]	sig_08;
		wire	[4:0]	sig_13;
		wire		sig_i_a2;
		wire		sig_o_a2;
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire  sig_01; // __W_PORT_SIGNAL_MAP_REQ
			wire	[4:0]	sig_02; 
			wire  sig_03; // __W_PORT_SIGNAL_MAP_REQ
			wire  sig_04; // __W_PORT_SIGNAL_MAP_REQ
			wire [3:0] sig_05; // __W_PORT_SIGNAL_MAP_REQ
			wire [3:0] sig_06; // __W_PORT_SIGNAL_MAP_REQ
			wire [6:0] sig_14;
			wire [6:0] sig_i_ae; // __W_PORT_SIGNAL_MAP_REQ
			wire [7:0] sig_o_ae; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


    // %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	p_mix_sig_01_go = sig_01;  // __I_O_BIT_PORT
			assign	p_mix_sig_03_go = sig_03;  // __I_O_BIT_PORT
			assign	sig_04 = p_mix_sig_04_gi;  // __I_I_BIT_PORT
			assign	p_mix_sig_05_2_1_go[1:0] = sig_05[2:1];  // __I_O_SLICE_PORT
			assign	sig_06 = p_mix_sig_06_gi;  // __I_I_BUS_PORT
			assign	sig_i_ae = p_mix_sig_i_ae_gi;  // __I_I_BUS_PORT
			assign	p_mix_sig_o_ae_go = sig_o_ae;  // __I_O_BUS_PORT


    //
    // Generated Instances
    // wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_aa
		`ent_aa_inst_name inst_aa(
			.port_aa_1(sig_01), // Use internally test1Will create p_mix_sig_1_go port
			.port_aa_2(sig_02[0]), // Use internally test2, no port generated
			.port_aa_3(sig_03), // Interhierachy link, will create p_mix_sig_3_go
			.port_aa_4(sig_04), // Interhierachy link, will create p_mix_sig_4_gi
			.port_aa_5(sig_05), // Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,...
			.port_aa_6(sig_06), // Conflicting definition (X2)
			.sig_07(sig_07), // Conflicting definition, IN false!
			.sig_08(sig_08), // VHDL intermediate needed (port name)
			.sig_13(sig_13), // Create internal signal name
			.sig_14(sig_14) // Multiline comment 1
				// Multiline comment 2
				// Multiline comment 3
		);
		// End of Generated Instance Port Map for inst_aa

		// Generated Instance Port Map for inst_ab
		ent_ab inst_ab(
			.port_ab_1(sig_01), // Use internally test1Will create p_mix_sig_1_go port
			.port_ab_2(sig_02[1]), // Use internally test2, no port generated
			.sig_13(sig_13), // Create internal signal name
			.sig_14(sig_14) // Multiline comment 1
				// Multiline comment 2
				// Multiline comment 3
		);
		// End of Generated Instance Port Map for inst_ab

		// Generated Instance Port Map for inst_ac
		ent_ac inst_ac(
			.port_ac_2(sig_02[3]) // Use internally test2, no port generated
		);
		// End of Generated Instance Port Map for inst_ac

		// Generated Instance Port Map for inst_ad
		`ent_ad_inst_name inst_ad(
			.port_ad_2(sig_02[4]) // Use internally test2, no port generated
		);
		// End of Generated Instance Port Map for inst_ad

		// Generated Instance Port Map for inst_ae
		ent_ae inst_ae(
			.port_ae_2[1:0](sig_02[1:0]),
			.port_ae_2[4:3](sig_02[4:3]), // Use internally test2, no port generated// __E_CANNOT_COMBINE_SPLICES
			.port_ae_5(sig_05), // Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,...
			.port_ae_6(sig_06), // Conflicting definition (X2)
			.sig_07(sig_07), // Conflicting definition, IN false!
			.sig_08(sig_08), // VHDL intermediate needed (port name)
			.sig_i_ae(sig_i_ae), // Input Bus
			.sig_o_ae(sig_o_ae) // Output Bus
		);
		// End of Generated Instance Port Map for inst_ae



endmodule
//
// End of Generated Module rtl of ent_a
//
//
//!End of Module/s
// --------------------------------------------------------------
