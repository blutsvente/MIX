-- -------------------------------------------------------------
--
--  Entity Declaration for inst_eba_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:29 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_eba_e-e.vhd,v 1.1 2004/04/06 10:50:24 wig Exp $
-- $Date: 2004/04/06 10:50:24 $
-- $Log: inst_eba_e-e.vhd,v $
-- Revision 1.1  2004/04/06 10:50:24  wig
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
-- Start of Generated Entity inst_eba_e
--
entity inst_eba_e is
        -- Generics:
		-- No Generated Generics for Entity inst_eba_e

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_eba_e
			mbist_aci_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			mbist_vcd_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			reset_n	: in	std_ulogic;
			reset_n_s	: in	std_ulogic;
			vclkl27	: in	std_ulogic
		-- End of Generated Port for Entity inst_eba_e
		);
end inst_eba_e;
--
-- End of Generated Entity inst_eba_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
