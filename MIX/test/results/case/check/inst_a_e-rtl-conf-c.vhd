-- -------------------------------------------------------------
--
-- Generated Configuration for inst_A_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 17:18:10 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl ../case.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-conf-c.vhd,v 1.1 2007/03/05 08:58:59 wig Exp $
-- $Date: 2007/03/05 08:58:59 $
-- $Log: inst_a_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2007/03/05 08:58:59  wig
-- Upgraded testcases
-- case/force still not fully operational (internal names keep case).
--
-- Revision 1.1  2007/03/03 17:24:06  wig
-- Updated testcase for case matches. Added filename serialization.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.101 2007/03/01 16:28:38 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_A_e_rtl_conf / inst_A_e
--
configuration inst_A_e_rtl_conf of inst_A_e is

	for rtl

			-- Generated Configuration
			for INST_AA : INST_AA_e
				use configuration work.INST_AA_e_rtl_conf;
			end for;


	end for; 
end inst_A_e_rtl_conf;
--
-- End of Generated Configuration inst_A_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------