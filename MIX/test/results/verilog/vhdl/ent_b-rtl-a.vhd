-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_b
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 15:11:01 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -sheet HIER=HIER_VHDL -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_b-rtl-a.vhd,v 1.2 2005/07/15 16:20:03 wig Exp $
-- $Date: 2005/07/15 16:20:03 $
-- $Log: ent_b-rtl-a.vhd,v $
-- Revision 1.2  2005/07/15 16:20:03  wig
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
-- Start of Generated Architecture rtl of ent_b
--
architecture rtl of ent_b is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ent_ba	-- 
		-- No Generated Generics

		-- No Generated Port

	end component;
	-- ---------

	component ent_bb	-- 
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
