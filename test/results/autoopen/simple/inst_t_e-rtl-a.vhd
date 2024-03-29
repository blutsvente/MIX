-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_t_e
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 10:32:44 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../autoopen.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-a.vhd,v 1.2 2005/07/15 16:20:08 wig Exp $
-- $Date: 2005/07/15 16:20:08 $
-- $Log: inst_t_e-rtl-a.vhd,v $
-- Revision 1.2  2005/07/15 16:20:08  wig
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
-- Start of Generated Architecture rtl of inst_t_e
--
architecture rtl of inst_t_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_a_e	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity inst_a_e
			s_open_i	: in	std_ulogic;
			s_open_o	: out	std_ulogic
		-- End of Generated Port for Entity inst_a_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	s_open_i	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_open_o	: std_ulogic; 
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
		-- Generated Instance Port Map for inst_a
		inst_a: inst_a_e
		port map (

			s_open_i => s_open_i, -- open input
			s_open_o => open -- open output -- __I_OUT_OPEN
		);
		-- End of Generated Instance Port Map for inst_a



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
