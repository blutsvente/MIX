-- -------------------------------------------------------------
--
-- Generated Configuration for ent_b
--
-- Generated
--  by:  wig
--  on:  Fri Dec 19 16:26:29 2003
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_b-RTL-CONF-c.vhd,v 1.1 2003/12/22 08:40:25 wig Exp $
-- $Date: 2003/12/22 08:40:25 $
-- $Log: ent_b-RTL-CONF-c.vhd,v $
-- Revision 1.1  2003/12/22 08:40:25  wig
-- Added testcase bitsplice and sigport.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.25 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_b_RTL_CONF / ent_b
--
configuration ent_b_RTL_CONF of ent_b is
        for rtl

	    	-- Generated Configuration
			for inst_ba : ent_ba
				use configuration work.ent_ba_RTL_CONF;
			end for;
			for inst_bb : ent_bb
				use configuration work.ent_bb_RTL_CONF;
			end for;


	end for; 
end ent_b_RTL_CONF;
--
-- End of Generated Configuration ent_b_RTL_CONF
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
