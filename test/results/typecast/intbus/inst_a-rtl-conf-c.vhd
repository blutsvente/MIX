-- -------------------------------------------------------------
--
-- Generated Configuration for inst_a
--
-- Generated
--  by:  wig
--  on:  Mon Aug  9 17:44:47 2004
--  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../../typecast.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a-rtl-conf-c.vhd,v 1.1 2004/08/09 15:47:10 wig Exp $
-- $Date: 2004/08/09 15:47:10 $
-- $Log: inst_a-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/08/09 15:47:10  wig
-- added typecast/intbus testcase
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.43 2004/08/04 12:49:37 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.32 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_a_rtl_conf / inst_a
--
configuration inst_a_rtl_conf of inst_a is
        for rtl

	    	-- Generated Configuration
			for inst_aa_i : inst_aa
				use configuration work.inst_aa_rtl_conf;
			end for;
			for inst_ab_i : inst_ab
				use configuration work.inst_ab_rtl_conf;
			end for;


	end for; 
end inst_a_rtl_conf;
--
-- End of Generated Configuration inst_a_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
