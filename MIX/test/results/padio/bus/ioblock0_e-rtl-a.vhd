-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ioblock0_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock0_e-rtl-a.vhd,v 1.1 2004/04/06 10:44:21 wig Exp $
-- $Date: 2004/04/06 10:44:21 $
-- $Log: ioblock0_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 10:44:21  wig
-- Adding result/padio
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.17 , wilfried.gaensheimer@micronas.com
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
			sel	: in	std_ulogic_vector(3 downto 0)
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
			sel	: in	std_ulogic_vector(3 downto 0)
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
			signal	iosel_0	: std_ulogic(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
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
			iosel_0(0) <= p_mix_iosel_0_0_0_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
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
			sel => iosel_0 -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_data_i1

		-- Generated Instance Port Map for ioc_data_o1
		ioc_data_o1: ioc_g_o
		port map (
			do => data_o1, -- io data
			p_do => pad_do_2, -- data out to pad
			p_en => pad_en_2, -- pad output enable
			sel => iosel_0 -- IO_Select
		);
		-- End of Generated Instance Port Map for ioc_data_o1



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
