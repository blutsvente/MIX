-- -------------------------------------------------------------
--
--  Entity Declaration for ios_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ios_e-e.vhd,v 1.1 2004/04/06 10:44:24 wig Exp $
-- $Date: 2004/04/06 10:44:24 $
-- $Log: ios_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:44:24  wig
-- Adding result/padio
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.17 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity ios_e
--
entity ios_e is
        -- Generics:
		-- No Generated Generics for Entity ios_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ios_e
			p_mix_d9_di_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_d9_do_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_en_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_pu_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_data_i1_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i33_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i34_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o1_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o35_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o36_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_di2_1_0_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_di2_7_3_go	: out	std_ulogic_vector(4 downto 0);
			p_mix_disp2_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_disp2_7_3_gi	: in	std_ulogic_vector(4 downto 0);
			p_mix_disp2_en_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_disp2_en_7_3_gi	: in	std_ulogic_vector(4 downto 0);
			p_mix_display_ls_en_gi	: in	std_ulogic;
			p_mix_display_ls_hr_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ls_min_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_en_gi	: in	std_ulogic;
			p_mix_display_ms_hr_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_min_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_iosel_0_0_0_gi	: in	std_ulogic;
			p_mix_iosel_disp_gi	: in	std_ulogic_vector(3 downto 0);
			p_mix_pad_di_12_gi	: in	std_ulogic;
			p_mix_pad_di_13_gi	: in	std_ulogic;
			p_mix_pad_di_14_gi	: in	std_ulogic;
			p_mix_pad_di_15_gi	: in	std_ulogic;
			p_mix_pad_di_16_gi	: in	std_ulogic;
			p_mix_pad_di_17_gi	: in	std_ulogic;
			p_mix_pad_di_18_gi	: in	std_ulogic;
			p_mix_pad_di_1_gi	: in	std_ulogic;
			p_mix_pad_di_31_gi	: in	std_ulogic;
			p_mix_pad_di_32_gi	: in	std_ulogic;
			p_mix_pad_di_33_gi	: in	std_ulogic;
			p_mix_pad_di_34_gi	: in	std_ulogic;
			p_mix_pad_di_39_gi	: in	std_ulogic;
			p_mix_pad_di_40_gi	: in	std_ulogic;
			p_mix_pad_do_12_go	: out	std_ulogic;
			p_mix_pad_do_13_go	: out	std_ulogic;
			p_mix_pad_do_14_go	: out	std_ulogic;
			p_mix_pad_do_15_go	: out	std_ulogic;
			p_mix_pad_do_16_go	: out	std_ulogic;
			p_mix_pad_do_17_go	: out	std_ulogic;
			p_mix_pad_do_18_go	: out	std_ulogic;
			p_mix_pad_do_2_go	: out	std_ulogic;
			p_mix_pad_do_31_go	: out	std_ulogic;
			p_mix_pad_do_32_go	: out	std_ulogic;
			p_mix_pad_do_35_go	: out	std_ulogic;
			p_mix_pad_do_36_go	: out	std_ulogic;
			p_mix_pad_do_39_go	: out	std_ulogic;
			p_mix_pad_do_40_go	: out	std_ulogic;
			p_mix_pad_en_12_go	: out	std_ulogic;
			p_mix_pad_en_13_go	: out	std_ulogic;
			p_mix_pad_en_14_go	: out	std_ulogic;
			p_mix_pad_en_15_go	: out	std_ulogic;
			p_mix_pad_en_16_go	: out	std_ulogic;
			p_mix_pad_en_17_go	: out	std_ulogic;
			p_mix_pad_en_18_go	: out	std_ulogic;
			p_mix_pad_en_2_go	: out	std_ulogic;
			p_mix_pad_en_31_go	: out	std_ulogic;
			p_mix_pad_en_32_go	: out	std_ulogic;
			p_mix_pad_en_35_go	: out	std_ulogic;
			p_mix_pad_en_36_go	: out	std_ulogic;
			p_mix_pad_en_39_go	: out	std_ulogic;
			p_mix_pad_en_40_go	: out	std_ulogic;
			p_mix_pad_pu_31_go	: out	std_ulogic;
			p_mix_pad_pu_32_go	: out	std_ulogic
		-- End of Generated Port for Entity ios_e
		);
end ios_e;
--
-- End of Generated Entity ios_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
