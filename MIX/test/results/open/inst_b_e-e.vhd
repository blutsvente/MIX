-- -------------------------------------------------------------
--
--  Entity Declaration for inst_b_e
--
-- Generated
--  by:  wig
--  on:  Thu Jan 27 08:21:01 2005
--  cmd: h:/work/mix_new/mix/mix_0.pl -strip -nodelta ../open.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_b_e-e.vhd,v 1.3 2005/11/30 14:04:19 wig Exp $
-- $Date: 2005/11/30 14:04:19 $
-- $Log: inst_b_e-e.vhd,v $
-- Revision 1.3  2005/11/30 14:04:19  wig
-- Updated testcase references
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.48 2005/01/26 14:01:45 wig Exp 
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
-- Start of Generated Entity inst_b_e
--
entity inst_b_e is
        -- Generics:
		-- No Generated Generics for Entity inst_b_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_b_e
			mix_key_open	: out	std_ulogic; -- replace name
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
