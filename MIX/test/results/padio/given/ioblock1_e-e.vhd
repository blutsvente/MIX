-- -------------------------------------------------------------
--
--  Entity Declaration for ioblock1_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:46:40 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock1_e-e.vhd,v 1.2 2005/07/19 07:13:15 wig Exp $
-- $Date: 2005/07/19 07:13:15 $
-- $Log: ioblock1_e-e.vhd,v $
-- Revision 1.2  2005/07/19 07:13:15  wig
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
-- Start of Generated Entity ioblock1_e
--
entity ioblock1_e is

        -- Generics:
		-- No Generated Generics for Entity ioblock1_e


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ioblock1_e
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
			p_mix_iosel_disp_gi	: in	std_ulogic;
			p_mix_iosel_ls_hr_gi	: in	std_ulogic;
			p_mix_iosel_ls_min_gi	: in	std_ulogic;
			p_mix_iosel_ms_hr_gi	: in	std_ulogic;
			p_mix_nand_dir_gi	: in	std_ulogic;
			p_mix_nand_out_2_gi	: in	std_ulogic;
			p_mix_pad_di_12_gi	: in	std_ulogic;
			p_mix_pad_di_13_gi	: in	std_ulogic;
			p_mix_pad_di_14_gi	: in	std_ulogic;
			p_mix_pad_di_15_gi	: in	std_ulogic;
			p_mix_pad_di_16_gi	: in	std_ulogic;
			p_mix_pad_di_17_gi	: in	std_ulogic;
			p_mix_pad_di_18_gi	: in	std_ulogic;
			p_mix_pad_do_12_go	: out	std_ulogic;
			p_mix_pad_do_13_go	: out	std_ulogic;
			p_mix_pad_do_14_go	: out	std_ulogic;
			p_mix_pad_do_15_go	: out	std_ulogic;
			p_mix_pad_do_16_go	: out	std_ulogic;
			p_mix_pad_do_17_go	: out	std_ulogic;
			p_mix_pad_do_18_go	: out	std_ulogic;
			p_mix_pad_en_12_go	: out	std_ulogic;
			p_mix_pad_en_13_go	: out	std_ulogic;
			p_mix_pad_en_14_go	: out	std_ulogic;
			p_mix_pad_en_15_go	: out	std_ulogic;
			p_mix_pad_en_16_go	: out	std_ulogic;
			p_mix_pad_en_17_go	: out	std_ulogic;
			p_mix_pad_en_18_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock1_e
		);
end ioblock1_e;
--
-- End of Generated Entity ioblock1_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
