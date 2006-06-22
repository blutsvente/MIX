// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of avfb_top_rs
//
// Generated
//  by:  wig
//  on:  Tue Apr 18 07:50:26 2006
//  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bugver.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: avfb_top_rs.v,v 1.1 2006/04/19 07:33:13 wig Exp $
// $Date: 2006/04/19 07:33:13 $
// $Log: avfb_top_rs.v,v $
// Revision 1.1  2006/04/19 07:33:13  wig
// Updated/added testcase for 20060404c issue. Needs more work!
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.82 2006/04/13 13:31:52 wig Exp 
//
// Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps



//
//
// Start of Generated Module rtl of avfb_top_rs
//

	// No user `defines in this module
`define top_rs_selclk_out2_par_c 'b0  // __I_VectorConv


module avfb_top_rs
//
// Generated module i_avfb_top_rs
//
		(
		selclk_out2_par_o
		);

	// Generated Module Outputs:
		output	[4:0]	selclk_out2_par_o;
	// Generated Wires:
		wire	[4:0]	selclk_out2_par_o;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire [4:0] top_rs_selclk_out2_par; // __W_PORT_SIGNAL_MAP_REQ
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign top_rs_selclk_out2_par[4:4] = `top_rs_selclk_out2_par_c;
			assign	selclk_out2_par_o = top_rs_selclk_out2_par;  // __I_O_BUS_PORT




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for i_rs_i2c_dcs
		rs_I2C_DCS i_rs_i2c_dcs (
			.selclk_out2_par_o(top_rs_selclk_out2_par[3:0])
		);
		// End of Generated Instance Port Map for i_rs_i2c_dcs



endmodule
//
// End of Generated Module rtl of avfb_top_rs
//

//
//!End of Module/s
// --------------------------------------------------------------