-- -------------------------------------------------------------
--
-- Generated Configuration for ioblock1_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:34 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock1_e-conf-c.vhd,v 1.1 2004/04/06 10:44:30 wig Exp $
-- $Date: 2004/04/06 10:44:30 $
-- $Log: ioblock1_e-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:30  wig
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
-- Start of Generated Configuration ioblock1_e_conf / ioblock1_e
--
configuration ioblock1_e_conf of ioblock1_e is
        for rtl

	    	-- Generated Configuration
			for ioc_r_io_12 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_13 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_14 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_15 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_16 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_17 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_r_io_18 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;


	end for; 
end ioblock1_e_conf;
--
-- End of Generated Configuration ioblock1_e_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
