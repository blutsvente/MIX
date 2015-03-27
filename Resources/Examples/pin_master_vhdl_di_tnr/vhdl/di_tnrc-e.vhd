-- -------------------------------------------------------------
--
--  Entity Declaration for di_tnrc
--
-- Generated
--  by:  lutscher
--  on:  Tue Jun 23 14:19:39 2009
--  cmd: /home/lutscher/work/MIX/mix_1.pl di_tnr.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author$
-- $Id$
-- $Date$
-- $Log$
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.109 2008/04/01 12:48:34 wig Exp 
--
-- Generator: mix_1.pl Version: Revision: 1.3 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity di_tnrc
--
entity di_tnrc is

	-- Generics:
		-- No Generated Generics for Entity di_tnrc

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity di_tnrc
			af_c0_i	: in	std_ulogic ;
			al_c0_i	: in	std_ulogic;
			al_c1_i	: in	std_ulogic;
			ap_c0_i	: in	std_ulogic;
			ap_p0_i	: in	std_ulogic;
			asresi_n	: in	std_ulogic;
			c_p0_i	: in	std_ulogic_vector(7 downto 0);
			c_p0_o	: out	std_ulogic_vector(7 downto 0);
			c_p1_i	: in	std_ulogic_vector(7 downto 0);
			c_p1_o	: out	std_ulogic_vector(7 downto 0);
			cblack_p_i	: in	std_ulogic_vector(7 downto 0);
			clkin	: in	std_ulogic;
			hsync_c_i	: in	std_ulogic;
			nr_dis_c_i	: in	std_ulogic;
			nron_iic_i	: in	std_ulogic;
			tnrabs_iic_i	: in	std_ulogic;
			tnrclc_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrkvaly_p_i	: in	std_ulogic_vector(3 downto 0);
			tnrs0c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs1c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs2c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs3c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs4c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs5c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs6c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs7c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrsel_iic_i	: in	std_ulogic;
			tnrssc_iic_i	: in	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity di_tnrc
		);
end di_tnrc;
--
-- End of Generated Entity di_tnrc
--


--
--!End of Entity/ies
-- --------------------------------------------------------------