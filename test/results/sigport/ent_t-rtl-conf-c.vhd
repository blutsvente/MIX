-- -------------------------------------------------------------
--
-- Generated Configuration for ent_t
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 18:34:27 2007
--  cmd: /home/wig/work/MIX/mix_0.pl ../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-rtl-conf-c.vhd,v 1.1 2007/03/05 13:35:50 wig Exp $
-- $Date: 2007/03/05 13:35:50 $
-- $Log: ent_t-rtl-conf-c.vhd,v $
-- Revision 1.1  2007/03/05 13:35:50  wig
-- Reworked testcase sigport (changed case of generated files).
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.104 2007/03/03 17:24:06 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_t_RTL_CONF / ent_t
--
configuration ent_t_RTL_CONF of ent_t is

	for rtl

			-- Generated Configuration
			for inst_a : ent_a
				use configuration work.ent_a_RTL_CONF;
			end for;
			for inst_b : ent_b
				use configuration work.ent_b_RTL_CONF;
			end for;


	end for; 
end ent_t_RTL_CONF;
--
-- End of Generated Configuration ent_t_RTL_CONF
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
