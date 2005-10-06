-- -------------------------------------------------------------
--
--  Entity Declaration for ioblock0_e
--
-- Generated
--  by:  wig
--  on:  Mon Jul 18 15:55:26 2005
--  cmd: h:/work/eclipse/mix/mix_0.pl -strip -nodelta ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock0_e-e.vhd,v 1.2 2005/10/06 11:16:05 wig Exp $
-- $Date: 2005/10/06 11:16:05 $
-- $Log: ioblock0_e-e.vhd,v $
-- Revision 1.2  2005/10/06 11:16:05  wig
-- Got testcoverage up, fixed generic problem, prepared report
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.57 2005/07/18 08:58:22 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.36 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity ioblock0_e
--
entity ioblock0_e is

        -- Generics:
		-- No Generated Generics for Entity ioblock0_e


    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ioblock0_e
			p_mix_data_i1_go	: out	std_ulogic_vector(7 downto 0);
			p_mix_data_o1_gi	: in	std_ulogic_vector(7 downto 0);
			p_mix_iosel_0_0_0_gi	: in	std_ulogic; -- __W_SINGLEBITBUS
			p_mix_pad_di_1_gi	: in	std_ulogic;
			p_mix_pad_do_2_go	: out	std_ulogic;
			p_mix_pad_en_2_go	: out	std_ulogic
		-- End of Generated Port for Entity ioblock0_e
		);
end ioblock0_e;
--
-- End of Generated Entity ioblock0_e
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
