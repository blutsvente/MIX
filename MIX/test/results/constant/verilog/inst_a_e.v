// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of inst_a_e
//
// Generated
//  by:  wig
//  on:  Wed Aug 18 12:44:01 2004
//  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../../constant.xls
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: wig $
// $Id: inst_a_e.v,v 1.3 2004/08/18 10:47:09 wig Exp $
// $Date: 2004/08/18 10:47:09 $
// $Log: inst_a_e.v,v $
// Revision 1.3  2004/08/18 10:47:09  wig
// reworked some testcases
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.45 2004/08/09 15:48:14 wig Exp 
//
// Generator: mix_0.pl Revision: 1.32 , wilfried.gaensheimer@micronas.com
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of inst_a_e
//

`define bug20040329a_t1_c 1'h0  // __I_ConvConstant2:0x0
`define bug20040329a_t2_c 1'b0 
`define bug20040329a_t3_c 1'b0  // __I_ConvConstant3:0b0
`define bug20040329a_t4_c 8'b0101_0101  // __I_ConvConstant3:0b0101_0101
`define bus20040728_c 1'b0 
`define bus20040728_altconst 1'b0 
`define bus20040728_altconst2 1'b1 
`define bus20040728_part_c1 1'b0 
`define bus20040728_part_c2 1'b0 
`define bus20040728_top_c1 1'b0 
`define bus20040728_top_c2 1'b1 
`define const_01_c 1'b0 
`define const_02_c 1'b1 
`define const_03_c 'b64  // __I_VectorConv
`define const_04_c 'b32  // __I_VectorConv
`define const_05_c 1'b1 
`define mix_const_1_c 1'b0 
`define mix_const_10_c 16#FF#  // __I_ConstNoconv
`define mix_const_11_c 2#1010_1010#  // __I_ConstNoconv
`define mix_const_12_c 2.2E-6  // __I_ConstNoconv
`define mix_const_13_c 10 ns 
`define mix_const_14_c 2.27 us 
`define mix_const_15_c ein string  // __I_ConstNoconv
`define mix_const_16_c 'b11111111  // __I_VectorConv
`define mix_const_18_c 'b01010101  // __I_VectorConv
`define mix_const_2_c 1'b1 
`define mix_const_21_c 'b10101100  // __I_VectorConv
`define mix_const_22_c 'b10101100  // __I_VectorConv
`define mix_const_23_c 8'b11111111  // __I_ConvConstant: 16#FF#
`define mix_const_24_c 8'b00010001  // __I_ConvConstant: 16#11#
`define mix_const_25_c 11'b00011111111  // __I_ConvConstant: 16#FF#
`define mix_const_26_c 8'b11111111  // __I_ConvConstant: 0xff
`define mix_const_27_c 8'b01010101  // __I_ConvConstant: 0b01010101
`define mix_const_28_c 8'b00000111  // __I_ConvConstant: 8#07#
`define mix_const_29_c 8'b11001100  // __I_ConvConstant: 2#11001100#
`define mix_const_3_c 1'b1 
`define mix_const_30_c 4#3030#  // __I_ConvConstant: 4#3030#
`define mix_const_31_c 4'b11101110  // __E_VECTOR_WIDTH  // __I_ConvConstant: 16#ee#
`define mix_const_4_c 1'b0 
`define mix_const_5_c 1'b0 
`define mix_const_6_c 1'b1 
`define mix_const_7_c 10  // __I_ConstNoconv
`define mix_const_8_c 10.2  // __I_ConstNoconv
`define mix_const_9_c 1_000_000.0  // __I_ConstNoconv


