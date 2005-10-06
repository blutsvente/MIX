-- -------------------------------------------------------------
--
--  Entity Declaration for inst_bug_e
--
-- Generated
--  by:  wig
--  on:  Thu Oct  6 12:55:50 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_bug_e-e.vhd,v 1.1 2005/10/06 13:36:57 wig Exp $
-- $Date: 2005/10/06 13:36:57 $
-- $Log: inst_bug_e-e.vhd,v $
-- Revision 1.1  2005/10/06 13:36:57  wig
-- New testcase or generics
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.59 2005/10/06 11:21:44 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.37 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_bug_e
--
entity inst_bug_e is

	-- Generics:
		generic(
		-- Generated Generics for Entity inst_bug_e
			CHROMA_GROUP_DELAY2_G	: integer	:= 1;
			CHROMA_GROUP_DELAY_G	: integer	:= 12;
			CHROMA_LINE_DELAY2_G	: integer	:= 3;
			CHROMA_LINE_DELAY_G	: integer	:= 0;
			CHROMA_PIPE_DELAY2_G	: integer	:= 2;
			CHROMA_PIPE_DELAY_G	: integer	:= 1
		-- End of Generated Generics for Entity inst_bug_e
		);
	-- Generated Port Declaration:
		-- No Generated Port for Entity inst_bug_e


end inst_bug_e;
--
-- End of Generated Entity inst_bug_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
