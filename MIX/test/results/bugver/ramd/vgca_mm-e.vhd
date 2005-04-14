-- -------------------------------------------------------------
--
--  Entity Declaration for vgca_mm
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 19:03:15 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_mm-e.vhd,v 1.2 2005/04/14 06:53:00 wig Exp $
-- $Date: 2005/04/14 06:53:00 $
-- $Log: vgca_mm-e.vhd,v $
-- Revision 1.2  2005/04/14 06:53:00  wig
-- Updates: fixed import errors and adjusted I2C parser
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.49 2005/01/27 08:20:30 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.33 , wilfried.gaensheimer@micronas.com
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
