-- -------------------------------------------------------------
--
--  Entity Declaration for padframe
--
-- Generated
--  by:  wig
--  on:  Thu Jul  6 16:43:58 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: padframe-e.vhd,v 1.3 2006/07/10 07:30:09 wig Exp $
-- $Date: 2006/07/10 07:30:09 $
-- $Log: padframe-e.vhd,v $
-- Revision 1.3  2006/07/10 07:30:09  wig
-- Updated more testcasess.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.91 2006/07/04 12:22:35 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.46 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity padframe
--
entity padframe is

	-- Generics:
		-- No Generated Generics for Entity padframe

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity padframe
			mix_logic0_0	: in	std_ulogic;	-- padin
			mix_logic0_bus_4	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_i	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_i2	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_o	: out	std_ulogic_vector(31 downto 0);	-- padout
			ramd_o2	: out	std_ulogic_vector(31 downto 0);	-- padout
			ramd_o3	: out	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity padframe
		);
end padframe;
--
-- End of Generated Entity padframe
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
