-- -------------------------------------------------------------
--
--  Entity Declaration for inst_ab_e
--
-- Generated
--  by:  wig
--  on:  Wed Nov 10 10:29:04 2004
--  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../genwidth.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ab_e-e.vhd,v 1.2 2004/11/10 09:54:10 wig Exp $
-- $Date: 2004/11/10 09:54:10 $
-- $Log: inst_ab_e-e.vhd,v $
-- Revision 1.2  2004/11/10 09:54:10  wig
-- testcase extended
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.46 2004/08/18 10:45:45 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.32 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity inst_ab_e
--
entity inst_ab_e is
        -- Generics:
		generic(
		-- Generated Generics for Entity inst_ab_e
			width	: integer	:= 8
		-- End of Generated Generics for Entity inst_ab_e
		);
    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity inst_ab_e
			y_p0_i	: in	std_ulogic_vector(width - 1 downto 0)
		-- End of Generated Port for Entity inst_ab_e
		);
end inst_ab_e;
--
-- End of Generated Entity inst_ab_e
--

--
--!End of Entity/ies
-- --------------------------------------------------------------