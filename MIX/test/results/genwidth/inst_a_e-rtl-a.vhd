-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Thu Dec 18 10:32:49 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\genwidth.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.1 2004/04/06 11:08:17 wig Exp $
-- $Date: 2004/04/06 11:08:17 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:08:17  wig
-- Adding result/genwidth
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Revision: 1.24 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_a_e
--
architecture rtl of inst_a_e is 

	-- Generated Constant Declarations
		constant width : integer := 9; -- __I_PARAMETER


	--
	-- Components
	--

	-- Generated Components
	component inst_aa_e	-- 
		generic (
		-- Generated Generics for Entity inst_aa_e
			width	: integer	:= 8
		-- End of Generated Generics for Entity inst_aa_e
		);
		port (
		-- Generated Port for Entity inst_aa_e
			y_p_i	: out	std_ulogic_vector(width - 1 downto 0)
		-- End of Generated Port for Entity inst_aa_e
		);
	end component;
	-- ---------

	component inst_ab_e	-- 
		generic (
		-- Generated Generics for Entity inst_ab_e
			width	: integer	:= 8
		-- End of Generated Generics for Entity inst_ab_e
		);
		port (
		-- Generated Port for Entity inst_ab_e
			y_p0_i	: in	std_ulogic_vector(width - 1 downto 0)
		-- End of Generated Port for Entity inst_ab_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	y_c422444	: std_ulogic_vector(width - 1 downto 0); 
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
		-- Generated Instance Port Map for inst_aa
		inst_aa: inst_aa_e
		generic map (
			width => 9
		)
		port map (
			y_p_i => y_c422444
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: inst_ab_e
		generic map (
			width => 9
		)
		port map (
			y_p0_i => y_c422444
		);
		-- End of Generated Instance Port Map for inst_ab



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------