-- -------------------------------------------------------------
--
--  Entity Declaration for inst_e_e
--
-- Generated
--  by:  wig
--  on:  Wed Jun  7 17:05:33 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_e_e-e.vhd,v 1.2 2006/06/22 07:19:59 wig Exp $
-- $Date: 2006/06/22 07:19:59 $
-- $Log: inst_e_e-e.vhd,v $
-- Revision 1.2  2006/06/22 07:19:59  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.89 2006/05/23 06:48:05 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.45 , wilfried.gaensheimer@micronas.com
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
			video_i	: in	std_ulogic_vector(3 downto 0);
			widesig_i	: in	std_ulogic_vector(31 downto 0);
			p_mix_widesig_r_0_gi	: in	std_ulogic;
			p_mix_widesig_r_1_gi	: in	std_ulogic;
			p_mix_widesig_r_2_gi	: in	std_ulogic;
			p_mix_widesig_r_3_gi	: in	std_ulogic;
			p_mix_widesig_r_4_gi	: in	std_ulogic;
			p_mix_widesig_r_5_gi	: in	std_ulogic;
			p_mix_widesig_r_6_gi	: in	std_ulogic;
			p_mix_widesig_r_7_gi	: in	std_ulogic;
			p_mix_widesig_r_8_gi	: in	std_ulogic;
			p_mix_widesig_r_9_gi	: in	std_ulogic;
			p_mix_widesig_r_10_gi	: in	std_ulogic;
			p_mix_widesig_r_11_gi	: in	std_ulogic;
			p_mix_widesig_r_12_gi	: in	std_ulogic;
			p_mix_widesig_r_13_gi	: in	std_ulogic;
			p_mix_widesig_r_14_gi	: in	std_ulogic;
			p_mix_widesig_r_15_gi	: in	std_ulogic;
			p_mix_widesig_r_16_gi	: in	std_ulogic;
			p_mix_widesig_r_17_gi	: in	std_ulogic;
			p_mix_widesig_r_18_gi	: in	std_ulogic;
			p_mix_widesig_r_19_gi	: in	std_ulogic;
			p_mix_widesig_r_20_gi	: in	std_ulogic;
			p_mix_widesig_r_21_gi	: in	std_ulogic;
			p_mix_widesig_r_22_gi	: in	std_ulogic;
			p_mix_widesig_r_23_gi	: in	std_ulogic;
			p_mix_widesig_r_24_gi	: in	std_ulogic;
			p_mix_widesig_r_25_gi	: in	std_ulogic;
			p_mix_widesig_r_26_gi	: in	std_ulogic;
			p_mix_widesig_r_27_gi	: in	std_ulogic;
			p_mix_widesig_r_28_gi	: in	std_ulogic;
			p_mix_widesig_r_29_gi	: in	std_ulogic;
			p_mix_widesig_r_30_gi	: in	std_ulogic;
			p_mix_unsplice_a1_no3_125_0_gi	: in	std_ulogic_vector(125 downto 0);
			p_mix_unsplice_a1_no3_127_127_gi	: in	std_ulogic;
			p_mix_unsplice_a2_all128_127_0_gi	: in	std_ulogic_vector(127 downto 0);
			p_mix_unsplice_a3_up100_100_0_gi	: in	std_ulogic_vector(100 downto 0);
			p_mix_unsplice_a4_mid100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_a5_midp100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_bad_a_1_1_gi	: in	std_ulogic;
			p_mix_unsplice_bad_b_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_widemerge_a1_31_0_gi	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_e_e
		);
end inst_e_e;
--
-- End of Generated Entity inst_e_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
