-- -------------------------------------------------------------
--
-- Generated Configuration for ent_a
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 14:50:36 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-RTL-CONF-c.vhd,v 1.2 2005/07/15 16:20:02 wig Exp $
-- $Date: 2005/07/15 16:20:02 $
-- $Log: ent_a-RTL-CONF-c.vhd,v $
-- Revision 1.2  2005/07/15 16:20:02  wig
-- Update all testcases; still problems though
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.55 2005/07/13 15:38:34 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_a_RTL_CONF / ent_a
--
configuration ent_a_RTL_CONF of ent_a is

        for rtl

	    	-- Generated Configuration
			for inst_aa : ent_aa
				use configuration work.ent_aa_RTL_CONF;
			end for;
			for inst_ab : ent_ab
				use configuration work.ent_ab_RTL_CONF;
			end for;
			for inst_ac : ent_ac
				use configuration work.ent_ac_RTL_CONF;
			end for;
			for inst_ad : ent_ad
				use configuration work.ent_ad_RTL_CONF;
			end for;
			for inst_ae : ent_ae
				use configuration work.ent_ae_RTL_CONF;
			end for;


	end for; 
end ent_a_RTL_CONF;
--
-- End of Generated Configuration ent_a_RTL_CONF
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
