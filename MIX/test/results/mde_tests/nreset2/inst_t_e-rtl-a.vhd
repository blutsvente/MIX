-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_t_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:59 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-a.vhd,v 1.1 2004/04/06 10:50:56 wig Exp $
-- $Date: 2004/04/06 10:50:56 $
-- $Log: inst_t_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 10:50:56  wig
-- Adding result/mde_tests
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
		-- No Generated Port
	end component;
	-- ---------

	component inst_b_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_c_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_d_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_e_e	-- 
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
		-- Generated Instance Port Map for inst_a
		inst_a: inst_a_e

		;
		-- End of Generated Instance Port Map for inst_a

		-- Generated Instance Port Map for inst_b
		inst_b: inst_b_e

		;
		-- End of Generated Instance Port Map for inst_b

		-- Generated Instance Port Map for inst_c
		inst_c: inst_c_e

		;
		-- End of Generated Instance Port Map for inst_c

		-- Generated Instance Port Map for inst_d
		inst_d: inst_d_e

		;
		-- End of Generated Instance Port Map for inst_d

		-- Generated Instance Port Map for inst_e
		inst_e: inst_e_e

		;
		-- End of Generated Instance Port Map for inst_e



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------