-- -------------------------------------------------------------
--
-- Generated Configuration for __COMMON__
--
-- Generated
--  by:  lutscher
--  on:  Tue Jun 23 10:43:20 2009
--  cmd: /home/lutscher/work/MIX/mix_1.pl a_clk.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author$
-- $Id$
-- $Date$
-- $Log$
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.109 2008/04/01 12:48:34 wig Exp 
--
-- Generator: mix_1.pl Version: Revision: 1.3 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration A_CLK_RTL_CONF / A_CLK
--
configuration A_CLK_RTL_CONF of A_CLK is

	for rtl

			-- Generated Configuration
			for PADS : PADS
				use configuration work.PADS_RTL_CONF;
			end for;
			for control : a_fsm
				use configuration work.a_fsm_RTL_CONF;
			end for;
			for u0_alreg : alreg
				use configuration work.alreg_RTL_CONF;
			end for;
			for u1_alreg : alreg
				use configuration work.alreg_RTL_CONF;
			end for;
			for u2_alreg : alreg
				use configuration work.alreg_RTL_CONF;
			end for;
			for u3_alreg : alreg
				use configuration work.alreg_RTL_CONF;
			end for;
			for u_counter : count4
				use configuration work.count4_RTL_CONF;
			end for;
			for u_ddrv4 : ddrv4
				use configuration work.ddrv4_RTL_CONF;
			end for;
			for u_keypad : keypad
				use configuration work.keypad_RTL_CONF;
			end for;
			for u_keyscan : keyscan
				use configuration work.keyscan_RTL_CONF;
			end for;
			for u_timegen : timegen
				use configuration work.timegen_RTL_CONF;
			end for;


	end for; 
end A_CLK_RTL_CONF;
--
-- End of Generated Configuration A_CLK_RTL_CONF
--

--
-- Start of Generated Configuration PADS_RTL_CONF / PADS
--
configuration PADS_RTL_CONF of PADS is

	for rtl

			-- Generated Configuration
			for Pad_1 : padcell
				use configuration work.Pad_1_structural_conf;
			end for;
			for Pad_10 : padcell
				use configuration work.Pad_10_structural_conf;
			end for;
			for Pad_2 : padcell
				use configuration work.Pad_2_structural_conf;
			end for;
			for Pad_3 : padcell
				use configuration work.Pad_3_structural_conf;
			end for;
			for Pad_4 : padcell
				use configuration work.Pad_4_structural_conf;
			end for;
			for Pad_5 : padcell
				use configuration work.Pad_5_structural_conf;
			end for;
			for Pad_6 : padcell
				use configuration work.Pad_6_structural_conf;
			end for;
			for Pad_7 : padcell
				use configuration work.Pad_7_structural_conf;
			end for;
			for Pad_8 : padcell
				use configuration work.Pad_8_structural_conf;
			end for;
			for Pad_9 : padcell
				use configuration work.Pad_9_structural_conf;
			end for;


	end for; 
end PADS_RTL_CONF;
--
-- End of Generated Configuration PADS_RTL_CONF
--

--
-- Start of Generated Configuration ddrv4_RTL_CONF / ddrv4
--
configuration ddrv4_RTL_CONF of ddrv4 is

	for rtl

			-- Generated Configuration
			for d_ls_hr : ddrv
				use configuration work.d_ls_hr_RTL_CONF;
			end for;
			for d_ls_min : ddrv
				use configuration work.d_ls_min_RTL_CONF;
			end for;
			for d_ms_hr : ddrv
				use configuration work.d_ms_hr_RTL_CONF;
			end for;
			for d_ms_min : ddrv
				use configuration work.d_ms_min_RTL_CONF;
			end for;
			for u_and_f : and_f
				use configuration work.u_and_f_RTL_CONF;
			end for;


	end for; 
end ddrv4_RTL_CONF;
--
-- End of Generated Configuration ddrv4_RTL_CONF
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------