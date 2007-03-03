-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_b_e
--
-- Generated
--  by:  wig
--  on:  Sat Mar  3 11:02:57 2007
--  cmd: /cygdrive/c/Documents and Settings/wig/My Documents/work/MIX/mix_0.pl -nodelta ../../udc.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_b_e-rtl-a.vhd,v 1.1 2007/03/03 11:17:34 wig Exp $
-- $Date: 2007/03/03 11:17:34 $
-- $Log: inst_b_e-rtl-a.vhd,v $
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
-- Start of Generated Architecture rtl of inst_b_e
--
architecture rtl of inst_b_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
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

	component inst_bb_e	-- bb instance
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_bb_e
			port_bb_o	: out	std_ulogic_vector(7 downto 0)	-- vector test bb to ab
		-- End of Generated Port for Entity inst_bb_e
		);
	end component;
	-- ---------

	component inst_vb_e	-- verilog udc inst_bc2_i
		-- No Generated Generics
		-- Generated Generics for Entity inst_vb_e
		-- End of Generated Generics for Entity inst_vb_e
		-- No Generated Port
	end component;
	-- ---------

	component inst_be_i	-- no verilog udc here
		-- No Generated Generics
		-- Generated Generics for Entity inst_be_i
		-- End of Generated Generics for Entity inst_be_i
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	signal_aa_ba	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	signal_bb_ab	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
	--
	-- End of Generated Signal List
	--


udc: THIS GOES TO DECL of inst_b_i

begin

udc: THIS ARE TWO LINES in BODY of inst_b_i
SECOND LINE
	--
	-- Generated Concurrent Statements
	--

	--
	-- Generated Signal Assignments
	--
		signal_aa_ba	<=	p_mix_signal_aa_ba_gi;  -- __I_I_BIT_PORT
		p_mix_signal_bb_ab_go	<=	signal_bb_ab;  -- __I_O_BUS_PORT


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_ba_i
		inst_ba_i: inst_xa_e	-- mulitple instantiated
		port map (

			port_xa_i => signal_aa_ba,	-- signal test aa to ba
			port_xa_o => open	-- open signal to create port
		);

		-- End of Generated Instance Port Map for inst_ba_i

		-- Generated Instance Port Map for inst_bb_i
		inst_bb_i: inst_bb_e	-- bb instance
		port map (
			port_bb_o => signal_bb_ab	-- vector test bb to ab
		);

		-- End of Generated Instance Port Map for inst_bb_i

		-- Generated Instance Port Map for inst_bc1_i
		inst_bc1_i: inst_vb_e	-- verilog udc inst_bc2_i

		;

		-- End of Generated Instance Port Map for inst_bc1_i

udc: preinst_udc for inst_bc2_i
		-- Generated Instance Port Map for inst_bc2_i
		inst_bc2_i: inst_vb_e	-- verilog udc inst_bc2_i

		;

		-- End of Generated Instance Port Map for inst_bc2_i

udc: post_inst_udc for inst_bc2_i
udc: preinst_udc for inst_bc2_i
		-- Generated Instance Port Map for inst_be_i
		inst_be_i: inst_be_i	-- no verilog udc here

		;

		-- End of Generated Instance Port Map for inst_be_i

udc: post_inst_udc for inst_bc2_i
		-- Generated Instance Port Map for inst_bf_i
		inst_bf_i: inst_be_i	-- no verilog udc here

		;

		-- End of Generated Instance Port Map for inst_bf_i



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
