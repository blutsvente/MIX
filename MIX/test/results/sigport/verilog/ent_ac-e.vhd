-- -------------------------------------------------------------
--
--  Entity Declaration for ent_ac
--
-- Generated
--  by:  wig
--  on:  Mon Oct 13 10:23:45 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_ac-e.vhd,v 1.1 2003/12/22 08:40:37 wig Exp $
-- $Date: 2003/12/22 08:40:37 $
-- $Log: ent_ac-e.vhd,v $
-- Revision 1.1  2003/12/22 08:40:37  wig
-- Added testcase bitsplice and sigport.
--
-- Revision 1.1  2003/11/27 09:16:01  abauer
-- *** empty log message ***
--
-- Revision 1.2  2003/10/13 08:58:38  wig
-- Add lots of testcases:
-- padio
-- padio2
-- verilog
-- autoopen
-- typecast
-- ....
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.27 2003/09/08 15:14:24 wig Exp 
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
-- Start of Generated Entity ent_ac
--
entity ent_ac is
        -- Generics:
		-- No Generated Generics for Entity ent_ac

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_ac
			port_ac_2	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity ent_ac
		);
end ent_ac;
--
-- End of Generated Entity ent_ac
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
