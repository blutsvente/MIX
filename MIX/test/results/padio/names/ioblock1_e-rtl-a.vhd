-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ioblock1_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:56:34 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock1_e-rtl-a.vhd,v 1.3 2005/07/19 07:13:11 wig Exp $
-- $Date: 2005/07/19 07:13:11 $
-- $Log: ioblock1_e-rtl-a.vhd,v $
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
-- Start of Generated Architecture rtl of ioblock1_e
--
architecture rtl of ioblock1_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ioc_r_io	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioc_r_io
			di	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			do	: in	std_ulogic_vector(4 downto 0);
			en	: in	std_ulogic_vector(4 downto 0);
			p_di	: in	std_ulogic;
			p_do	: out	std_ulogic;
			p_en	: out	std_ulogic;
			sel	: in	std_ulogic_vector(4 downto 0)
		-- End of Generated Port for Entity ioc_r_io
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	di2	: std_ulogic_vector(8 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	disp2	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	disp2_en	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ls_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_hr	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	display_ms_min	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_disp	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ls_hr	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ls_min	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ms_hr	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_ms_min	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_12	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_13	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_14	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_15	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_16	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_17	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_18	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
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
			iosel_disp <= p_mix_iosel_disp_gi;  -- __I_I_BIT_PORT
			iosel_ls_hr <= p_mix_iosel_ls_hr_gi;  -- __I_I_BIT_PORT
			iosel_ls_min <= p_mix_iosel_ls_min_gi;  -- __I_I_BIT_PORT
			iosel_ms_hr <= p_mix_iosel_ms_hr_gi;  -- __I_I_BIT_PORT
			iosel_ms_min <= p_mix_iosel_ms_min_gi;  -- __I_I_BIT_PORT
			pad_di_12 <= p_mix_pad_di_12_gi;  -- __I_I_BIT_PORT
			pad_di_13 <= p_mix_pad_di_13_gi;  -- __I_I_BIT_PORT
			pad_di_14 <= p_mix_pad_di_14_gi;  -- __I_I_BIT_PORT
			pad_di_15 <= p_mix_pad_di_15_gi;  -- __I_I_BIT_PORT
			pad_di_16 <= p_mix_pad_di_16_gi;  -- __I_I_BIT_PORT
			pad_di_17 <= p_mix_pad_di_17_gi;  -- __I_I_BIT_PORT
			pad_di_18 <= p_mix_pad_di_18_gi;  -- __I_I_BIT_PORT
			p_mix_pad_do_12_go <= pad_do_12;  -- __I_O_BIT_PORT
			p_mix_pad_do_13_go <= pad_do_13;  -- __I_O_BIT_PORT
			p_mix_pad_do_14_go <= pad_do_14;  -- __I_O_BIT_PORT
			p_mix_pad_do_15_go <= pad_do_15;  -- __I_O_BIT_PORT
			p_mix_pad_do_16_go <= pad_do_16;  -- __I_O_BIT_PORT
			p_mix_pad_do_17_go <= pad_do_17;  -- __I_O_BIT_PORT
			p_mix_pad_do_18_go <= pad_do_18;  -- __I_O_BIT_PORT
			p_mix_pad_en_12_go <= pad_en_12;  -- __I_O_BIT_PORT
			p_mix_pad_en_13_go <= pad_en_13;  -- __I_O_BIT_PORT
			p_mix_pad_en_14_go <= pad_en_14;  -- __I_O_BIT_PORT
			p_mix_pad_en_15_go <= pad_en_15;  -- __I_O_BIT_PORT
			p_mix_pad_en_16_go <= pad_en_16;  -- __I_O_BIT_PORT
			p_mix_pad_en_17_go <= pad_en_17;  -- __I_O_BIT_PORT
			p_mix_pad_en_18_go <= pad_en_18;  -- __I_O_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for ioc_disp_2
		ioc_disp_2: ioc_r_io
		port map (

			di => di2(0), -- io data
			do(0) => disp2(0), -- io data
			do(1) => display_ls_min(0), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(0), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(0), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(0), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(0), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_12, -- data in from pad
			p_do => pad_do_12, -- data out to pad
			p_en => pad_en_12, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_2

		-- Generated Instance Port Map for ioc_disp_3
		ioc_disp_3: ioc_r_io
		port map (

			di => di2(1), -- io data
			do(0) => disp2(1), -- io data
			do(1) => display_ls_min(1), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(1), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(1), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(1), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(1), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_13, -- data in from pad
			p_do => pad_do_13, -- data out to pad
			p_en => pad_en_13, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_3

		-- Generated Instance Port Map for ioc_disp_4
		ioc_disp_4: ioc_r_io
		port map (

			di => di2(3), -- io data
			do(0) => disp2(3), -- io data
			do(1) => display_ls_min(2), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(2), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(2), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(2), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(3), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_14, -- data in from pad
			p_do => pad_do_14, -- data out to pad
			p_en => pad_en_14, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_4

		-- Generated Instance Port Map for ioc_disp_5
		ioc_disp_5: ioc_r_io
		port map (

			di => di2(4), -- io data
			do(0) => disp2(4), -- io data
			do(1) => display_ls_min(3), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(3), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(3), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(3), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(4), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_15, -- data in from pad
			p_do => pad_do_15, -- data out to pad
			p_en => pad_en_15, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_5

		-- Generated Instance Port Map for ioc_disp_6
		ioc_disp_6: ioc_r_io
		port map (

			di => di2(5), -- io data
			do(0) => disp2(5), -- io data
			do(1) => display_ls_min(4), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(4), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(4), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(4), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(5), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_16, -- data in from pad
			p_do => pad_do_16, -- data out to pad
			p_en => pad_en_16, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_6

		-- Generated Instance Port Map for ioc_disp_7
		ioc_disp_7: ioc_r_io
		port map (

			di => di2(6), -- io data
			do(0) => disp2(6), -- io data
			do(1) => display_ls_min(5), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(5), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(5), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(5), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(6), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_17, -- data in from pad
			p_do => pad_do_17, -- data out to pad
			p_en => pad_en_17, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_7

		-- Generated Instance Port Map for ioc_disp_8
		ioc_disp_8: ioc_r_io
		port map (

			di => di2(7), -- io data
			do(0) => disp2(7), -- io data
			do(1) => display_ls_min(6), -- Display storage buffer 0 ls_min
			do(2) => display_ls_hr(6), -- Display storage buffer 2 ls_hr
			do(3) => display_ms_hr(6), -- Display storage buffer 3 ms_hr
			do(4) => display_ms_min(6), -- Display storage buffer 1 ms_min
			en(0) => disp2_en(7), -- io data
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(2) => display_ls_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			en(4) => display_ms_en, -- __I_BIT_TO_BUSPORT -- io_enable
			p_di => pad_di_18, -- data in from pad
			p_do => pad_do_18, -- data out to pad
			p_en => pad_en_18, -- pad output enable
			sel(0) => iosel_disp, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_ls_min, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_ls_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_ms_hr, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_ms_min -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_disp_8



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
