-- -------------------------------------------------------------
--
-- Generated Configuration for ddrv4
--
-- Generated
--  by:  wig
--  on:  Wed Jul 16 09:56:49 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ddrv4-c.vhd,v 1.1 2004/04/06 10:44:18 wig Exp $
-- $Date: 2004/04/06 10:44:18 $
-- $Log: ddrv4-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:18  wig
-- Adding result/padio
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.19 2003/07/09 07:52:44 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.13 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ddrv4_rtl_conf / ddrv4
--
configuration ddrv4_rtl_conf of ddrv4 is
        for rtl

	    	-- Generated Configuration
			for d_ls_hr : ddrv
				use configuration work.d_ls_hr_RTL_CONF;
			end for;
			for d_ls_min : ddrv
				use configuration work.d_ls_min_RTL_CONF;
			end for;
			for d_ms_hr : ddrv
				use configuration work.d_ms_hr_RTL_CONF;
			end for;
			for d_ms_min : ddrv
				use configuration work.d_ms_min_RTL_CONF;
			end for;
			for u_and_f : and_f
				use configuration work.u_and_f_RTL_CONF;
			end for;


	end for; 
end ddrv4_rtl_conf;
--
-- End of Generated Configuration ddrv4_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
