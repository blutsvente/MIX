-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_a
--
-- Generated
--  by:  wig
--  on:  Tue Jul  8 18:15:59 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\highlow.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent-a-rtl-a.vhd,v 1.1 2004/04/06 11:07:25 wig Exp $
-- $Date: 2004/04/06 11:07:25 $
-- $Log: ent-a-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:07:25  wig
-- Adding result/highlow
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.18 2003/06/05 14:48:01 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.12 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
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
	--
	-- Components
	--

	-- Generated Components
	component ent_aa
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_aa
			high_bus_3_0	: in	std_ulogic_vector(3 downto 0);
			low_bit_aa	: in	std_ulogic;
			mix_logic0_bus	: in	std_ulogic_vector(3 downto 0);
			mix_logic1	: in	std_ulogic;
			part_zero	: out	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity ent_aa
		);
	end component;
	-- ---------

	component ent_ab
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_ab
			low_bus_6_0	: in	std_ulogic_vector(6 downto 0);
			port_part_zero_u	: in	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity ent_ab
		);
	end component;
	-- ---------

	component ent_ac
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component ent_ad
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component ent_ae
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
			signal	mix_logic1	: std_ulogic; 
			signal	mix_logic1_bus	: std_ulogic_vector(3 downto 0); 
			signal	mix_logic0	: std_ulogic; 
			signal	mix_logic0_bus	: std_ulogic_vector(6 downto 0); 
			signal	part_zero	: std_ulogic_vector(3 downto 0); 
		--
		-- End of Generated Signal List
		--


	-- Generated Constant Declarations


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			mix_logic1 <= '1';
			mix_logic1_bus <= ( others => '1' );
			mix_logic0 <= '0';
			mix_logic0_bus <= ( others => '0' );


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: ent_aa
		port map (
			high_bus_3_0 => mix_logic1_bus,
			low_bit_aa => mix_logic0,
			mix_logic0_bus => mix_logic0_bus(3 downto 0),
			mix_logic1 => mix_logic1,
			part_zero => part_zero
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: ent_ab
		port map (
			low_bus_6_0 => mix_logic0_bus,
			port_part_zero_u(1 downto 0) => part_zero(3 downto 2),
			port_part_zero_u(3 downto 2) => mix_logic0_bus(1 downto 0)
		);
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: ent_ac
		;
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
