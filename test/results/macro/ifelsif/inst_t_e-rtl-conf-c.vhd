-- -------------------------------------------------------------
--
-- Generated Configuration for inst_t_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar  6 12:38:07 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -variant Ifelsif -nodelta -bak ../../macro.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-conf-c.vhd,v 1.1 2007/03/06 12:44:33 wig Exp $
-- $Date: 2007/03/06 12:44:33 $
-- $Log: inst_t_e-rtl-conf-c.vhd,v $
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
-- Start of Generated Configuration inst_t_e_rtl_conf / inst_t_e
--
configuration inst_t_e_rtl_conf of inst_t_e is

	for rtl

			-- Generated Configuration
			for inst_10 : inst_10_e
				use configuration work.inst_10_e_rtl_conf;
			end for;
			for inst_6 : inst_6_e
				use configuration work.inst_6_e_rtl_conf;
			end for;
			for inst_7 : inst_7_e
				use configuration work.inst_7_e_rtl_conf;
			end for;
			for inst_8 : inst_8_e
				use configuration work.inst_8_e_rtl_conf;
			end for;
			for inst_9 : inst_9_e
				use configuration work.inst_9_e_rtl_conf;
			end for;
			for inst_a : inst_a_e
				use configuration work.inst_a_e_rtl_conf;
			end for;
			for inst_b : inst_b_e
				use configuration work.inst_b_e_rtl_conf;
			end for;
			for inst_k1_k2 : inst_k1_k2_e
				use configuration work.inst_k1_k2_rtl_conf;
			end for;
			for inst_k1_k4 : inst_k1_k4_e
				use configuration work.inst_k1_k4_rtl_conf;
			end for;
			for inst_k3_k2 : inst_k3_k2_e
				use configuration work.inst_k3_k2_rtl_conf;
			end for;
			for inst_k3_k4 : inst_k3_k4_e
				use configuration work.inst_k3_k4_rtl_conf;
			end for;
			for inst_ok_1 : inst_ok_1_e
				use configuration work.inst_ok_1_rtl_conf;
			end for;
			for inst_ok_10 : inst_ok_10_e
				use configuration work.inst_ok_10_rtl_conf;
			end for;
			for inst_ok_2 : inst_ok_2_e
				use configuration work.inst_ok_2_rtl_conf;
			end for;
			for inst_ok_3 : inst_ok_3_e
				use configuration work.inst_ok_3_rtl_conf;
			end for;
			for inst_ok_4 : inst_ok_4_e
				use configuration work.inst_ok_4_rtl_conf;
			end for;
			for inst_ok_5 : inst_ok_5_e
				use configuration work.inst_ok_5_rtl_conf;
			end for;
			for inst_ok_6 : inst_ok_6_e
				use configuration work.inst_ok_6_rtl_conf;
			end for;
			for inst_ok_7 : inst_ok_7_e
				use configuration work.inst_ok_7_rtl_conf;
			end for;
			for inst_ok_8 : inst_ok_8_e
				use configuration work.inst_ok_8_rtl_conf;
			end for;
			for inst_ok_9 : inst_ok_9_e
				use configuration work.inst_ok_9_rtl_conf;
			end for;
			for inst_shadow_1 : inst_shadow_1_e
				use configuration work.inst_shadow_1_rtl_conf;
			end for;
			for inst_shadow_10 : inst_shadow_10_e
				use configuration work.inst_shadow_10_rtl_conf;
			end for;
			for inst_shadow_2 : inst_shadow_2_e
				use configuration work.inst_shadow_2_rtl_conf;
			end for;
			for inst_shadow_3 : inst_shadow_3_e
				use configuration work.inst_shadow_3_rtl_conf;
			end for;
			for inst_shadow_4 : inst_shadow_4_e
				use configuration work.inst_shadow_4_rtl_conf;
			end for;
			for inst_shadow_5 : inst_shadow_5_e
				use configuration work.inst_shadow_5_rtl_conf;
			end for;
			for inst_shadow_6 : inst_shadow_6_e
				use configuration work.inst_shadow_6_rtl_conf;
			end for;
			for inst_shadow_7 : inst_shadow_7_e
				use configuration work.inst_shadow_7_rtl_conf;
			end for;
			for inst_shadow_8 : inst_shadow_8_e
				use configuration work.inst_shadow_8_rtl_conf;
			end for;
			for inst_shadow_9 : inst_shadow_9_e
				use configuration work.inst_shadow_9_rtl_conf;
			end for;
			for inst_shadow_a : inst_shadow_a_e
				use configuration work.inst_shadow_a_rtl_conf;
			end for;
			for inst_shadow_b : inst_shadow_b_e
				use configuration work.inst_shadow_b_rtl_conf;
			end for;
			for inst_shadow_k1_k2 : inst_shadow_k1_k2_e
				use configuration work.inst_shadow_k1_k2_rtl_conf;
			end for;
			for inst_shadow_k1_k4 : inst_shadow_k1_k4_e
				use configuration work.inst_shadow_k1_k4_rtl_conf;
			end for;
			for inst_shadow_k3_k2 : inst_shadow_k3_k2_e
				use configuration work.inst_shadow_k3_k2_rtl_conf;
			end for;
			for inst_shadow_k3_k4 : inst_shadow_k3_k4_e
				use configuration work.inst_shadow_k3_k4_rtl_conf;
			end for;
			for inst_shadow_ok_1 : inst_shadow_ok_1_e
				use configuration work.inst_shadow_ok_1_rtl_conf;
			end for;
			for inst_shadow_ok_10 : inst_shadow_ok_10_e
				use configuration work.inst_shadow_ok_10_rtl_conf;
			end for;
			for inst_shadow_ok_2 : inst_shadow_ok_2_e
				use configuration work.inst_shadow_ok_2_rtl_conf;
			end for;
			for inst_shadow_ok_3 : inst_shadow_ok_3_e
				use configuration work.inst_shadow_ok_3_rtl_conf;
			end for;
			for inst_shadow_ok_4 : inst_shadow_ok_4_e
				use configuration work.inst_shadow_ok_4_rtl_conf;
			end for;
			for inst_shadow_ok_5 : inst_shadow_ok_5_e
				use configuration work.inst_shadow_ok_5_rtl_conf;
			end for;
			for inst_shadow_ok_6 : inst_shadow_ok_6_e
				use configuration work.inst_shadow_ok_6_rtl_conf;
			end for;
			for inst_shadow_ok_7 : inst_shadow_ok_7_e
				use configuration work.inst_shadow_ok_7_rtl_conf;
			end for;
			for inst_shadow_ok_8 : inst_shadow_ok_8_e
				use configuration work.inst_shadow_ok_8_rtl_conf;
			end for;
			for inst_shadow_ok_9 : inst_shadow_ok_9_e
				use configuration work.inst_shadow_ok_9_rtl_conf;
			end for;
			for inst_shadow_t : inst_shadow_t_e
				use configuration work.inst_shadow_t_rtl_conf;
			end for;


	end for; 
end inst_t_e_rtl_conf;
--
-- End of Generated Configuration inst_t_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
