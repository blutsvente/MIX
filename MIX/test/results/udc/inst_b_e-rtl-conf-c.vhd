-- -------------------------------------------------------------
--
-- Generated Configuration for inst_b_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 11 15:05:01 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_b_e-rtl-conf-c.vhd,v 1.2 2005/07/15 16:20:05 wig Exp $
-- $Date: 2005/07/15 16:20:05 $
-- $Log: inst_b_e-rtl-conf-c.vhd,v $
-- Revision 1.2  2005/07/15 16:20:05  wig
-- Update all testcases; still problems though
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.54 2005/06/23 13:14:42 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.35 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_b_e_rtl_conf / inst_b_e
--
configuration inst_b_e_rtl_conf of inst_b_e is

        for rtl

	    	-- Generated Configuration
			for inst_ba_i : inst_xa_e
				use configuration work.inst_xa_e_rtl_conf;
			end for;
			for inst_bb_i : inst_bb_e
				use configuration work.inst_bb_e_rtl_conf;
			end for;


	end for; 
end inst_b_e_rtl_conf;
--
-- End of Generated Configuration inst_b_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
