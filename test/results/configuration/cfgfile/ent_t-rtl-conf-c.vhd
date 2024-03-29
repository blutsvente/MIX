-- -------------------------------------------------------------
--
-- Generated Configuration for ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Mar 16 07:48:49 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -conf macro._MP_VHDL_USE_ENTY_MP_=Overwritten vhdl_enty from cmdline -conf macro._MP_VHDL_HOOK_ARCH_BODY_MP_=Use macro vhdl_hook_arch_body -conf macro._MP_ADD_MY_OWN_MP_=overloading my own macro -nodelta ../../configuration.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-rtl-conf-c.vhd,v 1.1 2006/07/04 09:54:10 wig Exp $
-- $Date: 2006/07/04 09:54:10 $
-- $Log: ent_t-rtl-conf-c.vhd,v $
-- Revision 1.1  2006/07/04 09:54:10  wig
-- Update more testcases, add configuration/cfgfile
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.77 2006/03/14 08:10:34 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
-- adding lot's of testcases 
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf

ADD_MY_OWN: 		overloading my own macro	-- adding my own macro 
MY_TICK_IN_TEST: 	has a ' inside	-- has a ' inside 
MY_TICK_FIRST_TEST:	' start with tick	-- ' start with tick 
MY_TICK_LAST_TEST:	ends with '	-- ends with ' 
MY_DQUOTE_IN_TEST:	has a " inside	-- has a " inside 
MY_DQUOTE_FIRST_TEST:	" start with tick	-- " start with tick 
MY_DQUOTE_LAST_TEST:	ends with "	-- ends with " 
MY_DQUOTE_TICK_TEST:	has a ' and a " here ' " more	-- has a ' and a " here ' " more 
MY_SOME_SEPS: 		special " $ & ' \n and more       -- special " $ & ' \n and more 
-- END

--
-- Start of Generated Configuration ent_t_rtl_conf / ent_t
--
configuration ent_t_rtl_conf of ent_t is

	for rtl

			-- Generated Configuration
			for inst_a : ent_a
				use configuration work.ent_a_rtl_conf;
			end for;
			for inst_b : ent_b
				use configuration work.ent_b_rtl_conf;
			end for;
			-- __I_NO_CONFIG_VERILOG --for inst_c : ent_c
			-- __I_NO_CONFIG_VERILOG --	use configuration work.ent_c_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;


	end for; 
end ent_t_rtl_conf;
--
-- End of Generated Configuration ent_t_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
