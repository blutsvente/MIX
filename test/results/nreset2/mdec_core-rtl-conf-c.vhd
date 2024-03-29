-- -------------------------------------------------------------
--
-- Generated Configuration for mdec_core
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:56:34 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\nreset2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: mdec_core-rtl-conf-c.vhd,v 1.1 2004/04/06 10:46:43 wig Exp $
-- $Date: 2004/04/06 10:46:43 $
-- $Log: mdec_core-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:46:43  wig
-- Adding result/nreset2
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
-- Start of Generated Configuration mdec_core_rtl_conf / mdec_core
--
configuration mdec_core_rtl_conf of mdec_core is
        for rtl

	    	-- Generated Configuration
			-- __I_NO_CONFIG_VERILOG --for aou_i1 : aou
			-- __I_NO_CONFIG_VERILOG --	use configuration work.aou_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for cgu_i1 : cgu
			-- __I_NO_CONFIG_VERILOG --	use configuration work.cgu_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for cpu_i1 : cpu
			-- __I_NO_CONFIG_VERILOG --	use configuration work.cpu_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for ema_i1 : ema
			-- __I_NO_CONFIG_VERILOG --	use configuration work.ema_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			for ga_i1 : ga
				use configuration work.ga_rtl_conf;
			end for;
			-- __I_NO_CONFIG_VERILOG --for i58_io_logic_i1 : i58_io_logic
			-- __I_NO_CONFIG_VERILOG --	use configuration work.i58_io_logic_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for ifu_top_i1 : ifu_top
			-- __I_NO_CONFIG_VERILOG --	use configuration work.ifu_top_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for pdu_i1 : pdu
			-- __I_NO_CONFIG_VERILOG --	use configuration work.pdu_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			-- __I_NO_CONFIG_VERILOG --for tsd_top_i1 : tsd_top
			-- __I_NO_CONFIG_VERILOG --	use configuration work.tsd_top_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			for vip_i1 : vip
				use configuration work.vip_rtl_c0;
			end for;
			for vo_i1 : vo
				use configuration work.vo_rtl_conf;
			end for;
			for vor_i1 : vor
				use configuration work.vor_rtl_conf;
			end for;


	end for; 
end mdec_core_rtl_conf;
--
-- End of Generated Configuration mdec_core_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
