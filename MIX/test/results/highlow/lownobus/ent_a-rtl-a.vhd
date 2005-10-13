-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_a
--
-- Generated
--  by:  wig
--  on:  Tue Sep 27 05:17:18 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../highlow.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-rtl-a.vhd,v 1.3 2005/10/13 09:09:45 wig Exp $
-- $Date: 2005/10/13 09:09:45 $
-- $Log: ent_a-rtl-a.vhd,v $
-- Revision 1.3  2005/10/13 09:09:45  wig
-- Added intermediate CONN sheet split
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.58 2005/09/14 14:40:06 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.37 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of ent_a
--
architecture rtl of ent_a is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ent_aa	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ent_aa
			partzero_2	: out	std_ulogic_vector(7 downto 0);
			partzero_22	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_aa
		);
	end component;
	-- ---------

	component ent_ab	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ent_ab
			partzero	: in	std_ulogic_vector(15 downto 0);
			partzero2	: in	std_ulogic_vector(15 downto 0);
			port_low2bus	: in	std_ulogic_vector(5 downto 0);
			port_low3bus	: in	std_ulogic_vector(4 downto 0);
			port_lowbus	: in	std_ulogic_vector(5 downto 0);
			port_lowbus2	: in	std_ulogic_vector(4 downto 0)
		-- End of Generated Port for Entity ent_ab
		);
	end component;
	-- ---------

	component ent_ac	-- 
		-- No Generated Generics

		port (
		-- Generated Port for Entity ent_ac
			partzero_1	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity ent_ac
		);
	end component;
	-- ---------

	component ent_ad	-- 
		-- No Generated Generics

		-- No Generated Port

	end component;
	-- ---------

	component ent_ae	-- 
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
			signal	mix_logic0_bus	: std_ulogic_vector(5 downto 0); 
			constant partzero_c : std_ulogic_vector(1 downto 0) := ( others => '1' ); 
			constant partzero_1c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant partzero_1c : std_ulogic_vector(3 downto 0) := ( others => '0' ); 
			signal	partzero	: std_ulogic_vector(15 downto 0); 
			constant partzero2_c : std_ulogic_vector(1 downto 0) := ( others => '1' ); 
			constant partzero2_1c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant partzero2_2c : std_ulogic_vector(3 downto 0) := ( others => '0' ); 
			signal	partzero2	: std_ulogic_vector(15 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			mix_logic0_bus <= ( others => '0' );
			partzero(10 downto 9) <= partzero_c;
			partzero(6) <= partzero_1c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			partzero(15 downto 12) <= partzero_2c;
			partzero2(10 downto 9) <= partzero2_c;
			partzero2(6) <= partzero2_1c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			partzero2(15 downto 12) <= partzero2_2c;
			partzero2(10 downto 9) <= p_mix_partzero2_10_9_gi(1 downto 0);  -- __I_I_SLICE_PORT
			partzero2(6) <= p_mix_partzero2_6_6_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			partzero2(15 downto 12) <= p_mix_partzero2_15_12_gi(3 downto 0);  -- __I_I_SLICE_PORT
			p_mix_partzero2_5_0_go(5 downto 0) <= partzero2(5 downto 0);  -- __I_O_SLICE_PORT
			p_mix_partzero2_11_11_go <= partzero2(11);  -- __I_O_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			p_mix_partzero2_8_7_go(1 downto 0) <= partzero2(8 downto 7);  -- __I_O_SLICE_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: ent_aa
		port map (

			partzero_2(5 downto 0) => partzero(5 downto 0), -- map parts to high and lowmap parts to high and low inst_aa, single bitmap partzero to inst_aamap...
			partzero_2(7 downto 6) => partzero(8 downto 7), -- map parts to high and lowmap parts to high and low inst_aa, single bitmap partzero to inst_aamap...
			partzero_22(5 downto 0) => partzero2(5 downto 0), -- map parts to high and low, 2map partzero to inst_aa, 2map partzero to inst_aa, 2, 2
			partzero_22(7 downto 6) => partzero2(8 downto 7) -- map parts to high and low, 2map partzero to inst_aa, 2map partzero to inst_aa, 2, 2
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: ent_ab
		port map (
			partzero => partzero, -- map parts to high and lowmap parts to high and low inst_aa, single bitmap partzero to inst_aamap...
			partzero2 => partzero2, -- map parts to high and low, 2map partzero to inst_aa, 2map partzero to inst_aa, 2, 2
			port_low2bus => mix_logic0_bus, -- Map mix_logic0 to a bus, use std_ulogic_vector (X2)Map mix_logic0 to a bus no vectorCorrect mix_...
			port_low3bus => mix_logic0_bus(4 downto 0), -- Map mix_logic0 to a bus, use std_ulogic_vector (X2)Map mix_logic0 to a bus no vectorCorrect mix_...
			port_lowbus => mix_logic0_bus, -- Map mix_logic0 to a bus, use std_ulogic_vector (X2)Map mix_logic0 to a bus no vectorCorrect mix_...
			port_lowbus2 => mix_logic0_bus(4 downto 0) -- Map mix_logic0 to a bus, use std_ulogic_vector (X2)Map mix_logic0 to a bus no vectorCorrect mix_...
		);
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: ent_ac
		port map (

			partzero_1 => partzero(11), -- map parts to high and lowmap parts to high and low inst_aa, single bitmap partzero to inst_aamap...
			partzero_1 => partzero2(11) -- map parts to high and low, 2map partzero to inst_aa, 2map partzero to inst_aa, 2, 2
		);
		-- End of Generated Instance Port Map for inst_ac

		-- Generated Instance Port Map for inst_ad
		inst_ad: ent_ad

		;
		-- End of Generated Instance Port Map for inst_ad

		-- Generated Instance Port Map for inst_ae
		inst_ae: ent_ae

		;
		-- End of Generated Instance Port Map for inst_ae



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
