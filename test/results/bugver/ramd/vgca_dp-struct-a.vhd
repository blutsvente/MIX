-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of vgca_dp
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 19:03:15 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_dp-struct-a.vhd,v 1.2 2005/04/14 06:53:00 wig Exp $
-- $Date: 2005/04/14 06:53:00 $
-- $Log: vgca_dp-struct-a.vhd,v $
-- Revision 1.2  2005/04/14 06:53:00  wig
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
-- Start of Generated Architecture struct of vgca_dp
--
architecture struct of vgca_dp is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component dp_dd	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component dp_ga	-- 
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
		-- Generated Instance Port Map for i_dp_dd
		i_dp_dd: dp_dd

		;
		-- End of Generated Instance Port Map for i_dp_dd

		-- Generated Instance Port Map for i_dp_ga
		i_dp_ga: dp_ga

		;
		-- End of Generated Instance Port Map for i_dp_ga



end struct;

--
--!End of Architecture/s
-- --------------------------------------------------------------