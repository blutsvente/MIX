// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_ea_e
//
// Generated
//  by:  wig
//  on:  Thu Nov  6 15:59:09 2003
//  cmd: H:\work\mix\mix_0.pl -nodelta ..\autoopen.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_ea_e.v,v 1.1 2004/04/06 11:19:49 wig Exp $
// $Date: 2004/04/06 11:19:49 $
// $Log: inst_ea_e.v,v $
// Revision 1.1  2004/04/06 11:19:49  wig
// Adding result/autoopen
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
//
// Generator: mix_0.pl Revision: 1.17 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of inst_ea_e
//

	// No `defines in this module

module inst_ea_e
	//
	// Generated module inst_ea
	//
		(
		s_eo1,
		s_eo2,
		s_eo3,
		s_eo4,
		s_eo5
		);
		// Generated Module Inputs:
		input		s_eo4;
		// Generated Module Outputs:
		output		s_eo1;
		output		s_eo2;
		output		s_eo3;
		output		s_eo5;
		// Generated Wires:
		wire		s_eo1;
		wire		s_eo2;
		wire		s_eo3;
		wire		s_eo4;
		wire		s_eo5;
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
		// Generated Instance Port Map for inst_eaa
		inst_eaa_e inst_eaa(

		);
		// End of Generated Instance Port Map for inst_eaa

		// Generated Instance Port Map for inst_eab
		inst_eab_e inst_eab(

		);
		// End of Generated Instance Port Map for inst_eab

		// Generated Instance Port Map for inst_eac
		inst_eac_e inst_eac(

		);
		// End of Generated Instance Port Map for inst_eac



endmodule
//
// End of Generated Module rtl of inst_ea_e
//
//
//!End of Module/s
// --------------------------------------------------------------