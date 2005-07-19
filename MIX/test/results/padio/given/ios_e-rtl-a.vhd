-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ios_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:46:40 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ios_e-rtl-a.vhd,v 1.2 2005/07/19 07:13:15 wig Exp $
-- $Date: 2005/07/19 07:13:15 $
-- $Log: ios_e-rtl-a.vhd,v $
-- Revision 1.2  2005/07/19 07:13:15  wig
-- Update testcases. Added highlow/nolowbus
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.57 2005/07/18 08:58:22 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of ios_e
--
architecture rtl of ios_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ioblock0_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioblock0_e
			p_mix_data_i1_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o1_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_iosel_0_gi	: in	std_ulogic;
			p_mix_iosel_1_gi	: in	std_ulogic;
			p_mix_iosel_2_gi	: in	std_ulogic;
			p_mix_iosel_3_gi	: in	std_ulogic;
			p_mix_iosel_4_gi	: in	std_ulogic;
			p_mix_iosel_5_gi	: in	std_ulogic;
			p_mix_nand_dir_gi	: in	std_ulogic;
			p_mix_nand_out_2_go	: out	std_ulogic;
			p_mix_pad_di_1_gi	: in	std_ulogic;
			p_mix_pad_do_2_go	: out	std_ulogic;
			p_mix_pad_en_2_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock0_e
		);
	end component;
	-- ---------

	component ioblock1_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioblock1_e
			p_mix_di2_1_0_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_di2_7_3_go	: out	std_ulogic_vector(4 downto 0);
			p_mix_disp2_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_disp2_7_3_gi	: in	std_ulogic_vector(4 downto 0);
			p_mix_disp2_en_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_disp2_en_7_3_gi	: in	std_ulogic_vector(4 downto 0);
			p_mix_display_ls_en_gi	: in	std_ulogic;
			p_mix_display_ls_hr_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ls_min_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_en_gi	: in	std_ulogic;
			p_mix_display_ms_hr_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_min_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_iosel_disp_gi	: in	std_ulogic;
			p_mix_iosel_ls_hr_gi	: in	std_ulogic;
			p_mix_iosel_ls_min_gi	: in	std_ulogic;
			p_mix_iosel_ms_hr_gi	: in	std_ulogic;
			p_mix_nand_dir_gi	: in	std_ulogic;
			p_mix_nand_out_2_gi	: in	std_ulogic;
			p_mix_pad_di_12_gi	: in	std_ulogic;
			p_mix_pad_di_13_gi	: in	std_ulogic;
			p_mix_pad_di_14_gi	: in	std_ulogic;
			p_mix_pad_di_15_gi	: in	std_ulogic;
			p_mix_pad_di_16_gi	: in	std_ulogic;
			p_mix_pad_di_17_gi	: in	std_ulogic;
			p_mix_pad_di_18_gi	: in	std_ulogic;
			p_mix_pad_do_12_go	: out	std_ulogic;
			p_mix_pad_do_13_go	: out	std_ulogic;
			p_mix_pad_do_14_go	: out	std_ulogic;
			p_mix_pad_do_15_go	: out	std_ulogic;
			p_mix_pad_do_16_go	: out	std_ulogic;
			p_mix_pad_do_17_go	: out	std_ulogic;
			p_mix_pad_do_18_go	: out	std_ulogic;
			p_mix_pad_en_12_go	: out	std_ulogic;
			p_mix_pad_en_13_go	: out	std_ulogic;
			p_mix_pad_en_14_go	: out	std_ulogic;
			p_mix_pad_en_15_go	: out	std_ulogic;
			p_mix_pad_en_16_go	: out	std_ulogic;
			p_mix_pad_en_17_go	: out	std_ulogic;
			p_mix_pad_en_18_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock1_e
		);
	end component;
	-- ---------

	component ioblock2_e	-- 
		-- No Generated Generics

		-- No Generated Port

	end component;
	-- ---------

	component ioblock3_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioblock3_e
			p_mix_d9_di_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_d9_do_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_en_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_pu_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_data_i33_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i34_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o35_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o36_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_display_ls_en_gi	: in	std_ulogic;
			p_mix_display_ms_en_gi	: in	std_ulogic;
			p_mix_iosel_bus_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_nand_dir_gi	: in	std_ulogic;
			p_mix_pad_di_31_gi	: in	std_ulogic;
			p_mix_pad_di_32_gi	: in	std_ulogic;
			p_mix_pad_di_33_gi	: in	std_ulogic;
			p_mix_pad_di_34_gi	: in	std_ulogic;
			p_mix_pad_di_39_gi	: in	std_ulogic;
			p_mix_pad_di_40_gi	: in	std_ulogic;
			p_mix_pad_do_31_go	: out	std_ulogic;
			p_mix_pad_do_32_go	: out	std_ulogic;
			p_mix_pad_do_35_go	: out	std_ulogic;
			p_mix_pad_do_36_go	: out	std_ulogic;
			p_mix_pad_do_39_go	: out	std_ulogic;
			p_mix_pad_do_40_go	: out	std_ulogic;
			p_mix_pad_en_31_go	: out	std_ulogic;
			p_mix_pad_en_32_go	: out	std_ulogic;
			p_mix_pad_en_35_go	: out	std_ulogic;
			p_mix_pad_en_36_go	: out	std_ulogic;
			p_mix_pad_en_39_go	: out	std_ulogic;
			p_mix_pad_en_40_go	: out	std_ulogic;
			p_mix_pad_pu_31_go	: out	std_ulogic;
			p_mix_pad_pu_32_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock3_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	d9_di	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	d9_do	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	d9_en	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	d9_pu	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_i1	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_i33	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_i34	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_o1	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_o35	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_o36	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	di2	: std_ulogic_vector(8 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	disp2	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	disp2_en	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_0	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_1	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_3	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_4	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_5	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_bus	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_disp	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ls_hr	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ls_min	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ms_hr	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	nand_dir	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	nand_out_2	: std_ulogic; 
			signal	pad_di_1	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_33	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_34	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_35	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_36	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_35	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_36	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_pu_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_pu_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			p_mix_d9_di_go <= d9_di;  -- __I_O_BUS_PORT
			d9_do <= p_mix_d9_do_gi;  -- __I_I_BUS_PORT
			d9_en <= p_mix_d9_en_gi;  -- __I_I_BUS_PORT
			d9_pu <= p_mix_d9_pu_gi;  -- __I_I_BUS_PORT
			p_mix_data_i1_go <= data_i1;  -- __I_O_BUS_PORT
			p_mix_data_i33_go <= data_i33;  -- __I_O_BUS_PORT
			p_mix_data_i34_go <= data_i34;  -- __I_O_BUS_PORT
			data_o1 <= p_mix_data_o1_gi;  -- __I_I_BUS_PORT
			data_o35 <= p_mix_data_o35_gi;  -- __I_I_BUS_PORT
			data_o36 <= p_mix_data_o36_gi;  -- __I_I_BUS_PORT
			p_mix_di2_1_0_go(1 downto 0) <= di2(1 downto 0);  -- __I_O_SLICE_PORT
			p_mix_di2_7_3_go(4 downto 0) <= di2(7 downto 3);  -- __I_O_SLICE_PORT
			disp2(1 downto 0) <= p_mix_disp2_1_0_gi(1 downto 0);  -- __I_I_SLICE_PORT
			disp2(7 downto 3) <= p_mix_disp2_7_3_gi(4 downto 0);  -- __I_I_SLICE_PORT
			disp2_en(7 downto 3) <= p_mix_disp2_en_7_3_gi(4 downto 0);  -- __I_I_SLICE_PORT
			disp2_en(1 downto 0) <= p_mix_disp2_en_1_0_gi(1 downto 0);  -- __I_I_SLICE_PORT
			display_ls_en <= p_mix_display_ls_en_gi;  -- __I_I_BIT_PORT
			display_ls_hr <= p_mix_display_ls_hr_gi;  -- __I_I_BUS_PORT
			display_ls_min <= p_mix_display_ls_min_gi;  -- __I_I_BUS_PORT
			display_ms_en <= p_mix_display_ms_en_gi;  -- __I_I_BIT_PORT
			display_ms_hr <= p_mix_display_ms_hr_gi;  -- __I_I_BUS_PORT
			display_ms_min <= p_mix_display_ms_min_gi;  -- __I_I_BUS_PORT
			iosel_0 <= p_mix_iosel_0_gi;  -- __I_I_BIT_PORT
			iosel_1 <= p_mix_iosel_1_gi;  -- __I_I_BIT_PORT
			iosel_2 <= p_mix_iosel_2_gi;  -- __I_I_BIT_PORT
			iosel_3 <= p_mix_iosel_3_gi;  -- __I_I_BIT_PORT
			iosel_4 <= p_mix_iosel_4_gi;  -- __I_I_BIT_PORT
			iosel_5 <= p_mix_iosel_5_gi;  -- __I_I_BIT_PORT
			iosel_bus <= p_mix_iosel_bus_gi;  -- __I_I_BUS_PORT
			iosel_disp <= p_mix_iosel_disp_gi;  -- __I_I_BIT_PORT
			iosel_ls_hr <= p_mix_iosel_ls_hr_gi;  -- __I_I_BIT_PORT
			iosel_ls_min <= p_mix_iosel_ls_min_gi;  -- __I_I_BIT_PORT
			iosel_ms_hr <= p_mix_iosel_ms_hr_gi;  -- __I_I_BIT_PORT
			nand_dir <= p_mix_nand_dir_gi;  -- __I_I_BIT_PORT
			pad_di_1 <= p_mix_pad_di_1_gi;  -- __I_I_BIT_PORT
			pad_di_12 <= p_mix_pad_di_12_gi;  -- __I_I_BIT_PORT
			pad_di_13 <= p_mix_pad_di_13_gi;  -- __I_I_BIT_PORT
			pad_di_14 <= p_mix_pad_di_14_gi;  -- __I_I_BIT_PORT
			pad_di_15 <= p_mix_pad_di_15_gi;  -- __I_I_BIT_PORT
			pad_di_16 <= p_mix_pad_di_16_gi;  -- __I_I_BIT_PORT
			pad_di_17 <= p_mix_pad_di_17_gi;  -- __I_I_BIT_PORT
			pad_di_18 <= p_mix_pad_di_18_gi;  -- __I_I_BIT_PORT
			pad_di_31 <= p_mix_pad_di_31_gi;  -- __I_I_BIT_PORT
			pad_di_32 <= p_mix_pad_di_32_gi;  -- __I_I_BIT_PORT
			pad_di_33 <= p_mix_pad_di_33_gi;  -- __I_I_BIT_PORT
			pad_di_34 <= p_mix_pad_di_34_gi;  -- __I_I_BIT_PORT
			pad_di_39 <= p_mix_pad_di_39_gi;  -- __I_I_BIT_PORT
			pad_di_40 <= p_mix_pad_di_40_gi;  -- __I_I_BIT_PORT
			p_mix_pad_do_12_go <= pad_do_12;  -- __I_O_BIT_PORT
			p_mix_pad_do_13_go <= pad_do_13;  -- __I_O_BIT_PORT
			p_mix_pad_do_14_go <= pad_do_14;  -- __I_O_BIT_PORT
			p_mix_pad_do_15_go <= pad_do_15;  -- __I_O_BIT_PORT
			p_mix_pad_do_16_go <= pad_do_16;  -- __I_O_BIT_PORT
			p_mix_pad_do_17_go <= pad_do_17;  -- __I_O_BIT_PORT
			p_mix_pad_do_18_go <= pad_do_18;  -- __I_O_BIT_PORT
			p_mix_pad_do_2_go <= pad_do_2;  -- __I_O_BIT_PORT
			p_mix_pad_do_31_go <= pad_do_31;  -- __I_O_BIT_PORT
			p_mix_pad_do_32_go <= pad_do_32;  -- __I_O_BIT_PORT
			p_mix_pad_do_35_go <= pad_do_35;  -- __I_O_BIT_PORT
			p_mix_pad_do_36_go <= pad_do_36;  -- __I_O_BIT_PORT
			p_mix_pad_do_39_go <= pad_do_39;  -- __I_O_BIT_PORT
			p_mix_pad_do_40_go <= pad_do_40;  -- __I_O_BIT_PORT
			p_mix_pad_en_12_go <= pad_en_12;  -- __I_O_BIT_PORT
			p_mix_pad_en_13_go <= pad_en_13;  -- __I_O_BIT_PORT
			p_mix_pad_en_14_go <= pad_en_14;  -- __I_O_BIT_PORT
			p_mix_pad_en_15_go <= pad_en_15;  -- __I_O_BIT_PORT
			p_mix_pad_en_16_go <= pad_en_16;  -- __I_O_BIT_PORT
			p_mix_pad_en_17_go <= pad_en_17;  -- __I_O_BIT_PORT
			p_mix_pad_en_18_go <= pad_en_18;  -- __I_O_BIT_PORT
			p_mix_pad_en_2_go <= pad_en_2;  -- __I_O_BIT_PORT
			p_mix_pad_en_31_go <= pad_en_31;  -- __I_O_BIT_PORT
			p_mix_pad_en_32_go <= pad_en_32;  -- __I_O_BIT_PORT
			p_mix_pad_en_35_go <= pad_en_35;  -- __I_O_BIT_PORT
			p_mix_pad_en_36_go <= pad_en_36;  -- __I_O_BIT_PORT
			p_mix_pad_en_39_go <= pad_en_39;  -- __I_O_BIT_PORT
			p_mix_pad_en_40_go <= pad_en_40;  -- __I_O_BIT_PORT
			p_mix_pad_pu_31_go <= pad_pu_31;  -- __I_O_BIT_PORT
			p_mix_pad_pu_32_go <= pad_pu_32;  -- __I_O_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for ioblock_0
		ioblock_0: ioblock0_e
		port map (

			p_mix_data_i1_go => data_i1, -- io data
			p_mix_data_o1_gi => data_o1, -- io data
			p_mix_iosel_0_gi => iosel_0, -- IO_Select
			p_mix_iosel_1_gi => iosel_1, -- IO_Select
			p_mix_iosel_2_gi => iosel_2, -- IO_Select
			p_mix_iosel_3_gi => iosel_3, -- IO_Select
			p_mix_iosel_4_gi => iosel_4, -- IO_Select
			p_mix_iosel_5_gi => iosel_5, -- IO_Select
			p_mix_nand_dir_gi => nand_dir, -- Direction (X17)
			p_mix_nand_out_2_go => nand_out_2, -- Links ...
			p_mix_pad_di_1_gi => pad_di_1, -- data in from pad
			p_mix_pad_do_2_go => pad_do_2, -- data out to pad
			p_mix_pad_en_2_go => pad_en_2 -- pad output enable
		);
		-- End of Generated Instance Port Map for ioblock_0

		-- Generated Instance Port Map for ioblock_1
		ioblock_1: ioblock1_e
		port map (

			p_mix_di2_1_0_go => di2(1 downto 0), -- io data
			p_mix_di2_7_3_go => di2(7 downto 3), -- io data
			p_mix_disp2_1_0_gi => disp2(1 downto 0), -- io data
			p_mix_disp2_7_3_gi => disp2(7 downto 3), -- io data
			p_mix_disp2_en_1_0_gi => disp2_en(1 downto 0), -- io data
			p_mix_disp2_en_7_3_gi => disp2_en(7 downto 3), -- io data
			p_mix_display_ls_en_gi => display_ls_en, -- io_enable
			p_mix_display_ls_hr_gi => display_ls_hr, -- Display storage buffer 2 ls_hr
			p_mix_display_ls_min_gi => display_ls_min, -- Display storage buffer 0 ls_min
			p_mix_display_ms_en_gi => display_ms_en, -- io_enable
			p_mix_display_ms_hr_gi => display_ms_hr, -- Display storage buffer 3 ms_hr
			p_mix_display_ms_min_gi => display_ms_min, -- Display storage buffer 1 ms_min
			p_mix_iosel_disp_gi => iosel_disp, -- IO_Select
			p_mix_iosel_ls_hr_gi => iosel_ls_hr, -- IO_Select
			p_mix_iosel_ls_min_gi => iosel_ls_min, -- IO_Select
			p_mix_iosel_ms_hr_gi => iosel_ms_hr, -- IO_Select
			p_mix_nand_dir_gi => nand_dir, -- Direction (X17)
			p_mix_nand_out_2_gi => nand_out_2, -- Links ...
			p_mix_pad_di_12_gi => pad_di_12, -- data in from pad
			p_mix_pad_di_13_gi => pad_di_13, -- data in from pad
			p_mix_pad_di_14_gi => pad_di_14, -- data in from pad
			p_mix_pad_di_15_gi => pad_di_15, -- data in from pad
			p_mix_pad_di_16_gi => pad_di_16, -- data in from pad
			p_mix_pad_di_17_gi => pad_di_17, -- data in from pad
			p_mix_pad_di_18_gi => pad_di_18, -- data in from pad
			p_mix_pad_do_12_go => pad_do_12, -- data out to pad
			p_mix_pad_do_13_go => pad_do_13, -- data out to pad
			p_mix_pad_do_14_go => pad_do_14, -- data out to pad
			p_mix_pad_do_15_go => pad_do_15, -- data out to pad
			p_mix_pad_do_16_go => pad_do_16, -- data out to pad
			p_mix_pad_do_17_go => pad_do_17, -- data out to pad
			p_mix_pad_do_18_go => pad_do_18, -- data out to pad
			p_mix_pad_en_12_go => pad_en_12, -- pad output enable
			p_mix_pad_en_13_go => pad_en_13, -- pad output enable
			p_mix_pad_en_14_go => pad_en_14, -- pad output enable
			p_mix_pad_en_15_go => pad_en_15, -- pad output enable
			p_mix_pad_en_16_go => pad_en_16, -- pad output enable
			p_mix_pad_en_17_go => pad_en_17, -- pad output enable
			p_mix_pad_en_18_go => pad_en_18 -- pad output enable
		);
		-- End of Generated Instance Port Map for ioblock_1

		-- Generated Instance Port Map for ioblock_2
		ioblock_2: ioblock2_e

		;
		-- End of Generated Instance Port Map for ioblock_2

		-- Generated Instance Port Map for ioblock_3
		ioblock_3: ioblock3_e
		port map (

			p_mix_d9_di_go => d9_di, -- d9io
			p_mix_d9_do_gi => d9_do, -- d9io
			p_mix_d9_en_gi => d9_en, -- d9io
			p_mix_d9_pu_gi => d9_pu, -- d9io
			p_mix_data_i33_go => data_i33, -- io data
			p_mix_data_i34_go => data_i34, -- io data
			p_mix_data_o35_gi => data_o35, -- io data
			p_mix_data_o36_gi => data_o36, -- io data
			p_mix_display_ls_en_gi => display_ls_en, -- io_enable
			p_mix_display_ms_en_gi => display_ms_en, -- io_enable
			p_mix_iosel_bus_gi => iosel_bus, -- io data
			p_mix_nand_dir_gi => nand_dir, -- Direction (X17)
			p_mix_pad_di_31_gi => pad_di_31, -- data in from pad
			p_mix_pad_di_32_gi => pad_di_32, -- data in from pad
			p_mix_pad_di_33_gi => pad_di_33, -- data in from pad
			p_mix_pad_di_34_gi => pad_di_34, -- data in from pad
			p_mix_pad_di_39_gi => pad_di_39, -- data in from pad
			p_mix_pad_di_40_gi => pad_di_40, -- data in from pad
			p_mix_pad_do_31_go => pad_do_31, -- data out to pad
			p_mix_pad_do_32_go => pad_do_32, -- data out to pad
			p_mix_pad_do_35_go => pad_do_35, -- data out to pad
			p_mix_pad_do_36_go => pad_do_36, -- data out to pad
			p_mix_pad_do_39_go => pad_do_39, -- data out to pad
			p_mix_pad_do_40_go => pad_do_40, -- data out to pad
			p_mix_pad_en_31_go => pad_en_31, -- pad output enable
			p_mix_pad_en_32_go => pad_en_32, -- pad output enable
			p_mix_pad_en_35_go => pad_en_35, -- pad output enable
			p_mix_pad_en_36_go => pad_en_36, -- pad output enable
			p_mix_pad_en_39_go => pad_en_39, -- pad output enable
			p_mix_pad_en_40_go => pad_en_40, -- pad output enable
			p_mix_pad_pu_31_go => pad_pu_31, -- pull-up control
			p_mix_pad_pu_32_go => pad_pu_32 -- pull-up control
		);
		-- End of Generated Instance Port Map for ioblock_3



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
