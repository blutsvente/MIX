-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_e_e
--
-- Generated
--  by:  wig
--  on:  Thu Feb 16 18:07:35 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_e_e-rtl-a.vhd,v 1.1 2006/04/10 15:42:09 wig Exp $
-- $Date: 2006/04/10 15:42:09 $
-- $Log: inst_e_e-rtl-a.vhd,v $
-- Revision 1.1  2006/04/10 15:42:09  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.76 2006/01/19 08:49:31 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_e_e
--
architecture rtl of inst_e_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_ea_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ea_e
			p_mix_tmi_sbist_fail_9_0_go	: out	std_ulogic_vector(9 downto 0);
			video_i	: in	std_ulogic_vector(3 downto 0);
			p_mix_cp_lcmd_6_6_gi	: in	std_ulogic;
			p_mix_cp_lcmd_3_6_6_gi	: in	std_ulogic;
			p_mix_cp_lcmd_2_6_6_gi	: in	std_ulogic;
			p_mix_v_select_2_2_gi	: in	std_ulogic;
			p_mix_v_select_5_5_gi	: in	std_ulogic;
			p_mix_c_addr_12_0_gi	: in	std_ulogic_vector(12 downto 0);
			p_mix_c_bus_in_31_0_gi	: in	std_ulogic_vector(31 downto 0);
			p_mix_tmi_sbist_fail_11_10_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_widesig_31_0_gi	: in	std_ulogic_vector(31 downto 0);
			p_mix_widesig_r_0_gi	: in	std_ulogic;
			p_mix_widesig_r_1_gi	: in	std_ulogic;
			p_mix_widesig_r_2_gi	: in	std_ulogic;
			p_mix_widesig_r_3_gi	: in	std_ulogic;
			p_mix_widesig_r_4_gi	: in	std_ulogic;
			p_mix_widesig_r_5_gi	: in	std_ulogic;
			p_mix_widesig_r_6_gi	: in	std_ulogic;
			p_mix_widesig_r_7_gi	: in	std_ulogic;
			p_mix_widesig_r_8_gi	: in	std_ulogic;
			p_mix_widesig_r_9_gi	: in	std_ulogic;
			p_mix_widesig_r_10_gi	: in	std_ulogic;
			p_mix_widesig_r_11_gi	: in	std_ulogic;
			p_mix_widesig_r_12_gi	: in	std_ulogic;
			p_mix_widesig_r_13_gi	: in	std_ulogic;
			p_mix_widesig_r_14_gi	: in	std_ulogic;
			p_mix_widesig_r_15_gi	: in	std_ulogic;
			p_mix_widesig_r_16_gi	: in	std_ulogic;
			p_mix_widesig_r_17_gi	: in	std_ulogic;
			p_mix_widesig_r_18_gi	: in	std_ulogic;
			p_mix_widesig_r_19_gi	: in	std_ulogic;
			p_mix_widesig_r_20_gi	: in	std_ulogic;
			p_mix_widesig_r_21_gi	: in	std_ulogic;
			p_mix_widesig_r_22_gi	: in	std_ulogic;
			p_mix_widesig_r_23_gi	: in	std_ulogic;
			p_mix_widesig_r_24_gi	: in	std_ulogic;
			p_mix_widesig_r_25_gi	: in	std_ulogic;
			p_mix_widesig_r_26_gi	: in	std_ulogic;
			p_mix_widesig_r_27_gi	: in	std_ulogic;
			p_mix_widesig_r_28_gi	: in	std_ulogic;
			p_mix_widesig_r_29_gi	: in	std_ulogic;
			p_mix_widesig_r_30_gi	: in	std_ulogic;
			p_mix_unsplice_a1_no3_125_0_gi	: in	std_ulogic_vector(125 downto 0);
			p_mix_unsplice_a1_no3_127_127_gi	: in	std_ulogic;
			p_mix_unsplice_a2_all128_127_0_gi	: in	std_ulogic_vector(127 downto 0);
			p_mix_unsplice_a3_up100_100_0_gi	: in	std_ulogic_vector(100 downto 0);
			p_mix_unsplice_a4_mid100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_a5_midp100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_bad_a_1_1_gi	: in	std_ulogic;
			p_mix_unsplice_bad_b_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_widemerge_a1_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_ea_e
		);
	end component;
	-- ---------

	component inst_eb_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_eb_e
			p_mix_tmi_sbist_fail_12_10_go	: out	std_ulogic_vector(2 downto 0);
			p_mix_c_addr_12_0_gi	: in	std_ulogic_vector(12 downto 0);
			p_mix_c_bus_in_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_eb_e
		);
	end component;
	-- ---------

	component inst_ec_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ec_e
			p_mix_v_select_2_2_gi	: in	std_ulogic;
			p_mix_v_select_5_5_gi	: in	std_ulogic;
			p_mix_c_addr_12_0_gi	: in	std_ulogic_vector(12 downto 0);
			p_mix_c_bus_in_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_ec_e
		);
	end component;
	-- ---------

	component inst_ed_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ed_e
			p_mix_c_addr_12_0_gi	: in	std_ulogic_vector(12 downto 0);
			p_mix_c_bus_in_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_ed_e
		);
	end component;
	-- ---------

	component inst_ee_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ee_e
		-- End of Generated Generics for Entity inst_ee_e
		port (
		-- Generated Port for Entity inst_ee_e
			tmi_sbist_fail	: in	std_ulogic_vector(12 downto 0)
		-- End of Generated Port for Entity inst_ee_e
		);
	end component;
	-- ---------

	component inst_ef_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ef_e
		-- End of Generated Generics for Entity inst_ef_e
		port (
		-- Generated Port for Entity inst_ef_e
			cp_lcmd	: out	std_ulogic_vector(6 downto 0);	-- GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_p	: out	std_ulogic_vector(6 downto 0);	-- Signal name != port name
			cp_lcmd_2	: out	std_ulogic_vector(6 downto 0);	-- Second way to wire to zero / GuestBusLBC(memorymappedI/O)Interface
			c_addr	: out	std_ulogic_vector(12 downto 0);
			c_bus_in	: out	std_ulogic_vector(31 downto 0)	-- CBUSinterface
		-- End of Generated Port for Entity inst_ef_e
		);
	end component;
	-- ---------

	component inst_eg_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_eg_e
		-- End of Generated Generics for Entity inst_eg_e
		port (
		-- Generated Port for Entity inst_eg_e
			c_addr	: in	std_ulogic_vector(12 downto 0);
			c_bus_in	: in	std_ulogic_vector(31 downto 0)	-- cpui/finputs
		-- End of Generated Port for Entity inst_eg_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	c_addr	: std_ulogic_vector(12 downto 0); 
			signal	c_bus_in	: std_ulogic_vector(31 downto 0); 
			signal	cp_lcmd	: std_ulogic_vector(6 downto 0); 
			signal	cp_lcmd_2	: std_ulogic_vector(6 downto 0); 
			signal	cp_lcmd_3	: std_ulogic_vector(6 downto 0); 
			signal	tmi_sbist_fail	: std_ulogic_vector(12 downto 0); 
			signal	unsplice_a1_no3	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_a2_all128	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_a3_up100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_a4_mid100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_a5_midp100	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_bad_a	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	unsplice_bad_b	: std_ulogic_vector(127 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	v_select	: std_ulogic_vector(5 downto 0); 
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

	-- Generated Signal Assignments
			unsplice_a1_no3(125 downto 0) <= p_mix_unsplice_a1_no3_125_0_gi(125 downto 0);  -- __I_I_SLICE_PORT
			unsplice_a1_no3(127) <= p_mix_unsplice_a1_no3_127_127_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			unsplice_a2_all128 <= p_mix_unsplice_a2_all128_127_0_gi;  -- __I_I_BUS_PORT
			unsplice_a3_up100(100 downto 0) <= p_mix_unsplice_a3_up100_100_0_gi(100 downto 0);  -- __I_I_SLICE_PORT
			unsplice_a4_mid100(99 downto 2) <= p_mix_unsplice_a4_mid100_99_2_gi(97 downto 0);  -- __I_I_SLICE_PORT
			unsplice_a5_midp100(99 downto 2) <= p_mix_unsplice_a5_midp100_99_2_gi(97 downto 0);  -- __I_I_SLICE_PORT
			unsplice_bad_a(1) <= p_mix_unsplice_bad_a_1_1_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			unsplice_bad_b(1 downto 0) <= p_mix_unsplice_bad_b_1_0_gi(1 downto 0);  -- __I_I_SLICE_PORT
			widemerge_a1 <= p_mix_widemerge_a1_31_0_gi;  -- __I_I_BUS_PORT
			widesig <= widesig_i;  -- __I_I_BUS_PORT
			widesig_r_0 <= p_mix_widesig_r_0_gi;  -- __I_I_BIT_PORT
			widesig_r_1 <= p_mix_widesig_r_1_gi;  -- __I_I_BIT_PORT
			widesig_r_10 <= p_mix_widesig_r_10_gi;  -- __I_I_BIT_PORT
			widesig_r_11 <= p_mix_widesig_r_11_gi;  -- __I_I_BIT_PORT
			widesig_r_12 <= p_mix_widesig_r_12_gi;  -- __I_I_BIT_PORT
			widesig_r_13 <= p_mix_widesig_r_13_gi;  -- __I_I_BIT_PORT
			widesig_r_14 <= p_mix_widesig_r_14_gi;  -- __I_I_BIT_PORT
			widesig_r_15 <= p_mix_widesig_r_15_gi;  -- __I_I_BIT_PORT
			widesig_r_16 <= p_mix_widesig_r_16_gi;  -- __I_I_BIT_PORT
			widesig_r_17 <= p_mix_widesig_r_17_gi;  -- __I_I_BIT_PORT
			widesig_r_18 <= p_mix_widesig_r_18_gi;  -- __I_I_BIT_PORT
			widesig_r_19 <= p_mix_widesig_r_19_gi;  -- __I_I_BIT_PORT
			widesig_r_2 <= p_mix_widesig_r_2_gi;  -- __I_I_BIT_PORT
			widesig_r_20 <= p_mix_widesig_r_20_gi;  -- __I_I_BIT_PORT
			widesig_r_21 <= p_mix_widesig_r_21_gi;  -- __I_I_BIT_PORT
			widesig_r_22 <= p_mix_widesig_r_22_gi;  -- __I_I_BIT_PORT
			widesig_r_23 <= p_mix_widesig_r_23_gi;  -- __I_I_BIT_PORT
			widesig_r_24 <= p_mix_widesig_r_24_gi;  -- __I_I_BIT_PORT
			widesig_r_25 <= p_mix_widesig_r_25_gi;  -- __I_I_BIT_PORT
			widesig_r_26 <= p_mix_widesig_r_26_gi;  -- __I_I_BIT_PORT
			widesig_r_27 <= p_mix_widesig_r_27_gi;  -- __I_I_BIT_PORT
			widesig_r_28 <= p_mix_widesig_r_28_gi;  -- __I_I_BIT_PORT
			widesig_r_29 <= p_mix_widesig_r_29_gi;  -- __I_I_BIT_PORT
			widesig_r_3 <= p_mix_widesig_r_3_gi;  -- __I_I_BIT_PORT
			widesig_r_30 <= p_mix_widesig_r_30_gi;  -- __I_I_BIT_PORT
			widesig_r_4 <= p_mix_widesig_r_4_gi;  -- __I_I_BIT_PORT
			widesig_r_5 <= p_mix_widesig_r_5_gi;  -- __I_I_BIT_PORT
			widesig_r_6 <= p_mix_widesig_r_6_gi;  -- __I_I_BIT_PORT
			widesig_r_7 <= p_mix_widesig_r_7_gi;  -- __I_I_BIT_PORT
			widesig_r_8 <= p_mix_widesig_r_8_gi;  -- __I_I_BIT_PORT
			widesig_r_9 <= p_mix_widesig_r_9_gi;  -- __I_I_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_ea
		inst_ea: inst_ea_e
		port map (

			p_mix_c_addr_12_0_gi => c_addr,
			p_mix_c_bus_in_31_0_gi => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			p_mix_cp_lcmd_2_6_6_gi => cp_lcmd_2(6),	-- Second way to wire to zero / GuestBusLBC(memorymappedI/O)Interface
			p_mix_cp_lcmd_3_6_6_gi => cp_lcmd_3(6),	-- Signal name != port name
			p_mix_cp_lcmd_6_6_gi => cp_lcmd(6),	-- GuestBusLBC(memorymappedI/O)Interface
			p_mix_tmi_sbist_fail_11_10_gi => tmi_sbist_fail(11 downto 10),
			p_mix_tmi_sbist_fail_9_0_go => tmi_sbist_fail(9 downto 0),
			p_mix_unsplice_a1_no3_125_0_gi => unsplice_a1_no3(125 downto 0),	-- leaves 3 unconnected
			p_mix_unsplice_a1_no3_127_127_gi => unsplice_a1_no3(127),	-- leaves 3 unconnected
			p_mix_unsplice_a2_all128_127_0_gi => unsplice_a2_all128,	-- full 128 bit port
			p_mix_unsplice_a3_up100_100_0_gi => unsplice_a3_up100(100 downto 0),	-- connect 100 bits from 0
			p_mix_unsplice_a4_mid100_99_2_gi => unsplice_a4_mid100(99 downto 2),	-- connect mid 100 bits
			p_mix_unsplice_a5_midp100_99_2_gi => unsplice_a5_midp100(99 downto 2),	-- connect mid 100 bits
			p_mix_unsplice_bad_a_1_1_gi => unsplice_bad_a(1),
			p_mix_unsplice_bad_b_1_0_gi => unsplice_bad_b(1 downto 0),	-- # conflict
			p_mix_v_select_2_2_gi => v_select(2),	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
			p_mix_v_select_5_5_gi => v_select(5),	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
			p_mix_widemerge_a1_31_0_gi => widemerge_a1,
			p_mix_widesig_31_0_gi => widesig,
			p_mix_widesig_r_0_gi => widesig_r_0,
			p_mix_widesig_r_10_gi => widesig_r_10,
			p_mix_widesig_r_11_gi => widesig_r_11,
			p_mix_widesig_r_12_gi => widesig_r_12,
			p_mix_widesig_r_13_gi => widesig_r_13,
			p_mix_widesig_r_14_gi => widesig_r_14,
			p_mix_widesig_r_15_gi => widesig_r_15,
			p_mix_widesig_r_16_gi => widesig_r_16,
			p_mix_widesig_r_17_gi => widesig_r_17,
			p_mix_widesig_r_18_gi => widesig_r_18,
			p_mix_widesig_r_19_gi => widesig_r_19,
			p_mix_widesig_r_1_gi => widesig_r_1,
			p_mix_widesig_r_20_gi => widesig_r_20,
			p_mix_widesig_r_21_gi => widesig_r_21,
			p_mix_widesig_r_22_gi => widesig_r_22,
			p_mix_widesig_r_23_gi => widesig_r_23,
			p_mix_widesig_r_24_gi => widesig_r_24,
			p_mix_widesig_r_25_gi => widesig_r_25,
			p_mix_widesig_r_26_gi => widesig_r_26,
			p_mix_widesig_r_27_gi => widesig_r_27,
			p_mix_widesig_r_28_gi => widesig_r_28,
			p_mix_widesig_r_29_gi => widesig_r_29,
			p_mix_widesig_r_2_gi => widesig_r_2,
			p_mix_widesig_r_30_gi => widesig_r_30,
			p_mix_widesig_r_3_gi => widesig_r_3,
			p_mix_widesig_r_4_gi => widesig_r_4,
			p_mix_widesig_r_5_gi => widesig_r_5,
			p_mix_widesig_r_6_gi => widesig_r_6,
			p_mix_widesig_r_7_gi => widesig_r_7,
			p_mix_widesig_r_8_gi => widesig_r_8,
			p_mix_widesig_r_9_gi => widesig_r_9,
			video_i => video_i
		);
		-- End of Generated Instance Port Map for inst_ea

		-- Generated Instance Port Map for inst_eb
		inst_eb: inst_eb_e
		port map (

			p_mix_c_addr_12_0_gi => c_addr,
			p_mix_c_bus_in_31_0_gi => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			p_mix_tmi_sbist_fail_12_10_go => tmi_sbist_fail(12 downto 10)
		);
		-- End of Generated Instance Port Map for inst_eb

		-- Generated Instance Port Map for inst_ec
		inst_ec: inst_ec_e
		port map (
			p_mix_c_addr_12_0_gi => c_addr,
			p_mix_c_bus_in_31_0_gi => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			p_mix_v_select_2_2_gi => v_select(2),	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
			p_mix_v_select_5_5_gi => v_select(5)	-- RequestBusinterface:RequestBus#6(VPU)VPUinterface
		);
		-- End of Generated Instance Port Map for inst_ec

		-- Generated Instance Port Map for inst_ed
		inst_ed: inst_ed_e
		port map (
			p_mix_c_addr_12_0_gi => c_addr,
			p_mix_c_bus_in_31_0_gi => c_bus_in	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
		);
		-- End of Generated Instance Port Map for inst_ed

		-- Generated Instance Port Map for inst_ee
		inst_ee: inst_ee_e
		port map (
			tmi_sbist_fail => tmi_sbist_fail
		);
		-- End of Generated Instance Port Map for inst_ee

		-- Generated Instance Port Map for inst_ef
		inst_ef: inst_ef_e
		port map (
			c_addr => c_addr,
			c_bus_in => c_bus_in,	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
			cp_lcmd => cp_lcmd,	-- GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_2 => cp_lcmd_2,	-- Second way to wire to zero / GuestBusLBC(memorymappedI/O)Interface
			cp_lcmd_p => cp_lcmd_3	-- Signal name != port name
		);
		-- End of Generated Instance Port Map for inst_ef

		-- Generated Instance Port Map for inst_eg
		inst_eg: inst_eg_e
		port map (
			c_addr => c_addr,
			c_bus_in => c_bus_in	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
		);
		-- End of Generated Instance Port Map for inst_eg



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
