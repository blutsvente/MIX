-- -------------------------------------------------------------
--
--  Entity Declaration for inst_xa_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 11:02:57 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_xa_e-e.vhd,v 1.1 2007/03/03 11:17:34 wig Exp $
-- $Date: 2007/03/03 11:17:34 $
-- $Log: inst_xa_e-e.vhd,v $
-- Revision 1.1  2007/03/03 11:17:34  wig
-- Extended ::udc: language dependent %AINS% and %PINS%: e.g. <VHDL>...</VHDL>
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.101 2007/03/01 16:28:38 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity inst_xa_e
--
entity inst_xa_e is
HOOK: global hook in entity
	-- Generics:
		-- No Generated Generics for Entity inst_xa_e

	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_xa_e
			port_xa_i	: in	std_ulogic;	-- signal test aa to ba
			port_xa_o	: out	std_ulogic	-- open signal to create port
		-- End of Generated Port for Entity inst_xa_e
		);
end inst_xa_e;
--
-- End of Generated Entity inst_xa_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------