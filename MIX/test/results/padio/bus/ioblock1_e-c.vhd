-- -------------------------------------------------------------
--
-- Generated Configuration for ioblock1_e
--
-- Generated
--  by:  wig
--  on:  Wed Jul 16 09:56:49 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock1_e-c.vhd,v 1.1 2004/04/06 10:44:21 wig Exp $
-- $Date: 2004/04/06 10:44:21 $
-- $Log: ioblock1_e-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:21  wig
-- Adding result/padio
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.19 2003/07/09 07:52:44 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.13 , wilfried.gaensheimer@micronas.com
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
			for ioc_disp_2 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_3 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_4 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_5 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_6 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_7 : ioc_r_io
				use configuration work.ioc_r_io_conf;
			end for;
			for ioc_disp_8 : ioc_r_io
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