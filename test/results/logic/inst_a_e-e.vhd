-- -------------------------------------------------------------
--
--  Entity Declaration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 10:55:02 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../logic.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-e.vhd,v 1.3 2005/07/18 08:59:29 wig Exp $
-- $Date: 2005/07/18 08:59:29 $
-- $Log: inst_a_e-e.vhd,v $
-- Revision 1.3  2005/07/18 08:59:29  wig
-- do not write config for simple logic
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.56 2005/07/15 16:39:38 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_a_e
--
entity inst_a_e is

        -- Generics:
		-- No Generated Generics for Entity inst_a_e


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_a_e
			and_o1	: out	std_ulogic;
			and_o2	: out	std_ulogic_vector(15 downto 0);
			or_o1	: out	std_ulogic;
			or_o2	: out	std_ulogic_vector(15 downto 0);
			wire_bus_i	: in	std_ulogic_vector(7 downto 0);
			wire_bus_o	: out	std_ulogic_vector(7 downto 0);
			wire_i	: in	std_ulogic;
			wire_o	: out	std_ulogic
		-- End of Generated Port for Entity inst_a_e
		);
end inst_a_e;
--
-- End of Generated Entity inst_a_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------