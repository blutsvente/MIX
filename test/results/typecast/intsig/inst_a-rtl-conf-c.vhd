-- -------------------------------------------------------------
--
-- Generated Configuration for inst_a
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 18:56:39 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -nodelta ../../typecast.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a-rtl-conf-c.vhd,v 1.2 2005/04/14 06:53:00 wig Exp $
-- $Date: 2005/04/14 06:53:00 $
-- $Log: inst_a-rtl-conf-c.vhd,v $
-- Revision 1.2  2005/04/14 06:53:00  wig
-- Updates: fixed import errors and adjusted I2C parser
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.49 2005/01/27 08:20:30 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.33 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration inst_a_rtl_conf / inst_a
--
configuration inst_a_rtl_conf of inst_a is
        for rtl

	    	-- Generated Configuration
			for inst_aa_i : inst_aa
				use configuration work.inst_aa_rtl_conf;
			end for;
			for inst_ab_i : inst_ab
				use configuration work.inst_ab_rtl_conf;
			end for;


	end for; 
end inst_a_rtl_conf;
--
-- End of Generated Configuration inst_a_rtl_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------