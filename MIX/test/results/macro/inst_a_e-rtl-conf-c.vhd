-- -------------------------------------------------------------
--
-- Generated Configuration for inst_a_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:56:56 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\macro.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-conf-c.vhd,v 1.1 2004/04/06 10:52:48 wig Exp $
-- $Date: 2004/04/06 10:52:48 $
-- $Log: inst_a_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:52:48  wig
-- Adding result/macro
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
			for inst_10 : inst_10_e
				use configuration work.inst_10_e_rtl_conf;
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


	end for; 
end inst_a_e_rtl_conf;
--
-- End of Generated Configuration inst_a_e_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------