-- -------------------------------------------------------------
--
--  Entity Declaration for ioblock3_e
--
-- Generated
--  by:  wig
--  on:  Wed Dec 14 12:20:57 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock3_e-e.vhd,v 1.4 2005/12/14 12:38:05 wig Exp $
-- $Date: 2005/12/14 12:38:05 $
-- $Log: ioblock3_e-e.vhd,v $
-- Revision 1.4  2005/12/14 12:38:05  wig
-- Updated some testcases (verilog, padio)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.72 2005/11/30 14:01:21 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ioblock3_e
--
entity ioblock3_e is

	-- Generics:
		-- No Generated Generics for Entity ioblock3_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ioblock3_e
			p_mix_d9_di_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_d9_do_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_en_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_d9_pu_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_data_i33_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_i34_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o35_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_data_o36_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_display_ls_en_gi	: in	std_ulogic;
			p_mix_display_ms_en_gi	: in	std_ulogic;
			p_mix_iosel_0_gi	: in	std_ulogic;
			p_mix_iosel_bus_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_nand_dir_gi	: in	std_ulogic;
			p_mix_pad_di_31_gi	: in	std_ulogic;
			p_mix_pad_di_32_gi	: in	std_ulogic;
			p_mix_pad_di_33_gi	: in	std_ulogic;
			p_mix_pad_di_34_gi	: in	std_ulogic;
			p_mix_pad_di_39_gi	: in	std_ulogic;
			p_mix_pad_di_40_gi	: in	std_ulogic;
			p_mix_pad_do_31_go	: out	std_ulogic;
			p_mix_pad_do_32_go	: out	std_ulogic;
			p_mix_pad_do_35_go	: out	std_ulogic;
			p_mix_pad_do_36_go	: out	std_ulogic;
			p_mix_pad_do_39_go	: out	std_ulogic;
			p_mix_pad_do_40_go	: out	std_ulogic;
			p_mix_pad_en_31_go	: out	std_ulogic;
			p_mix_pad_en_32_go	: out	std_ulogic;
			p_mix_pad_en_35_go	: out	std_ulogic;
			p_mix_pad_en_36_go	: out	std_ulogic;
			p_mix_pad_en_39_go	: out	std_ulogic;
			p_mix_pad_en_40_go	: out	std_ulogic;
			p_mix_pad_pu_31_go	: out	std_ulogic;
			p_mix_pad_pu_32_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock3_e
		);
end ioblock3_e;
--
-- End of Generated Entity ioblock3_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
