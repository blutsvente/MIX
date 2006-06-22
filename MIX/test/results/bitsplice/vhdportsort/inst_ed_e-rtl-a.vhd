-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_ed_e
--
-- Generated
--  by:  wig
--  on:  Wed Jun  7 17:05:33 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ed_e-rtl-a.vhd,v 1.2 2006/06/22 07:19:59 wig Exp $
-- $Date: 2006/06/22 07:19:59 $
-- $Log: inst_ed_e-rtl-a.vhd,v $
-- Revision 1.2  2006/06/22 07:19:59  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.89 2006/05/23 06:48:05 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.45 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_ed_e
--
architecture rtl of inst_ed_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component inst_eda_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_eda_e
		-- End of Generated Generics for Entity inst_eda_e
		-- No Generated Port
	end component;
	-- ---------

	component inst_edb_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_edb_e
		-- End of Generated Generics for Entity inst_edb_e
		port (
		-- Generated Port for Entity inst_edb_e
			c_add	: in	std_ulogic_vector(12 downto 0);
			c_bus_in	: in	std_ulogic_vector(31 downto 0)	-- CBUSinterface
		-- End of Generated Port for Entity inst_edb_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	c_addr	: std_ulogic_vector(12 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	c_bus_in	: std_ulogic_vector(31 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
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
		c_addr	<=	p_mix_c_addr_12_0_gi;  -- __I_I_BUS_PORT
		c_bus_in	<=	p_mix_c_bus_in_31_0_gi;  -- __I_I_BUS_PORT


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_eda
		inst_eda: inst_eda_e

		;

		-- End of Generated Instance Port Map for inst_eda

		-- Generated Instance Port Map for inst_edb
		inst_edb: inst_edb_e
		port map (
			c_add => c_addr,
			c_bus_in => c_bus_in	-- CBUSinterfacecpui/finputsCPUInterface (X2)C-BusinterfaceCPUinterface
		);

		-- End of Generated Instance Port Map for inst_edb



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
