-- -------------------------------------------------------------
--
--  Entity Declaration for inst_t_e
--
-- Generated
--  by:  wig
--  on:  Thu Jan 19 07:52:39 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../autoopen.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-e.vhd,v 1.3 2006/01/19 08:50:42 wig Exp $
-- $Date: 2006/01/19 08:50:42 $
-- $Log: inst_t_e-e.vhd,v $
-- Revision 1.3  2006/01/19 08:50:42  wig
-- Updated testcases, left 6 failing now (constant, bitsplice/X, ...)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.75 2006/01/18 16:59:29 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_t_e
--
entity inst_t_e is

	-- Generics:
		-- No Generated Generics for Entity inst_t_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_t_e
			s_ai14	: in	std_ulogic_vector(7 downto 0);
			s_ai16	: in	std_ulogic_vector(7 downto 0);
			s_ai6	: in	std_ulogic;
			s_ai8	: in	std_ulogic;
			s_aio17	: inout	std_ulogic;
			s_aio18	: inout	std_ulogic;
			s_aio19	: inout	std_ulogic;
			s_ao11	: out	std_ulogic_vector(7 downto 0);
			s_ao13	: out	std_ulogic_vector(7 downto 0);
			s_ao3	: out	std_ulogic;
			s_ao5	: out	std_ulogic;
			s_eo3	: out	std_ulogic;
			s_eo5	: out	std_ulogic
		-- End of Generated Port for Entity inst_t_e
		);
end inst_t_e;
--
-- End of Generated Entity inst_t_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
