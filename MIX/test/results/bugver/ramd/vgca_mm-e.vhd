-- -------------------------------------------------------------
--
--  Entity Declaration for vgca_mm
--
-- Generated
--  by:  wig
--  on:  Wed Aug  6 13:50:14 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\ramd20030717.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_mm-e.vhd,v 1.1 2004/04/06 11:15:58 wig Exp $
-- $Date: 2004/04/06 11:15:58 $
-- $Log: vgca_mm-e.vhd,v $
-- Revision 1.1  2004/04/06 11:15:58  wig
-- Adding result/bugver
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.22 2003/07/23 13:34:40 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.14 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity vgca_mm
--
entity vgca_mm is
        -- Generics:
		-- No Generated Generics for Entity vgca_mm

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity vgca_mm
			ramd_i	: in	std_ulogic_vector(31 downto 0);
			ramd_i2	: in	std_ulogic_vector(31 downto 0);
			ramd_i3	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity vgca_mm
		);
end vgca_mm;
--
-- End of Generated Entity vgca_mm
--

--
--!End of Entity/ies
-- --------------------------------------------------------------