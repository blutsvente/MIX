-- -------------------------------------------------------------
--
--  Entity Declaration for ent_t
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 16:08:19 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -sheet HIER=HIER_MIXED -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-e.vhd,v 1.3 2005/07/19 07:13:17 wig Exp $
-- $Date: 2005/07/19 07:13:17 $
-- $Log: ent_t-e.vhd,v $
-- Revision 1.3  2005/07/19 07:13:17  wig
-- Update testcases. Added highlow/nolowbus
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.57 2005/07/18 08:58:22 wig Exp 
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
