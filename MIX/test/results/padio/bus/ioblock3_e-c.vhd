-- -------------------------------------------------------------
--
-- Generated Configuration for ioblock3_e
--
-- Generated
--  by:  wig
--  on:  Wed Jul 16 09:56:49 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock3_e-c.vhd,v 1.1 2004/04/06 10:44:22 wig Exp $
-- $Date: 2004/04/06 10:44:22 $
-- $Log: ioblock3_e-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:22  wig
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
-- Start of Generated Configuration ioblock3_e_conf / ioblock3_e
--
configuration ioblock3_e_conf of ioblock3_e is
        for rtl

	    	-- Generated Configuration
			for ioc_data_10 : ioc_r_iou
				use configuration work.ioc_r_iou_conf;
			end for;
			for ioc_data_9 : ioc_r_iou
				use configuration work.ioc_r_iou_conf;
			end for;
			for ioc_data_i33 : ioc_g_i
				use configuration work.ioc_g_i_conf;
			end for;
			for ioc_data_i34 : ioc_g_i
				use configuration work.ioc_g_i_conf;
			end for;
			for ioc_data_o35 : ioc_g_o
				use configuration work.ioc_g_o_conf;
			end for;
			for ioc_data_o36 : ioc_g_o
				use configuration work.ioc_g_o_conf;
			end for;
			for ioc_disp_10 : ioc_r_io3
				use configuration work.ioc_r_io3_conf;
			end for;
			for ioc_disp_9 : ioc_r_io3
				use configuration work.ioc_r_io3_conf;
			end for;


	end for; 
end ioblock3_e_conf;
--
-- End of Generated Configuration ioblock3_e_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
