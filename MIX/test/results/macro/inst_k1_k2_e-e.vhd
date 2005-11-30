-- -------------------------------------------------------------
--
--  Entity Declaration for inst_k1_k2_e
--
-- Generated
--  by:  wig
--  on:  Wed Nov 30 09:22:45 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../macro.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_k1_k2_e-e.vhd,v 1.3 2005/11/30 14:04:02 wig Exp $
-- $Date: 2005/11/30 14:04:02 $
-- $Log: inst_k1_k2_e-e.vhd,v $
-- Revision 1.3  2005/11/30 14:04:02  wig
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
-- Start of Generated Entity inst_k1_k2_e
--
entity inst_k1_k2_e is

	-- Generics:
		-- No Generated Generics for Entity inst_k1_k2_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_k1_k2_e
			port1	: in	std_ulogic_vector(3 downto 0);	-- Macro test 0 k1_k2
			port2	: in	std_ulogic_vector(3 downto 0);	-- Macro test 0 k1_k2
			port3	: in	std_ulogic_vector(3 downto 0);	-- Macro test 0 k1_k2
			port_mac	: out	std_ulogic; 	-- Macro test 0 k1_k2 __I_AUTO_REDUCED_BUS2SIGNAL
			port_mac_c	: out	std_ulogic_vector(6 downto 0)	-- Macro test 0 k1_k2
		-- End of Generated Port for Entity inst_k1_k2_e
		);
end inst_k1_k2_e;
--
-- End of Generated Entity inst_k1_k2_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
