-- -------------------------------------------------------------
--
-- Generated Configuration for ent_t
--
-- Generated
--  by:  wig
--  on:  Tue Mar 23 10:47:28 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -sheet HIER=HIER_UAMN -strip -nodelta ../../verilog.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-rtl-conf-c.vhd,v 1.1 2004/04/06 10:15:28 wig Exp $
-- $Date: 2004/04/06 10:15:28 $
-- $Log: ent_t-rtl-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 10:15:28  wig
-- Adding result/verilog testcase, again
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.26 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_t_rtl_conf / ent_t
--
configuration ent_t_rtl_conf of ent_t is
        for rtl

	    	-- Generated Configuration
			-- __I_NO_CONFIG_VERILOG --for inst_a : ent_a
			-- __I_NO_CONFIG_VERILOG --	use configuration work.ent_a_rtl_conf;
			-- __I_NO_CONFIG_VERILOG --end for;
			for inst_b : ent_b
				use configuration work.ent_b_rtl_conf;
			end for;


	end for; 
end ent_t_rtl_conf;
--
-- End of Generated Configuration ent_t_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
