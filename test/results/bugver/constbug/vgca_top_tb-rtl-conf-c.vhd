-- -------------------------------------------------------------
--
-- Generated Configuration for vgca_top_tb
--
-- Generated
--  by:  wig
--  on:  Wed Aug 18 12:40:14 2004
--  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_top_tb-rtl-conf-c.vhd,v 1.2 2004/08/18 10:46:57 wig Exp $
-- $Date: 2004/08/18 10:46:57 $
-- $Log: vgca_top_tb-rtl-conf-c.vhd,v $
-- Revision 1.2  2004/08/18 10:46:57  wig
-- reworked some testcases
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.45 2004/08/09 15:48:14 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.32 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration vgca_top_tb_rtl_conf / vgca_top_tb
--
configuration vgca_top_tb_rtl_conf of vgca_top_tb is
        for rtl

	    	-- Generated Configuration
			for dut : vgca_top
				use configuration work.vgca_top_struct_conf;
			end for;


	end for; 
end vgca_top_tb_rtl_conf;
--
-- End of Generated Configuration vgca_top_tb_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
