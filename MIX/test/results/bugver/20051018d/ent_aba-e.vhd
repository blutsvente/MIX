-- -------------------------------------------------------------
--
--  Entity Declaration for ent_aba
--
-- Generated
--  by:  wig
--  on:  Wed Nov  2 10:48:49 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_aba-e.vhd,v 1.2 2005/11/02 14:29:09 wig Exp $
-- $Date: 2005/11/02 14:29:09 $
-- $Log: ent_aba-e.vhd,v $
-- Revision 1.2  2005/11/02 14:29:09  wig
-- Remove extra ; from port map if port has comment
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.66 2005/10/24 15:43:48 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.38 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ent_aba
--
entity ent_aba is

	-- Generics:
		-- No Generated Generics for Entity ent_aba

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_aba
			data_oe	: out	std_ulogic_vector(31 downto 0);	-- bad conection bits detected
			data_oe_r	: out	std_ulogic_vector(31 downto 0)	-- reverse order
		-- End of Generated Port for Entity ent_aba
		);
end ent_aba;
--
-- End of Generated Entity ent_aba
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
