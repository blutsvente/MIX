// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of rs_fe1
//
// Generated
//  by:  lutscher
//  on:  Wed Nov  9 13:50:17 2005
//  cmd: /home/lutscher/work/MIX/mix_0.pl -strip -nodelta ../../reg_shell.sxc
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: lutscher $
// $Id: rs_fe1.v,v 1.5 2005/12/14 13:53:53 lutscher Exp $
// $Date: 2005/12/14 13:53:53 $
// $Log: rs_fe1.v,v $
// Revision 1.5  2005/12/14 13:53:53  lutscher
// updated
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.69 2005/11/09 08:31:06 lutscher Exp 
//
// Generator: mix_0.pl Revision: 1.39 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of rs_fe1
//

	// No `defines in this module


module rs_fe1
//
// Generated module rs_fe1_i
//
		(
		input	wire		clk_f20,
		input	wire		res_f20_n_i,
		input	wire		mreset_n_i,
		input	wire	[2:0]	mcmd_i,
		input	wire	[13:0]	maddr_i,
		input	wire	[31:0]	mdata_i,
		input	wire		mrespaccept_i,
		output	wire		scmdaccept_o,
		output	wire	[1:0]	sresp_o,
		output	wire	[31:0]	sdata_o,
		input	wire		clk_a,
		input	wire		res_a_n_i,
		input	wire		test_i,
		input	wire		Cvbsdetect_set_p_i,
		input	wire		ycdetect_i,
		input	wire		usr_r_test_i,
		input	wire		usr_r_test_trans_done_p_i,
		output	wire		usr_r_test_rd_p_o,
		input	wire	[7:0]	sha_r_test_i,
		output	wire	[4:0]	mvstart_o,
		output	wire	[5:0]	mvstop_o,
		output	wire	[3:0]	usr_rw_test_o,
		input	wire	[3:0]	usr_rw_test_i,
		input	wire		usr_rw_test_trans_done_p_i,
		output	wire		usr_rw_test_rd_p_o,
		output	wire		usr_rw_test_wr_p_o,
		output	wire	[31:0]	sha_rw2_o,
		output	wire	[15:0]	wd_16_test_o,
		output	wire	[7:0]	wd_16_test2_o,
		input	wire		upd_rw_en_i,
		input	wire		upd_rw_force_i,
		input	wire		upd_rw_i,
		input	wire		upd_r_en_i,
		input	wire		upd_r_force_i,
		input	wire		upd_r_i,
		output	wire	[3:0]	dgatel_o,
		output	wire	[4:0]	dgates_o,
		output	wire	[2:0]	dummy_fe_o,
		output	wire	[3:0]	usr_w_test_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	wire		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_o,
		output	wire	[3:0]	sha_w_test_o,
		input	wire	[2:0]	r_test_i,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i
		);
	// Module parameters:
		parameter cgtransp = 0;
		parameter P_TOCNT_WIDTH = 10;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire	[13:0]	addr; 
			wire	[31:0]	rd_data; 
			wire	[63:0]	rd_data_vec; 
			wire		rd_err; 
			wire	[1:0]	rd_err_vec; 
			wire		rd_wr; 
			wire		trans_done; 
			wire	[1:0]	trans_done_vec; 
			wire		trans_start; 
			wire	[31:0]	wr_data; 
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments




	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for rs_cfg_fe1_clk_a_i
		rs_cfg_fe1_clk_a	#(
			.cgtransp(cgtransp), // __W_ILLEGAL_PARAM
			.sync(1)
		) rs_cfg_fe1_clk_a_i (	// Config register module for clock domain 'clk_a'

			.addr_i(addr),
			.clk_a(clk_a),
			.dgatel_o(dgatel_o),
			.dgates_o(dgates_o),
			.dummy_fe_o(dummy_fe_o),
			.r_test_i(r_test_i),
			.rd_data_o(rd_data_vec[31:0]),
			.rd_err_o(rd_err_vec[0]),
			.rd_wr_i(rd_wr),
			.res_a_n_i(res_a_n_i),
			.sha_w_test_o(sha_w_test_o),
			.test_i(test_i),
			.trans_done_o(trans_done_vec[0]),
			.trans_start(trans_start),
			.upd_w_en_i(upd_w_en_i),
			.upd_w_force_i(upd_w_force_i),
			.upd_w_i(upd_w_i),
			.usr_w_test_o(usr_w_test_o),
			.usr_w_test_trans_done_p_i(usr_w_test_trans_done_p_i),
			.usr_w_test_wr_p_o(usr_w_test_wr_p_o),
			.w_test_o(w_test_o),
			.wr_data_i(wr_data)
		);
		// End of Generated Instance Port Map for rs_cfg_fe1_clk_a_i

		// Generated Instance Port Map for rs_cfg_fe1_i
		rs_cfg_fe1	#(
			.cgtransp(cgtransp), // __W_ILLEGAL_PARAM
			.sync(0)
		) rs_cfg_fe1_i (	// Config register module

			.Cvbsdetect_set_p_i(Cvbsdetect_set_p_i),
			.addr_i(addr),
			.clk_f20(clk_f20),
			.mvstart_o(mvstart_o),
			.mvstop_o(mvstop_o),
			.rd_data_o(rd_data_vec[63:32]),
			.rd_err_o(rd_err_vec[1]),
			.rd_wr_i(rd_wr),
			.res_f20_n_i(res_f20_n_i),
			.sha_r_test_i(sha_r_test_i),
			.sha_rw2_o(sha_rw2_o),
			.test_i(test_i),
			.trans_done_o(trans_done_vec[1]),
			.trans_start(trans_start),
			.upd_r_en_i(upd_r_en_i),
			.upd_r_force_i(upd_r_force_i),
			.upd_r_i(upd_r_i),
			.upd_rw_en_i(upd_rw_en_i),
			.upd_rw_force_i(upd_rw_force_i),
			.upd_rw_i(upd_rw_i),
			.usr_r_test_i(usr_r_test_i),
			.usr_r_test_rd_p_o(usr_r_test_rd_p_o),
			.usr_r_test_trans_done_p_i(usr_r_test_trans_done_p_i),
			.usr_rw_test_i(usr_rw_test_i),
			.usr_rw_test_o(usr_rw_test_o),
			.usr_rw_test_rd_p_o(usr_rw_test_rd_p_o),
			.usr_rw_test_trans_done_p_i(usr_rw_test_trans_done_p_i),
			.usr_rw_test_wr_p_o(usr_rw_test_wr_p_o),
			.wd_16_test2_o(wd_16_test2_o),
			.wd_16_test_o(wd_16_test_o),
			.wr_data_i(wr_data),
			.ycdetect_i(ycdetect_i)
		);
		// End of Generated Instance Port Map for rs_cfg_fe1_i

		// Generated Instance Port Map for u0_ocp_target_i
		ocp_target	#(
			.P_AWIDTH(14),
			.P_DWIDTH(32),
			.P_TOCNT_WIDTH(P_TOCNT_WIDTH), // __W_ILLEGAL_PARAM
			.sync(0)
		) u0_ocp_target_i (	// OCP target module

			.addr_o(addr),
			.clk_i(clk_f20),
			.maddr_i(maddr_i),
			.mcmd_i(mcmd_i),
			.mdata_i(mdata_i),
			.mreset_n_i(mreset_n_i),
			.mrespaccept_i(mrespaccept_i),
			.rd_data_i(rd_data),
			.rd_err_i(rd_err),
			.rd_wr_o(rd_wr),
			.reset_n_i(res_f20_n_i),
			.scmdaccept_o(scmdaccept_o),
			.sdata_o(sdata_o),
			.sresp_o(sresp_o),
			.trans_done_i(trans_done),
			.trans_start_o(trans_start),
			.wr_data_o(wr_data)
		);
		// End of Generated Instance Port Map for u0_ocp_target_i

		// Generated Instance Port Map for u1_rs_mcda_i
		rs_mcda	#(
			.N_DOMAINS(2),
			.N_SYNCDOM(1),
			.P_DWIDTH(32)
		) u1_rs_mcda_i (	// Multi-clock-domain Adapter

			.clk_ocp(clk_f20),
			.mreset_n_i(mreset_n_i),
			.rd_data_o(rd_data),
			.rd_data_vec_i(rd_data_vec),
			.rd_err_o(rd_err),
			.rd_err_vec_i(rd_err_vec),
			.rst_ocp_n_i(res_f20_n_i),
			.trans_done_o(trans_done),
			.trans_done_vec_i(trans_done_vec),
			.trans_start_i(trans_start)
		);
		// End of Generated Instance Port Map for u1_rs_mcda_i



endmodule
//
// End of Generated Module rtl of rs_fe1
//
//
//!End of Module/s
// --------------------------------------------------------------
