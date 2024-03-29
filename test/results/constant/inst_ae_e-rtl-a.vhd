-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_ae_e
--
-- Generated
--  by:  wig
--  on:  Wed Aug 18 12:41:45 2004
--  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../constant.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ae_e-rtl-a.vhd,v 1.4 2005/10/06 11:16:07 wig Exp $
-- $Date: 2005/10/06 11:16:07 $
-- $Log: inst_ae_e-rtl-a.vhd,v $
-- Revision 1.4  2005/10/06 11:16:07  wig
-- Got testcoverage up, fixed generic problem, prepared report
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.45 2004/08/09 15:48:14 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.32 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_ae_e
--
architecture rtl of inst_ae_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_aea_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_aea_e
			bus20040728_altop_i	: in	std_ulogic_vector(7 downto 0);
			bus20040728_top_i	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_aea_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	bus20040728_altop	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	bus20040728_top	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			bus20040728_altop <= bus20040728_altop_i;  -- __I_I_BUS_PORT
			--!wig: ERROR: bus20040728_top(7 downto 4) <= p_mix_bus20040728_top_7_4_gi(3 downto 0);  -- __I_I_SLICE_PORT
			bus20040728_top <= p_mix_bus20040728_top_7_0_gi;  -- __I_I_SLICE_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aea
		inst_aea: inst_aea_e
		port map (
			bus20040728_altop_i => bus20040728_altop,
			bus20040728_top_i => bus20040728_top
		);
		-- End of Generated Instance Port Map for inst_aea



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
