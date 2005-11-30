// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_ed_e
//
// Generated
//  by:  wig
//  on:  Tue Nov 29 12:59:05 2005
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bitsplice.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_ed_e.v,v 1.3 2005/11/30 14:04:16 wig Exp $
// $Date: 2005/11/30 14:04:16 $
// $Log: inst_ed_e.v,v $
// Revision 1.3  2005/11/30 14:04:16  wig
// Updated testcase references
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.71 2005/11/22 11:00:47 wig Exp 
//
// Generator: mix_0.pl Revision: 1.42 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of inst_ed_e
//

	// No user `defines in this module


module inst_ed_e
//
// Generated module inst_ed
//
		(
		p_mix_c_addr_12_0_gi,
		p_mix_c_bus_in_31_0_gi
		);
	// Generated Module Inputs:
		input	[12:0]	p_mix_c_addr_12_0_gi;
		input	[31:0]	p_mix_c_bus_in_31_0_gi;
	// Generated Wires:
		wire	[12:0]	p_mix_c_addr_12_0_gi;
		wire	[31:0]	p_mix_c_bus_in_31_0_gi;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire [12:0] c_addr; // __W_PORT_SIGNAL_MAP_REQ
			wire [31:0] c_bus_in; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	c_addr = p_mix_c_addr_12_0_gi;  // __I_I_BUS_PORT
			assign	c_bus_in = p_mix_c_bus_in_31_0_gi;  // __I_I_BUS_PORT




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_eda
		inst_eda_e inst_eda (

		);
		// End of Generated Instance Port Map for inst_eda

		// Generated Instance Port Map for inst_edb
		inst_edb_e inst_edb (
			.c_add(c_addr),
			.c_bus_in(c_bus_in)	// CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
		);
		// End of Generated Instance Port Map for inst_edb



endmodule
//
// End of Generated Module rtl of inst_ed_e
//
//
//!End of Module/s
// --------------------------------------------------------------
