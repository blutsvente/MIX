-- -------------------------------------------------------------
--
--  Entity Declaration for ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Mar 16 07:48:49 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -conf macro._MP_VHDL_USE_ENTY_MP_=Overwritten vhdl_enty from cmdline -conf macro._MP_VHDL_HOOK_ARCH_BODY_MP_=Use macro vhdl_hook_arch_body -conf macro._MP_ADD_MY_OWN_MP_=overloading my own macro -nodelta ../../configuration.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-e.vhd,v 1.1 2006/03/16 14:12:15 wig Exp $
-- $Date: 2006/03/16 14:12:15 $
-- $Log: ent_t-e.vhd,v $
-- Revision 1.1  2006/03/16 14:12:15  wig
-- Added testcase for command line -conf add/overload
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.77 2006/03/14 08:10:34 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
-- adding to vhdl_use_enty
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

typedef use_enty_private std_ulogic_vector;

--

--
-- Start of Generated Entity ent_t
--
entity ent_t is

	-- Generics:
		-- No Generated Generics for Entity ent_t

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_t
			sig_i_a	: in	std_ulogic;
			sig_i_a2	: in	std_ulogic;
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);
			sig_o_a	: out	std_ulogic;
			sig_o_a2	: out	std_ulogic;
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_t
		);
end ent_t;
--
-- End of Generated Entity ent_t
--


--
--!End of Entity/ies
-- --------------------------------------------------------------