-- -------------------------------------------------------------
--
--  Entity Declaration for inst_ab_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar 30 08:23:00 2004
--  cmd: H:\work\mix_new\MIX\mix_0.pl -strip -nodelta ../constant.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ab_e-e.vhd,v 1.1 2004/04/06 11:10:46 wig Exp $
-- $Date: 2004/04/06 11:10:46 $
-- $Log: inst_ab_e-e.vhd,v $
-- Revision 1.1  2004/04/06 11:10:46  wig
-- Adding result/constant
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.38 2004/03/25 11:21:34 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.28 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity inst_ab_e
--
entity inst_ab_e is
        -- Generics:
		-- No Generated Generics for Entity inst_ab_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_ab_e
			const_04	: in	std_ulogic_vector(3 downto 0);
			const_08_p	: in	std_ulogic_vector(4 downto 0);
			const_09_p	: in	std_ulogic_vector(2 downto 0);
			const_10_2	: in	std_ulogic_vector(3 downto 0);
			inst_duo_2	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_ab_e
		);
end inst_ab_e;
--
-- End of Generated Entity inst_ab_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------