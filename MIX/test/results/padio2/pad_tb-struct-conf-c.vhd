-- -------------------------------------------------------------
--
-- Generated Configuration for pad_tb
--
-- Generated
--  by:  wig
--  on:  Fri Jul 15 14:47:37 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pad_tb-struct-conf-c.vhd,v 1.2 2005/07/15 16:20:03 wig Exp $
-- $Date: 2005/07/15 16:20:03 $
-- $Log: pad_tb-struct-conf-c.vhd,v $
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
-- Start of Generated Configuration pad_tb_struct_conf / pad_tb
--
configuration pad_tb_struct_conf of pad_tb is

        for struct

	    	-- Generated Configuration
			for i_padframe : padframe
				use configuration work.padframe_struct_conf;
			end for;


	end for; 
end pad_tb_struct_conf;
--
-- End of Generated Configuration pad_tb_struct_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
