-- -------------------------------------------------------------
--
--  Entity Declaration for inst_ef_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:43 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ef_e-e.vhd,v 1.1 2004/04/06 10:50:10 wig Exp $
-- $Date: 2004/04/06 10:50:10 $
-- $Log: inst_ef_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:50:10  wig
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
-- Start of Generated Entity inst_ef_e
--
entity inst_ef_e is
        -- Generics:
		-- No Generated Generics for Entity inst_ef_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_ef_e
			cp_laddro	: out	std_ulogic_vector(31 downto 0);
			cp_lcmd	: out	std_ulogic_vector(6 downto 0);
			cpu_scani	: in	std_ulogic_vector(7 downto 0);
			cpu_scano	: out	std_ulogic_vector(7 downto 0);
			int23	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			int24	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			int25	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			int26	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			int27	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic;
			tap_reset_n	: in	std_ulogic;
			tap_reset_n_o	: out	std_ulogic
		-- End of Generated Port for Entity inst_ef_e
		);
end inst_ef_e;
--
-- End of Generated Entity inst_ef_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
