-- -------------------------------------------------------------
--
-- Generated Configuration for pad_tb
--
-- Generated
--  by:  wig
--  on:  Thu Jan 19 07:44:48 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pad_tb-struct-conf-c.vhd,v 1.4 2006/01/19 08:50:41 wig Exp $
-- $Date: 2006/01/19 08:50:41 $
-- $Log: pad_tb-struct-conf-c.vhd,v $
-- Revision 1.4  2006/01/19 08:50:41  wig
-- Updated testcases, left 6 failing now (constant, bitsplice/X, ...)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.75 2006/01/18 16:59:29 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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
