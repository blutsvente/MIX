-- -------------------------------------------------------------
--
--  Entity Declaration for inst_aa_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:55:45 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\io.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_aa_e-e.vhd,v 1.1 2004/04/06 11:04:58 wig Exp $
-- $Date: 2004/04/06 11:04:58 $
-- $Log: inst_aa_e-e.vhd,v $
-- Revision 1.1  2004/04/06 11:04:58  wig
-- Adding result/io
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
-- Start of Generated Entity inst_aa_e
--
entity inst_aa_e is
        -- Generics:
		-- No Generated Generics for Entity inst_aa_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_aa_e
			sig_in_01_p	: in	std_ulogic;
			sig_in_03_p	: in	std_ulogic_vector(7 downto 0);
			sig_io_out_05_p	: inout	std_ulogic_vector(5 downto 0);
			sig_io_out_06_p	: inout	std_ulogic_vector(6 downto 0);
			sig_out_02_p	: out	std_ulogic;
			sig_out_04_p	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_aa_e
		);
end inst_aa_e;
--
-- End of Generated Entity inst_aa_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------