-- -------------------------------------------------------------
--
--  Entity Declaration for inst_eac_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:43 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_eac_e-e.vhd,v 1.1 2004/04/06 10:49:57 wig Exp $
-- $Date: 2004/04/06 10:49:57 $
-- $Log: inst_eac_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:49:57  wig
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
-- Start of Generated Entity inst_eac_e
--
entity inst_eac_e is
        -- Generics:
		-- No Generated Generics for Entity inst_eac_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_eac_e
			adp_bist_fail	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			cp_laddr	: in	std_ulogic_vector(31 downto 0);
			cp_lcmd	: in	std_ulogic_vector(6 downto 0);
			cpu_bist_fail	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			cvi_sbist_fail0	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			cvi_sbist_fail1	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ema_bist_fail	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ga_sbist_fail0	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ga_sbist_fail1	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpio_int	: out	std_ulogic_vector(4 downto 0);
			ifu_bist_fail	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			mcu_bist_fail	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic;
			pdu_bist_fail0	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			pdu_bist_fail1	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			tmu_dac_reset	: out	std_ulogic;
			tsd_bist_fail	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity inst_eac_e
		);
end inst_eac_e;
--
-- End of Generated Entity inst_eac_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
