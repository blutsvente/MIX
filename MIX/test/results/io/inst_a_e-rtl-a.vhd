-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:55:45 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\io.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.1 2004/04/06 11:04:58 wig Exp $
-- $Date: 2004/04/06 11:04:58 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:04:58  wig
-- Adding result/io
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
-- Start of Generated Architecture rtl of inst_a_e
--
architecture rtl of inst_a_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_aa_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_aa_e
			sig_in_01_p	: in	std_ulogic;
			sig_in_03_p	: in	std_ulogic_vector(7 downto 0);
			sig_io_out_05_p	: inout	std_ulogic_vector(5 downto 0);
			sig_io_out_06_p	: inout	std_ulogic_vector(6 downto 0);
			sig_out_02_p	: out	std_ulogic;
			sig_out_04_p	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_aa_e
		);
	end component;
	-- ---------

	component inst_ab_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_ac_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	sig_in_01	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_in_03	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_io_05	: std_ulogic_vector(5 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_io_06	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_out_02	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_out_04	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			sig_in_01 <= p_mix_sig_in_01_gi;  -- __I_I_BIT_PORT
			sig_in_03 <= p_mix_sig_in_03_gi;  -- __I_I_BUS_PORT
			sig_io_05 <= p_mix_sig_io_05_gc;  -- __I_I_BUS_PORT
			sig_io_06 <= p_mix_sig_io_06_gc;  -- __I_I_BUS_PORT
			p_mix_sig_out_02_go <= sig_out_02;  -- __I_O_BIT_PORT
			p_mix_sig_out_04_go <= sig_out_04;  -- __I_O_BUS_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: inst_aa_e
		port map (
			sig_in_01_p => sig_in_01,
			sig_in_03_p => sig_in_03,
			sig_io_out_05_p => sig_io_05,
			sig_io_out_06_p => sig_io_06,
			sig_out_02_p => sig_out_02,
			sig_out_04_p => sig_out_04
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: inst_ab_e

		;
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: inst_ac_e

		;
		-- End of Generated Instance Port Map for inst_ac



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------