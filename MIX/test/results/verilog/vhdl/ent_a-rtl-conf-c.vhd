-- -------------------------------------------------------------
--
-- Generated Configuration for ent_a
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 16:07:02 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -sheet HIER=HIER_VHDL -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-rtl-conf-c.vhd,v 1.3 2005/07/19 07:13:12 wig Exp $
-- $Date: 2005/07/19 07:13:12 $
-- $Log: ent_a-rtl-conf-c.vhd,v $
-- Revision 1.3  2005/07/19 07:13:12  wig
-- Update testcases. Added highlow/nolowbus
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.57 2005/07/18 08:58:22 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_a_rtl_conf / ent_a
--
configuration ent_a_rtl_conf of ent_a is

        for rtl

	    	-- Generated Configuration
			for inst_aa : ent_aa
				use configuration work.ent_aa_rtl_conf;
			end for;
			for inst_ab : ent_ab
				use configuration work.ent_ab_rtl_conf;
			end for;
			for inst_ac : ent_ac
				use configuration work.ent_ac_rtl_conf;
			end for;
			for inst_ad : ent_ad
				use configuration work.ent_ad_rtl_conf;
			end for;
			for inst_ae : ent_ae
				use configuration work.ent_ae_rtl_conf;
			end for;


	end for; 
end ent_a_rtl_conf;
--
-- End of Generated Configuration ent_a_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
