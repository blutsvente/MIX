-- -------------------------------------------------------------
--
--  Entity Declaration for inst_aa
--
-- Generated
--  by:  wig
--  on:  Thu Feb 10 18:54:13 2005
--  cmd: H:/work/eclipse/MIX/mix_0.pl -strip -nodelta ../typecast.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_aa-e.vhd,v 1.3 2005/04/14 06:53:01 wig Exp $
-- $Date: 2005/04/14 06:53:01 $
-- $Log: inst_aa-e.vhd,v $
-- Revision 1.3  2005/04/14 06:53:01  wig
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

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity inst_aa
--
entity inst_aa is
        -- Generics:
		-- No Generated Generics for Entity inst_aa

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_aa
			port_a_1	: out	std_ulogic;
			port_a_11	: out	std_ulogic_vector(7 downto 0);
			port_a_3	: out	std_ulogic_vector(7 downto 0);
			port_a_5	: out	std_ulogic;
			port_a_7	: out	std_logic_vector(7 downto 0);
			port_a_9	: out	std_ulogic;
			signal_10	: out	std_logic;
			signal_12	: out	std_logic_vector(15 downto 0);
			signal_2	: out	std_logic;
			signal_4	: out	std_logic_vector(15 downto 0);
			signal_6	: out	std_logic;
			signal_8	: out	std_ulogic_vector(15 downto 0)
		-- End of Generated Port for Entity inst_aa
		);
end inst_aa;
--
-- End of Generated Entity inst_aa
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
