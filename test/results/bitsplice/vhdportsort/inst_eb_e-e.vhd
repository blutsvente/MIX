-- -------------------------------------------------------------
--
--  Entity Declaration for inst_eb_e
--
-- Generated
--  by:  wig
--  on:  Wed Jun  7 17:05:33 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_eb_e-e.vhd,v 1.2 2006/06/22 07:19:59 wig Exp $
-- $Date: 2006/06/22 07:19:59 $
-- $Log: inst_eb_e-e.vhd,v $
-- Revision 1.2  2006/06/22 07:19:59  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.89 2006/05/23 06:48:05 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.45 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_eb_e
--
entity inst_eb_e is

	-- Generics:
		-- No Generated Generics for Entity inst_eb_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_eb_e
			p_mix_tmi_sbist_fail_12_10_go	: out	std_ulogic_vector(2 downto 0);
			p_mix_c_addr_12_0_gi	: in	std_ulogic_vector(12 downto 0);
			p_mix_c_bus_in_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_eb_e
		);
end inst_eb_e;
--
-- End of Generated Entity inst_eb_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
