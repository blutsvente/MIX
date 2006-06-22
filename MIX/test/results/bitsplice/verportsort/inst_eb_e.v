// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_eb_e
//
// Generated
//  by:  wig
//  on:  Mon Apr 10 13:26:55 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bitsplice.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_eb_e.v,v 1.1 2006/04/10 15:42:10 wig Exp $
// $Date: 2006/04/10 15:42:10 $
// $Log: inst_eb_e.v,v $
// Revision 1.1  2006/04/10 15:42:10  wig
// Updated testcase (__TOP__)
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
//
// Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of inst_eb_e
//

	// No user `defines in this module


module inst_eb_e
//
// Generated module inst_eb
//
		(
		p_mix_tmi_sbist_fail_12_10_go,
		p_mix_c_addr_12_0_gi,
		p_mix_c_bus_in_31_0_gi
		);
	// Generated Module Inputs:
		input	[12:0]	p_mix_c_addr_12_0_gi;
		input	[31:0]	p_mix_c_bus_in_31_0_gi;
	// Generated Module Outputs:
		output	[2:0]	p_mix_tmi_sbist_fail_12_10_go;
	// Generated Wires:
		wire	[2:0]	p_mix_tmi_sbist_fail_12_10_go;
		wire	[12:0]	p_mix_c_addr_12_0_gi;
		wire	[31:0]	p_mix_c_bus_in_31_0_gi;
// End of generated module header




	// Internal signals

		//
		// Generated Signal List
		//
			wire [12:0] c_addr; // __W_PORT_SIGNAL_MAP_REQ
			wire [31:0] c_bus_in; // __W_PORT_SIGNAL_MAP_REQ
			wire [12:0] tmi_sbist_fail; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign	c_addr = p_mix_c_addr_12_0_gi;  // __I_I_BUS_PORT
			assign	c_bus_in = p_mix_c_bus_in_31_0_gi;  // __I_I_BUS_PORT
			assign	p_mix_tmi_sbist_fail_12_10_go[2:0] = tmi_sbist_fail[12:10];  // __I_O_SLICE_PORT




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_eba
		inst_eba_e inst_eba (

			.c_addr_i(c_addr),
			.c_bus_i(c_bus_in),	// CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			.mbist_aci_fail_o(tmi_sbist_fail[10]),
			.mbist_vcd_fail_o(tmi_sbist_fail[11])
		);
		// End of Generated Instance Port Map for inst_eba

		// Generated Instance Port Map for inst_ebb
		inst_ebb_e inst_ebb (

			.c_addr_i(c_addr),
			.c_bus_i(c_bus_in),	// CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			.mbist_sum_fail_o(tmi_sbist_fail[12])
		);
		// End of Generated Instance Port Map for inst_ebb

		// Generated Instance Port Map for inst_ebc
		inst_ebc_e inst_ebc (
			.c_addr(c_addr),
			.c_bus_in(c_bus_in)	// CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
		);
		// End of Generated Instance Port Map for inst_ebc



endmodule
//
// End of Generated Module rtl of inst_eb_e
//

//
//!End of Module/s
// --------------------------------------------------------------