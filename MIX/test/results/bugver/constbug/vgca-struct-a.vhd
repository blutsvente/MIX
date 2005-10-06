-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of vgca
--
-- Generated
--  by:  wig
--  on:  Wed Aug 18 12:40:14 2004
--  cmd: H:/work/mix_new/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca-struct-a.vhd,v 1.3 2005/10/06 11:16:07 wig Exp $
-- $Date: 2005/10/06 11:16:07 $
-- $Log: vgca-struct-a.vhd,v $
-- Revision 1.3  2005/10/06 11:16:07  wig
-- Got testcoverage up, fixed generic problem, prepared report
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.45 2004/08/09 15:48:14 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.32 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of vgca
--
architecture struct of vgca is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component mic32_top	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity mic32_top
			eic_int_src_alt_i	: in	std_ulogic_vector(60 downto 1);
			eic_int_src_i	: in	std_ulogic_vector(60 downto 1)
		-- End of Generated Port for Entity mic32_top
		);
	end component;
	-- ---------

	component vgca_di	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity vgca_di
			fmdstatusm_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			fmdstatuss_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			lbdstatusm_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			lbdstatuss_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			line_stable_m_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			line_stable_s_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			pixel_stable_m_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			pixel_stable_s_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			vaqm_vsync_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			vaqs_vsync_irq_o	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity vgca_di
		);
	end component;
	-- ---------

	component vgca_dp	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_fe	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_ga	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_peri	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity vgca_peri
			cadc_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			crt_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ddc_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpio_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpt1_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpt2_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpt3_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			gpt4_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			i2c_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			i2s_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			irri_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			nvmc_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			rtc_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ssi1_rx_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ssi1_tx_irq_alt_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ssi1_tx_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ssi2_rx_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			ssi2_tx_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			uart1_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			uart2_irq_o	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			wdt_irq_o	: out	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity vgca_peri
		);
	end component;
	-- ---------

	component vgca_rc	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	eic_int_src	: std_ulogic_vector(60 downto 1); 
			signal	eic_int_src_alt	: std_ulogic_vector(60 downto 1); 
			constant eic_int_src_c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant eic_int_src_c_1c : std_ulogic_vector(2 downto 0) := ( others => '0' ); 
			constant eic_int_src_c_2c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant eic_int_src_c_3c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant eic_int_src_c_4c : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant mix_const_0 : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant mix_const_1 : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant mix_const_2 : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant mix_const_3 : std_ulogic := '0';  -- __W_SINGLE_BIT_BUS
			constant mix_const_4 : std_ulogic_vector(2 downto 0) := ( others => '0' ); 
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			eic_int_src(1) <= eic_int_src_c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src(10) <= eic_int_src_c_2c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src(19) <= eic_int_src_c_3c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src(44) <= eic_int_src_c_4c; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src(59 downto 57) <= eic_int_src_c_1c;
			eic_int_src_alt(1) <= mix_const_0; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src_alt(10) <= mix_const_1; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src_alt(19) <= mix_const_2; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src_alt(44) <= mix_const_3; -- __W_SINGLE_BIT_BUS -- __W_SINGLE_BIT_BUS
			eic_int_src_alt(59 downto 57) <= mix_const_4;


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for i_mic32_top
		i_mic32_top: mic32_top
		port map (
			eic_int_src_alt_i => eic_int_src_alt,
			eic_int_src_i => eic_int_src -- Interrupt Controller (X10)
		);
		-- End of Generated Instance Port Map for i_mic32_top

		-- Generated Instance Port Map for i_vgca_di
		i_vgca_di: vgca_di
		port map (
			fmdstatusm_irq_o => eic_int_src(40), -- Interrupt Controller (X10)
			fmdstatuss_irq_o => eic_int_src(43), -- Interrupt Controller (X10)
			lbdstatusm_irq_o => eic_int_src(34), -- Interrupt Controller (X10)
			lbdstatuss_irq_o => eic_int_src(37), -- Interrupt Controller (X10)
			line_stable_m_irq_o => eic_int_src(2), -- Interrupt Controller (X10)
			line_stable_s_irq_o => eic_int_src(3), -- Interrupt Controller (X10)
			pixel_stable_m_irq_o => eic_int_src(46), -- Interrupt Controller (X10)
			pixel_stable_s_irq_o => eic_int_src(47), -- Interrupt Controller (X10)
			vaqm_vsync_irq_o => eic_int_src(17), -- Interrupt Controller (X10)
			vaqs_vsync_irq_o => eic_int_src(18) -- Interrupt Controller (X10)
		);
		-- End of Generated Instance Port Map for i_vgca_di

		-- Generated Instance Port Map for i_vgca_dp
		i_vgca_dp: vgca_dp

		;
		-- End of Generated Instance Port Map for i_vgca_dp

		-- Generated Instance Port Map for i_vgca_fe
		i_vgca_fe: vgca_fe

		;
		-- End of Generated Instance Port Map for i_vgca_fe

		-- Generated Instance Port Map for i_vgca_ga
		i_vgca_ga: vgca_ga

		;
		-- End of Generated Instance Port Map for i_vgca_ga

		-- Generated Instance Port Map for i_vgca_peri
		i_vgca_peri: vgca_peri
		port map (
			cadc_irq_o => eic_int_src(30), -- Interrupt Controller (X10)
			crt_irq_o => eic_int_src(54), -- Interrupt Controller (X10)
			ddc_irq_o => eic_int_src(15), -- Interrupt Controller (X10)
			gpio_irq_o => eic_int_src(26), -- Interrupt Controller (X10)
			gpt1_irq_o => eic_int_src(48), -- Interrupt Controller (X10)
			gpt2_irq_o => eic_int_src(27), -- Interrupt Controller (X10)
			gpt3_irq_o => eic_int_src(28), -- Interrupt Controller (X10)
			gpt4_irq_o => eic_int_src(29), -- Interrupt Controller (X10)
			i2c_irq_o => eic_int_src(31), -- Interrupt Controller (X10)
			i2s_irq_o => eic_int_src(16), -- Interrupt Controller (X10)
			irri_irq_o => eic_int_src(51), -- Interrupt Controller (X10)
			nvmc_irq_o => eic_int_src(14), -- Interrupt Controller (X10)
			rtc_irq_o => eic_int_src(21), -- Interrupt Controller (X10)
			ssi1_rx_irq_o => eic_int_src(22), -- Interrupt Controller (X10)
			ssi1_tx_irq_alt_o => eic_int_src_alt(12),
			ssi1_tx_irq_o => eic_int_src(12), -- Interrupt Controller (X10)
			ssi2_rx_irq_o => eic_int_src(23), -- Interrupt Controller (X10)
			ssi2_tx_irq_o => eic_int_src(13), -- Interrupt Controller (X10)
			uart1_irq_o => eic_int_src(24), -- Interrupt Controller (X10)
			uart2_irq_o => eic_int_src(25), -- Interrupt Controller (X10)
			wdt_irq_o => eic_int_src(60) -- Interrupt Controller (X10)
		);
		-- End of Generated Instance Port Map for i_vgca_peri

		-- Generated Instance Port Map for i_vgca_rc
		i_vgca_rc: vgca_rc

		;
		-- End of Generated Instance Port Map for i_vgca_rc



end struct;

--
--!End of Architecture/s
-- --------------------------------------------------------------
