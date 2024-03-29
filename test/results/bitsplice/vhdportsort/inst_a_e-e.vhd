-- -------------------------------------------------------------
--
--  Entity Declaration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Wed Jun  7 17:05:33 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta -bak ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-e.vhd,v 1.2 2006/06/22 07:19:59 wig Exp $
-- $Date: 2006/06/22 07:19:59 $
-- $Log: inst_a_e-e.vhd,v $
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
-- Start of Generated Entity inst_a_e
--
entity inst_a_e is

	-- Generics:
		-- No Generated Generics for Entity inst_a_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_a_e
			widesig_o	: out	std_ulogic_vector(31 downto 0);
			widesig_r_0	: out	std_ulogic;
			widesig_r_1	: out	std_ulogic;
			widesig_r_2	: out	std_ulogic;
			widesig_r_3	: out	std_ulogic;
			widesig_r_4	: out	std_ulogic;
			widesig_r_5	: out	std_ulogic;
			widesig_r_6	: out	std_ulogic;
			widesig_r_7	: out	std_ulogic;
			widesig_r_8	: out	std_ulogic;
			widesig_r_9	: out	std_ulogic;
			widesig_r_10	: out	std_ulogic;
			widesig_r_11	: out	std_ulogic;
			widesig_r_12	: out	std_ulogic;
			widesig_r_13	: out	std_ulogic;
			widesig_r_14	: out	std_ulogic;
			widesig_r_15	: out	std_ulogic;
			widesig_r_16	: out	std_ulogic;
			widesig_r_17	: out	std_ulogic;
			widesig_r_18	: out	std_ulogic;
			widesig_r_19	: out	std_ulogic;
			widesig_r_20	: out	std_ulogic;
			widesig_r_21	: out	std_ulogic;
			widesig_r_22	: out	std_ulogic;
			widesig_r_23	: out	std_ulogic;
			widesig_r_24	: out	std_ulogic;
			widesig_r_25	: out	std_ulogic;
			widesig_r_26	: out	std_ulogic;
			widesig_r_27	: out	std_ulogic;
			widesig_r_28	: out	std_ulogic;
			widesig_r_29	: out	std_ulogic;
			widesig_r_30	: out	std_ulogic;
			unsplice_a1_no3	: out	std_ulogic_vector(127 downto 0);	-- leaves 3 unconnected
			unsplice_a2_all128	: out	std_ulogic_vector(127 downto 0);	-- full 128 bit port
			unsplice_a3_up100	: out	std_ulogic_vector(127 downto 0);	-- connect 100 bits from 0
			unsplice_a4_mid100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_a5_midp100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_bad_a	: out	std_ulogic_vector(127 downto 0);
			unsplice_bad_b	: out	std_ulogic_vector(127 downto 0);
			widemerge_a1	: out	std_ulogic_vector(31 downto 0);
			p_mix_test1_go	: out	std_ulogic
		-- End of Generated Port for Entity inst_a_e
		);
end inst_a_e;
--
-- End of Generated Entity inst_a_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
