-- -------------------------------------------------------------
--
--  Entity Declaration for inst_b_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:56:41 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\open.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_b_e-e.vhd,v 1.1 2004/04/06 10:45:49 wig Exp $
-- $Date: 2004/04/06 10:45:49 $
-- $Log: inst_b_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:45:49  wig
-- Adding result/open
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
-- Start of Generated Entity inst_b_e
--
entity inst_b_e is
        -- Generics:
		-- No Generated Generics for Entity inst_b_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_b_e
			mix_key_open	: out	std_ulogic;
			non_open	: in	std_ulogic_vector(2 downto 0);
			non_open_bit	: in	std_ulogic;
			open_bit_2	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			open_bit_3	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			open_bit_4	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity inst_b_e
		);
end inst_b_e;
--
-- End of Generated Entity inst_b_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
