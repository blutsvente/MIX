-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_a
--
-- Generated
--  by:  wig
--  on:  Fri Dec 19 16:38:59 2003
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../sigport.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_a-rtl-a.vhd,v 1.1 2003/12/22 08:40:30 wig Exp $
-- $Date: 2003/12/22 08:40:30 $
-- $Log: ent_a-rtl-a.vhd,v $
-- Revision 1.1  2003/12/22 08:40:30  wig
-- Added testcase bitsplice and sigport.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Revision: 1.25 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of ent_a
--
architecture rtl of ent_a is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ent_aa	-- 
		-- No Generated Generics
		port (
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
	end component;
	-- ---------

	component ent_ab	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_ab
			port_ab_1	: in	std_ulogic;
			port_ab_2	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			sig_13	: in	std_ulogic_vector(4 downto 0)
		-- End of Generated Port for Entity ent_ab
		);
	end component;
	-- ---------

	component ent_ac	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_ac
			port_ac_2	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity ent_ac
		);
	end component;
	-- ---------

	component ent_ad	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_ad
			port_ad_2	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity ent_ad
		);
	end component;
	-- ---------

	component ent_ae	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_ae
			port_ae_2	: in	std_ulogic_vector(4 downto 0);
			port_ae_5	: in	std_ulogic_vector(3 downto 0);
			port_ae_6	: in	std_ulogic_vector(3 downto 0);
			sig_07	: in	std_ulogic_vector(5 downto 0);
			sig_08	: in	std_ulogic_vector(8 downto 2);
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_ae
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	sig_01	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_02	: std_ulogic_vector(4 downto 0); 
			signal	sig_03	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_04	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_05	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_06	: std_ulogic_vector(3 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_sig_07	: std_ulogic_vector(5 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_sig_08	: std_ulogic_vector(8 downto 2); -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_int_sig_13	: std_ulogic_vector(4 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_i_ae	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	sig_o_ae	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			p_mix_sig_01_go <= sig_01;  -- __I_O_BIT_PORT
			p_mix_sig_03_go <= sig_03;  -- __I_O_BIT_PORT
			sig_04 <= p_mix_sig_04_gi;  -- __I_I_BIT_PORT
			p_mix_sig_05_2_1_go(1 downto 0) <= sig_05(2 downto 1);  -- __I_O_SLICE_PORT
			sig_06 <= p_mix_sig_06_gi;  -- __I_I_BUS_PORT
			s_int_sig_07 <= sig_07;  -- __I_I_BUS_PORT
			sig_08 <= s_int_sig_08;  -- __I_O_BUS_PORT
			sig_13 <= s_int_sig_13;  -- __I_O_BUS_PORT
			sig_i_ae <= p_mix_sig_i_ae_gi;  -- __I_I_BUS_PORT
			p_mix_sig_o_ae_go <= sig_o_ae;  -- __I_O_BUS_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: ent_aa
		port map (
			port_aa_1 => sig_01, -- Use internally test1Will create p_mix_sig_1_go port
			port_aa_2 => sig_02(0), -- Use internally test2, no port generated
			port_aa_3 => sig_03, -- Interhierachy link, will create p_mix_sig_3_go
			port_aa_4 => sig_04, -- Interhierachy link, will create p_mix_sig_4_gi
			port_aa_5 => sig_05, -- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,...
			port_aa_6 => sig_06, -- Conflicting definition (X2)
			sig_07 => s_int_sig_07, -- Conflicting definition, IN false!
			sig_08 => s_int_sig_08, -- VHDL intermediate needed (port name)
			sig_13 => s_int_sig_13 -- Create internal signal name
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: ent_ab
		port map (
			port_ab_1 => sig_01, -- Use internally test1Will create p_mix_sig_1_go port
			port_ab_2 => sig_02(1), -- Use internally test2, no port generated
			sig_13 => s_int_sig_13 -- Create internal signal name
		);
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: ent_ac
		port map (
			port_ac_2 => sig_02(3) -- Use internally test2, no port generated
		);
		-- End of Generated Instance Port Map for inst_ac

		-- Generated Instance Port Map for inst_ad
		inst_ad: ent_ad
		port map (
			port_ad_2 => sig_02(4) -- Use internally test2, no port generated
		);
		-- End of Generated Instance Port Map for inst_ad

		-- Generated Instance Port Map for inst_ae
		inst_ae: ent_ae
		port map (
			port_ae_2(0) => sig_02(0),
			port_ae_2(1) => sig_02(1),
			port_ae_2(3) => sig_02(3),
			port_ae_2(4) => sig_02(4), -- Use internally test2, no port generated
			port_ae_5 => sig_05, -- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,...
			port_ae_6 => sig_06, -- Conflicting definition (X2)
			sig_07 => s_int_sig_07, -- Conflicting definition, IN false!
			sig_08 => s_int_sig_08, -- VHDL intermediate needed (port name)
			sig_i_ae => sig_i_ae, -- Input Bus
			sig_o_ae => sig_o_ae -- Output Bus
		);
		-- End of Generated Instance Port Map for inst_ae

		-- Generated Instance Port Map for inst_ae2
		inst_ae2: ent_ae

		;
		-- End of Generated Instance Port Map for inst_ae2



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
