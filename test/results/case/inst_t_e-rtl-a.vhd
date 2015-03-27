-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_t_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 17:08:41 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../case.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-a.vhd,v 1.2 2007/03/03 17:24:06 wig Exp $
-- $Date: 2007/03/03 17:24:06 $
-- $Log: inst_t_e-rtl-a.vhd,v $
-- Revision 1.2  2007/03/03 17:24:06  wig
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
-- Start of Generated Architecture rtl of inst_t_e
--
architecture rtl of inst_t_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component inst_A_e
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_a_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_a_e
			case_a_p	: out	std_ulogic
		-- End of Generated Port for Entity inst_a_e
		);
	end component;
	-- ---------

	component inst_b_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_b_e
			case_b_p	: in	std_ulogic
		-- End of Generated Port for Entity inst_b_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	case	: std_ulogic; 
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
		-- Generated Instance Port Map for inst_A
		inst_A: inst_A_e

		;

		-- End of Generated Instance Port Map for inst_A

		-- Generated Instance Port Map for inst_a
		inst_a: inst_a_e
		port map (
			case_a_p => case
		);

		-- End of Generated Instance Port Map for inst_a

		-- Generated Instance Port Map for inst_b
		inst_b: inst_b_e
		port map (
			case_b_p => case
		);

		-- End of Generated Instance Port Map for inst_b



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------