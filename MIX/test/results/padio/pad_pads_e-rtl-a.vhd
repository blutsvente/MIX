-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of pad_pads_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:43:46 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pad_pads_e-rtl-a.vhd,v 1.3 2005/07/19 07:13:18 wig Exp $
-- $Date: 2005/07/19 07:13:18 $
-- $Log: pad_pads_e-rtl-a.vhd,v $
-- Revision 1.3  2005/07/19 07:13:18  wig
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
-- Start of Generated Architecture rtl of pad_pads_e
--
architecture rtl of pad_pads_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component w_pad_i	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_pad_i
			di	: out	std_ulogic
		-- End of Generated Port for Entity w_pad_i
		);
	end component;
	-- ---------

	component w_disp	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_disp
			di	: out	std_ulogic;
			do	: in	std_ulogic;
			en	: in	std_ulogic
		-- End of Generated Port for Entity w_disp
		);
	end component;
	-- ---------

	component w_pad_o	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_pad_o
			do	: in	std_ulogic;
			en	: in	std_ulogic
		-- End of Generated Port for Entity w_pad_o
		);
	end component;
	-- ---------

	component w_data2	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_data2
			di	: out	std_ulogic;
			do	: in	std_ulogic;
			en	: in	std_ulogic;
			pu	: in	std_ulogic
		-- End of Generated Port for Entity w_data2
		);
	end component;
	-- ---------

	component w_data3	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_data3
			di	: out	std_ulogic;
			do	: in	std_ulogic;
			en	: in	std_ulogic;
			pu	: in	std_ulogic
		-- End of Generated Port for Entity w_data3
		);
	end component;
	-- ---------

	component w_pad_dir	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_pad_dir
			di	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity w_pad_dir
		);
	end component;
	-- ---------

	component w_pad_dire	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_pad_dire
			di	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			do	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			en	: in	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity w_pad_dire
		);
	end component;
	-- ---------

	component w_osc	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity w_osc
			pd	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			xo	: in	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity w_osc
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	mix_logic1	: std_ulogic; 
			signal	mix_logic0	: std_ulogic; 
			signal	clki2c	: std_ulogic; 
			signal	clki3c	: std_ulogic; 
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
			--  __I_OUT_OPEN signal	pad_dir_di	: std_ulogic; 
			--  __I_OUT_OPEN signal	pad_dir_di38	: std_ulogic; 
			signal	pad_dir_do38	: std_ulogic; 
			signal	pad_dir_en38	: std_ulogic; 
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
			mix_logic1 <= '1';
			mix_logic0 <= '0';
			p_mix_pad_di_1_go <= pad_di_1;  -- __I_O_BIT_PORT
			p_mix_pad_di_12_go <= pad_di_12;  -- __I_O_BIT_PORT
			p_mix_pad_di_13_go <= pad_di_13;  -- __I_O_BIT_PORT
			p_mix_pad_di_14_go <= pad_di_14;  -- __I_O_BIT_PORT
			p_mix_pad_di_15_go <= pad_di_15;  -- __I_O_BIT_PORT
			p_mix_pad_di_16_go <= pad_di_16;  -- __I_O_BIT_PORT
			p_mix_pad_di_17_go <= pad_di_17;  -- __I_O_BIT_PORT
			p_mix_pad_di_18_go <= pad_di_18;  -- __I_O_BIT_PORT
			p_mix_pad_di_31_go <= pad_di_31;  -- __I_O_BIT_PORT
			p_mix_pad_di_32_go <= pad_di_32;  -- __I_O_BIT_PORT
			p_mix_pad_di_33_go <= pad_di_33;  -- __I_O_BIT_PORT
			p_mix_pad_di_34_go <= pad_di_34;  -- __I_O_BIT_PORT
			p_mix_pad_di_39_go <= pad_di_39;  -- __I_O_BIT_PORT
			p_mix_pad_di_40_go <= pad_di_40;  -- __I_O_BIT_PORT
			pad_do_12 <= p_mix_pad_do_12_gi;  -- __I_I_BIT_PORT
			pad_do_13 <= p_mix_pad_do_13_gi;  -- __I_I_BIT_PORT
			pad_do_14 <= p_mix_pad_do_14_gi;  -- __I_I_BIT_PORT
			pad_do_15 <= p_mix_pad_do_15_gi;  -- __I_I_BIT_PORT
			pad_do_16 <= p_mix_pad_do_16_gi;  -- __I_I_BIT_PORT
			pad_do_17 <= p_mix_pad_do_17_gi;  -- __I_I_BIT_PORT
			pad_do_18 <= p_mix_pad_do_18_gi;  -- __I_I_BIT_PORT
			pad_do_2 <= p_mix_pad_do_2_gi;  -- __I_I_BIT_PORT
			pad_do_31 <= p_mix_pad_do_31_gi;  -- __I_I_BIT_PORT
			pad_do_32 <= p_mix_pad_do_32_gi;  -- __I_I_BIT_PORT
			pad_do_35 <= p_mix_pad_do_35_gi;  -- __I_I_BIT_PORT
			pad_do_36 <= p_mix_pad_do_36_gi;  -- __I_I_BIT_PORT
			pad_do_39 <= p_mix_pad_do_39_gi;  -- __I_I_BIT_PORT
			pad_do_40 <= p_mix_pad_do_40_gi;  -- __I_I_BIT_PORT
			pad_en_12 <= p_mix_pad_en_12_gi;  -- __I_I_BIT_PORT
			pad_en_13 <= p_mix_pad_en_13_gi;  -- __I_I_BIT_PORT
			pad_en_14 <= p_mix_pad_en_14_gi;  -- __I_I_BIT_PORT
			pad_en_15 <= p_mix_pad_en_15_gi;  -- __I_I_BIT_PORT
			pad_en_16 <= p_mix_pad_en_16_gi;  -- __I_I_BIT_PORT
			pad_en_17 <= p_mix_pad_en_17_gi;  -- __I_I_BIT_PORT
			pad_en_18 <= p_mix_pad_en_18_gi;  -- __I_I_BIT_PORT
			pad_en_2 <= p_mix_pad_en_2_gi;  -- __I_I_BIT_PORT
			pad_en_31 <= p_mix_pad_en_31_gi;  -- __I_I_BIT_PORT
			pad_en_32 <= p_mix_pad_en_32_gi;  -- __I_I_BIT_PORT
			pad_en_35 <= p_mix_pad_en_35_gi;  -- __I_I_BIT_PORT
			pad_en_36 <= p_mix_pad_en_36_gi;  -- __I_I_BIT_PORT
			pad_en_39 <= p_mix_pad_en_39_gi;  -- __I_I_BIT_PORT
			pad_en_40 <= p_mix_pad_en_40_gi;  -- __I_I_BIT_PORT
			pad_pu_31 <= p_mix_pad_pu_31_gi;  -- __I_I_BIT_PORT
			pad_pu_32 <= p_mix_pad_pu_32_gi;  -- __I_I_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for pad_1
		pad_1: w_pad_i
		port map (

			di => pad_di_1 -- data in from pad
		);
		-- End of Generated Instance Port Map for pad_1

		-- Generated Instance Port Map for pad_12
		pad_12: w_disp
		port map (

			di => pad_di_12, -- data in from pad
			do => pad_do_12, -- data out to pad
			en => pad_en_12 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_12

		-- Generated Instance Port Map for pad_13
		pad_13: w_disp
		port map (

			di => pad_di_13, -- data in from pad
			do => pad_do_13, -- data out to pad
			en => pad_en_13 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_13

		-- Generated Instance Port Map for pad_14
		pad_14: w_disp
		port map (

			di => pad_di_14, -- data in from pad
			do => pad_do_14, -- data out to pad
			en => pad_en_14 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_14

		-- Generated Instance Port Map for pad_15
		pad_15: w_disp
		port map (

			di => pad_di_15, -- data in from pad
			do => pad_do_15, -- data out to pad
			en => pad_en_15 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_15

		-- Generated Instance Port Map for pad_16
		pad_16: w_disp
		port map (

			di => pad_di_16, -- data in from pad
			do => pad_do_16, -- data out to pad
			en => pad_en_16 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_16

		-- Generated Instance Port Map for pad_17
		pad_17: w_disp
		port map (

			di => pad_di_17, -- data in from pad
			do => pad_do_17, -- data out to pad
			en => pad_en_17 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_17

		-- Generated Instance Port Map for pad_18
		pad_18: w_disp
		port map (

			di => pad_di_18, -- data in from pad
			do => pad_do_18, -- data out to pad
			en => pad_en_18 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_18

		-- Generated Instance Port Map for pad_2
		pad_2: w_pad_o
		port map (
			do => pad_do_2, -- data out to pad
			en => pad_en_2 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_2

		-- Generated Instance Port Map for pad_31
		pad_31: w_data2
		port map (

			di => pad_di_31, -- data in from pad
			do => pad_do_31, -- data out to pad
			en => pad_en_31, -- pad output enable
			pu => pad_pu_31 -- pull-up control
		);
		-- End of Generated Instance Port Map for pad_31

		-- Generated Instance Port Map for pad_32
		pad_32: w_data3
		port map (

			di => pad_di_32, -- data in from pad
			do => pad_do_32, -- data out to pad
			en => pad_en_32, -- pad output enable
			pu => pad_pu_32 -- pull-up control
		);
		-- End of Generated Instance Port Map for pad_32

		-- Generated Instance Port Map for pad_33
		pad_33: w_pad_i
		port map (

			di => pad_di_33 -- data in from pad
		);
		-- End of Generated Instance Port Map for pad_33

		-- Generated Instance Port Map for pad_34
		pad_34: w_pad_i
		port map (

			di => pad_di_34 -- data in from pad
		);
		-- End of Generated Instance Port Map for pad_34

		-- Generated Instance Port Map for pad_35
		pad_35: w_pad_o
		port map (
			do => pad_do_35, -- data out to pad
			en => pad_en_35 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_35

		-- Generated Instance Port Map for pad_36
		pad_36: w_pad_o
		port map (
			do => pad_do_36, -- data out to pad
			en => pad_en_36 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_36

		-- Generated Instance Port Map for pad_37
		pad_37: w_pad_dir
		port map (

			di => open -- __I_OUT_OPEN
		);
		-- End of Generated Instance Port Map for pad_37

		-- Generated Instance Port Map for pad_38
		pad_38: w_pad_dire
		port map (

			di => open, -- __I_OUT_OPEN
			do => pad_dir_do38,
			en => pad_dir_en38
		);
		-- End of Generated Instance Port Map for pad_38

		-- Generated Instance Port Map for pad_39
		pad_39: w_disp
		port map (

			di => pad_di_39, -- data in from pad
			do => pad_do_39, -- data out to pad
			en => pad_en_39 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_39

		-- Generated Instance Port Map for pad_40
		pad_40: w_disp
		port map (

			di => pad_di_40, -- data in from pad
			do => pad_do_40, -- data out to pad
			en => pad_en_40 -- pad output enable
		);
		-- End of Generated Instance Port Map for pad_40

		-- Generated Instance Port Map for pad_41
		pad_41: w_osc
		port map (
			pd => mix_logic1,
			xo => clki2c
		);
		-- End of Generated Instance Port Map for pad_41

		-- Generated Instance Port Map for pad_42
		pad_42: w_osc
		port map (
			pd => mix_logic1,
			xo => clki3c
		);
		-- End of Generated Instance Port Map for pad_42

		-- Generated Instance Port Map for pad_43
		pad_43: w_osc
		port map (
			pd => mix_logic0,
			xo => clki3c
		);
		-- End of Generated Instance Port Map for pad_43



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
