-- -------------------------------------------------------------
--
--  Entity Declaration for inst_k1_k2_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:56:56 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\macro.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_k1_k2_e-e.vhd,v 1.1 2004/04/06 10:52:50 wig Exp $
-- $Date: 2004/04/06 10:52:50 $
-- $Log: inst_k1_k2_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:52:50  wig
-- Adding result/macro
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.17 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
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
			port1	: in	std_ulogic_vector(3 downto 0);
			port2	: in	std_ulogic_vector(3 downto 0);
			port3	: in	std_ulogic_vector(3 downto 0);
			port_mac	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			port_mac_c	: out	std_ulogic_vector(6 downto 0)
		-- End of Generated Port for Entity inst_k1_k2_e
		);
end inst_k1_k2_e;
--
-- End of Generated Entity inst_k1_k2_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
