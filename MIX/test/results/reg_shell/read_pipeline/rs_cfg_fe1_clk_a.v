// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of rs_cfg_fe1_clk_a
//
// Generated
//  by:  lutscher
//  on:  Wed Dec 14 14:51:40 2005
//  cmd: /home/lutscher/work/MIX/mix_0.pl ../../reg_shell.sxc
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: lutscher $
// $Id: rs_cfg_fe1_clk_a.v,v 1.1 2005/12/14 13:56:02 lutscher Exp $
// $Date: 2005/12/14 13:56:02 $
// $Log: rs_cfg_fe1_clk_a.v,v $
// Revision 1.1  2005/12/14 13:56:02  lutscher
// *** empty log message ***
//
//
// Based on Mix Verilog Architecture Template built into RCSfile: MixWriter.pm,v 
// Id: MixWriter.pm,v 1.72 2005/11/30 14:01:21 wig Exp 
//
// Generator: mix_0.pl Revision: 1.43 , wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------


`timescale 1ns/10ps

//
//
// Start of Generated Module rtl of rs_cfg_fe1_clk_a
//

	// No user `defines in this module
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
		output	wire	[3:0]	dgatel_par_o,
		output	wire	[4:0]	dgates_par_o,
		output	wire	[2:0]	dummy_fe_par_o,
		output	wire	[3:0]	usr_w_test_par_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	reg		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_par_o,
		output	reg	[3:0]	sha_w_test_par_o,
		input	wire	[2:0]	r_test_par_i,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i
		);
	// Module parameters:
		parameter sync = 1;
		parameter cgtransp = 0;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire		int_upd_w_p; 
			wire		tie0_1; 
			wire		u2_sync_generic_i_trans_start_p; 
			wire		u3_sync_rst_i_int_rst_n; 
			wire		u4_ccgc_iwr_clk; 
			wire		u4_ccgc_iwr_clk_en; 
			wire		u5_ccgc_ishdw_clk; 
			wire		u5_ccgc_ishdw_clk_en; 
			wire		u6_ccgc_ird_clk; 
			wire		u6_ccgc_ird_clk_en; 
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign tie0_1 = `tie0_1_c;


        /*
          Generator information:
          used package Micronas::Reg is version 1.16  
          this module is version 1.20  
        */

        /*
          local definitions
        */
        `define REG_00_OFFS 0 // reg_0x0
        `define REG_04_OFFS 1 // reg_0x4
        `define REG_08_OFFS 2 // reg_0x8
        `define REG_0C_OFFS 3 // reg_0xC
        `define REG_10_OFFS 4 // reg_0x10
        `define REG_14_OFFS 5 // reg_0x14
        `define REG_18_OFFS 6 // reg_0x18
        `define REG_1C_OFFS 7 // reg_0x1C
        `define REG_20_OFFS 8 // reg_0x20
        `define REG_28_OFFS 10 // reg_0x28

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
        reg  [31:0] REG_20;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_28;
        reg  int_upd_w;

        wire wr_p;
        wire rd_p;
        reg  int_trans_done;
        wire [3:0] iaddr;
        wire addr_overshoot;
        wire trans_done_p;

        reg  rd_done_p;
        reg  wr_done_p;
        reg  fwd_txn;
        wire [0:0] fwd_decode_vec;
        wire [0:0] fwd_done_vec;
        reg  [31:0] mux_rd_data;
        reg  mux_rd_err;
        reg  [31:0] mux_rd_data_0_0;
        reg  mux_rd_err_0_0;
        reg  [31:0] mux_rd_data_0_2;
        reg  mux_rd_err_0_2;

        /*
          local wire and output assignments
        */
        assign dummy_fe_par_o   = REG_00[11:9];
        assign dgatel_par_o     = REG_00[3:0];
        assign dgates_par_o     = REG_00[8:4];
        assign w_test_par_o     = REG_20[19:16];
        assign sha_w_test_shdw               = REG_20[23:20];
        assign usr_w_test_par_o = wr_data_i[3:0];

        // clip address to decoded range
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];

        /*
          clock enable signals
        */
        assign u4_ccgc_iwr_clk_en = wr_p; // write-clock enable
        assign u5_ccgc_ishdw_clk_en = int_upd_w; // shadow-clock enable
        assign u6_ccgc_ird_clk_en = rd_p; // read-clock enable

        // write txn start pulse
        assign wr_p = ~rd_wr_i & u2_sync_generic_i_trans_start_p;

        // read txn start pulse
        assign rd_p = rd_wr_i & u2_sync_generic_i_trans_start_p;

        /*
          generate txn done signals
        */
        assign fwd_done_vec = {usr_w_test_trans_done_p_i}; // ack for forwarded txns
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
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
        always @(posedge u4_ccgc_iwr_clk or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_20[19:16] <= 'h0;
                REG_20[23:20] <= 'h0;
            end
            else begin
                case (iaddr)
                    `REG_00_OFFS: begin
                        REG_00[11:9] <= wr_data_i[11:9];
                        REG_00[3:0]  <= wr_data_i[3:0];
                        REG_00[8:4]  <= wr_data_i[8:4];
                    end
                    `REG_20_OFFS: begin
                        REG_20[19:16] <= wr_data_i[19:16];
                        REG_20[23:20] <= wr_data_i[23:20];
                    end
                endcase
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                fwd_txn                           <= 0;
                usr_w_test_wr_p_o <= 0;
            end
            else begin
                usr_w_test_wr_p_o <= 0;
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn                           <= |fwd_decode_vec; // set flag for forwarded txn
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
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n)
                int_upd_w <= 1;
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        // shadow process
        always @(posedge u5_ccgc_ishdw_clk) begin
            if (int_upd_w) begin
                sha_w_test_par_o <= sha_w_test_shdw;
            end
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;

        always @(iaddr or mux_rd_data_0_0 or mux_rd_err_0_0 or mux_rd_data_0_2 or mux_rd_err_0_2) begin // stage 1
            case (iaddr[3:2])
                0: begin
                    mux_rd_data <= mux_rd_data_0_0;
                    mux_rd_err  <= mux_rd_err_0_0;
                end
                2: begin
                    mux_rd_data <= mux_rd_data_0_2;
                    mux_rd_err  <= mux_rd_err_0_2;
                end
                default: begin
                    mux_rd_data <= 0;
                    mux_rd_err <= 1;
                end
            endcase
        end

        always @(posedge u6_ccgc_ird_clk or negedge u3_sync_rst_i_int_rst_n) begin // stage 0
            if (~u3_sync_rst_i_int_rst_n) begin
                mux_rd_data_0_0 <= 0;
                mux_rd_err_0_0 <= 0;
            end
            else begin
                mux_rd_err_0_0 <= 0;
                case (iaddr[1:0])
                    0: begin
                        mux_rd_data_0_0[3:0] <= REG_00[3:0];
                        mux_rd_data_0_0[8:4] <= REG_00[8:4];
                        mux_rd_data_0_0[11:9] <= REG_00[11:9];
                    end
                    default: begin
                        mux_rd_data_0_0 <= 0;
                        mux_rd_err_0_0 <= 1;
                    end
                endcase
            end
        end

        always @(posedge u6_ccgc_ird_clk or negedge u3_sync_rst_i_int_rst_n) begin // stage 0
            if (~u3_sync_rst_i_int_rst_n) begin
                mux_rd_data_0_2 <= 0;
                mux_rd_err_0_2 <= 0;
            end
            else begin
                mux_rd_err_0_2 <= 0;
                case (iaddr[1:0])
                    2: begin
                        mux_rd_data_0_2[2:0] <= r_test_par_i;
                    end
                    default: begin
                        mux_rd_data_0_2 <= 0;
                        mux_rd_err_0_2 <= 1;
                    end
                endcase
            end
        end

        /*
          checking code
        */
        `ifdef ASSERT_ON

        property p_pos_pulse_check (sig); // check for positive pulse
             @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
             sig |=> ~sig;
        endproperty
        assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i));

        p_fwd_done_expected: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> fwd_txn
        );

        p_fwd_done_onehot: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> onehot(fwd_done_vec)
        );

        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           fwd_done_vec != 0 |-> fwd_txn
        );

        function onehot (input [0:0] vec); // not built-in to SV yet
          integer i,j;
          begin
             j = 0;
        	 for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0;
        	 onehot = (j==1) ? 1 : 0;
          end
        endfunction
          
          
        `endif

	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for u14_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u14_sync_generic_i (	// Synchronizer for update-signal upd_w

			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(int_upd_w_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_w_i)
		);
		// End of Generated Instance Port Map for u14_sync_generic_i

		// Generated Instance Port Map for u2_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u2_sync_generic_i (	// Synchronizer for trans_done signal

			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(u2_sync_generic_i_trans_start_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(trans_start)
		);
		// End of Generated Instance Port Map for u2_sync_generic_i

		// Generated Instance Port Map for u3_sync_rst_i
		sync_rst	#(
			.act(0),
			.sync(1)
		) u3_sync_rst_i (	// Reset synchronizer

			.clk_r(clk_a),
			.rst_i(res_a_n_i),
			.rst_o(u3_sync_rst_i_int_rst_n)
		);
		// End of Generated Instance Port Map for u3_sync_rst_i

		// Generated Instance Port Map for u4_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u4_ccgc_i (	// Clock-gating cell for write-clock

			.clk_i(clk_a),
			.clk_o(u4_ccgc_iwr_clk),
			.enable_i(u4_ccgc_iwr_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u4_ccgc_i

		// Generated Instance Port Map for u5_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u5_ccgc_i (	// Clock-gating cell for shadow-clock

			.clk_i(clk_a),
			.clk_o(u5_ccgc_ishdw_clk),
			.enable_i(u5_ccgc_ishdw_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u5_ccgc_i

		// Generated Instance Port Map for u6_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u6_ccgc_i (	// Clock-gating cell for read-clock

			.clk_i(clk_a),
			.clk_o(u6_ccgc_ird_clk),
			.enable_i(u6_ccgc_ird_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u6_ccgc_i



endmodule
//
// End of Generated Module rtl of rs_cfg_fe1_clk_a
//
//
//!End of Module/s
// --------------------------------------------------------------
