-- -------------------------------------------------------------
--
-- Generated Configuration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Wed Apr  5 12:50:28 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-conf-c.vhd,v 1.1 2006/04/10 15:42:11 wig Exp $
-- $Date: 2006/04/10 15:42:11 $
-- $Log: inst_a_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2006/04/10 15:42:11  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_a_e_rtl_conf / inst_a_e
--
configuration inst_a_e_rtl_conf of inst_a_e is

	for rtl

			-- Generated Configuration
			for inst_aa_i : inst_xa_e
				use configuration work.inst_xa_e_rtl_conf;
			end for;
			for inst_ab_i : inst_ab_e
				use configuration work.inst_ab_e_rtl_conf;
			end for;


	end for; 
end inst_a_e_rtl_conf;
--
-- End of Generated Configuration inst_a_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
