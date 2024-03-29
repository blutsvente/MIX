-- -------------------------------------------------------------
--
-- Generated Configuration for a_clk
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:58:21 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\..\padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: a_clk-rtl-conf-c.vhd,v 1.1 2004/04/06 10:44:18 wig Exp $
-- $Date: 2004/04/06 10:44:18 $
-- $Log: a_clk-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:44:18  wig
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
-- Start of Generated Configuration a_clk_rtl_conf / a_clk
--
configuration a_clk_rtl_conf of a_clk is
        for rtl

	    	-- Generated Configuration
			for control : a_fsm
				use configuration work.a_fsm_rtl_conf;
			end for;
			for ios : ios_e
				use configuration work.ios_e_conf;
			end for;
			for pad_pads : pad_pads_e
				use configuration work.pad_pads_e_conf;
			end for;
			for test_ctrl : testctrl_e
				use configuration work.testctrl_e_rtl_conf;
			end for;
			for u0_alreg : alreg
				use configuration work.alreg_rtl_conf;
			end for;
			for u1_alreg : alreg
				use configuration work.alreg_rtl_conf;
			end for;
			for u2_alreg : alreg
				use configuration work.alreg_rtl_conf;
			end for;
			for u3_alreg : alreg
				use configuration work.alreg_rtl_conf;
			end for;
			for u_counter : count4
				use configuration work.count4_rtl_conf;
			end for;
			for u_ddrv4 : ddrv4
				use configuration work.ddrv4_rtl_conf;
			end for;
			for u_keypad : keypad
				use configuration work.keypad_rtl_conf;
			end for;
			for u_keyscan : keyscan
				use configuration work.keyscan_rtl_conf;
			end for;
			for u_timegen : timegen
				use configuration work.timegen_rtl_conf;
			end for;


	end for; 
end a_clk_rtl_conf;
--
-- End of Generated Configuration a_clk_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
