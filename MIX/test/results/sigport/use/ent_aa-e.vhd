-- -------------------------------------------------------------
--
--  Entity Declaration for ent_aa
--
-- Generated
--  by:  wig
--  on:  Fri Dec 19 16:38:59 2003
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_aa-e.vhd,v 1.1 2003/12/22 08:40:30 wig Exp $
-- $Date: 2003/12/22 08:40:30 $
-- $Log: ent_aa-e.vhd,v $
-- Revision 1.1  2003/12/22 08:40:30  wig
-- Added testcase bitsplice and sigport.
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.25 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- Generated use statements
library use_a;
use use_a.c_a.c_b.all;
use use_a.c_a2.all;

--

--
-- Start of Generated Entity ent_aa
--
entity ent_aa is
        -- Generics:
		-- No Generated Generics for Entity ent_aa

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_aa
			port_aa_1	: out	std_ulogic;
			port_aa_2	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			port_aa_3	: out	std_ulogic;
			port_aa_4	: in	std_ulogic;
			port_aa_5	: out	std_ulogic_vector(3 downto 0);
			port_aa_6	: out	std_ulogic_vector(3 downto 0);
			sig_07	: out	std_ulogic_vector(5 downto 0);
			sig_08	: out	std_ulogic_vector(8 downto 2);
			sig_13	: out	std_ulogic_vector(4 downto 0)
		-- End of Generated Port for Entity ent_aa
		);
end ent_aa;
--
-- End of Generated Entity ent_aa
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
