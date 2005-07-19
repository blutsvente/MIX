-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of a_clk
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:56:34 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: a_clk-rtl-a.vhd,v 1.3 2005/07/19 07:13:11 wig Exp $
-- $Date: 2005/07/19 07:13:11 $
-- $Log: a_clk-rtl-a.vhd,v $
-- Revision 1.3  2005/07/19 07:13:11  wig
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
-- Start of Generated Architecture rtl of a_clk
--
architecture rtl of a_clk is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component a_fsm	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity a_fsm
			alarm_button	: in	std_ulogic;
			clk	: in	std_ulogic;
			d9_core_di	: in	std_ulogic_vector(1 downto 0);
			d9_core_en	: in	std_ulogic_vector(1 downto 0);
			d9_core_pu	: in	std_ulogic_vector(1 downto 0);
			data_core_do	: out	std_ulogic_vector(1 downto 0);
			data_core_i33	: in	std_ulogic_vector(7 downto 0);
			data_core_i34	: in	std_ulogic_vector(7 downto 0);
			data_core_o35	: out	std_ulogic_vector(7 downto 0);
			data_core_o36	: out	std_ulogic_vector(7 downto 0);
			data_i1	: in	std_ulogic_vector(7 downto 0);
			data_o1	: out	std_ulogic_vector(7 downto 0);
			di	: in	std_ulogic_vector(7 downto 0);
			di2	: in	std_ulogic_vector(8 downto 0);
			disp2_en	: in	std_ulogic_vector(7 downto 0);
			disp_ls_port	: out	std_ulogic;
			disp_ms_port	: out	std_ulogic;
			iosel_bus	: out	std_ulogic_vector(7 downto 0);
			iosel_bus_disp	: out	std_ulogic;
			iosel_bus_ls_hr	: out	std_ulogic;
			iosel_bus_ls_min	: out	std_ulogic;
			iosel_bus_ms_hr	: out	std_ulogic;
			iosel_bus_ms_min	: out	std_ulogic;
			iosel_bus_nosel	: out	std_ulogic;
			iosel_bus_port	: out	std_ulogic_vector(7 downto 0);
			key	: in	std_ulogic_vector(3 downto 0);
			load_new_a	: out	std_ulogic;
			load_new_c	: out	std_ulogic;
			one_second	: in	std_ulogic;
			reset	: in	std_ulogic;
			shift	: out	std_ulogic;
			show_a	: out	std_ulogic;
			show_new_time	: out	std_ulogic;
			time_button	: in	std_ulogic
		-- End of Generated Port for Entity a_fsm
		);
	end component;
	-- ---------

	component ios_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ios_e
			p_mix_d9_di_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_d9_do_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_en_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_pu_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_data_i1_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i33_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i34_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o1_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o35_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o36_gi	: in	std_ulogic_vector(7 downto 0);
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
			p_mix_iosel_0_gi	: in	std_ulogic;
			p_mix_iosel_1_gi	: in	std_ulogic;
			p_mix_iosel_2_gi	: in	std_ulogic;
			p_mix_iosel_3_gi	: in	std_ulogic;
			p_mix_iosel_4_gi	: in	std_ulogic;
			p_mix_iosel_5_gi	: in	std_ulogic;
			p_mix_iosel_6_gi	: in	std_ulogic;
			p_mix_iosel_7_gi	: in	std_ulogic;
			p_mix_iosel_bus_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_iosel_disp_gi	: in	std_ulogic;
			p_mix_iosel_ls_hr_gi	: in	std_ulogic;
			p_mix_iosel_ls_min_gi	: in	std_ulogic;
			p_mix_iosel_ms_hr_gi	: in	std_ulogic;
			p_mix_iosel_ms_min_gi	: in	std_ulogic;
			p_mix_pad_di_12_gi	: in	std_ulogic;
			p_mix_pad_di_13_gi	: in	std_ulogic;
			p_mix_pad_di_14_gi	: in	std_ulogic;
			p_mix_pad_di_15_gi	: in	std_ulogic;
			p_mix_pad_di_16_gi	: in	std_ulogic;
			p_mix_pad_di_17_gi	: in	std_ulogic;
			p_mix_pad_di_18_gi	: in	std_ulogic;
			p_mix_pad_di_1_gi	: in	std_ulogic;
			p_mix_pad_di_31_gi	: in	std_ulogic;
			p_mix_pad_di_32_gi	: in	std_ulogic;
			p_mix_pad_di_33_gi	: in	std_ulogic;
			p_mix_pad_di_34_gi	: in	std_ulogic;
			p_mix_pad_di_39_gi	: in	std_ulogic;
			p_mix_pad_di_40_gi	: in	std_ulogic;
			p_mix_pad_do_12_go	: out	std_ulogic;
			p_mix_pad_do_13_go	: out	std_ulogic;
			p_mix_pad_do_14_go	: out	std_ulogic;
			p_mix_pad_do_15_go	: out	std_ulogic;
			p_mix_pad_do_16_go	: out	std_ulogic;
			p_mix_pad_do_17_go	: out	std_ulogic;
			p_mix_pad_do_18_go	: out	std_ulogic;
			p_mix_pad_do_2_go	: out	std_ulogic;
			p_mix_pad_do_31_go	: out	std_ulogic;
			p_mix_pad_do_32_go	: out	std_ulogic;
			p_mix_pad_do_35_go	: out	std_ulogic;
			p_mix_pad_do_36_go	: out	std_ulogic;
			p_mix_pad_do_39_go	: out	std_ulogic;
			p_mix_pad_do_40_go	: out	std_ulogic;
			p_mix_pad_en_12_go	: out	std_ulogic;
			p_mix_pad_en_13_go	: out	std_ulogic;
			p_mix_pad_en_14_go	: out	std_ulogic;
			p_mix_pad_en_15_go	: out	std_ulogic;
			p_mix_pad_en_16_go	: out	std_ulogic;
			p_mix_pad_en_17_go	: out	std_ulogic;
			p_mix_pad_en_18_go	: out	std_ulogic;
			p_mix_pad_en_2_go	: out	std_ulogic;
			p_mix_pad_en_31_go	: out	std_ulogic;
			p_mix_pad_en_32_go	: out	std_ulogic;
			p_mix_pad_en_35_go	: out	std_ulogic;
			p_mix_pad_en_36_go	: out	std_ulogic;
			p_mix_pad_en_39_go	: out	std_ulogic;
			p_mix_pad_en_40_go	: out	std_ulogic;
			p_mix_pad_pu_31_go	: out	std_ulogic;
			p_mix_pad_pu_32_go	: out	std_ulogic
		-- End of Generated Port for Entity ios_e
		);
	end component;
	-- ---------

	component pad_pads_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity pad_pads_e
			p_mix_pad_di_12_go	: out	std_ulogic;
			p_mix_pad_di_13_go	: out	std_ulogic;
			p_mix_pad_di_14_go	: out	std_ulogic;
			p_mix_pad_di_15_go	: out	std_ulogic;
			p_mix_pad_di_16_go	: out	std_ulogic;
			p_mix_pad_di_17_go	: out	std_ulogic;
			p_mix_pad_di_18_go	: out	std_ulogic;
			p_mix_pad_di_1_go	: out	std_ulogic;
			p_mix_pad_di_31_go	: out	std_ulogic;
			p_mix_pad_di_32_go	: out	std_ulogic;
			p_mix_pad_di_33_go	: out	std_ulogic;
			p_mix_pad_di_34_go	: out	std_ulogic;
			p_mix_pad_di_39_go	: out	std_ulogic;
			p_mix_pad_di_40_go	: out	std_ulogic;
			p_mix_pad_do_12_gi	: in	std_ulogic;
			p_mix_pad_do_13_gi	: in	std_ulogic;
			p_mix_pad_do_14_gi	: in	std_ulogic;
			p_mix_pad_do_15_gi	: in	std_ulogic;
			p_mix_pad_do_16_gi	: in	std_ulogic;
			p_mix_pad_do_17_gi	: in	std_ulogic;
			p_mix_pad_do_18_gi	: in	std_ulogic;
			p_mix_pad_do_2_gi	: in	std_ulogic;
			p_mix_pad_do_31_gi	: in	std_ulogic;
			p_mix_pad_do_32_gi	: in	std_ulogic;
			p_mix_pad_do_35_gi	: in	std_ulogic;
			p_mix_pad_do_36_gi	: in	std_ulogic;
			p_mix_pad_do_39_gi	: in	std_ulogic;
			p_mix_pad_do_40_gi	: in	std_ulogic;
			p_mix_pad_en_12_gi	: in	std_ulogic;
			p_mix_pad_en_13_gi	: in	std_ulogic;
			p_mix_pad_en_14_gi	: in	std_ulogic;
			p_mix_pad_en_15_gi	: in	std_ulogic;
			p_mix_pad_en_16_gi	: in	std_ulogic;
			p_mix_pad_en_17_gi	: in	std_ulogic;
			p_mix_pad_en_18_gi	: in	std_ulogic;
			p_mix_pad_en_2_gi	: in	std_ulogic;
			p_mix_pad_en_31_gi	: in	std_ulogic;
			p_mix_pad_en_32_gi	: in	std_ulogic;
			p_mix_pad_en_35_gi	: in	std_ulogic;
			p_mix_pad_en_36_gi	: in	std_ulogic;
			p_mix_pad_en_39_gi	: in	std_ulogic;
			p_mix_pad_en_40_gi	: in	std_ulogic;
			p_mix_pad_pu_31_gi	: in	std_ulogic;
			p_mix_pad_pu_32_gi	: in	std_ulogic
		-- End of Generated Port for Entity pad_pads_e
		);
	end component;
	-- ---------

	component testctrl_e	-- 
		-- No Generated Generics

		-- No Generated Port

	end component;
	-- ---------

	component alreg	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity alreg
			alarm_time	: out	std_ulogic_vector(3 downto 0);
			load_new_a	: in	std_ulogic;
			new_alarm_time	: in	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity alreg
		);
	end component;
	-- ---------

	component count4	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity count4
			current_time_ls_hr	: out	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: out	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: out	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: out	std_ulogic_vector(3 downto 0);
			load_new_c	: in	std_ulogic;
			new_current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			new_current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			new_current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			new_current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			one_minute	: in	std_ulogic
		-- End of Generated Port for Entity count4
		);
	end component;
	-- ---------

	component ddrv4	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ddrv4
			alarm_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			key_buffer_0	: in	std_ulogic_vector(3 downto 0);
			key_buffer_1	: in	std_ulogic_vector(3 downto 0);
			key_buffer_2	: in	std_ulogic_vector(3 downto 0);
			key_buffer_3	: in	std_ulogic_vector(3 downto 0);
			p_mix_display_ls_hr_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ls_min_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_hr_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_min_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_sound_alarm_go	: out	std_ulogic;
			show_a	: in	std_ulogic;
			show_new_time	: in	std_ulogic
		-- End of Generated Port for Entity ddrv4
		);
	end component;
	-- ---------

	component keypad	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity keypad
			columns	: in	std_ulogic_vector(2 downto 0);
			rows	: out	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity keypad
		);
	end component;
	-- ---------

	component keyscan	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity keyscan
			alarm_button	: out	std_ulogic;
			columns	: out	std_ulogic_vector(2 downto 0);
			key	: out	std_ulogic_vector(3 downto 0);
			key_buffer_0	: out	std_ulogic_vector(3 downto 0);
			key_buffer_1	: out	std_ulogic_vector(3 downto 0);
			key_buffer_2	: out	std_ulogic_vector(3 downto 0);
			key_buffer_3	: out	std_ulogic_vector(3 downto 0);
			rows	: in	std_ulogic_vector(3 downto 0);
			shift	: in	std_ulogic;
			time_button	: out	std_ulogic
		-- End of Generated Port for Entity keyscan
		);
	end component;
	-- ---------

	component timegen	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity timegen
			one_minute	: out	std_ulogic;
			one_second	: out	std_ulogic;
			stopwatch	: in	std_ulogic
		-- End of Generated Port for Entity timegen
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	alarm_button	: std_ulogic; 
			signal	s_int_alarm_time_ls_hr	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_alarm_time_ls_min	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_alarm_time_ms_hr	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_alarm_time_ms_min	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	columns	: std_ulogic_vector(2 downto 0); 
			signal	s_int_current_time_ls_hr	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_current_time_ls_min	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_current_time_ms_hr	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_current_time_ms_min	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	d9_di	: std_ulogic_vector(1 downto 0); 
			signal	d9_do	: std_ulogic_vector(1 downto 0); 
			signal	d9_en	: std_ulogic_vector(1 downto 0); 
			signal	d9_pu	: std_ulogic_vector(1 downto 0); 
			signal	data_i1	: std_ulogic_vector(7 downto 0); 
			signal	data_i33	: std_ulogic_vector(7 downto 0); 
			signal	data_i34	: std_ulogic_vector(7 downto 0); 
			signal	data_o1	: std_ulogic_vector(7 downto 0); 
			signal	data_o35	: std_ulogic_vector(7 downto 0); 
			signal	data_o36	: std_ulogic_vector(7 downto 0); 
			signal	di2	: std_ulogic_vector(8 downto 0); 
			signal	disp2	: std_ulogic_vector(7 downto 0); 
			signal	disp2_en	: std_ulogic_vector(7 downto 0); 
			signal	display_ls_en	: std_ulogic; 
			signal	s_int_display_ls_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_display_ls_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_en	: std_ulogic; 
			signal	s_int_display_ms_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_display_ms_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_0	: std_ulogic; 
			signal	iosel_1	: std_ulogic; 
			signal	iosel_2	: std_ulogic; 
			signal	iosel_3	: std_ulogic; 
			signal	iosel_4	: std_ulogic; 
			signal	iosel_5	: std_ulogic; 
			signal	iosel_6	: std_ulogic; 
			signal	iosel_7	: std_ulogic; 
			signal	iosel_bus	: std_ulogic_vector(7 downto 0); 
			signal	iosel_disp	: std_ulogic; 
			signal	iosel_ls_hr	: std_ulogic; 
			signal	iosel_ls_min	: std_ulogic; 
			signal	iosel_ms_hr	: std_ulogic; 
			signal	iosel_ms_min	: std_ulogic; 
			--  __I_OUT_OPEN signal	iosel_nosel	: std_ulogic; 
			signal	key	: std_ulogic_vector(3 downto 0); 
			signal	s_int_key_buffer_0	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_key_buffer_1	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_key_buffer_2	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_key_buffer_3	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	load_new_a	: std_ulogic; 
			signal	load_new_c	: std_ulogic; 
			signal	one_minute	: std_ulogic; 
			signal	one_sec_pulse	: std_ulogic; 
			signal	pad_di_1	: std_ulogic; 
			signal	pad_di_12	: std_ulogic; 
			signal	pad_di_13	: std_ulogic; 
			signal	pad_di_14	: std_ulogic; 
			signal	pad_di_15	: std_ulogic; 
			signal	pad_di_16	: std_ulogic; 
			signal	pad_di_17	: std_ulogic; 
			signal	pad_di_18	: std_ulogic; 
			signal	pad_di_31	: std_ulogic; 
			signal	pad_di_32	: std_ulogic; 
			signal	pad_di_33	: std_ulogic; 
			signal	pad_di_34	: std_ulogic; 
			signal	pad_di_39	: std_ulogic; 
			signal	pad_di_40	: std_ulogic; 
			signal	pad_do_12	: std_ulogic; 
			signal	pad_do_13	: std_ulogic; 
			signal	pad_do_14	: std_ulogic; 
			signal	pad_do_15	: std_ulogic; 
			signal	pad_do_16	: std_ulogic; 
			signal	pad_do_17	: std_ulogic; 
			signal	pad_do_18	: std_ulogic; 
			signal	pad_do_2	: std_ulogic; 
			signal	pad_do_31	: std_ulogic; 
			signal	pad_do_32	: std_ulogic; 
			signal	pad_do_35	: std_ulogic; 
			signal	pad_do_36	: std_ulogic; 
			signal	pad_do_39	: std_ulogic; 
			signal	pad_do_40	: std_ulogic; 
			signal	pad_en_12	: std_ulogic; 
			signal	pad_en_13	: std_ulogic; 
			signal	pad_en_14	: std_ulogic; 
			signal	pad_en_15	: std_ulogic; 
			signal	pad_en_16	: std_ulogic; 
			signal	pad_en_17	: std_ulogic; 
			signal	pad_en_18	: std_ulogic; 
			signal	pad_en_2	: std_ulogic; 
			signal	pad_en_31	: std_ulogic; 
			signal	pad_en_32	: std_ulogic; 
			signal	pad_en_35	: std_ulogic; 
			signal	pad_en_36	: std_ulogic; 
			signal	pad_en_39	: std_ulogic; 
			signal	pad_en_40	: std_ulogic; 
			signal	pad_pu_31	: std_ulogic; 
			signal	pad_pu_32	: std_ulogic; 
			signal	rows	: std_ulogic_vector(3 downto 0); 
			signal	shift	: std_ulogic; 
			signal	s_int_show_a	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_show_new_time	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	time_button	: std_ulogic; 
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			s_int_alarm_time_ls_hr <= alarm_time_ls_hr;  -- __I_I_BUS_PORT
			s_int_alarm_time_ls_min <= alarm_time_ls_min;  -- __I_I_BUS_PORT
			s_int_alarm_time_ms_hr <= alarm_time_ms_hr;  -- __I_I_BUS_PORT
			s_int_alarm_time_ms_min <= alarm_time_ms_min;  -- __I_I_BUS_PORT
			s_int_current_time_ls_hr <= current_time_ls_hr;  -- __I_I_BUS_PORT
			s_int_current_time_ls_min <= current_time_ls_min;  -- __I_I_BUS_PORT
			s_int_current_time_ms_hr <= current_time_ms_hr;  -- __I_I_BUS_PORT
			s_int_current_time_ms_min <= current_time_ms_min;  -- __I_I_BUS_PORT
			display_ls_hr <= s_int_display_ls_hr;  -- __I_O_BUS_PORT
			display_ls_min <= s_int_display_ls_min;  -- __I_O_BUS_PORT
			display_ms_hr <= s_int_display_ms_hr;  -- __I_O_BUS_PORT
			display_ms_min <= s_int_display_ms_min;  -- __I_O_BUS_PORT
			s_int_key_buffer_0 <= key_buffer_0;  -- __I_I_BUS_PORT
			s_int_key_buffer_1 <= key_buffer_1;  -- __I_I_BUS_PORT
			s_int_key_buffer_2 <= key_buffer_2;  -- __I_I_BUS_PORT
			s_int_key_buffer_3 <= key_buffer_3;  -- __I_I_BUS_PORT
			s_int_show_a <= show_a;  -- __I_I_BIT_PORT
			s_int_show_new_time <= show_new_time;  -- __I_I_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for control
		control: a_fsm
		port map (

			alarm_button => alarm_button,
			clk => clk,
			d9_core_di => d9_di, -- d9io
			d9_core_en => d9_en, -- d9io
			d9_core_pu => d9_pu, -- d9io
			data_core_do => d9_do, -- d9io
			data_core_i33 => data_i33, -- io data
			data_core_i34 => data_i34, -- io data
			data_core_o35 => data_o35, -- io data
			data_core_o36 => data_o36, -- io data
			data_i1 => data_i1, -- io data
			data_o1 => data_o1, -- io data
			di => disp2, -- io data
			di2 => di2, -- io data
			disp2_en => disp2_en, -- io data
			disp_ls_port => display_ls_en, -- io_enable
			disp_ms_port => display_ms_en, -- io_enable
			iosel_bus(0) => iosel_0, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(1) => iosel_1, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(2) => iosel_2, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(3) => iosel_3, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(4) => iosel_4, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(5) => iosel_5, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(6) => iosel_6, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus(7) => iosel_7, -- __I_BIT_TO_BUSPORT -- IO_Select
			iosel_bus_disp => iosel_disp, -- IO_Select
			iosel_bus_ls_hr => iosel_ls_hr, -- IO_Select
			iosel_bus_ls_min => iosel_ls_min, -- IO_Select
			iosel_bus_ms_hr => iosel_ms_hr, -- IO_Select
			iosel_bus_ms_min => iosel_ms_min, -- IO_Select
			iosel_bus_nosel => open, -- IO_Select -- __I_OUT_OPEN
			iosel_bus_port => iosel_bus, -- io data
			key => key,
			load_new_a => load_new_a,
			load_new_c => load_new_c,
			one_second => one_sec_pulse,
			reset => reset,
			shift => shift,
			show_a => s_int_show_a,
			show_new_time => s_int_show_new_time,
			time_button => time_button
		);
		-- End of Generated Instance Port Map for control

		-- Generated Instance Port Map for ios
		ios: ios_e
		port map (

			p_mix_d9_di_go => d9_di, -- d9io
			p_mix_d9_do_gi => d9_do, -- d9io
			p_mix_d9_en_gi => d9_en, -- d9io
			p_mix_d9_pu_gi => d9_pu, -- d9io
			p_mix_data_i1_go => data_i1, -- io data
			p_mix_data_i33_go => data_i33, -- io data
			p_mix_data_i34_go => data_i34, -- io data
			p_mix_data_o1_gi => data_o1, -- io data
			p_mix_data_o35_gi => data_o35, -- io data
			p_mix_data_o36_gi => data_o36, -- io data
			p_mix_di2_1_0_go => di2(1 downto 0), -- io data
			p_mix_di2_7_3_go => di2(7 downto 3), -- io data
			p_mix_disp2_1_0_gi => disp2(1 downto 0), -- io data
			p_mix_disp2_7_3_gi => disp2(7 downto 3), -- io data
			p_mix_disp2_en_1_0_gi => disp2_en(1 downto 0), -- io data
			p_mix_disp2_en_7_3_gi => disp2_en(7 downto 3), -- io data
			p_mix_display_ls_en_gi => display_ls_en, -- io_enable
			p_mix_display_ls_hr_gi => s_int_display_ls_hr, -- Display storage buffer 2 ls_hr
			p_mix_display_ls_min_gi => s_int_display_ls_min, -- Display storage buffer 0 ls_min
			p_mix_display_ms_en_gi => display_ms_en, -- io_enable
			p_mix_display_ms_hr_gi => s_int_display_ms_hr, -- Display storage buffer 3 ms_hr
			p_mix_display_ms_min_gi => s_int_display_ms_min, -- Display storage buffer 1 ms_min
			p_mix_iosel_0_gi => iosel_0, -- IO_Select
			p_mix_iosel_1_gi => iosel_1, -- IO_Select
			p_mix_iosel_2_gi => iosel_2, -- IO_Select
			p_mix_iosel_3_gi => iosel_3, -- IO_Select
			p_mix_iosel_4_gi => iosel_4, -- IO_Select
			p_mix_iosel_5_gi => iosel_5, -- IO_Select
			p_mix_iosel_6_gi => iosel_6, -- IO_Select
			p_mix_iosel_7_gi => iosel_7, -- IO_Select
			p_mix_iosel_bus_gi => iosel_bus, -- io data
			p_mix_iosel_disp_gi => iosel_disp, -- IO_Select
			p_mix_iosel_ls_hr_gi => iosel_ls_hr, -- IO_Select
			p_mix_iosel_ls_min_gi => iosel_ls_min, -- IO_Select
			p_mix_iosel_ms_hr_gi => iosel_ms_hr, -- IO_Select
			p_mix_iosel_ms_min_gi => iosel_ms_min, -- IO_Select
			p_mix_pad_di_12_gi => pad_di_12, -- data in from pad
			p_mix_pad_di_13_gi => pad_di_13, -- data in from pad
			p_mix_pad_di_14_gi => pad_di_14, -- data in from pad
			p_mix_pad_di_15_gi => pad_di_15, -- data in from pad
			p_mix_pad_di_16_gi => pad_di_16, -- data in from pad
			p_mix_pad_di_17_gi => pad_di_17, -- data in from pad
			p_mix_pad_di_18_gi => pad_di_18, -- data in from pad
			p_mix_pad_di_1_gi => pad_di_1, -- data in from pad
			p_mix_pad_di_31_gi => pad_di_31, -- data in from pad
			p_mix_pad_di_32_gi => pad_di_32, -- data in from pad
			p_mix_pad_di_33_gi => pad_di_33, -- data in from pad
			p_mix_pad_di_34_gi => pad_di_34, -- data in from pad
			p_mix_pad_di_39_gi => pad_di_39, -- data in from pad
			p_mix_pad_di_40_gi => pad_di_40, -- data in from pad
			p_mix_pad_do_12_go => pad_do_12, -- data out to pad
			p_mix_pad_do_13_go => pad_do_13, -- data out to pad
			p_mix_pad_do_14_go => pad_do_14, -- data out to pad
			p_mix_pad_do_15_go => pad_do_15, -- data out to pad
			p_mix_pad_do_16_go => pad_do_16, -- data out to pad
			p_mix_pad_do_17_go => pad_do_17, -- data out to pad
			p_mix_pad_do_18_go => pad_do_18, -- data out to pad
			p_mix_pad_do_2_go => pad_do_2, -- data out to pad
			p_mix_pad_do_31_go => pad_do_31, -- data out to pad
			p_mix_pad_do_32_go => pad_do_32, -- data out to pad
			p_mix_pad_do_35_go => pad_do_35, -- data out to pad
			p_mix_pad_do_36_go => pad_do_36, -- data out to pad
			p_mix_pad_do_39_go => pad_do_39, -- data out to pad
			p_mix_pad_do_40_go => pad_do_40, -- data out to pad
			p_mix_pad_en_12_go => pad_en_12, -- pad output enable
			p_mix_pad_en_13_go => pad_en_13, -- pad output enable
			p_mix_pad_en_14_go => pad_en_14, -- pad output enable
			p_mix_pad_en_15_go => pad_en_15, -- pad output enable
			p_mix_pad_en_16_go => pad_en_16, -- pad output enable
			p_mix_pad_en_17_go => pad_en_17, -- pad output enable
			p_mix_pad_en_18_go => pad_en_18, -- pad output enable
			p_mix_pad_en_2_go => pad_en_2, -- pad output enable
			p_mix_pad_en_31_go => pad_en_31, -- pad output enable
			p_mix_pad_en_32_go => pad_en_32, -- pad output enable
			p_mix_pad_en_35_go => pad_en_35, -- pad output enable
			p_mix_pad_en_36_go => pad_en_36, -- pad output enable
			p_mix_pad_en_39_go => pad_en_39, -- pad output enable
			p_mix_pad_en_40_go => pad_en_40, -- pad output enable
			p_mix_pad_pu_31_go => pad_pu_31, -- pull-up control
			p_mix_pad_pu_32_go => pad_pu_32 -- pull-up control
		);
		-- End of Generated Instance Port Map for ios

		-- Generated Instance Port Map for pad_pads
		pad_pads: pad_pads_e
		port map (

			p_mix_pad_di_12_go => pad_di_12, -- data in from pad
			p_mix_pad_di_13_go => pad_di_13, -- data in from pad
			p_mix_pad_di_14_go => pad_di_14, -- data in from pad
			p_mix_pad_di_15_go => pad_di_15, -- data in from pad
			p_mix_pad_di_16_go => pad_di_16, -- data in from pad
			p_mix_pad_di_17_go => pad_di_17, -- data in from pad
			p_mix_pad_di_18_go => pad_di_18, -- data in from pad
			p_mix_pad_di_1_go => pad_di_1, -- data in from pad
			p_mix_pad_di_31_go => pad_di_31, -- data in from pad
			p_mix_pad_di_32_go => pad_di_32, -- data in from pad
			p_mix_pad_di_33_go => pad_di_33, -- data in from pad
			p_mix_pad_di_34_go => pad_di_34, -- data in from pad
			p_mix_pad_di_39_go => pad_di_39, -- data in from pad
			p_mix_pad_di_40_go => pad_di_40, -- data in from pad
			p_mix_pad_do_12_gi => pad_do_12, -- data out to pad
			p_mix_pad_do_13_gi => pad_do_13, -- data out to pad
			p_mix_pad_do_14_gi => pad_do_14, -- data out to pad
			p_mix_pad_do_15_gi => pad_do_15, -- data out to pad
			p_mix_pad_do_16_gi => pad_do_16, -- data out to pad
			p_mix_pad_do_17_gi => pad_do_17, -- data out to pad
			p_mix_pad_do_18_gi => pad_do_18, -- data out to pad
			p_mix_pad_do_2_gi => pad_do_2, -- data out to pad
			p_mix_pad_do_31_gi => pad_do_31, -- data out to pad
			p_mix_pad_do_32_gi => pad_do_32, -- data out to pad
			p_mix_pad_do_35_gi => pad_do_35, -- data out to pad
			p_mix_pad_do_36_gi => pad_do_36, -- data out to pad
			p_mix_pad_do_39_gi => pad_do_39, -- data out to pad
			p_mix_pad_do_40_gi => pad_do_40, -- data out to pad
			p_mix_pad_en_12_gi => pad_en_12, -- pad output enable
			p_mix_pad_en_13_gi => pad_en_13, -- pad output enable
			p_mix_pad_en_14_gi => pad_en_14, -- pad output enable
			p_mix_pad_en_15_gi => pad_en_15, -- pad output enable
			p_mix_pad_en_16_gi => pad_en_16, -- pad output enable
			p_mix_pad_en_17_gi => pad_en_17, -- pad output enable
			p_mix_pad_en_18_gi => pad_en_18, -- pad output enable
			p_mix_pad_en_2_gi => pad_en_2, -- pad output enable
			p_mix_pad_en_31_gi => pad_en_31, -- pad output enable
			p_mix_pad_en_32_gi => pad_en_32, -- pad output enable
			p_mix_pad_en_35_gi => pad_en_35, -- pad output enable
			p_mix_pad_en_36_gi => pad_en_36, -- pad output enable
			p_mix_pad_en_39_gi => pad_en_39, -- pad output enable
			p_mix_pad_en_40_gi => pad_en_40, -- pad output enable
			p_mix_pad_pu_31_gi => pad_pu_31, -- pull-up control
			p_mix_pad_pu_32_gi => pad_pu_32 -- pull-up control
		);
		-- End of Generated Instance Port Map for pad_pads

		-- Generated Instance Port Map for test_ctrl
		test_ctrl: testctrl_e

		;
		-- End of Generated Instance Port Map for test_ctrl

		-- Generated Instance Port Map for u0_alreg
		u0_alreg: alreg
		port map (

			alarm_time => s_int_alarm_time_ls_min, -- Display storage buffer 0 ls_min
			load_new_a => load_new_a,
			new_alarm_time => s_int_key_buffer_0 -- Display storage buffer 0 ls_min
		);
		-- End of Generated Instance Port Map for u0_alreg

		-- Generated Instance Port Map for u1_alreg
		u1_alreg: alreg
		port map (

			alarm_time => s_int_alarm_time_ms_min, -- Display storage buffer 1 ms_min
			load_new_a => load_new_a,
			new_alarm_time => s_int_key_buffer_1 -- Display storage buffer 1 ms_min
		);
		-- End of Generated Instance Port Map for u1_alreg

		-- Generated Instance Port Map for u2_alreg
		u2_alreg: alreg
		port map (

			alarm_time => s_int_alarm_time_ls_hr, -- Display storage buffer 2 ls_hr
			load_new_a => load_new_a,
			new_alarm_time => s_int_key_buffer_2 -- Display storage buffer 2 ls_hr
		);
		-- End of Generated Instance Port Map for u2_alreg

		-- Generated Instance Port Map for u3_alreg
		u3_alreg: alreg
		port map (

			alarm_time => s_int_alarm_time_ms_hr, -- Display storage buffer 3 ms_hr
			load_new_a => load_new_a,
			new_alarm_time => s_int_key_buffer_3 -- Display storage buffer 3 ms_hr
		);
		-- End of Generated Instance Port Map for u3_alreg

		-- Generated Instance Port Map for u_counter
		u_counter: count4
		port map (

			current_time_ls_hr => s_int_current_time_ls_hr, -- Display storage buffer 2 ls_hr
			current_time_ls_min => s_int_current_time_ls_min, -- Display storage buffer 0 ls_min
			current_time_ms_hr => s_int_current_time_ms_hr, -- Display storage buffer 3 ms_hr
			current_time_ms_min => s_int_current_time_ms_min, -- Display storage buffer 1 ms_min
			load_new_c => load_new_c,
			new_current_time_ls_hr => s_int_key_buffer_2, -- Display storage buffer 2 ls_hr
			new_current_time_ls_min => s_int_key_buffer_0, -- Display storage buffer 0 ls_min
			new_current_time_ms_hr => s_int_key_buffer_3, -- Display storage buffer 3 ms_hr
			new_current_time_ms_min => s_int_key_buffer_1, -- Display storage buffer 1 ms_min
			one_minute => one_minute
		);
		-- End of Generated Instance Port Map for u_counter

		-- Generated Instance Port Map for u_ddrv4
		u_ddrv4: ddrv4
		port map (

			alarm_time_ls_hr => s_int_alarm_time_ls_hr, -- Display storage buffer 2 ls_hr
			alarm_time_ls_min => s_int_alarm_time_ls_min, -- Display storage buffer 0 ls_min
			alarm_time_ms_hr => s_int_alarm_time_ms_hr, -- Display storage buffer 3 ms_hr
			alarm_time_ms_min => s_int_alarm_time_ms_min, -- Display storage buffer 1 ms_min
			current_time_ls_hr => s_int_current_time_ls_hr, -- Display storage buffer 2 ls_hr
			current_time_ls_min => s_int_current_time_ls_min, -- Display storage buffer 0 ls_min
			current_time_ms_hr => s_int_current_time_ms_hr, -- Display storage buffer 3 ms_hr
			current_time_ms_min => s_int_current_time_ms_min, -- Display storage buffer 1 ms_min
			key_buffer_0 => s_int_key_buffer_0, -- Display storage buffer 0 ls_min
			key_buffer_1 => s_int_key_buffer_1, -- Display storage buffer 1 ms_min
			key_buffer_2 => s_int_key_buffer_2, -- Display storage buffer 2 ls_hr
			key_buffer_3 => s_int_key_buffer_3, -- Display storage buffer 3 ms_hr
			p_mix_display_ls_hr_go => s_int_display_ls_hr, -- Display storage buffer 2 ls_hr
			p_mix_display_ls_min_go => s_int_display_ls_min, -- Display storage buffer 0 ls_min
			p_mix_display_ms_hr_go => s_int_display_ms_hr, -- Display storage buffer 3 ms_hr
			p_mix_display_ms_min_go => s_int_display_ms_min, -- Display storage buffer 1 ms_min
			p_mix_sound_alarm_go => sound_alarm,
			show_a => s_int_show_a,
			show_new_time => s_int_show_new_time
		);
		-- End of Generated Instance Port Map for u_ddrv4

		-- Generated Instance Port Map for u_keypad
		u_keypad: keypad
		port map (

			columns => columns,
			rows => rows -- Keypad Output
		);
		-- End of Generated Instance Port Map for u_keypad

		-- Generated Instance Port Map for u_keyscan
		u_keyscan: keyscan
		port map (

			alarm_button => alarm_button,
			columns => columns,
			key => key,
			key_buffer_0 => s_int_key_buffer_0, -- Display storage buffer 0 ls_min
			key_buffer_1 => s_int_key_buffer_1, -- Display storage buffer 1 ms_min
			key_buffer_2 => s_int_key_buffer_2, -- Display storage buffer 2 ls_hr
			key_buffer_3 => s_int_key_buffer_3, -- Display storage buffer 3 ms_hr
			rows => rows, -- Keypad Output
			shift => shift,
			time_button => time_button
		);
		-- End of Generated Instance Port Map for u_keyscan

		-- Generated Instance Port Map for u_timegen
		u_timegen: timegen
		port map (

			one_minute => one_minute,
			one_second => one_sec_pulse,
			stopwatch => stopwatch -- Driven by reset
		);
		-- End of Generated Instance Port Map for u_timegen



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
