// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_t_e
//
// Generated
//  by:  wig
//  on:  Mon Nov 10 10:10:32 2003
//  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\open.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_t_e.v,v 1.1 2004/04/06 10:45:54 wig Exp $
// $Date: 2004/04/06 10:45:54 $
// $Log: inst_t_e.v,v $
// Revision 1.1  2004/04/06 10:45:54  wig
// Adding result/open
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
// Start of Generated Module rtl of inst_t_e
//

	// No `defines in this module

module inst_t_e
	//
	// Generated module inst_t
	//
		(
		);
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire	[2:0]	non_open; 
			wire		non_open_bit; 
			wire	[3:0]	wire_open; 
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
		inst_a_e inst_a(
			.open_bit(),
			.open_bus(),
			.open_bus_9(),
			.open_in_bit_11(),
			.open_in_bus_10(),
			.open_part12({ non_open_bit, 3'bz, non_open }), // __W_PORT // __I_BIT_TO_BUSPORT // __I_COMBINE_SPLICES
			.open_part13({ 1'bz, non_open_bit, 1'bz, 1'bz, non_open }), // __W_PORT // __I_BIT_TO_BUSPORT // __I_COMBINE_SPLICES
			.wire_open({ 2'bz, wire_open }), // __W_PORT // __I_COMBINE_SPLICES
			.wire_open_in(wire_open)
		);
		// End of Generated Instance Port Map for inst_a

		// Generated Instance Port Map for inst_b
		inst_b_e inst_b(
			.mix_key_open(),
			.non_open(non_open),
			.non_open_bit(non_open_bit),
			.open_bit_2(),
			.open_bit_3(),
			.open_bit_4()
		);
		// End of Generated Instance Port Map for inst_b



endmodule
//
// End of Generated Module rtl of inst_t_e
//
//
//!End of Module/s
// --------------------------------------------------------------