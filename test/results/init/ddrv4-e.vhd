-- -------------------------------------------------------------
--
--  Entity Declaration for ddrv4
--
-- Generated
--  by:  wig
--  on:  Wed May  7 10:18:05 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\a_clk.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ddrv4-e.vhd,v 1.1 2004/04/06 11:06:38 wig Exp $
-- $Date: 2004/04/06 11:06:38 $
-- $Log: ddrv4-e.vhd,v $
-- Revision 1.1  2004/04/06 11:06:38  wig
-- Adding result/init
--
-- Revision 1.1  2003/11/27 09:15:06  abauer
-- *** empty log message ***
--
-- Revision 1.1  2003/10/13 08:55:33  wig
-- Add lots of testcases:
-- padio
-- padio2
-- verilog
-- autoopen
-- typecast
-- ....
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.16 2003/04/28 06:40:37 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.11 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity ddrv4
--
entity ddrv4 is
        -- Generics:
		-- No Generated Generics for Entity ddrv4

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ddrv4
			alarm_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ls_min	: in	std_ulogic_vector(3 downto 0); -- alarm_time_ls_min comment
			alarm_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0); -- alarm_time_ms_min paren (
			clk	: in	std_ulogic;
			current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			display_ls_hr	: out	std_ulogic_vector(6 downto 0);
			-- display_ls_min	: out	std_ulogic_vector(6 downto 0);
			--comment display_ms_hr	: out	std_ulogic_vector(6 downto 0);
			display_ms_min	: out	std_ulogic_vector(6 downto 0);
			key_buffer_0	: in	std_ulogic_vector(3 downto 0);
			key_buffer_1	: in	std_ulogic_vector(3 downto 0);
			key_buffer_2	: in	std_ulogic_vector(3 downto 0);
			key_buffer_3	: in	std_ulogic_vector(3 downto 0);
			p_mix_sa_test6_3_0_gi	: in	std_ulogic_vector(3 downto 0);
			p_mix_sound_alarm_test1_go	: out	std_ulogic;
			p_mix_sound_alarm_test3_go	: out	std_ulogic; -- p_mix_sound_alarm_test1_go comment
			p_mix_sound_alarm_test4_gi	: in	std_ulogic; -- p_mix_sound_alarm_test4_gi comment paren ( ( more to come
			p_mix_sound_alarm_test5_2_1_go	: out	std_ulogic_vector(1 downto 0);
			reset	: in	std_ulogic;
			sa_test7	: in	std_ulogic_vector(5 downto 0);
			sa_test8	: out	std_ulogic_vector(8 downto 2);
			show_a	: in	std_ulogic;
			show_new_time	: in	std_ulogic;
			sound_alarm	: out	std_ulogic
		-- End of Generated Port for Entity ddrv4
		);
end ddrv4;
--
-- End of Generated Entity ddrv4
--

--
--!End of Entity/ies
-- --------------------------------------------------------------