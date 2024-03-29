-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of clkgen
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 19:03:15 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: clkgen-struct-a.vhd,v 1.2 2005/04/14 06:52:59 wig Exp $
-- $Date: 2005/04/14 06:52:59 $
-- $Log: clkgen-struct-a.vhd,v $
-- Revision 1.2  2005/04/14 06:52:59  wig
-- Updates: fixed import errors and adjusted I2C parser
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.49 2005/01/27 08:20:30 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.33 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of clkgen
--
architecture struct of clkgen is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component clkgen_sc	-- 
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
		-- Generated Instance Port Map for i_clkgen_sc
		i_clkgen_sc: clkgen_sc

		;
		-- End of Generated Instance Port Map for i_clkgen_sc



end struct;

--
--!End of Architecture/s
-- --------------------------------------------------------------
