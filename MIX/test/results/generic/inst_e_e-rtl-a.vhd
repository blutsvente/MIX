-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_e_e
--
-- Generated
--  by:  wig
--  on:  Wed Nov 30 06:48:17 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../generic.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_e_e-rtl-a.vhd,v 1.3 2005/11/30 14:04:04 wig Exp $
-- $Date: 2005/11/30 14:04:04 $
-- $Log: inst_e_e-rtl-a.vhd,v $
-- Revision 1.3  2005/11/30 14:04:04  wig
-- Updated testcase references
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.71 2005/11/22 11:00:47 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.42 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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
	component inst_ea_e
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
		-- Generated Instance Port Map for inst_ea
		inst_ea: inst_ea_e

		;
		-- End of Generated Instance Port Map for inst_ea



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
