-- -------------------------------------------------------------
--
-- Generated Configuration for di_tnr
--
-- Generated
--  by:  lutscher
--  on:  Tue Jun 23 14:19:39 2009
--  cmd: /home/lutscher/work/MIX/mix_1.pl di_tnr.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author$
-- $Id$
-- $Date$
-- $Log$
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.109 2008/04/01 12:48:34 wig Exp 
--
-- Generator: mix_1.pl Version: Revision: 1.3 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration di_tnr_struct_conf_mix / di_tnr
--
configuration di_tnr_struct_conf_mix of di_tnr is

	for struct

			-- Generated Configuration
			for ctrl : di_tnr_ctrl
				use configuration work.di_tnr_ctrl_rtl_conf;
			end for;
			for tnrc : di_tnrc
				use configuration work.di_tnrc_struct_conf;
			end for;
			for tnry : di_tnry
				use configuration work.di_tnry_struct_conf;
			end for;


	end for; 
end di_tnr_struct_conf_mix;
--
-- End of Generated Configuration di_tnr_struct_conf_mix
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
