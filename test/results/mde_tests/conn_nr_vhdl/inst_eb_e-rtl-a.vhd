-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_eb_e
--
-- Generated
--  by:  wig
--  on:  Mon Mar 22 13:27:43 2004
--  cmd: H:\work\mix_new\mix\mix_0.pl -strip -nodelta ../../mde_tests.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_eb_e-rtl-a.vhd,v 1.1 2004/04/06 10:49:59 wig Exp $
-- $Date: 2004/04/06 10:49:59 $
-- $Log: inst_eb_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 10:49:59  wig
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
-- Start of Generated Architecture rtl of inst_eb_e
--
architecture rtl of inst_eb_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_eba_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_eba_e
			mbist_aci_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			mbist_vcd_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			reset_n	: in	std_ulogic;
			reset_n_s	: in	std_ulogic;
			vclkl27	: in	std_ulogic
		-- End of Generated Port for Entity inst_eba_e
		);
	end component;
	-- ---------

	component inst_ebb_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ebb_e
			mbist_sum_fail_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			req_select_o	: out	std_ulogic_vector(5 downto 0);
			reset_n	: in	std_ulogic;
			reset_n_s	: in	std_ulogic;
			vclkl27	: in	std_ulogic
		-- End of Generated Port for Entity inst_ebb_e
		);
	end component;
	-- ---------

	component inst_ebc_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ebc_e
			nreset	: in	std_ulogic;
			nreset_s	: in	std_ulogic
		-- End of Generated Port for Entity inst_ebc_e
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	nreset	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	nreset_s	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	tmi_sbist_fail	: std_ulogic_vector(12 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	v_select	: std_ulogic_vector(5 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			nreset <= p_mix_nreset_gi;  -- __I_I_BIT_PORT
			nreset_s <= p_mix_nreset_s_gi;  -- __I_I_BIT_PORT
			p_mix_tmi_sbist_fail_12_10_go(2 downto 0) <= tmi_sbist_fail(12 downto 10);  -- __I_O_SLICE_PORT
			p_mix_v_select_5_0_go <= v_select;  -- __I_O_BUS_PORT


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_eba
		inst_eba: inst_eba_e
		port map (
			mbist_aci_fail_o => tmi_sbist_fail(10),
			mbist_vcd_fail_o => tmi_sbist_fail(11),
			reset_n => nreset, -- GlobalRESET(Verilogmacro)
			reset_n_s => nreset_s, -- GlobalRESET(Verilogmacro)
			vclkl27 => vclkl27 -- ClockSignalsClocksforMacrosglobalsignaldefinitonsclock,reset&powerdown
		);
		-- End of Generated Instance Port Map for inst_eba

		-- Generated Instance Port Map for inst_ebb
		inst_ebb: inst_ebb_e
		port map (
			mbist_sum_fail_o => tmi_sbist_fail(12),
			req_select_o => v_select, -- VPUinterfaceRequestBusinterface:RequestBus#6(VPU)requestbusinterfaceforcgpandcgclientserver
			reset_n => nreset, -- GlobalRESET(Verilogmacro)
			reset_n_s => nreset_s, -- GlobalRESET(Verilogmacro)
			vclkl27 => vclkl27 -- ClockSignalsClocksforMacrosglobalsignaldefinitonsclock,reset&powerdown
		);
		-- End of Generated Instance Port Map for inst_ebb

		-- Generated Instance Port Map for inst_ebc
		inst_ebc: inst_ebc_e
		port map (
			nreset => nreset, -- GlobalRESET(Verilogmacro)
			nreset_s => nreset_s -- GlobalRESET(Verilogmacro)
		);
		-- End of Generated Instance Port Map for inst_ebc



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
