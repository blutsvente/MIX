-- -------------------------------------------------------------
--
-- Generated Configuration for ent_a
--
-- Generated
--  by:  wig
--  on:  Wed Nov  2 10:48:49 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-struct-conf-c.vhd,v 1.1 2005/11/02 12:53:46 wig Exp $
-- $Date: 2005/11/02 12:53:46 $
-- $Log: ent_a-struct-conf-c.vhd,v $
-- Revision 1.1  2005/11/02 12:53:46  wig
-- fixed issue 20051018d and more
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.66 2005/10/24 15:43:48 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.38 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_a_struct_conf / ent_a
--
configuration ent_a_struct_conf of ent_a is

	for struct

			-- Generated Configuration
			for inst_aa : ent_aa
				use configuration work.ent_aa_struct_conf;
			end for;
			for inst_ab : ent_ab
				use configuration work.ent_ab_struct_conf;
			end for;


	end for; 
end ent_a_struct_conf;
--
-- End of Generated Configuration ent_a_struct_conf
--


--
--!End of Configuration/ies
-- --------------------------------------------------------------
