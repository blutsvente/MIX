// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of rs_cfg_fe1_clk_a
//
// Generated
//  by:  lutscher
//  on:  Thu Nov  3 14:25:15 2005
//  cmd: /home/lutscher/work/MIX/mix_0.pl -nodelta ../../reg_shell.sxc
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: lutscher $
// $Id: rs_cfg_fe1_clk_a.v,v 1.2 2005/11/03 13:29:32 lutscher Exp $
// $Date: 2005/11/03 13:29:32 $
// $Log: rs_cfg_fe1_clk_a.v,v $
// Revision 1.2  2005/11/03 13:29:32  lutscher
// updated
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.67 2005/11/02 14:28:45 wig Exp 
//
// Generator: mix_0.pl Revision: 1.39 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns / 1ps

//
//
// Start of Generated Module rtl of rs_cfg_fe1_clk_a
//

	// No `defines in this module
`define tie0_1_c 1'b0 


module rs_cfg_fe1_clk_a
//
// Generated module rs_cfg_fe1_clk_a_i
//
		(
		input	wire		clk_a,
		input	wire		res_a_n_i,
		input	wire		test_i,
		input	wire	[13:0]	addr_i,
		input	wire		trans_start,
		input	wire	[31:0]	wr_data_i,
		input	wire		rd_wr_i,
		output	wire	[31:0]	rd_data_o,
		output	wire		rd_err_o,
		output	wire		trans_done_o,
		output	wire	[3:0]	dgatel_o,
		output	wire	[4:0]	dgates_o,
		output	wire	[2:0]	dummy_fe_o,
		output	wire	[3:0]	usr_w_test_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	reg		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_o,
		output	reg	[3:0]	sha_w_test_o,
		input	wire	[2:0]	r_test_i,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i
		);
	// Module parameters:
		parameter sync = 1;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire		int_upd_w_p; 
			wire		tie0_1; 
			wire		u0_i_trans_start_p; 
			wire		u1_i_int_rst_n; 
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign tie0_1 = `tie0_1_c;



        /*
          local definitions
        */
        `define REG_00_OFFS 0 // FE_YCDET_M_0x0
        `define REG_04_OFFS 1 // FE_YCDET_M_0x4
        `define REG_08_OFFS 2 // FE_MVDET_M_0x8
        `define REG_0C_OFFS 3 // FE_MVDET_M_0xC
        `define REG_10_OFFS 4 // FE_MVDET_M_0x10
        `define REG_14_OFFS 5 // FE_MVDET_M_0x14
        `define REG_18_OFFS 6 // FE_MVDET_M_0x18
        `define REG_1C_OFFS 7 // FE_MVDET_M_0x1C
        `define REG_20_OFFS 8 // FE_MVDET_M_0x20

        /*  
          local wire or register declarations
        */  
        reg  [31:0] REG_00;
        reg  [31:0] REG_04;
        reg  [31:0] REG_08;
        reg  [31:0] REG_0C;
        reg  [31:0] REG_10;
        reg  [31:0] REG_14;
        reg  [31:0] REG_18;
        reg  [31:0] REG_1C;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_20;
        reg  int_upd_w;

        wire wr_p;
        wire rd_p;
        reg  [31:0] mux_rd_data;
        reg  int_trans_done;
        reg  mux_rd_err;
        wire [3:0] iaddr;
        wire addr_overshoot;
        wire trans_done_p;

        reg  rd_done_p;
        reg  wr_done_p;
        reg  fwd_txn;
        wire [0:0] fwd_decode_vec;
        wire [0:0] fwd_done_vec;

        /*
          local wire and output assignments
        */
        assign dgatel_o        = REG_00[3:0];
        assign dgates_o        = REG_00[8:4];
        assign dummy_fe_o      = REG_00[11:9];
        assign sha_w_test_shdw = REG_1C[23:20];
        assign usr_w_test_o    = REG_1C[3:0];
        assign w_test_o        = REG_1C[19:16];

        // clip address to decoded range
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];

        // write txn start pulse
        assign wr_p = ~rd_wr_i & u0_i_trans_start_p;

        // read txn start pulse
        assign rd_p = rd_wr_i & u0_i_trans_start_p;

        /*
          generate txn done signals
        */
        assign fwd_done_vec = {usr_w_test_trans_done_p_i}; // ack for forwarded txns
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);

        always @(posedge clk_a or negedge u1_i_int_rst_n) begin
            if (~u1_i_int_rst_n) begin
                int_trans_done <= 0;
                wr_done_p <= 0;
                rd_done_p <= 0;
            end
            else begin
                wr_done_p <= wr_p;
                rd_done_p <= rd_p;
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done;
            end
        end
        assign trans_done_o = int_trans_done;

        /*
          write process
        */
        always @(posedge clk_a or negedge u1_i_int_rst_n) begin
            if (~u1_i_int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_1C[19:16] <= 'h0;
                REG_1C[23:20] <= 'h0;
            end
            else begin
                if (wr_p)
                    case (iaddr)
                        `REG_00_OFFS: begin
                            REG_00[11:9] <= wr_data_i[11:9];
                            REG_00[3:0]  <= wr_data_i[3:0];
                            REG_00[8:4]  <= wr_data_i[8:4];
                        end
                        `REG_1C_OFFS: begin
                            REG_1C[19:16] <= wr_data_i[19:16];
                            REG_1C[23:20] <= wr_data_i[23:20];
                        end
                        default: ;
                    endcase
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = {(iaddr == `REG_1C_OFFS) & ~rd_wr_i};

        always @(posedge clk_a or negedge u1_i_int_rst_n) begin
            if (~u1_i_int_rst_n) begin
                fwd_txn           <= 0;
                usr_w_test_wr_p_o <= 0;
            end
            else begin
                usr_w_test_wr_p_o <= 0;
                if (u0_i_trans_start_p) begin
                    fwd_txn           <= |fwd_decode_vec; // set flag for forwarded txn
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p)
                    fwd_txn <= 0; // reset flag for forwarded transaction
                end
            end

        /*
          shadowing for update signal 'upd_w'
        */
        // generate internal update signal
        always @(posedge clk_a or negedge u1_i_int_rst_n) begin
            if (~u1_i_int_rst_n)
                int_upd_w <= 1;
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        // shadow process
        always @(posedge clk_a) begin
            if (int_upd_w) begin
                sha_w_test_o <= sha_w_test_shdw;
            end
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(REG_00 or iaddr or r_test_i) begin
            mux_rd_err  <= 0;
            mux_rd_data <= 0;
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0] <= REG_00[3:0];
                    mux_rd_data[8:4] <= REG_00[8:4];
                    mux_rd_data[11:9] <= REG_00[11:9];
                end
                `REG_20_OFFS : begin
                    mux_rd_data[2:0] <= r_test_i;
                end
                default: begin
                    mux_rd_err <= 1; // no decode
                end
            endcase
        end

        /*
          checking code
        */

	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for u0_i
		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u0_i (	// Synchronizer for trans_done signal

			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(u0_i_trans_start_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(trans_start)
		);
		// End of Generated Instance Port Map for u0_i

		// Generated Instance Port Map for u1_i
		sync_rst	#(
			.act(0),
			.sync(1)
		) u1_i (	// Reset synchronizer

			.clk_r(clk_a),
			.rst_i(res_a_n_i),
			.rst_o(u1_i_int_rst_n)
		);
		// End of Generated Instance Port Map for u1_i

		// Generated Instance Port Map for u6_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u6_i (	// Synchronizer for update-signal upd_w

			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(int_upd_w_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_w_i)
		);
		// End of Generated Instance Port Map for u6_i



endmodule
//
// End of Generated Module rtl of rs_cfg_fe1_clk_a
//
//
//!End of Module/s
// --------------------------------------------------------------
