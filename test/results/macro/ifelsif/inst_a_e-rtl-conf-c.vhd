-- -------------------------------------------------------------
--
-- Generated Configuration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar  6 12:38:07 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -variant Ifelsif -nodelta -bak ../../macro.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-conf-c.vhd,v 1.1 2007/03/06 12:44:33 wig Exp $
-- $Date: 2007/03/06 12:44:33 $
-- $Log: inst_a_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2007/03/06 12:44:33  wig
-- Adding IF/ELSIF/ELSE for generators and testcase.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.104 2007/03/03 17:24:06 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.47 , wilfried.gaensheimer@micronas.com
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
			for inst_1 : inst_1_e
				use configuration work.inst_1_e_rtl_conf;
			end for;
			for inst_2 : inst_2_e
				use configuration work.inst_2_e_rtl_conf;
			end for;
			for inst_3 : inst_3_e
				use configuration work.inst_3_e_rtl_conf;
			end for;
			for inst_4 : inst_4_e
				use configuration work.inst_4_e_rtl_conf;
			end for;
			for inst_5 : inst_5_e
				use configuration work.inst_5_e_rtl_conf;
			end for;


	end for; 
end inst_a_e_rtl_conf;
--
-- End of Generated Configuration inst_a_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
