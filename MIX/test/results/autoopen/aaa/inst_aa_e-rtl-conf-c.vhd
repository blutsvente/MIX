-- -------------------------------------------------------------
--
-- Generated Configuration for inst_aa_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar 30 18:39:52 2004
--  cmd: H:\work\mix_new\MIX\mix_0.pl -strip -nodelta ../../autoopen.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_aa_e-rtl-conf-c.vhd,v 1.1 2004/04/06 11:19:54 wig Exp $
-- $Date: 2004/04/06 11:19:54 $
-- $Log: inst_aa_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 11:19:54  wig
-- Adding result/autoopen
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.39 2004/03/30 11:05:58 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.28 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_aa_e_rtl_conf / inst_aa_e
--
configuration inst_aa_e_rtl_conf of inst_aa_e is
        for rtl

	    	-- Generated Configuration
			for inst_aaa : inst_aaa_e
				use configuration work.inst_aaa_e_rtl_conf;
			end for;


	end for; 
end inst_aa_e_rtl_conf;
--
-- End of Generated Configuration inst_aa_e_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
