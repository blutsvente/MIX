-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_b
--
-- Generated
--  by:  wig
--  on:  Thu Mar 16 07:48:49 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -conf macro._MP_VHDL_USE_ENTY_MP_=Overwritten vhdl_enty from cmdline -conf macro._MP_VHDL_HOOK_ARCH_BODY_MP_=Use macro vhdl_hook_arch_body -conf macro._MP_ADD_MY_OWN_MP_=overloading my own macro -nodelta ../../configuration.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_b-rtl-a.vhd,v 1.1 2006/03/16 14:12:15 wig Exp $
-- $Date: 2006/03/16 14:12:15 $
-- $Log: ent_b-rtl-a.vhd,v $
-- Revision 1.1  2006/03/16 14:12:15  wig
-- Added testcase for command line -conf add/overload
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.77 2006/03/14 08:10:34 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
-- modifiy vhdl_use_arch 
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch

typedef vhdl_use_arch_def std_ulogic_vector;
-- end of vhdl_use_arch

--
--
-- Start of Generated Architecture rtl of ent_b
--
architecture rtl of ent_b is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ent_ba
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component ent_bb
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
		--
		-- End of Generated Signal List
		--




begin

Use macro vhdl_hook_arch_body
	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_ba
		inst_ba: ent_ba

		;
		-- End of Generated Instance Port Map for inst_ba

		-- Generated Instance Port Map for inst_bb
		inst_bb: ent_bb

		;
		-- End of Generated Instance Port Map for inst_bb



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------