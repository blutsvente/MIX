-- -------------------------------------------------------------
--
--  Entity Declaration for inst_ee_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:43 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ee_e-e.vhd,v 1.1 2004/04/06 10:50:09 wig Exp $
-- $Date: 2004/04/06 10:50:09 $
-- $Log: inst_ee_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:50:09  wig
-- Adding result/mde_tests
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.26 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity inst_ee_e
--
entity inst_ee_e is
        -- Generics:
		-- No Generated Generics for Entity inst_ee_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_ee_e
			cgs_ramclk	: in	std_ulogic;
			itm_scani	: out	std_ulogic_vector(70 downto 0);
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic;
			si_vclkx2	: in	std_ulogic;
			tmi_sbist_fail	: in	std_ulogic_vector(12 downto 0);
			tmi_scano	: in	std_ulogic_vector(70 downto 0)
		-- End of Generated Port for Entity inst_ee_e
		);
end inst_ee_e;
--
-- End of Generated Entity inst_ee_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
