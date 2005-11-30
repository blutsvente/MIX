-- -------------------------------------------------------------
--
--  Entity Declaration for ent_b
--
-- Generated
--  by:  wig
--  on:  Wed Nov 30 10:05:42 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -sheet HIER=HIER_MIXED ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_b-e.vhd,v 1.5 2005/11/30 14:04:18 wig Exp $
-- $Date: 2005/11/30 14:04:18 $
-- $Log: ent_b-e.vhd,v $
-- Revision 1.5  2005/11/30 14:04:18  wig
-- Updated testcase references
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.71 2005/11/22 11:00:47 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.42 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ent_b
--
entity ent_b is

	-- Generics:
		-- No Generated Generics for Entity ent_b

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_b
			port_b_1	: in	std_ulogic;	-- Will create p_mix_sig_1_go port
			port_b_3	: in	std_ulogic;	-- Interhierachy link, will create p_mix_sig_3_go
			port_b_4	: out	std_ulogic;	-- Interhierachy link, will create p_mix_sig_4_gi
			port_b_5_1	: in	std_ulogic; 	-- Bus, single bits go to outside, will create p_mix_sig_5_2_2_go __I_AUTO_REDUCED_BUS2SIGNAL
			port_b_5_2	: in	std_ulogic; 	-- Bus, single bits go to outside, will create P_MIX_sound_alarm_test5_1_1_GO __I_AUTO_REDUCED_BUS2SIGNAL
			port_b_6i	: in	std_ulogic_vector(3 downto 0);	-- Conflicting definition
			port_b_6o	: out	std_ulogic_vector(3 downto 0);	-- Conflicting definition
			sig_07	: in	std_ulogic_vector(5 downto 0);	-- Conflicting definition, IN false!
			sig_08	: in	std_ulogic_vector(8 downto 2)	-- VHDL intermediate needed (port name)
		-- End of Generated Port for Entity ent_b
		);
end ent_b;
--
-- End of Generated Entity ent_b
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
