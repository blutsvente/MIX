// -------------------------------------------------------------
//
// Generated Architecture Declaration for struct of ent_aa
//
// Generated
//  by:  wig
//  on:  Tue Nov 22 09:12:37 2005
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: ent_aa.v,v 1.1 2005/11/22 11:01:47 wig Exp $
// $Date: 2005/11/22 11:01:47 $
// $Log: ent_aa.v,v $
// Revision 1.1  2005/11/22 11:01:47  wig
// added testcase bugver/20051121a
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.70 2005/11/10 07:55:25 lutscher Exp 
//
// Generator: mix_0.pl Revision: 1.40 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps

//
//
// Start of Generated Module struct of ent_aa
//

	// No user `defines in this module


module ent_aa
//
// Generated module inst_aa
//
		(
		p_mix_sc_sig_2_go
		);
	// Generated Module Outputs:
		output	[31:0]	p_mix_sc_sig_2_go;
	// Generated Wires:
		wire	[31:0]	p_mix_sc_sig_2_go;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire [31:0] sc_sig_2; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	p_mix_sc_sig_2_go = sc_sig_2;  // __I_O_BUS_PORT




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_aaa
		ent_aaa inst_aaa (	// is i_mic32_top / hier inst_aaa inst_aaa inst_aa
			.sc_p_3(sc_sig_2)	// reverse orderreverse order
				// multiline comments
		);
		// End of Generated Instance Port Map for inst_aaa



endmodule
//
// End of Generated Module struct of ent_aa
//
//
//!End of Module/s
// --------------------------------------------------------------
