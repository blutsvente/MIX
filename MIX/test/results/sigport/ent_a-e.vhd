-- -------------------------------------------------------------
--
--  Entity Declaration for ent_a
--
-- Generated
--  by:  wig
--  on:  Fri Dec 19 16:26:29 2003
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-e.vhd,v 1.1 2003/12/22 08:40:21 wig Exp $
-- $Date: 2003/12/22 08:40:21 $
-- $Log: ent_a-e.vhd,v $
-- Revision 1.1  2003/12/22 08:40:21  wig
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

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity ent_a
--
entity ent_a is
        -- Generics:
		-- No Generated Generics for Entity ent_a

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_a
			p_mix_sig_01_go	: out	std_ulogic;
			p_mix_sig_03_go	: out	std_ulogic;
			p_mix_sig_04_gi	: in	std_ulogic;
			p_mix_sig_05_2_1_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_sig_06_gi	: in	std_ulogic_vector(3 downto 0);
			p_mix_sig_i_ae_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_sig_o_ae_go	: out	std_ulogic_vector(7 downto 0);
			port_i_a	: in	std_ulogic;
			port_o_a	: out	std_ulogic;
			sig_07	: in	std_ulogic_vector(5 downto 0);
			sig_08	: out	std_ulogic_vector(8 downto 2);
			sig_13	: out	std_ulogic_vector(4 downto 0);
			sig_i_a2	: in	std_ulogic;
			sig_o_a2	: out	std_ulogic
		-- End of Generated Port for Entity ent_a
		);
end ent_a;
--
-- End of Generated Entity ent_a
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
