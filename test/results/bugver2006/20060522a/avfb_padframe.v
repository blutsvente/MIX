// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of avfb_padframe
//
// Generated
//  by:  wig
//  on:  Wed Mar  7 17:42:31 2007
//  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl ../../bugver2006.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: avfb_padframe.v,v 1.2 2007/03/08 09:11:44 wig Exp $
// $Date: 2007/03/08 09:11:44 $
// $Log: avfb_padframe.v,v $
// Revision 1.2  2007/03/08 09:11:44  wig
// Updating testcase (wrong reference)
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.104 2007/03/03 17:24:06 wig Exp 
//
// Generator: mix_0.pl Revision: 1.47 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of avfb_padframe
//

// No user `defines in this module


module avfb_padframe
//
// Generated Module i_avfb_padframe
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
		// Generated Instance Port Map for pad_data9
		IO60DRV1 pad_data9 (
			.pad(data9)	// From TopLevel Boundary
		);
		// End of Generated Instance Port Map for pad_data9



endmodule
//
// End of Generated Module rtl of avfb_padframe
//

//
//!End of Module/s
// --------------------------------------------------------------