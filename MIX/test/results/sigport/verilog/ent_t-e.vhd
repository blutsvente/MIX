-- -------------------------------------------------------------
--
--  Entity Declaration for ent_t
--
-- Generated
--  by:  wig
--  on:  Mon Oct 13 10:23:45 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-e.vhd,v 1.1 2003/12/22 08:40:39 wig Exp $
-- $Date: 2003/12/22 08:40:39 $
-- $Log: ent_t-e.vhd,v $
-- Revision 1.1  2003/12/22 08:40:39  wig
-- Added testcase bitsplice and sigport.
--
-- Revision 1.1  2003/11/27 09:16:01  abauer
-- *** empty log message ***
--
-- Revision 1.2  2003/10/13 08:58:40  wig
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
-- Start of Generated Entity ent_t
--
entity ent_t is
        -- Generics:
		-- No Generated Generics for Entity ent_t

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_t
			sig_i_a	: in	std_ulogic;
			sig_i_a2	: in	std_ulogic;
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);
			sig_o_a	: out	std_ulogic;
			sig_o_a2	: out	std_ulogic;
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_t
		);
end ent_t;
--
-- End of Generated Entity ent_t
--

--
--!End of Entity/ies
-- --------------------------------------------------------------