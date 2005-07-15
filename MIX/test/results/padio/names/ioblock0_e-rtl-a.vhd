-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ioblock0_e
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 14:43:23 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock0_e-rtl-a.vhd,v 1.2 2005/07/15 16:20:02 wig Exp $
-- $Date: 2005/07/15 16:20:02 $
-- $Log: ioblock0_e-rtl-a.vhd,v $
-- Revision 1.2  2005/07/15 16:20:02  wig
-- Update all testcases; still problems though
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.55 2005/07/13 15:38:34 wig Exp 
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
-- Start of Generated Architecture rtl of ioblock0_e
--
architecture rtl of ioblock0_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ioc_g_i	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioc_g_i
			di	: out	std_ulogic_vector(7 downto 0);
			p_di	: in	std_ulogic;
			sel	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ioc_g_i
		);
	end component;
	-- ---------

	component ioc_g_o	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ioc_g_o
			do	: in	std_ulogic_vector(7 downto 0);
			p_do	: out	std_ulogic;
			p_en	: out	std_ulogic;
			sel	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ioc_g_o
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	data_i1	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	data_o1	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_0	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_1	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_3	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_4	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_5	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_6	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	iosel_7	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_di_1	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_do_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pad_en_2	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			p_mix_data_i1_go <= data_i1;  -- __I_O_BUS_PORT
			data_o1 <= p_mix_data_o1_gi;  -- __I_I_BUS_PORT
			iosel_0 <= p_mix_iosel_0_gi;  -- __I_I_BIT_PORT
			iosel_1 <= p_mix_iosel_1_gi;  -- __I_I_BIT_PORT
			iosel_2 <= p_mix_iosel_2_gi;  -- __I_I_BIT_PORT
			iosel_3 <= p_mix_iosel_3_gi;  -- __I_I_BIT_PORT
			iosel_4 <= p_mix_iosel_4_gi;  -- __I_I_BIT_PORT
			iosel_5 <= p_mix_iosel_5_gi;  -- __I_I_BIT_PORT
			iosel_6 <= p_mix_iosel_6_gi;  -- __I_I_BIT_PORT
			iosel_7 <= p_mix_iosel_7_gi;  -- __I_I_BIT_PORT
			pad_di_1 <= p_mix_pad_di_1_gi;  -- __I_I_BIT_PORT
			p_mix_pad_do_2_go <= pad_do_2;  -- __I_O_BIT_PORT
			p_mix_pad_en_2_go <= pad_en_2;  -- __I_O_BIT_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for ioc_data_i1
		ioc_data_i1: ioc_g_i
		port map (

			di => data_i1, -- io data
			p_di => pad_di_1, -- data in from pad
			sel(0) => iosel_0, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_1, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_2, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_3, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_4, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(5) => iosel_5, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(6) => iosel_6, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(7) => iosel_7 -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_data_i1

		-- Generated Instance Port Map for ioc_data_o1
		ioc_data_o1: ioc_g_o
		port map (

			do => data_o1, -- io data
			p_do => pad_do_2, -- data out to pad
			p_en => pad_en_2, -- pad output enable
			sel(0) => iosel_0, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(1) => iosel_1, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(2) => iosel_2, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(3) => iosel_3, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(4) => iosel_4, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(5) => iosel_5, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(6) => iosel_6, -- __I_BIT_TO_BUSPORT -- IO_Select
			sel(7) => iosel_7 -- __I_BIT_TO_BUSPORT -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_data_o1



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
