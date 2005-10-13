-- -------------------------------------------------------------
--
--  Entity Declaration for ent_aa
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 16:07:27 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -sheet HIER=HIER_MIXED -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_aa-e.vhd,v 1.4 2005/10/13 09:09:45 wig Exp $
-- $Date: 2005/10/13 09:09:45 $
-- $Log: ent_aa-e.vhd,v $
-- Revision 1.4  2005/10/13 09:09:45  wig
-- Added intermediate CONN sheet split
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
-- Start of Generated Entity ent_aa
--
entity ent_aa is

        -- Generics:
		-- No Generated Generics for Entity ent_aa


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_aa
			port_aa_1	: out	std_ulogic;
			port_aa_2	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			port_aa_3	: out	std_ulogic;
			port_aa_4	: in	std_ulogic;
			port_aa_5	: out	std_ulogic_vector(3 downto 0);
			port_aa_6	: out	std_ulogic_vector(3 downto 0);
			sig_07	: out	std_ulogic_vector(5 downto 0);
			sig_08	: out	std_ulogic_vector(8 downto 2);
			sig_13	: out	std_ulogic_vector(4 downto 0);
			sig_14	: out	std_ulogic_vector(6 downto 0) 
		-- End of Generated Port for Entity ent_aa
		);
end ent_aa;
--
-- End of Generated Entity ent_aa
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