module inst_a_e
	//
	// Generated module inst_a
	//
		(
		);
		// End of generated module header


    // Internal signals

		//
		// Generated Signal List
		//
			wire		bug20040329a_t1;
			wire		bug20040329a_t2;
			wire		bug20040329a_t3;
			wire		bug20040329a_t4;
			wire	[7:0]	bus20040728;
			wire	[7:0]	bus20040728_altop; 
			wire	[7:0]	bus20040728_part; 
			wire	[7:0]	bus20040728_top; 
			wire		const_01;
			wire		const_02;
			wire	[6:0]	const_03;
			wire	[3:0]	const_04;
			wire		const_05;
			wire	[4:0]	mix_const_1;
			wire		mix_const_10;
			wire		mix_const_11;
			wire		mix_const_12;
			wire		mix_const_13;
			wire		mix_const_14;
			wire		mix_const_15;
			wire	[7:0]	mix_const_16;
			wire	[7:0]	mix_const_18;
			wire	[2:0]	mix_const_2;
			wire	[7:0]	mix_const_21;
			wire	[7:0]	mix_const_22;
			wire	[7:0]	mix_const_23;
			wire	[7:0]	mix_const_24;
			wire	[10:0]	mix_const_25;
			wire	[7:0]	mix_const_26;
			wire	[7:0]	mix_const_27;
			wire	[7:0]	mix_const_28;
			wire	[7:0]	mix_const_29;
			wire	[3:0]	mix_const_3;
			wire	[7:0]	mix_const_30;
			wire	[3:0]	mix_const_31;
			wire	[3:0]	mix_const_4;
			wire		mix_const_5;
			wire		mix_const_6;
			wire		mix_const_7;
			wire		mix_const_8;
			wire		mix_const_9;
		//
		// End of Generated Signal List
		//


    // %COMPILER_OPTS%

	// Generated Signal Assignments
			assign bug20040329a_t1 = `bug20040329a_t1_c;
			assign bug20040329a_t2 = `bug20040329a_t2_c;
			assign bug20040329a_t3 = `bug20040329a_t3_c;
			assign bug20040329a_t4 = `bug20040329a_t4_c;
			assign bus20040728 = `bus20040728_c;
			assign bus20040728_altop[3:1] = `bus20040728_altconst;
			assign bus20040728_altop[0:0] = `bus20040728_altconst2;
			assign bus20040728_part[2:2] = `bus20040728_part_c1;
			assign bus20040728_part[6:4] = `bus20040728_part_c2;
			assign bus20040728_top[3:1] = `bus20040728_top_c1;
			assign bus20040728_top[0:0] = `bus20040728_top_c2;
			assign const_01 = `const_01_c;
			assign const_02 = `const_02_c;
			assign const_03 = `const_03_c;
			assign const_04 = `const_04_c;
			assign const_05 = `const_05_c;
			assign mix_const_1 = `mix_const_1_c;
			assign mix_const_10 = `mix_const_10_c;
			assign mix_const_11 = `mix_const_11_c;
			assign mix_const_12 = `mix_const_12_c;
			assign mix_const_13 = `mix_const_13_c;
			assign mix_const_14 = `mix_const_14_c;
			assign mix_const_15 = `mix_const_15_c;
			assign mix_const_16 = `mix_const_16_c;
			assign mix_const_18 = `mix_const_18_c;
			assign mix_const_2 = `mix_const_2_c;
			assign mix_const_21 = `mix_const_21_c;
			assign mix_const_22 = `mix_const_22_c;
			assign mix_const_23 = `mix_const_23_c;
			assign mix_const_24 = `mix_const_24_c;
			assign mix_const_25 = `mix_const_25_c;
			assign mix_const_26 = `mix_const_26_c;
			assign mix_const_27 = `mix_const_27_c;
			assign mix_const_28 = `mix_const_28_c;
			assign mix_const_29 = `mix_const_29_c;
			assign mix_const_3 = `mix_const_3_c;
			assign mix_const_30 = `mix_const_30_c;
			assign mix_const_31 = `mix_const_31_c;
			assign mix_const_4 = `mix_const_4_c;
			assign mix_const_5 = `mix_const_5_c;
			assign mix_const_6 = `mix_const_6_c;
			assign mix_const_7 = `mix_const_7_c;
			assign mix_const_8 = `mix_const_8_c;
			assign mix_const_9 = `mix_const_9_c;


    //
    // Generated Instances
    // wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for inst_aa
		inst_aa_e inst_aa(
			.bit_vector_p(mix_const_16),
			.bug20040329a_t1(bug20040329a_t1),
			.bug20040329a_t2(bug20040329a_t2),
			.bug20040329a_t3(bug20040329a_t3),
			.bug20040329a_t4(bug20040329a_t4),
			.bus20040728_all_i(bus20040728),
			.bus20040728_part_i(bus20040728_part),
			.const_01_p(const_01),
			.const_02_p(const_02),
			.const_03(const_03), // Constant Wire, wire port const_wire to constant
			.const_05(const_05), // Constant Wire, wire port const_wire to constant
			.inst_duo_1(mix_const_22),
			.int_time_p(mix_const_13),
			.integer_p(mix_const_7),
			.one_p(mix_const_6),
			.real_p(mix_const_8),
			.real_time_p(mix_const_14),
			.reale_p(mix_const_12),
			.std_u_11_vport(mix_const_24),
			.std_u_logic_bin_p(mix_const_27),
			.std_u_logic_binv_p(mix_const_29),
			.std_u_logic_hexerr_p(mix_const_31),
			.std_u_logic_octv_p(mix_const_28),
			.std_u_logic_port_02(mix_const_26),
			.std_u_logic_quadv_p(mix_const_30),
			.std_u_logic_vport(mix_const_23),
			.std_u_logic_vport_ext(mix_const_25),
			.std_ulogic_vector_p(mix_const_18),
			.string_p(mix_const_15),
			.under_p(mix_const_9),
			.vector_duo_1(mix_const_21),
			.vector_duo_2(mix_const_21),
			.vhdl_basehex_p(mix_const_10),
			.vhdlbase2_p(mix_const_11),
			.zero_p(mix_const_5)
		);
		// End of Generated Instance Port Map for inst_aa

		// Generated Instance Port Map for inst_ab
		inst_ab_e inst_ab(
			.bus20040728_altop_o1(bus20040728_altop[7:4]),
			.bus20040728_o1(bus20040728_part[1:0]),
			.bus20040728_o2(bus20040728_part[3]),
			.bus20040728_top_o1(bus20040728_top[7:4]),
			.const_04(const_04), // Constant Wire, wire port const_wire to constant
			.const_08_p(mix_const_1), // Set to 0
			.const_09_p(mix_const_2), // Set to 1
			.const_10_2({ mix_const_4[0], mix_const_3[0], mix_const_4[0], mix_const_3[0] }), // Set two pins to 1 // Set two pins to 0 // __I_COMBINE_SPLICES
			.inst_duo_2(mix_const_22)
		);
		// End of Generated Instance Port Map for inst_ab

		// Generated Instance Port Map for inst_ac
		inst_ac_e inst_ac(
			.bus20040728_oc(bus20040728_part[7])
		);
		// End of Generated Instance Port Map for inst_ac

		// Generated Instance Port Map for inst_ad
		inst_ad_e inst_ad(

		);
		// End of Generated Instance Port Map for inst_ad

		// Generated Instance Port Map for inst_ae
		inst_ae_e inst_ae(
			.bus20040728_altop_i(bus20040728_altop),
			.p_mix_bus20040728_top_7_4_gi(bus20040728_top[7:4])
		);
		// End of Generated Instance Port Map for inst_ae



endmodule
//
// End of Generated Module rtl of inst_a_e
//
//
//!End of Module/s
// --------------------------------------------------------------
