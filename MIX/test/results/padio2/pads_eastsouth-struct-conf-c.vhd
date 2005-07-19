-- -------------------------------------------------------------
--
-- Generated Configuration for pads_eastsouth
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 17:59:48 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pads_eastsouth-struct-conf-c.vhd,v 1.3 2005/07/19 07:13:15 wig Exp $
-- $Date: 2005/07/19 07:13:15 $
-- $Log: pads_eastsouth-struct-conf-c.vhd,v $
-- Revision 1.3  2005/07/19 07:13:15  wig
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
-- Start of Generated Configuration pads_eastsouth_struct_conf / pads_eastsouth
--
configuration pads_eastsouth_struct_conf of pads_eastsouth is

        for struct

	    	-- Generated Configuration
			for ioc_ramd_12 : iom_sstl
				use configuration work.iom_sstl_rtl_conf;
			end for;


	end for; 
end pads_eastsouth_struct_conf;
--
-- End of Generated Configuration pads_eastsouth_struct_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
