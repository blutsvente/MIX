-- -------------------------------------------------------------
--
--  Entity Declaration for di_tnr
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
-- Start of Generated Entity di_tnr
--
entity di_tnr is

	-- Generics:
		-- No Generated Generics for Entity di_tnr

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity di_tnr
			af_c1_o	: out	std_ulogic;
			af_p0_i	: in	std_ulogic;
			al_c1_o	: out	std_ulogic;
			al_p0_i	: in	std_ulogic;
			ap_c1_o	: out	std_ulogic;
			ap_p0_i	: in	std_ulogic;
			asresi_n	: in	std_ulogic;
			c0_p0_i	: in	std_ulogic_vector(7 downto 0);
			c0_p0_o	: out	std_ulogic_vector(7 downto 0);
			c1_p1_i	: in	std_ulogic_vector(7 downto 0);
			c1_p1_o	: out	std_ulogic_vector(7 downto 0);
			cblack_p_i	: in	std_ulogic_vector(7 downto 0);
			clkin	: in	std_ulogic;
			field_p0_i	: in	std_ulogic;
			fieldc_c1_o	: out	std_ulogic;
			fieldy0_c1_o	: out	std_ulogic;
			fieldy1_c1_o	: out	std_ulogic;
			frafiesel_iic_i	: in	std_ulogic;
			hsync_c1_o	: out	std_ulogic;
			hsync_p0_i	: in	std_ulogic;
			nr_dis_c_i	: in	std_ulogic;
			nron_iic_i	: in	std_ulogic;
			req_p1_o	: out	std_ulogic;
			tnrabs_iic_i	: in	std_ulogic;
			tnrclc_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrcly_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrmd4y_iic_i	: in	std_ulogic;
			tnrmdnr4c_iic_i	: in	std_ulogic;
			tnrnr4y_iic_i	: in	std_ulogic;
			tnrs0c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs0y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs1c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs1y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs2c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs2y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs3c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs3y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs4c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs4y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs5c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs5y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs6c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs6y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs7c_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrs7y_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrsel_iic_i	: in	std_ulogic;
			tnrssc_iic_i	: in	std_ulogic_vector(3 downto 0);
			tnrssy_iic_i	: in	std_ulogic_vector(3 downto 0);
			uen_c1_o	: out	std_ulogic;
			uen_p0_i	: in	std_ulogic;
			vsync_c1_o	: out	std_ulogic;
			vsync_p0_i	: in	std_ulogic;
			y0_p0_i	: in	std_ulogic_vector(7 downto 0);
			y0_p0_o	: out	std_ulogic_vector(7 downto 0);
			y1_p1_i	: in	std_ulogic_vector(7 downto 0);
			y1_p1_o	: out	std_ulogic_vector(7 downto 0);
			y2_p1_i	: in	std_ulogic_vector(7 downto 0);
			y2_p1_o	: out	std_ulogic_vector(7 downto 0);
			yblack_p_i	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity di_tnr
		);
end di_tnr;
--
-- End of Generated Entity di_tnr
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
