-- -------------------------------------------------------------
--
-- Generated Configuration for inst_t_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 09:45:57 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-conf-c.vhd,v 1.1 2007/03/03 11:17:34 wig Exp $
-- $Date: 2007/03/03 11:17:34 $
-- $Log: inst_t_e-rtl-conf-c.vhd,v $
-- Revision 1.1  2007/03/03 11:17:34  wig
-- Extended ::udc: language dependent %AINS% and %PINS%: e.g. <VHDL>...</VHDL>
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.101 2007/03/01 16:28:38 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_t_e_rtl_conf / inst_t_e
--
configuration inst_t_e_rtl_conf of inst_t_e is

	for rtl

			-- Generated Configuration
			for inst_a_i : inst_a_e
				use configuration work.inst_a_e_rtl_conf;
			end for;
			-- __I_NO_CONFIG_VERILOG --for inst_b_i : inst_b_e
			-- __I_NO_CONFIG_VERILOG --	use configuration work.inst_b_e_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;


	end for; 
end inst_t_e_rtl_conf;
--
-- End of Generated Configuration inst_t_e_rtl_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
