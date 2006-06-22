-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_ea_e
--
-- Generated
--  by:  wig
--  on:  Thu Apr 27 05:43:23 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ea_e-rtl-a.vhd,v 1.4 2006/06/22 07:20:00 wig Exp $
-- $Date: 2006/06/22 07:20:00 $
-- $Log: inst_ea_e-rtl-a.vhd,v $
-- Revision 1.4  2006/06/22 07:20:00  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.83 2006/04/19 07:32:08 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_ea_e
--
architecture rtl of inst_ea_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component inst_eaa_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_eaa_e
			c_addr_i	: in	std_ulogic_vector(12 downto 0);
			c_bus_i	: in	std_ulogic_vector(31 downto 0);	-- CBUSinterface
			mbist_clut_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			mbist_fifo_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			unsplice_a1_no3	: in	std_ulogic_vector(127 downto 0);	-- leaves 3 unconnected
			unsplice_a2_all128	: in	std_ulogic_vector(127 downto 0);	-- full 128 bit port
			unsplice_a3_up100	: in	std_ulogic_vector(100 downto 0);	-- connect 100 bits from 0
			unsplice_a4_mid100	: in	std_ulogic_vector(97 downto 0);	-- connect mid 100 bits
			unsplice_a5_midp100	: in	std_ulogic_vector(99 downto 2);	-- connect mid 100 bits
			unsplice_bad_a	: in	std_ulogic_vector(1 downto 0);
			unsplice_bad_b	: in	std_ulogic_vector(3 downto 0);	-- # conflict
			video_p_0	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widemerge_a1_p	: in	std_ulogic_vector(31 downto 0);
			widesig_p	: in	std_ulogic_vector(30 downto 0);
			widesig_p_0	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_1	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_10	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_11	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_12	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_13	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_14	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_15	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_16	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_17	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_18	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_19	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_2	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_20	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_21	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_22	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_23	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_24	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_25	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_26	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_27	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_28	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_29	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_3	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_30	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_31	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_4	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_5	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_6	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_7	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_8	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			widesig_p_9	: in	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity inst_eaa_e
		);
	end component;
	-- ---------

	component inst_eab_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_eab_e
		-- End of Generated Generics for Entity inst_eab_e
		port (
		-- Generated Port for Entity inst_eab_e
			c_add	: in	std_ulogic_vector(12 downto 0);
			c_bus_in	: in	std_ulogic_vector(31 downto 0);	-- CBUSinterface
			v_select	: in	std_ulogic_vector(5 downto 0);	-- VPUinterface
			video_p_1	: in	std_ulogic
		-- End of Generated Port for Entity inst_eab_e
		);
	end component;
	-- ---------

	component inst_eac_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_eac_e
		-- End of Generated Generics for Entity inst_eac_e
		port (
		-- Generated Port for Entity inst_eac_e
			adp_bist_fail	: out	std_ulogic;
			c_addr	: in	std_ulogic_vector(12 downto 0);
			c_bus_in	: in	std_ulogic_vector(31 downto 0);	-- CBUSinterface
			cp_lcmd	: in	std_ulogic_vector(6 downto 0);	-- GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_2	: in	std_ulogic_vector(6 downto 0);	-- Second way to wire to zero / GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_p	: in	std_ulogic_vector(6 downto 0);	-- Signal name != port name
			cpu_bist_fail	: out	std_ulogic;
			cvi_sbist_fail0	: in	std_ulogic;
			cvi_sbist_fail1	: in	std_ulogic;
			ema_bist_fail	: out	std_ulogic;
			ga_sbist_fail0	: in	std_ulogic;
			ga_sbist_fail1	: in	std_ulogic;
			ifu_bist_fail	: out	std_ulogic;
			mcu_bist_fail	: out	std_ulogic;
			pdu_bist_fail0	: out	std_ulogic;
			pdu_bist_fail1	: out	std_ulogic;
			tsd_bist_fail	: out	std_ulogic;
			video_p_2	: in	std_ulogic
		-- End of Generated Port for Entity inst_eac_e
		);
	end component;
	-- ---------

	component inst_ead_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ead_e
		-- End of Generated Generics for Entity inst_ead_e
		port (
		-- Generated Port for Entity inst_ead_e
			video_p_3	: in	std_ulogic
		-- End of Generated Port for Entity inst_ead_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
	signal	mix_logic0_2	: std_ulogic; 
	signal	mix_logic0_bus_0	: std_ulogic_vector(5 downto 0); 
	signal	mix_logic0_bus_1	: std_ulogic_vector(5 downto 0); 
	signal	c_addr	: std_ulogic_vector(12 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	c_bus_in	: std_ulogic_vector(31 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	cp_lcmd	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	cp_lcmd_2	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			constant cp_lcmd_2_tolow_c : std_ulogic_vector(5 downto 0) := ( others => '0' ); 
	signal	cp_lcmd_2_tolow	: std_ulogic_vector(5 downto 0); 
	signal	cp_lcmd_3	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	tmi_sbist_fail	: std_ulogic_vector(12 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_a1_no3	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_a2_all128	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_a3_up100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_a4_mid100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_a5_midp100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_bad_a	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	unsplice_bad_b	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	v_select	: std_ulogic_vector(5 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	widemerge_a1	: std_ulogic_vector(31 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig	: std_ulogic_vector(31 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_0	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_1	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_10	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_11	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_19	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_20	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_21	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_22	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_23	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_24	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_25	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_26	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_27	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_28	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_29	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_3	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_30	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_4	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_5	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_6	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_7	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_8	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	signal	widesig_r_9	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
	--
	-- End of Generated Signal List
	--




begin


	--
	-- Generated Concurrent Statements
	--

	--
	-- Generated Signal Assignments
	--
		mix_logic0_2 <= '0';
		mix_logic0_bus_0 <= ( others => '0' );
		mix_logic0_bus_1 <= ( others => '0' );
	c_addr	<=	p_mix_c_addr_12_0_gi;  -- __I_I_BUS_PORT
	c_bus_in	<=	p_mix_c_bus_in_31_0_gi;  -- __I_I_BUS_PORT
	cp_lcmd(6)	<=	p_mix_cp_lcmd_6_6_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	cp_lcmd_2(6)	<=	p_mix_cp_lcmd_2_6_6_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			cp_lcmd_2_tolow <= cp_lcmd_2_tolow_c;
	cp_lcmd_3(6)	<=	p_mix_cp_lcmd_3_6_6_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	tmi_sbist_fail(11 downto 10)	<=	p_mix_tmi_sbist_fail_11_10_gi(1 downto 0);  -- __I_I_SLICE_PORT
	p_mix_tmi_sbist_fail_9_0_go(9 downto 0)	<=	tmi_sbist_fail(9 downto 0);  -- __I_O_SLICE_PORT
	unsplice_a1_no3(125 downto 0)	<=	p_mix_unsplice_a1_no3_125_0_gi(125 downto 0);  -- __I_I_SLICE_PORT
	unsplice_a1_no3(127)	<=	p_mix_unsplice_a1_no3_127_127_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	unsplice_a2_all128	<=	p_mix_unsplice_a2_all128_127_0_gi;  -- __I_I_BUS_PORT
	unsplice_a3_up100(100 downto 0)	<=	p_mix_unsplice_a3_up100_100_0_gi(100 downto 0);  -- __I_I_SLICE_PORT
	unsplice_a4_mid100(99 downto 2)	<=	p_mix_unsplice_a4_mid100_99_2_gi(97 downto 0);  -- __I_I_SLICE_PORT
	unsplice_a5_midp100(99 downto 2)	<=	p_mix_unsplice_a5_midp100_99_2_gi(97 downto 0);  -- __I_I_SLICE_PORT
	unsplice_bad_a(1)	<=	p_mix_unsplice_bad_a_1_1_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	unsplice_bad_b(1 downto 0)	<=	p_mix_unsplice_bad_b_1_0_gi(1 downto 0);  -- __I_I_SLICE_PORT
	v_select(5)	<=	p_mix_v_select_5_5_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	v_select(2)	<=	p_mix_v_select_2_2_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
	widemerge_a1	<=	p_mix_widemerge_a1_31_0_gi;  -- __I_I_BUS_PORT
	widesig	<=	p_mix_widesig_31_0_gi;  -- __I_I_BUS_PORT
	widesig_r_0	<=	p_mix_widesig_r_0_gi;  -- __I_I_BIT_PORT
	widesig_r_1	<=	p_mix_widesig_r_1_gi;  -- __I_I_BIT_PORT
	widesig_r_10	<=	p_mix_widesig_r_10_gi;  -- __I_I_BIT_PORT
	widesig_r_11	<=	p_mix_widesig_r_11_gi;  -- __I_I_BIT_PORT
	widesig_r_12	<=	p_mix_widesig_r_12_gi;  -- __I_I_BIT_PORT
	widesig_r_13	<=	p_mix_widesig_r_13_gi;  -- __I_I_BIT_PORT
	widesig_r_14	<=	p_mix_widesig_r_14_gi;  -- __I_I_BIT_PORT
	widesig_r_15	<=	p_mix_widesig_r_15_gi;  -- __I_I_BIT_PORT
	widesig_r_16	<=	p_mix_widesig_r_16_gi;  -- __I_I_BIT_PORT
	widesig_r_17	<=	p_mix_widesig_r_17_gi;  -- __I_I_BIT_PORT
	widesig_r_18	<=	p_mix_widesig_r_18_gi;  -- __I_I_BIT_PORT
	widesig_r_19	<=	p_mix_widesig_r_19_gi;  -- __I_I_BIT_PORT
	widesig_r_2	<=	p_mix_widesig_r_2_gi;  -- __I_I_BIT_PORT
	widesig_r_20	<=	p_mix_widesig_r_20_gi;  -- __I_I_BIT_PORT
	widesig_r_21	<=	p_mix_widesig_r_21_gi;  -- __I_I_BIT_PORT
	widesig_r_22	<=	p_mix_widesig_r_22_gi;  -- __I_I_BIT_PORT
	widesig_r_23	<=	p_mix_widesig_r_23_gi;  -- __I_I_BIT_PORT
	widesig_r_24	<=	p_mix_widesig_r_24_gi;  -- __I_I_BIT_PORT
	widesig_r_25	<=	p_mix_widesig_r_25_gi;  -- __I_I_BIT_PORT
	widesig_r_26	<=	p_mix_widesig_r_26_gi;  -- __I_I_BIT_PORT
	widesig_r_27	<=	p_mix_widesig_r_27_gi;  -- __I_I_BIT_PORT
	widesig_r_28	<=	p_mix_widesig_r_28_gi;  -- __I_I_BIT_PORT
	widesig_r_29	<=	p_mix_widesig_r_29_gi;  -- __I_I_BIT_PORT
	widesig_r_3	<=	p_mix_widesig_r_3_gi;  -- __I_I_BIT_PORT
	widesig_r_30	<=	p_mix_widesig_r_30_gi;  -- __I_I_BIT_PORT
	widesig_r_4	<=	p_mix_widesig_r_4_gi;  -- __I_I_BIT_PORT
	widesig_r_5	<=	p_mix_widesig_r_5_gi;  -- __I_I_BIT_PORT
	widesig_r_6	<=	p_mix_widesig_r_6_gi;  -- __I_I_BIT_PORT
	widesig_r_7	<=	p_mix_widesig_r_7_gi;  -- __I_I_BIT_PORT
	widesig_r_8	<=	p_mix_widesig_r_8_gi;  -- __I_I_BIT_PORT
	widesig_r_9	<=	p_mix_widesig_r_9_gi;  -- __I_I_BIT_PORT


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_eaa
		inst_eaa: inst_eaa_e
		port map (

			-- __E_PRINTCONN unsplice_bad_a => unsplice_bad_a
			c_addr_i => c_addr,
			c_bus_i => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			mbist_clut_fail_o => tmi_sbist_fail(8),
			mbist_fifo_fail_o => tmi_sbist_fail(9),
			unsplice_a1_no3(1 downto 0) => unsplice_a1_no3(1 downto 0),	-- leaves 3 unconnected
			unsplice_a1_no3(127 downto 4) => unsplice_a1_no3(125 downto 2),	-- leaves 3 unconnected
			unsplice_a1_no3(2) => unsplice_a1_no3(127),	-- leaves 3 unconnected
			unsplice_a2_all128 => unsplice_a2_all128,	-- full 128 bit port
			unsplice_a3_up100 => unsplice_a3_up100(100 downto 0),	-- connect 100 bits from 0
			unsplice_a4_mid100 => unsplice_a4_mid100(99 downto 2),	-- connect mid 100 bits
			unsplice_a5_midp100 => unsplice_a5_midp100(99 downto 2),	-- connect mid 100 bits
			unsplice_bad_b(1 downto 0) => unsplice_bad_b(1 downto 0),	-- # conflict
			unsplice_bad_b(3 downto 2) => unsplice_bad_b(1 downto 0),	-- # conflict
			video_p_0 => video_i(0),
			widemerge_a1_p => widemerge_a1,
			widesig_p(0) => widesig_r_0, -- __I_BIT_TO_BUSPORT
			widesig_p(1) => widesig_r_1, -- __I_BIT_TO_BUSPORT
			widesig_p(10) => widesig_r_10, -- __I_BIT_TO_BUSPORT
			widesig_p(11) => widesig_r_11, -- __I_BIT_TO_BUSPORT
			widesig_p(12) => widesig_r_12, -- __I_BIT_TO_BUSPORT
			widesig_p(13) => widesig_r_13, -- __I_BIT_TO_BUSPORT
			widesig_p(14) => widesig_r_14, -- __I_BIT_TO_BUSPORT
			widesig_p(15) => widesig_r_15, -- __I_BIT_TO_BUSPORT
			widesig_p(16) => widesig_r_16, -- __I_BIT_TO_BUSPORT
			widesig_p(17) => widesig_r_17, -- __I_BIT_TO_BUSPORT
			widesig_p(18) => widesig_r_18, -- __I_BIT_TO_BUSPORT
			widesig_p(19) => widesig_r_19, -- __I_BIT_TO_BUSPORT
			widesig_p(2) => widesig_r_2, -- __I_BIT_TO_BUSPORT
			widesig_p(20) => widesig_r_20, -- __I_BIT_TO_BUSPORT
			widesig_p(21) => widesig_r_21, -- __I_BIT_TO_BUSPORT
			widesig_p(22) => widesig_r_22, -- __I_BIT_TO_BUSPORT
			widesig_p(23) => widesig_r_23, -- __I_BIT_TO_BUSPORT
			widesig_p(24) => widesig_r_24, -- __I_BIT_TO_BUSPORT
			widesig_p(25) => widesig_r_25, -- __I_BIT_TO_BUSPORT
			widesig_p(26) => widesig_r_26, -- __I_BIT_TO_BUSPORT
			widesig_p(27) => widesig_r_27, -- __I_BIT_TO_BUSPORT
			widesig_p(28) => widesig_r_28, -- __I_BIT_TO_BUSPORT
			widesig_p(29) => widesig_r_29, -- __I_BIT_TO_BUSPORT
			widesig_p(3) => widesig_r_3, -- __I_BIT_TO_BUSPORT
			widesig_p(30) => widesig_r_30, -- __I_BIT_TO_BUSPORT
			widesig_p(4) => widesig_r_4, -- __I_BIT_TO_BUSPORT
			widesig_p(5) => widesig_r_5, -- __I_BIT_TO_BUSPORT
			widesig_p(6) => widesig_r_6, -- __I_BIT_TO_BUSPORT
			widesig_p(7) => widesig_r_7, -- __I_BIT_TO_BUSPORT
			widesig_p(8) => widesig_r_8, -- __I_BIT_TO_BUSPORT
			widesig_p(9) => widesig_r_9, -- __I_BIT_TO_BUSPORT
			widesig_p_0 => widesig(0),
			widesig_p_1 => widesig(1),
			widesig_p_10 => widesig(10),
			widesig_p_11 => widesig(11),
			widesig_p_12 => widesig(12),
			widesig_p_13 => widesig(13),
			widesig_p_14 => widesig(14),
			widesig_p_15 => widesig(15),
			widesig_p_16 => widesig(16),
			widesig_p_17 => widesig(17),
			widesig_p_18 => widesig(18),
			widesig_p_19 => widesig(19),
			widesig_p_2 => widesig(2),
			widesig_p_20 => widesig(20),
			widesig_p_21 => widesig(21),
			widesig_p_22 => widesig(22),
			widesig_p_23 => widesig(23),
			widesig_p_24 => widesig(24),
			widesig_p_25 => widesig(25),
			widesig_p_26 => widesig(26),
			widesig_p_27 => widesig(27),
			widesig_p_28 => widesig(28),
			widesig_p_29 => widesig(29),
			widesig_p_3 => widesig(3),
			widesig_p_30 => widesig(30),
			widesig_p_31 => widesig(31),
			widesig_p_4 => widesig(4),
			widesig_p_5 => widesig(5),
			widesig_p_6 => widesig(6),
			widesig_p_7 => widesig(7),
			widesig_p_8 => widesig(8),
			widesig_p_9 => widesig(9)
		);
		-- End of Generated Instance Port Map for inst_eaa

		-- Generated Instance Port Map for inst_eab
		inst_eab: inst_eab_e
		port map (
			c_add => c_addr,
			c_bus_in => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			v_select(0) => mix_logic0_2, -- __I_BIT_TO_BUSPORT
			v_select(1) => mix_logic0_2, -- __I_BIT_TO_BUSPORT
			v_select(2) => v_select(2),	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
			v_select(3) => mix_logic0_2, -- __I_BIT_TO_BUSPORT
			v_select(4) => mix_logic0_2, -- __I_BIT_TO_BUSPORT
			v_select(5) => v_select(5),	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
			video_p_1 => video_i(1)
		);
		-- End of Generated Instance Port Map for inst_eab

		-- Generated Instance Port Map for inst_eac
		inst_eac: inst_eac_e
		port map (

			adp_bist_fail => tmi_sbist_fail(0),
			c_addr => c_addr,
			c_bus_in => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			cp_lcmd(5 downto 0)  => mix_logic0_bus_0, -- __W_PORT
			cp_lcmd(6) => cp_lcmd(6),	-- GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_2(5 downto 0)  => cp_lcmd_2_tolow, -- __W_PORT
			cp_lcmd_2(6) => cp_lcmd_2(6),	-- Second way to wire to zero / GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_p(5 downto 0)  => mix_logic0_bus_1, -- __W_PORT
			cp_lcmd_p(6) => cp_lcmd_3(6),	-- Signal name != port name
			cpu_bist_fail => tmi_sbist_fail(1),
			cvi_sbist_fail0 => tmi_sbist_fail(10),
			cvi_sbist_fail1 => tmi_sbist_fail(11),
			ema_bist_fail => tmi_sbist_fail(7),
			ga_sbist_fail0 => tmi_sbist_fail(8),
			ga_sbist_fail1 => tmi_sbist_fail(9),
			ifu_bist_fail => tmi_sbist_fail(6),
			mcu_bist_fail => tmi_sbist_fail(2),
			pdu_bist_fail0 => tmi_sbist_fail(3),
			pdu_bist_fail1 => tmi_sbist_fail(4),
			tsd_bist_fail => tmi_sbist_fail(5),
			video_p_2 => video_i(2)
		);
		-- End of Generated Instance Port Map for inst_eac

		-- Generated Instance Port Map for inst_ead
		inst_ead: inst_ead_e
		port map (
			video_p_3 => video_i(3)
		);
		-- End of Generated Instance Port Map for inst_ead



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
