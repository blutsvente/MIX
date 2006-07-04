-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Mon Jun 26 16:29:28 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../genwidth.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.4 2006/07/04 09:54:11 wig Exp $
-- $Date: 2006/07/04 09:54:11 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.4  2006/07/04 09:54:11  wig
-- Update more testcases, add configuration/cfgfile
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.90 2006/06/22 07:13:21 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.46 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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

	--
	-- Generated Constant Declarations
	--
		constant width : integer := 9; -- __I_PARAMETER


	--
	-- Generated Components
	--
	component inst_aa_e
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

	component inst_ab_e
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

	component inst_ac_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ac_e
		-- End of Generated Generics for Entity inst_ac_e
		port (
		-- Generated Port for Entity inst_ac_e
			defwidth	: in	std_ulogic_vector(`dwidth - 1 downto 0)
		-- End of Generated Port for Entity inst_ac_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	y_c422444	: std_ulogic_vector(width - 1 downto 0); 
		-- __I_NODRV_I signal	y_defwidth	: std_ulogic_vector(`dwidth - 1 downto 0); 
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

		-- Generated Instance Port Map for inst_ac
		inst_ac: inst_ac_e
		port map (
			-- __I_NODRV_I defwidth =>  __nodrv__/y_defwidth
		);

		-- End of Generated Instance Port Map for inst_ac



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
