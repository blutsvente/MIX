-- -------------------------------------------------------------
--
--  Entity Declaration for a_clk
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: a_clk-e.vhd,v 1.1 2004/04/06 10:44:17 wig Exp $
-- $Date: 2004/04/06 10:44:17 $
-- $Log: a_clk-e.vhd,v $
-- Revision 1.1  2004/04/06 10:44:17  wig
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
-- Start of Generated Entity a_clk
--
entity a_clk is
        -- Generics:
		-- No Generated Generics for Entity a_clk

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity a_clk
			alarm_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			clk	: in	std_ulogic;
			current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			display_ls_hr	: out	std_ulogic_vector(6 downto 0);
			display_ls_min	: out	std_ulogic_vector(6 downto 0);
			display_ms_hr	: out	std_ulogic_vector(6 downto 0);
			display_ms_min	: out	std_ulogic_vector(6 downto 0);
			key_buffer_0	: in	std_ulogic_vector(3 downto 0);
			key_buffer_1	: in	std_ulogic_vector(3 downto 0);
			key_buffer_2	: in	std_ulogic_vector(3 downto 0);
			key_buffer_3	: in	std_ulogic_vector(3 downto 0);
			reset	: in	std_ulogic;
			show_a	: in	std_ulogic;
			show_new_time	: in	std_ulogic;
			sound_alarm	: out	std_ulogic;
			stopwatch	: in	std_ulogic
		-- End of Generated Port for Entity a_clk
		);
end a_clk;
--
-- End of Generated Entity a_clk
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
