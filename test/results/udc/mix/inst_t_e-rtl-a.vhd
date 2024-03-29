-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_t_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 11:02:57 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-a.vhd,v 1.1 2007/03/03 11:17:34 wig Exp $
-- $Date: 2007/03/03 11:17:34 $
-- $Log: inst_t_e-rtl-a.vhd,v $
-- Revision 1.1  2007/03/03 11:17:34  wig
-- Extended ::udc: language dependent %AINS% and %PINS%: e.g. <VHDL>...</VHDL>
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.101 2007/03/01 16:28:38 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.47 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch

HOOK: global text to add to head of architecture, here is %::inst%
--
--
-- Start of Generated Architecture rtl of inst_t_e
--
architecture rtl of inst_t_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component inst_a_e	-- a instance
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_a_e
			p_mix_signal_aa_ba_go	: out	std_ulogic;
			p_mix_signal_bb_ab_gi	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_a_e
		);
	end component;
	-- ---------

	component inst_b_e	-- Change parent to verilog
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_b_e
			p_mix_signal_aa_ba_gi	: in	std_ulogic;
			p_mix_signal_bb_ab_go	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_b_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	signal_aa_ba	: std_ulogic; 
		signal	s_int_signal_bb_ab	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	--
	-- End of Generated Signal List
	--




begin


	--
	-- Generated Concurrent Statements
	--

	--
	-- Generated Signal Assignments
	--
		signal_bb_ab	<=	s_int_signal_bb_ab;  -- __I_O_BUS_PORT


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_a_i
		inst_a_i: inst_a_e	-- a instance
		port map (

			p_mix_signal_aa_ba_go => signal_aa_ba,	-- signal test aa to ba
			p_mix_signal_bb_ab_gi => s_int_signal_bb_ab	-- vector test bb to ab
		);

		-- End of Generated Instance Port Map for inst_a_i

		-- Generated Instance Port Map for inst_b_i
		inst_b_i: inst_b_e	-- Change parent to verilog
		port map (

			p_mix_signal_aa_ba_gi => signal_aa_ba,	-- signal test aa to ba
			p_mix_signal_bb_ab_go => s_int_signal_bb_ab	-- vector test bb to ab
		);

		-- End of Generated Instance Port Map for inst_b_i



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
