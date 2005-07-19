-- -------------------------------------------------------------
--
--  Entity Declaration for ent_ae
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 16:07:27 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -sheet HIER=HIER_MIXED -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_ae-e.vhd,v 1.4 2005/07/19 07:13:20 wig Exp $
-- $Date: 2005/07/19 07:13:20 $
-- $Log: ent_ae-e.vhd,v $
-- Revision 1.4  2005/07/19 07:13:20  wig
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
-- Start of Generated Entity ent_ae
--
entity ent_ae is

        -- Generics:
		-- No Generated Generics for Entity ent_ae


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_ae
			port_ae_2	: in	std_ulogic_vector(4 downto 0);
			port_ae_5	: in	std_ulogic_vector(3 downto 0);
			port_ae_6	: in	std_ulogic_vector(3 downto 0);
			sig_07	: in	std_ulogic_vector(5 downto 0);
			sig_08	: in	std_ulogic_vector(8 downto 2);
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_ae
		);
end ent_ae;
--
-- End of Generated Entity ent_ae
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
