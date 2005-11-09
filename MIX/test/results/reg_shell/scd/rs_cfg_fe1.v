// -------------------------------------------------------------
//
// Generated Architecture Declaration for rtl of rs_cfg_fe1
//
// Generated
//  by:  lutscher
//  on:  Wed Nov  9 13:50:13 2005
//  cmd: /home/lutscher/work/MIX/mix_0.pl -strip -nodelta ../../reg_shell.sxc
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// $Author: lutscher $
// $Id: rs_cfg_fe1.v,v 1.5 2005/12/14 13:53:51 lutscher Exp $
// $Date: 2005/12/14 13:53:51 $
// $Log: rs_cfg_fe1.v,v $
// Revision 1.5  2005/12/14 13:53:51  lutscher
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
// Start of Generated Module rtl of rs_cfg_fe1
//

	// No `defines in this module
`define tie0_1_c 1'b0 


module rs_cfg_fe1
//
// Generated module rs_cfg_fe1_i
//
		(
		input	wire		clk_f20,
		input	wire		res_f20_n_i,
		input	wire		test_i,
		input	wire	[13:0]	addr_i,
		input	wire		trans_start,
		input	wire	[31:0]	wr_data_i,
		input	wire		rd_wr_i,
		output	wire		rd_err_o,
		output	wire		trans_done_o,
		output	wire	[31:0]	rd_data_o,
		output	wire	[3:0]	dgatel_o,
		output	wire	[4:0]	dgates_o,
		output	wire	[2:0]	dummy_fe_o,
		input	wire		Cvbsdetect_set_p_i,
		input	wire		ycdetect_i,
		input	wire		usr_r_test_i,
		input	wire		usr_r_test_trans_done_p_i,
		output	reg		usr_r_test_rd_p_o,
		input	wire	[7:0]	sha_r_test_i,
		output	wire	[4:0]	mvstart_o,
		output	reg	[5:0]	mvstop_o,
		output	wire	[3:0]	usr_rw_test_o,
		input	wire	[3:0]	usr_rw_test_i,
		input	wire		usr_rw_test_trans_done_p_i,
		output	reg		usr_rw_test_rd_p_o,
		output	reg		usr_rw_test_wr_p_o,
		output	reg	[31:0]	sha_rw2_o,
		output	wire	[15:0]	wd_16_test_o,
		output	wire	[7:0]	wd_16_test2_o,
		output	wire	[3:0]	usr_w_test_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	reg		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_o,
		output	reg	[3:0]	sha_w_test_o,
		input	wire	[2:0]	r_test_i,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i,
		input	wire		upd_rw_en_i,
		input	wire		upd_rw_force_i,
		input	wire		upd_rw_i,
		input	wire		upd_r_en_i,
		input	wire		upd_r_force_i,
		input	wire		upd_r_i
		);
	// Module parameters:
		parameter sync = 0;
		parameter cgtransp = 0;
// End of generated module header


	// Internal signals

		//
		// Generated Signal List
		//
			wire		int_rst_n; 
			wire		int_upd_r_p; 
			wire		int_upd_rw_p; 
			wire		int_upd_w_p; 
			wire		shdw_clk; 
			wire		shdw_clk_en; 
			wire		tie0_1; 
			wire		trans_start_p; 
			wire		wr_clk; 
			wire		wr_clk_en; 
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
        reg  [7:0] sha_r_test_shdw;
        reg  [31:0] REG_08;
        wire [5:0] mvstop_shdw;
        reg  [31:0] REG_0C;
        reg  [31:0] REG_10;
        wire [31:0] sha_rw2_shdw;
        reg  [31:0] REG_14;
        reg  [31:0] REG_18;
        reg  [31:0] REG_1C;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_20;
        reg  int_upd_w;
        reg  int_upd_rw;
        reg  int_upd_r;

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
        wire [2:0] fwd_decode_vec;
        wire [2:0] fwd_done_vec;

        /*
          local wire and output assignments
        */
        assign dummy_fe_o      = REG_00[11:9];
        assign dgatel_o        = REG_00[3:0];
        assign dgates_o        = REG_00[8:4];
        assign Cvbsdetect_o    = REG_04[0];
        assign mvstop_shdw     = REG_08[10:5];
        assign mvstart_o       = REG_08[4:0];
        assign sha_rw2_shdw    = REG_10;
        assign wd_16_test_o    = REG_14[15:0];
        assign wd_16_test2_o   = REG_18[7:0];
        assign w_test_o        = REG_1C[19:16];
        assign sha_w_test_shdw = REG_1C[23:20];
        assign usr_rw_test_o   = wr_data_i[14:11];
        assign usr_w_test_o    = wr_data_i[3:0];

        // clip address to decoded range
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];

        /*
          clock enable signals
        */
        assign wr_clk_en = wr_p; // write-clock enable
        assign shdw_clk_en = int_upd_w | int_upd_rw | int_upd_r; // shadow-clock enable

        // write txn start pulse
        assign wr_p = ~rd_wr_i & trans_start_p;

        // read txn start pulse
        assign rd_p = rd_wr_i & trans_start_p;

        /*
          generate txn done signals
        */
        assign fwd_done_vec = {usr_r_test_trans_done_p_i, usr_w_test_trans_done_p_i, usr_rw_test_trans_done_p_i}; // ack for forwarded txns
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);

        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n) begin
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
        always @(posedge wr_clk or negedge int_rst_n) begin
            if (~int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_08[10:5]  <= 'hd;
                REG_08[4:0]   <= 'h7;
                REG_10        <= 'h0;
                REG_14[15:0]  <= 'hd;
                REG_18[7:0]   <= 'hff;
                REG_1C[19:16] <= 'h0;
                REG_1C[23:20] <= 'h0;
            end
            else begin
                case (iaddr)
                    `REG_00_OFFS: begin
                        REG_00[11:9] <= wr_data_i[11:9];
                        REG_00[3:0]  <= wr_data_i[3:0];
                        REG_00[8:4]  <= wr_data_i[8:4];
                    end
                    `REG_08_OFFS: begin
                        REG_08[10:5] <= wr_data_i[10:5];
                        REG_08[4:0]  <= wr_data_i[4:0];
                    end
                    `REG_10_OFFS: begin
                        REG_10 <= wr_data_i;
                    end
                    `REG_14_OFFS: begin
                        REG_14[15:0] <= wr_data_i[15:0];
                    end
                    `REG_18_OFFS: begin
                        REG_18[7:0] <= wr_data_i[7:0];
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
          write process for status registers
        */
        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n) begin
                REG_04[0] <= 'h0;
            end
            else begin
                if (Cvbsdetect_set_p_i)
                    REG_04[0] <= 1;
                else if (wr_p && iaddr == `REG_04_OFFS)
                    REG_04[0] <= REG_04[0] & ~wr_data_i[0];
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = {(iaddr == `REG_04_OFFS) & rd_wr_i, (iaddr == `REG_0C_OFFS), (iaddr == `REG_1C_OFFS) & ~rd_wr_i};

        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n) begin
                fwd_txn            <= 0;
                usr_r_test_rd_p_o  <= 0;
                usr_rw_test_rd_p_o <= 0;
                usr_rw_test_wr_p_o <= 0;
                usr_w_test_wr_p_o  <= 0;
            end
            else begin
                usr_r_test_rd_p_o  <= 0;
                usr_rw_test_rd_p_o <= 0;
                usr_rw_test_wr_p_o <= 0;
                usr_w_test_wr_p_o  <= 0;
                if (trans_start_p) begin
                    fwd_txn            <= |fwd_decode_vec; // set flag for forwarded txn
                    usr_r_test_rd_p_o  <= fwd_decode_vec[2] & rd_wr_i;
                    usr_rw_test_rd_p_o <= fwd_decode_vec[1] & rd_wr_i;
                    usr_rw_test_wr_p_o <= fwd_decode_vec[1] & ~rd_wr_i;
                    usr_w_test_wr_p_o  <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p)
                    fwd_txn <= 0; // reset flag for forwarded transaction
                end
            end

        /*
          shadowing for update signal 'upd_w'
        */
        // generate internal update signal
        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n)
                int_upd_w <= 1;
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        // shadow process
        always @(posedge shdw_clk) begin
            if (int_upd_w) begin
                sha_w_test_o <= sha_w_test_shdw;
            end
        end

        /*
          shadowing for update signal 'upd_rw'
        */
        // generate internal update signal
        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n)
                int_upd_rw <= 1;
            else
                int_upd_rw <= (int_upd_rw_p & upd_rw_en_i) | upd_rw_force_i;
        end
        // shadow process
        always @(posedge shdw_clk) begin
            if (int_upd_rw) begin
                sha_rw2_o <= sha_rw2_shdw;
                mvstop_o  <= mvstop_shdw;
            end
        end

        /*
          shadowing for update signal 'upd_r'
        */
        // generate internal update signal
        always @(posedge clk_f20 or negedge int_rst_n) begin
            if (~int_rst_n)
                int_upd_r <= 1;
            else
                int_upd_r <= (int_upd_r_p & upd_r_en_i) | upd_r_force_i;
        end
        // shadow process
        always @(posedge shdw_clk) begin
            if (int_upd_r) begin
                sha_r_test_shdw <= sha_r_test_i;
            end
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(REG_00 or REG_04 or REG_08 or REG_14 or iaddr or mvstop_shdw or r_test_i or sha_r_test_shdw or sha_rw2_shdw or usr_r_test_i or usr_rw_test_i or ycdetect_i) begin
            mux_rd_err  <= 0;
            mux_rd_data <= 0;
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0] <= REG_00[3:0];
                    mux_rd_data[8:4] <= REG_00[8:4];
                    mux_rd_data[11:9] <= REG_00[11:9];
                end
                `REG_04_OFFS : begin
                    mux_rd_data[0] <= REG_04[0];
                    mux_rd_data[1] <= ycdetect_i;
                    mux_rd_data[2] <= usr_r_test_i;
                    mux_rd_data[10:3] <= sha_r_test_shdw;
                end
                `REG_08_OFFS : begin
                    mux_rd_data[4:0] <= REG_08[4:0];
                    mux_rd_data[10:5] <= mvstop_shdw;
                end
                `REG_0C_OFFS : begin
                    mux_rd_data[14:11] <= usr_rw_test_i;
                end
                `REG_10_OFFS : begin
                    mux_rd_data <= sha_rw2_shdw;
                end
                `REG_14_OFFS : begin
                    mux_rd_data[15:0] <= REG_14[15:0];
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
        `ifdef ASSERT_ON

        p_fwd_done_expected: assert property
        (
           @(posedge clk_f20) disable iff (~int_rst_n)
           usr_r_test_trans_done_p_i || usr_w_test_trans_done_p_i || usr_rw_test_trans_done_p_i |-> fwd_txn
        );

        p_fwd_done_onehot: assert property
        (
           @(posedge clk_f20) disable iff (~int_rst_n)
           usr_r_test_trans_done_p_i || usr_w_test_trans_done_p_i || usr_rw_test_trans_done_p_i |-> onehot(fwd_done_vec)
        );

        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_f20) disable iff (~int_rst_n)
           fwd_done_vec != 0 |-> fwd_txn
        );

        function onehot (input [2:0] vec); // not built-in to SV yet
          integer i,j;
          begin
             j = 0;
        	 for (i=0; i<3; i=i+1) j = j + vec[i] ? 1 : 0;
        	 onehot = (j==1) ? 1 : 0;
          end
        endfunction
          
          
        `endif

	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for u1_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(0)
		) u1_sync_generic_i (	// Synchronizer for trans_done signal

			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(trans_start_p),
			.rst_r(res_f20_n_i),
			.rst_s(tie0_1),
			.snd_i(trans_start)
		);
		// End of Generated Instance Port Map for u1_sync_generic_i

		// Generated Instance Port Map for u2_sync_rst_i
		sync_rst	#(
			.act(0),
			.sync(0)
		) u2_sync_rst_i (	// Reset synchronizer

			.clk_r(clk_f20),
			.rst_i(res_f20_n_i),
			.rst_o(int_rst_n)
		);
		// End of Generated Instance Port Map for u2_sync_rst_i

		// Generated Instance Port Map for u3_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u3_ccgc_i (	// Clock-gating cell for write-clock

			.clk_i(clk_f20),
			.clk_o(wr_clk),
			.enable_i(wr_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u3_ccgc_i

		// Generated Instance Port Map for u4_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u4_ccgc_i (	// Clock-gating cell for shadow-clock

			.clk_i(clk_f20),
			.clk_o(shdw_clk),
			.enable_i(shdw_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u4_ccgc_i

		// Generated Instance Port Map for u5_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u5_sync_generic_i (	// Synchronizer for update-signal upd_w

			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(int_upd_w_p),
			.rst_r(res_f20_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_w_i)
		);
		// End of Generated Instance Port Map for u5_sync_generic_i

		// Generated Instance Port Map for u6_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u6_sync_generic_i (	// Synchronizer for update-signal upd_rw

			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(int_upd_rw_p),
			.rst_r(res_f20_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_rw_i)
		);
		// End of Generated Instance Port Map for u6_sync_generic_i

		// Generated Instance Port Map for u7_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u7_sync_generic_i (	// Synchronizer for update-signal upd_r

			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(int_upd_r_p),
			.rst_r(res_f20_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_r_i)
		);
		// End of Generated Instance Port Map for u7_sync_generic_i



endmodule
//
// End of Generated Module rtl of rs_cfg_fe1
//
//
//!End of Module/s
// --------------------------------------------------------------
