-- -------------------------------------------------------------
--
-- Generated Configuration for pads_eastsouth
--
-- Generated
--  by:  wig
--  on:  Thu Dec 18 11:12:08 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pads_eastsouth-struct-conf-c.vhd,v 1.1 2004/04/06 10:42:13 wig Exp $
-- $Date: 2004/04/06 10:42:13 $
-- $Log: pads_eastsouth-struct-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:42:13  wig
-- Adding result/padio2
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.24 , wilfried.gaensheimer@micronas.com
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