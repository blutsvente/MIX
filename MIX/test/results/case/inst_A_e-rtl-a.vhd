-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:55:32 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\case.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_A_e-rtl-a.vhd,v 1.1 2004/04/06 11:13:30 wig Exp $
-- $Date: 2004/04/06 11:13:30 $
-- $Log: inst_A_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:13:30  wig
-- Adding result/case
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
		-- Generated Generics for Entity inst_aa_e
		-- End of Generated Generics for Entity inst_aa_e
		port (
		-- Generated Port for Entity inst_aa_e
			case_aa_p	: out	
		-- End of Generated Port for Entity inst_aa_e
		);
	end component;
	-- ---------

	component inst_ab_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ab_e
			case_ab_p	: in	
		-- End of Generated Port for Entity inst_ab_e
		);
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
			signal	Case	: ; 
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: inst_aa_e
		port map (
			case_aa_p => Case
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: inst_ab_e
		port map (
			case_ab_p => Case
		);
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: inst_ac_e

		;
		-- End of Generated Instance Port Map for inst_ac



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
