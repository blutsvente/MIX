-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 17:08:41 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../case.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a_1.vhd,v 1.1 2007/03/03 17:24:06 wig Exp $
-- $Date: 2007/03/03 17:24:06 $
-- $Log: inst_a_e-rtl-a_1.vhd,v $
-- Revision 1.1  2007/03/03 17:24:06  wig
-- Updated testcase for case matches. Added filename serialization.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.101 2007/03/01 16:28:38 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component inst_aa_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_aa_e
			case_aa_p	: out	_E_CONNTYPE
		-- End of Generated Port for Entity inst_aa_e
		);
	end component;
	-- ---------

	component inst_ab_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ab_e
			case_ab_p	: in	_E_CONNTYPE
		-- End of Generated Port for Entity inst_ab_e
		);
	end component;
	-- ---------

	component inst_ac_e
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



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

	--
	-- Generated Signal Assignments
	--


	--
	-- Generated Instances and Port Mappings
	--
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
