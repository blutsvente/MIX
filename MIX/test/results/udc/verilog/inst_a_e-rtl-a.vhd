-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Wed Apr  5 12:50:28 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.1 2006/04/10 15:42:11 wig Exp $
-- $Date: 2006/04/10 15:42:11 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.1  2006/04/10 15:42:11  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch

HOOK: global text to add to head of architecture, here is %::inst%
--
--
-- Start of Generated Architecture rtl of inst_a_e
--
architecture rtl of inst_a_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_xa_e	-- mulitple instantiated
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_xa_e
			port_xa_i	: in	std_ulogic;	-- signal test aa to ba
			port_xa_o	: out	std_ulogic	-- open signal to create port
		-- End of Generated Port for Entity inst_xa_e
		);
	end component;
	-- ---------

	component inst_ab_e	-- ab instance
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ab_e
			port_ab_i	: in	std_ulogic_vector(7 downto 0)	-- vector test bb to ab
		-- End of Generated Port for Entity inst_ab_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	mix_logic0	: std_ulogic; 
			signal	signal_aa_ba	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	signal_bb_ab	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--




begin

udc: THIS GOES TO BODY of inst_a_i;
	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			mix_logic0 <= '0';
			p_mix_signal_aa_ba_go <= signal_aa_ba;  -- __I_O_BIT_PORT
			signal_bb_ab <= p_mix_signal_bb_ab_gi;  -- __I_I_BUS_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa_i
		inst_aa_i: inst_xa_e	-- mulitple instantiated
		port map (

			port_xa_i => mix_logic0,	-- tie to low to create port
			port_xa_o => signal_aa_ba	-- signal test aa to ba
		);
		-- End of Generated Instance Port Map for inst_aa_i

		-- Generated Instance Port Map for inst_ab_i
		inst_ab_i: inst_ab_e	-- ab instance
		port map (
			port_ab_i => signal_bb_ab	-- vector test bb to ab
		);
		-- End of Generated Instance Port Map for inst_ab_i



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------