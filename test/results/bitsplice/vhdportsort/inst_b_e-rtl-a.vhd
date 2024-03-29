-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_b_e
--
-- Generated
--  by:  wig
--  on:  Wed Jun  7 17:05:33 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_b_e-rtl-a.vhd,v 1.2 2006/06/22 07:19:59 wig Exp $
-- $Date: 2006/06/22 07:19:59 $
-- $Log: inst_b_e-rtl-a.vhd,v $
-- Revision 1.2  2006/06/22 07:19:59  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.89 2006/05/23 06:48:05 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.45 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_b_e
--
architecture rtl of inst_b_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component ent_ba
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component ent_bb
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



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

	--
	-- Generated Signal Assignments
	--


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_ba
		inst_ba: ent_ba

		;

		-- End of Generated Instance Port Map for inst_ba

		-- Generated Instance Port Map for inst_bb
		inst_bb: ent_bb

		;

		-- End of Generated Instance Port Map for inst_bb



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
