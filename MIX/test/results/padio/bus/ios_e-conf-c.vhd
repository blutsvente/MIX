-- -------------------------------------------------------------
--
-- Generated Configuration for ios_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ios_e-conf-c.vhd,v 1.1 2004/04/06 10:44:24 wig Exp $
-- $Date: 2004/04/06 10:44:24 $
-- $Log: ios_e-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:24  wig
-- Adding result/padio
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.17 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ios_e_conf / ios_e
--
configuration ios_e_conf of ios_e is
        for rtl

	    	-- Generated Configuration
			for ioblock_0 : ioblock0_e
				use configuration work.ioblock0_e_conf;
			end for;
			for ioblock_1 : ioblock1_e
				use configuration work.ioblock1_e_conf;
			end for;
			for ioblock_2 : ioblock2_e
				use configuration work.ioblock2_e_conf;
			end for;
			for ioblock_3 : ioblock3_e
				use configuration work.ioblock3_e_conf;
			end for;


	end for; 
end ios_e_conf;
--
-- End of Generated Configuration ios_e_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
