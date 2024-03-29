-- -------------------------------------------------------------
--
--  Entity Declaration for ent_ae
--
-- Generated
--  by:  wig
--  on:  Wed Nov 30 10:05:42 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -sheet HIER=HIER_MIXED ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_ae-e.vhd,v 1.5 2005/11/30 14:04:19 wig Exp $
-- $Date: 2005/11/30 14:04:19 $
-- $Log: ent_ae-e.vhd,v $
-- Revision 1.5  2005/11/30 14:04:19  wig
-- Updated testcase references
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.71 2005/11/22 11:00:47 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.42 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ent_ae
--
entity ent_ae is

	-- Generics:
		-- No Generated Generics for Entity ent_ae

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_ae
			port_ae_2	: in	std_ulogic_vector(4 downto 0);	-- Use internally test2, no port generated
			port_ae_5	: in	std_ulogic_vector(3 downto 0);	-- Bus, single bits go to outside
			port_ae_6	: in	std_ulogic_vector(3 downto 0);	-- Conflicting definition
			sig_07	: in	std_ulogic_vector(5 downto 0);	-- Conflicting definition, IN false!
			sig_08	: in	std_ulogic_vector(8 downto 2);	-- VHDL intermediate needed (port name)
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);	-- Input Bus
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)	-- Output Bus
		-- End of Generated Port for Entity ent_ae
		);
end ent_ae;
--
-- End of Generated Entity ent_ae
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
