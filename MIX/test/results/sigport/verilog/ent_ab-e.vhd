-- -------------------------------------------------------------
--
--  Entity Declaration for ent_ab
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 16:37:20 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_ab-e.vhd,v 1.3 2005/07/15 16:20:04 wig Exp $
-- $Date: 2005/07/15 16:20:04 $
-- $Log: ent_ab-e.vhd,v $
-- Revision 1.3  2005/07/15 16:20:04  wig
-- Update all testcases; still problems though
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.55 2005/07/13 15:38:34 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ent_ab
--
entity ent_ab is

        -- Generics:
		-- No Generated Generics for Entity ent_ab


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_ab
			port_ab_1	: in	std_ulogic;
			port_ab_2	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			sig_13	: in	std_ulogic_vector(4 downto 0)
		-- End of Generated Port for Entity ent_ab
		);
end ent_ab;
--
-- End of Generated Entity ent_ab
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
