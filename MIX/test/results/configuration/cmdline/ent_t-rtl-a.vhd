-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Jun 29 16:41:09 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -conf macro._MP_VHDL_USE_ENTY_MP_=Overwritten vhdl_enty from cmdline -conf macro._MP_VHDL_HOOK_ARCH_BODY_MP_=Use macro vhdl_hook_arch_body -conf macro._MP_ADD_MY_OWN_MP_=overloading my own macro ../../configuration.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t-rtl-a.vhd,v 1.2 2006/07/04 09:54:11 wig Exp $
-- $Date: 2006/07/04 09:54:11 $
-- $Log: ent_t-rtl-a.vhd,v $
-- Revision 1.2  2006/07/04 09:54:11  wig
-- Update more testcases, add configuration/cfgfile
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.90 2006/06/22 07:13:21 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.46 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
-- modifiy vhdl_use_arch 
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch

typedef vhdl_use_arch_def std_ulogic_vector;
-- end of vhdl_use_arch

--
--
-- Start of Generated Architecture rtl of ent_t
--
architecture rtl of ent_t is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component ent_a
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_a
			p_mix_sig_01_go	: out	std_ulogic;
			p_mix_sig_03_go	: out	std_ulogic;
			p_mix_sig_04_gi	: in	std_ulogic;
			p_mix_sig_05_2_1_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_sig_06_gi	: in	std_ulogic_vector(3 downto 0);
			p_mix_sig_i_ae_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_sig_o_ae_go	: out	std_ulogic_vector(7 downto 0);
			port_i_a	: in	std_ulogic;	-- Input Port
			port_o_a	: out	std_ulogic;	-- Output Port
			sig_07	: in	std_ulogic_vector(5 downto 0);	-- Conflicting definition, IN false!
			sig_08	: out	std_ulogic_vector(8 downto 2);	-- VHDL intermediate needed (port name)
			sig_13	: out	std_ulogic_vector(4 downto 0);	-- Create internal signal name
			sig_i_a2	: in	std_ulogic;	-- Input Port
			sig_o_a2	: out	std_ulogic	-- Output Port
		-- End of Generated Port for Entity ent_a
		);
	end component;
	-- ---------

	component ent_b
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_b
			port_b_1	: in	std_ulogic;	-- Will create p_mix_sig_1_go port
			port_b_3	: in	std_ulogic;	-- Interhierachy link, will create p_mix_sig_3_go
			port_b_4	: out	std_ulogic;	-- Interhierachy link, will create p_mix_sig_4_gi
			port_b_5_1	: in	std_ulogic; 	-- Bus, single bits go to outside, will create p_mix_sig_5_2_2_go __I_AUTO_REDUCED_BUS2SIGNAL
			port_b_5_2	: in	std_ulogic; 	-- Bus, single bits go to outside, will create P_MIX_sound_alarm_test5_1_1_GO __I_AUTO_REDUCED_BUS2SIGNAL
			port_b_6i	: in	std_ulogic_vector(3 downto 0);	-- Conflicting definition
			port_b_6o	: out	std_ulogic_vector(3 downto 0);	-- Conflicting definition
			sig_07	: in	std_ulogic_vector(5 downto 0);	-- Conflicting definition, IN false!
			sig_08	: in	std_ulogic_vector(8 downto 2)	-- VHDL intermediate needed (port name)
		-- End of Generated Port for Entity ent_b
		);
	end component;
	-- ---------

	component ent_c
		-- No Generated Generics
		-- Generated Generics for Entity ent_c
		-- End of Generated Generics for Entity ent_c
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	sig_01	: std_ulogic; 
		signal	sig_03	: std_ulogic; 
		signal	sig_04	: std_ulogic; 
		signal	sig_05	: std_ulogic_vector(3 downto 0); 
		signal	sig_06	: std_ulogic_vector(3 downto 0); 
		signal	sig_07	: std_ulogic_vector(5 downto 0); 
		signal	sig_08	: std_ulogic_vector(8 downto 2); 
		--  __I_OUT_OPEN signal	sig_13	: std_ulogic_vector(4 downto 0); 
	--
	-- End of Generated Signal List
	--




begin

Use macro vhdl_hook_arch_body
	--
	-- Generated Concurrent Statements
	--

	--
	-- Generated Signal Assignments
	--


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_a
		inst_a: ent_a
		port map (

			p_mix_sig_01_go => sig_01,	-- Use internally test1Will create p_mix_sig_1_go port
			p_mix_sig_03_go => sig_03,	-- Interhierachy link, will create p_mix_sig_3_go
			p_mix_sig_04_gi => sig_04,	-- Interhierachy link, will create p_mix_sig_4_gi
			p_mix_sig_05_2_1_go => sig_05(2 downto 1),	-- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			p_mix_sig_06_gi => sig_06,	-- Conflicting definition (X2)
			p_mix_sig_i_ae_gi => sig_i_ae,	-- Input Bus
			p_mix_sig_o_ae_go => sig_o_ae,	-- Output Bus
			port_i_a => sig_i_a,	-- Input Port
			port_o_a => sig_o_a,	-- Output Port
			sig_07 => sig_07,	-- Conflicting definition, IN false!
			sig_08 => sig_08,	-- VHDL intermediate needed (port name)
			sig_13 => open,	-- Create internal signal name -- __I_OUT_OPEN
			sig_i_a2 => sig_i_a2,	-- Input Port
			sig_o_a2 => sig_o_a2	-- Output Port
		);

		-- End of Generated Instance Port Map for inst_a

		-- Generated Instance Port Map for inst_b
		inst_b: ent_b
		port map (

			port_b_1 => sig_01,	-- Use internally test1Will create p_mix_sig_1_go port
			port_b_3 => sig_03,	-- Interhierachy link, will create p_mix_sig_3_go
			port_b_4 => sig_04,	-- Interhierachy link, will create p_mix_sig_4_gi
			port_b_5_1 => sig_05(2),	-- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			port_b_5_2 => sig_05(1),	-- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			port_b_6i => sig_06,	-- Conflicting definition (X2)
			port_b_6o => sig_06,	-- Conflicting definition (X2)
			sig_07 => sig_07,	-- Conflicting definition, IN false!
			sig_08 => sig_08	-- VHDL intermediate needed (port name)
		);

		-- End of Generated Instance Port Map for inst_b

		-- Generated Instance Port Map for inst_c
		inst_c: ent_c

		;

		-- End of Generated Instance Port Map for inst_c



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
