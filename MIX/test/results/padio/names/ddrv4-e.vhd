-- -------------------------------------------------------------
--
--  Entity Declaration for ddrv4
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 14:43:23 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ddrv4-e.vhd,v 1.2 2005/07/15 16:20:02 wig Exp $
-- $Date: 2005/07/15 16:20:02 $
-- $Log: ddrv4-e.vhd,v $
-- Revision 1.2  2005/07/15 16:20:02  wig
-- Update all testcases; still problems though
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.55 2005/07/13 15:38:34 wig Exp 
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
-- Start of Generated Entity ddrv4
--
entity ddrv4 is

        -- Generics:
		-- No Generated Generics for Entity ddrv4


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ddrv4
			alarm_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			key_buffer_0	: in	std_ulogic_vector(3 downto 0);
			key_buffer_1	: in	std_ulogic_vector(3 downto 0);
			key_buffer_2	: in	std_ulogic_vector(3 downto 0);
			key_buffer_3	: in	std_ulogic_vector(3 downto 0);
			p_mix_display_ls_hr_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ls_min_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_hr_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_display_ms_min_go	: out	std_ulogic_vector(6 downto 0);
			p_mix_sound_alarm_go	: out	std_ulogic;
			show_a	: in	std_ulogic;
			show_new_time	: in	std_ulogic
		-- End of Generated Port for Entity ddrv4
		);
end ddrv4;
--
-- End of Generated Entity ddrv4
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
