-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_b
--
-- Generated
--  by:  wig
--  on:  Tue Mar 23 10:47:48 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -sheet HIER=HIER_MIXED -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_b-rtl-a.vhd,v 1.1 2004/04/06 10:15:30 wig Exp $
-- $Date: 2004/04/06 10:15:30 $
-- $Log: ent_b-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 10:15:30  wig
-- Adding result/verilog testcase, again
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
--
-- Generator: mix_0.pl Revision: 1.26 , wilfried.gaensheimer@micronas.com
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
		-- Generated Generics for Entity ent_ba
		-- End of Generated Generics for Entity ent_ba
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