-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_ea_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:29 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ea_e-rtl-a.vhd,v 1.3 2006/06/26 08:39:43 wig Exp $
-- $Date: 2006/06/26 08:39:43 $
-- $Log: inst_ea_e-rtl-a.vhd,v $
-- Revision 1.3  2006/06/26 08:39:43  wig
-- Update more testcases (up to generic)
--
-- Revision 1.1  2004/04/06 10:50:21  wig
-- Adding result/mde_tests
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.37 2003/12/23 13:25:21 abauer Exp 
--
-- Generator: mix_0.pl Revision: 1.26 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture rtl of inst_ea_e
--
architecture rtl of inst_ea_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_eaa_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_eaa_e
			mbist_clut_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			mbist_fifo_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			reset_n	: in	std_ulogic;
			reset_n_s	: in	std_ulogic
		-- End of Generated Port for Entity inst_eaa_e
		);
	end component;
	-- ---------

	component inst_eab_e	-- 
		-- No Generated Generics
		-- Generated Generics for Entity inst_eab_e
		-- End of Generated Generics for Entity inst_eab_e
		port (
		-- Generated Port for Entity inst_eab_e
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic;
			v_select	: in	std_ulogic_vector(5 downto 0)
		-- End of Generated Port for Entity inst_eab_e
		);
	end component;
	-- ---------

	component inst_eac_e	-- 
		-- No Generated Generics
		-- Generated Generics for Entity inst_eac_e
		-- End of Generated Generics for Entity inst_eac_e
		port (
		-- Generated Port for Entity inst_eac_e
			adp_bist_fail	: out	std_ulogic;
			cp_laddr	: in	std_ulogic_vector(31 downto 0);
			cp_lcmd	: in	std_ulogic_vector(6 downto 0);
			cpu_bist_fail	: out	std_ulogic;
			cvi_sbist_fail0	: in	std_ulogic;
			cvi_sbist_fail1	: in	std_ulogic;
			ema_bist_fail	: out	std_ulogic;
			ga_sbist_fail0	: in	std_ulogic;
			ga_sbist_fail1	: in	std_ulogic;
			gpio_int	: out	std_ulogic_vector(4 downto 0);
			ifu_bist_fail	: out	std_ulogic;
			mcu_bist_fail	: out	std_ulogic;
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic;
			pdu_bist_fail0	: out	std_ulogic;
			pdu_bist_fail1	: out	std_ulogic;
			tmu_dac_reset	: out	std_ulogic;
			tsd_bist_fail	: out	std_ulogic
		-- End of Generated Port for Entity inst_eac_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	mix_logic0_0	: std_ulogic; 
			signal	mix_logic0_2	: std_ulogic; 
			signal	mix_logic0_bus_1	: std_ulogic_vector(5 downto 0); 
			signal	cp_laddr	: std_ulogic_vector(31 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	cp_lcmd	: std_ulogic_vector(6 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	gpio_int	: std_ulogic_vector(4 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	nreset	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	nreset_s	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	tmi_sbist_fail	: std_ulogic_vector(12 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	tmu_dac_reset	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	v_select	: std_ulogic_vector(5 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			mix_logic0_0 <= '0';
			mix_logic0_2 <= '0';
			mix_logic0_bus_1 <= ( others => '0' );
			cp_laddr(31 downto 1) <= p_mix_cp_laddr_31_1_gi(30 downto 0);  -- __I_I_SLICE_PORT
			cp_lcmd(6) <= p_mix_cp_lcmd_6_6_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			p_mix_gpio_int_4_0_go <= gpio_int;  -- __I_O_BUS_PORT
			nreset <= p_mix_nreset_gi;  -- __I_I_BIT_PORT
			nreset_s <= p_mix_nreset_s_gi;  -- __I_I_BIT_PORT
			tmi_sbist_fail(11 downto 10) <= p_mix_tmi_sbist_fail_11_10_gi(1 downto 0);  -- __I_I_SLICE_PORT
			p_mix_tmi_sbist_fail_9_0_go(9 downto 0) <= tmi_sbist_fail(9 downto 0);  -- __I_O_SLICE_PORT
			p_mix_tmu_dac_reset_go <= tmu_dac_reset;  -- __I_O_BIT_PORT
			v_select(5) <= p_mix_v_select_5_5_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE
			v_select(2) <= p_mix_v_select_2_2_gi;  -- __I_I_SLICE_PORT -- __W_SINGLE_BIT_SLICE


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_eaa
		inst_eaa: inst_eaa_e
		port map (
			mbist_clut_fail_o => tmi_sbist_fail(8),
			mbist_fifo_fail_o => tmi_sbist_fail(9),
			reset_n => nreset, -- GlobalRESET(Verilogmacro)
			reset_n_s => nreset_s -- GlobalRESET(Verilogmacro)
		);
		-- End of Generated Instance Port Map for inst_eaa

		-- Generated Instance Port Map for inst_eab
		inst_eab: inst_eab_e
		port map (
			nreset => nreset, -- GlobalRESET(Verilogmacro)
			nreset_s => nreset_s, -- GlobalRESET(Verilogmacro)
			v_select(0) => mix_logic0_0,
			v_select(1) => mix_logic0_0,
			v_select(2) => v_select(2),
			v_select(3) => mix_logic0_0,
			v_select(4) => mix_logic0_0, -- GuestBusLBC(memorymappedI/O)Interface
			v_select(5) => v_select(5) -- VPUinterfaceRequestBusinterface:RequestBus#6(VPU)requestbusinterfaceforcgpandcgclientserver
		);
		-- End of Generated Instance Port Map for inst_eab

		-- Generated Instance Port Map for inst_eac
		inst_eac: inst_eac_e
		port map (
			adp_bist_fail => tmi_sbist_fail(0),
			cp_laddr(0) => mix_logic0_2, -- __I_BIT_TO_BUSPORT -- GuestBusLBC(memorymappedI/O)Interface
			cp_laddr(31 downto 1) => cp_laddr(31 downto 1), -- GuestBusLBC(memorymappedI/O)InterfaceLBCinterfacetobeusecurrentlybyGuestBus
			cp_lcmd(5 downto 0)  => mix_logic0_bus_1, -- __W_PORT
			cp_lcmd(6) => cp_lcmd(6), -- GuestBusLBC(memorymappedI/O)Interface
			cpu_bist_fail => tmi_sbist_fail(1),
			cvi_sbist_fail0 => tmi_sbist_fail(10),
			cvi_sbist_fail1 => tmi_sbist_fail(11),
			ema_bist_fail => tmi_sbist_fail(7),
			ga_sbist_fail0 => tmi_sbist_fail(8),
			ga_sbist_fail1 => tmi_sbist_fail(9),
			gpio_int => gpio_int, -- GPIOWakeUPSignalsInterruptinputs
			ifu_bist_fail => tmi_sbist_fail(6),
			mcu_bist_fail => tmi_sbist_fail(2),
			nreset => nreset, -- GlobalRESET(Verilogmacro)
			nreset_s => nreset_s, -- GlobalRESET(Verilogmacro)
			pdu_bist_fail0 => tmi_sbist_fail(3),
			pdu_bist_fail1 => tmi_sbist_fail(4),
			tmu_dac_reset => tmu_dac_reset, -- CADCTestModeRGBADAC
			tsd_bist_fail => tmi_sbist_fail(5)
		);
		-- End of Generated Instance Port Map for inst_eac



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
