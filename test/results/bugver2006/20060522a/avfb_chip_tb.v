// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of avfb_chip_tb
//
// Generated
//  by:  wig
//  on:  Thu Jul 20 11:19:51 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bugver2006.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: avfb_chip_tb.v,v 1.1 2006/10/30 15:38:11 wig Exp $
// $Date: 2006/10/30 15:38:11 $
// $Log: avfb_chip_tb.v,v $
// Revision 1.1  2006/10/30 15:38:11  wig
// Updated testcase bitsplice/rfe20060904a and added some bug testcases.
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.92 2006/07/12 15:23:40 wig Exp 
//
// Generator: mix_0.pl Revision: 1.46 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of avfb_chip_tb
//

// No user `defines in this module


module avfb_chip_tb
//
// Generated Module avfb_chip_tb
//
	(
		data9	// From TopLevel Boundary
	);

	// Generated Module In/Outputs:
		inout		data9;
	// Generated Wires:
		wire		data9;
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
		// Generated Instance Port Map for dut
		avfb_chip dut (
			.DATA9(data9)	// From TopLevel Boundary
		);
		// End of Generated Instance Port Map for dut



endmodule
//
// End of Generated Module rtl of avfb_chip_tb
//

//
//!End of Module/s
// --------------------------------------------------------------