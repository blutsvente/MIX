-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of vgca_mm
--
-- Generated
--  by:  wig
--  on:  Wed Aug  6 13:50:14 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\ramd20030717.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_mm-struct-a.vhd,v 1.1 2004/04/06 11:15:59 wig Exp $
-- $Date: 2004/04/06 11:15:59 $
-- $Log: vgca_mm-struct-a.vhd,v $
-- Revision 1.1  2004/04/06 11:15:59  wig
-- Adding result/bugver
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.22 2003/07/23 13:34:40 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.14 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of vgca_mm
--
architecture struct of vgca_mm is 
	--
	-- Components
	--

	-- Generated Components
	component mm_mm1	-- 
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


	-- Generated Constant Declarations


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for i_mm_mm1
		i_mm_mm1: mm_mm1
		;
		-- End of Generated Instance Port Map for i_mm_mm1



end struct;

--
--!End of Architecture/s
-- --------------------------------------------------------------
