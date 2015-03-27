-- -------------------------------------------------------------
--
-- Generated Configuration for vgca_cpu
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 19:03:15 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca_cpu-struct-conf-c.vhd,v 1.2 2005/04/14 06:53:00 wig Exp $
-- $Date: 2005/04/14 06:53:00 $
-- $Log: vgca_cpu-struct-conf-c.vhd,v $
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
-- Start of Generated Configuration vgca_cpu_struct_conf / vgca_cpu
--
configuration vgca_cpu_struct_conf of vgca_cpu is
        for struct

	    	-- Generated Configuration
			for i_cpu_watch : cpu_watch
				use configuration work.cpu_watch_struct_conf;
			end for;


	end for; 
end vgca_cpu_struct_conf;
--
-- End of Generated Configuration vgca_cpu_struct_conf
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------