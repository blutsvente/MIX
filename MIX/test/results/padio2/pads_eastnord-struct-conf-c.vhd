-- -------------------------------------------------------------
--
-- Generated Configuration for pads_eastnord
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 14:47:37 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pads_eastnord-struct-conf-c.vhd,v 1.2 2005/07/15 16:20:03 wig Exp $
-- $Date: 2005/07/15 16:20:03 $
-- $Log: pads_eastnord-struct-conf-c.vhd,v $
-- Revision 1.2  2005/07/15 16:20:03  wig
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
-- Start of Generated Configuration pads_eastnord_struct_conf / pads_eastnord
--
configuration pads_eastnord_struct_conf of pads_eastnord is

        for struct

	    	-- Generated Configuration
			for ioc_db2o_10 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_db2o_11 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_db2o_12 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_db2o_13 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_db2o_14 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_db2o_15 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_10 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_11 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_12 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_13 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_14 : ioc
				use configuration work.ioc_rtl_conf;
			end for;
			for ioc_dbo_15 : ioc
				use configuration work.ioc_rtl_conf;
			end for;


	end for; 
end pads_eastnord_struct_conf;
--
-- End of Generated Configuration pads_eastnord_struct_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
