-- -------------------------------------------------------------
--
--  Entity Declaration for ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Oct 13 08:24:14 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../intra.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-e.vhd,v 1.1 2005/10/13 09:09:44 wig Exp $
-- $Date: 2005/10/13 09:09:44 $
-- $Log: ent_t-e.vhd,v $
-- Revision 1.1  2005/10/13 09:09:44  wig
-- Added intermediate CONN sheet split
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.59 2005/10/06 11:21:44 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.37 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ent_t
--
entity ent_t is

	-- Generics:
		generic(
		-- Generated Generics for Entity ent_t
			generic_20	: integer	:= 32;	-- Parameter for generic on topGeneric on top
		-- End of Generated Generics for Entity ent_t
		);
	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_t
			const_p_18	: in	std_ulogic_vector(11 downto 0);	-- Constant on top
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
