-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_e_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar 30 08:23:00 2004
--  cmd: H:\work\mix_new\MIX\mix_0.pl -strip -nodelta ../constant.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_e_e-rtl-a.vhd,v 1.1 2004/04/06 11:10:50 wig Exp $
-- $Date: 2004/04/06 11:10:50 $
-- $Log: inst_e_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:10:50  wig
-- Adding result/constant
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.38 2004/03/25 11:21:34 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.28 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
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
	component inst_ea_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ea_e
			bad_width_p	: in	bit_vector(7 downto 0);
			const_06_p	: in	std_ulogic_vector(6 downto 0);
			const_07_p	: in	std_ulogic_vector(5 downto 0);
			zero_dup_e	: in	std_ulogic
		-- End of Generated Port for Entity inst_ea_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			constant const_06_c : std_ulogic_vector(6 downto 0) := "0001111"; -- __I_ConvConstant: 0xf
			signal const_06 : std_ulogic_vector(6 downto 0);
			constant mix_const_0_c : std_ulogic_vector(5 downto 0) := "001111"; -- __I_ConvConstant: 0xf
			signal mix_const_0 : std_ulogic_vector(5 downto 0);
			constant mix_const_17_c : bit_vector(7 downto 0) := "1010"; -- __I_VectorConv
			signal mix_const_17 : bit_vector(7 downto 0);
			constant mix_const_19_c : std_ulogic := '0';
			signal mix_const_19 : std_ulogic;
			constant mix_const_20_c : std_ulogic := '1';
			signal mix_const_20 : std_ulogic;
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			const_06 <= const_06_c;
			mix_const_0 <= mix_const_0_c;
			mix_const_17 <= mix_const_17_c;
			mix_const_19 <= mix_const_19_c;
			mix_const_20 <= mix_const_20_c;


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_ea
		inst_ea: inst_ea_e
		port map (
			bad_width_p => mix_const_17, -- #!Illegal
			const_06_p => const_06, -- Constant Wire, # take literally, but will not work!
			const_07_p => mix_const_0, -- Constant Wire, # take literally, but will not valid VHDL
			zero_dup_e => mix_const_19, -- #Illegal
			zero_dup_e => mix_const_20 -- #Illegal
		);
		-- End of Generated Instance Port Map for inst_ea



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------