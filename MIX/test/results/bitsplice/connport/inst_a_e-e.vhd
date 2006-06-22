-- -------------------------------------------------------------
--
--  Entity Declaration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Mon Apr 10 13:27:22 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-e.vhd,v 1.1 2006/04/10 15:42:05 wig Exp $
-- $Date: 2006/04/10 15:42:05 $
-- $Log: inst_a_e-e.vhd,v $
-- Revision 1.1  2006/04/10 15:42:05  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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
			unsplice_a1	: out	std_ulogic_vector(127 downto 0);	-- leaves 3 unconnected
			unsplice_a2_all128	: out	std_ulogic_vector(127 downto 0);	-- full 128 bit port
			unsplice_a3_up100	: out	std_ulogic_vector(127 downto 0);	-- connect 100 bits from 0
			unsplice_a4_mid100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_a5_midp100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_bad_a	: out	std_ulogic_vector(127 downto 0);
			unsplice_bad_b	: out	std_ulogic_vector(127 downto 0)
		-- End of Generated Port for Entity inst_a_e
		);
end inst_a_e;
--
-- End of Generated Entity inst_a_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------