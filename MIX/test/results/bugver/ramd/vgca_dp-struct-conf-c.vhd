-- -------------------------------------------------------------
--
-- Generated Configuration for vgca_dp
--
-- Generated
--  by:  wig
--  on:  Wed Aug  6 13:50:14 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\ramd20030717.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_dp-struct-conf-c.vhd,v 1.1 2004/04/06 11:15:57 wig Exp $
-- $Date: 2004/04/06 11:15:57 $
-- $Log: vgca_dp-struct-conf-c.vhd,v $
-- Revision 1.1  2004/04/06 11:15:57  wig
-- Adding result/bugver
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.22 2003/07/23 13:34:40 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.14 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration vgca_dp_struct_conf / vgca_dp
--
configuration vgca_dp_struct_conf of vgca_dp is
        for struct

	    	-- Generated Configuration
			for i_dp_dd : dp_dd
				use configuration work.dp_dd_struct_conf;
			end for;
			for i_dp_ga : dp_ga
				use configuration work.dp_ga_struct_conf;
			end for;


	end for; 
end vgca_dp_struct_conf;
--
-- End of Generated Configuration vgca_dp_struct_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------
