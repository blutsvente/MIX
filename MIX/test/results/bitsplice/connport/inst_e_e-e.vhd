-- -------------------------------------------------------------
--
--  Entity Declaration for inst_e_e
--
-- Generated
--  by:  wig
--  on:  Mon Apr 10 13:27:22 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_e_e-e.vhd,v 1.1 2006/04/10 15:42:04 wig Exp $
-- $Date: 2006/04/10 15:42:04 $
-- $Log: inst_e_e-e.vhd,v $
-- Revision 1.1  2006/04/10 15:42:04  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_e_e
--
entity inst_e_e is

	-- Generics:
		-- No Generated Generics for Entity inst_e_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_e_e
			p_mix_unsplice_a1_125_0_gi	: in	std_ulogic_vector(125 downto 0);
			p_mix_unsplice_a1_127_127_gi	: in	std_ulogic;
			p_mix_unsplice_a2_all128_127_0_gi	: in	std_ulogic_vector(127 downto 0);
			p_mix_unsplice_a3_up100_100_0_gi	: in	std_ulogic_vector(100 downto 0);
			p_mix_unsplice_a4_mid100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_a5_midp100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_bad_a_1_1_gi	: in	std_ulogic;
			p_mix_unsplice_bad_b_1_0_gi	: in	std_ulogic_vector(1 downto 0)
		-- End of Generated Port for Entity inst_e_e
		);
end inst_e_e;
--
-- End of Generated Entity inst_e_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
