-- -------------------------------------------------------------
--
-- Generated Configuration for ioblock0_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock0_e-conf-c.vhd,v 1.1 2004/04/06 10:44:20 wig Exp $
-- $Date: 2004/04/06 10:44:20 $
-- $Log: ioblock0_e-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:20  wig
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
-- Start of Generated Configuration ioblock0_e_conf / ioblock0_e
--
configuration ioblock0_e_conf of ioblock0_e is
        for rtl

	    	-- Generated Configuration
			for ioc_data_i1 : ioc_g_i
				use configuration work.ioc_g_i_conf;
			end for;
			for ioc_data_o1 : ioc_g_o
				use configuration work.ioc_g_o_conf;
			end for;


	end for; 
end ioblock0_e_conf;
--
-- End of Generated Configuration ioblock0_e_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
