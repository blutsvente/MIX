-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of pads_westsouth
--
-- Generated
--  by:  wig
--  on:  Thu Dec 18 11:12:08 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pads_westsouth-struct-a.vhd,v 1.1 2004/04/06 10:42:14 wig Exp $
-- $Date: 2004/04/06 10:42:14 $
-- $Log: pads_westsouth-struct-a.vhd,v $
-- Revision 1.1  2004/04/06 10:42:14  wig
-- Adding result/padio2
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.36 2003/12/05 14:59:29 abauer Exp 
--
-- Generator: mix_0.pl Revision: 1.24 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of pads_westsouth
--
architecture struct of pads_westsouth is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ioc	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ioc
			bypass	: in	std_ulogic_vector(1 downto 0);
			clk	: in	std_ulogic_vector(1 downto 0);
			clockdr_i	: in	std_ulogic;
			di	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			do	: in	std_ulogic_vector(1 downto 0);
			en	: in	std_ulogic_vector(1 downto 0);
			iddq	: in	std_ulogic_vector(1 downto 0);
			mode_1_i	: in	std_ulogic;
			mode_2_i	: in	std_ulogic;
			mode_3_i	: in	std_ulogic;
			mux_sel_p	: in	std_ulogic_vector(1 downto 0);
			pad	: inout	std_ulogic;
			res_n	: in	std_ulogic;
			scan_en_i	: in	std_ulogic;
			scan_i	: in	std_ulogic;
			scan_o	: out	std_ulogic;
			serial_input_i	: in	std_ulogic;
			serial_output_o	: out	std_ulogic;
			shiftdr_i	: in	std_ulogic;
			tck_i	: in	std_ulogic;
			updatedr_i	: in	std_ulogic
		-- End of Generated Port for Entity ioc
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	mix_logic1	: std_ulogic; 
			signal	mix_logic0	: std_ulogic; 
			signal	clkf81	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	clockdr_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	dbo_o	: std_ulogic_vector(15 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
			signal	default	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	mode_1_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	mode_2_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	mode_3_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	pmux_sel_por	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	res_f81_n	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	rgbout_byp_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	rgbout_iddq_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	rgbout_sio_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	s_in_db2o_0	: std_ulogic; 
			signal	s_in_db2o_1	: std_ulogic; 
			signal	s_in_db2o_2	: std_ulogic; 
			signal	s_in_db2o_3	: std_ulogic; 
			signal	s_in_db2o_4	: std_ulogic; 
			signal	s_in_db2o_5	: std_ulogic; 
			signal	s_in_db2o_6	: std_ulogic; 
			signal	s_in_db2o_7	: std_ulogic; 
			signal	s_in_db2o_8	: std_ulogic; 
			signal	s_in_db2o_9	: std_ulogic; 
			signal	s_in_dbo_0	: std_ulogic; 
			signal	s_in_dbo_1	: std_ulogic; 
			signal	s_in_dbo_2	: std_ulogic; 
			signal	s_in_dbo_3	: std_ulogic; 
			signal	s_in_dbo_4	: std_ulogic; 
			signal	s_in_dbo_5	: std_ulogic; 
			signal	s_in_dbo_6	: std_ulogic; 
			signal	s_in_dbo_7	: std_ulogic; 
			signal	s_in_dbo_8	: std_ulogic; 
			signal	s_in_dbo_9	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_0	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_1	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_2	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_3	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_4	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_5	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_6	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_7	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_8	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_db2o_9	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_0	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_1	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_2	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_3	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_4	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_5	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_6	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_7	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_8	: std_ulogic; 
			--  __I_OUT_OPEN signal	s_out_dbo_9	: std_ulogic; 
			signal	scan_en_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	shiftdr_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	tck_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	updatedr_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
			signal	varclk_i	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			mix_logic1 <= '1';
			mix_logic0 <= '0';
			clkf81 <= clkf81_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			clockdr_i <= clockdr_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			dbo_o_9_0_go(9 downto 0) <= dbo_o(9 downto 0);  -- __I_O_SLICE_PORT
			default <= default_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			mode_1_i <= mode_1_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			mode_2_i <= mode_2_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			mode_3_i <= mode_3_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			pmux_sel_por <= pmux_sel_por_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			res_f81_n <= res_f81_n_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			rgbout_byp_i <= rgbout_byp_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			rgbout_iddq_i <= rgbout_iddq_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			rgbout_sio_i <= rgbout_sio_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			scan_en_i <= scan_en_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			shiftdr_i <= shiftdr_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			tck_i <= tck_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			updatedr_i <= updatedr_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)
			varclk_i <= varclk_i_gi;  -- __I_I_SLICE_PORT -- __I_SINGLE_BIT (0)


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for ioc_db2o_0
		ioc_db2o_0: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(0), -- padout (X2)
			do(0) => db2o_i(0), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_0, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_0,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_0

		-- Generated Instance Port Map for ioc_db2o_1
		ioc_db2o_1: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(1), -- padout (X2)
			do(0) => db2o_i(1), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_1, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_1,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_1

		-- Generated Instance Port Map for ioc_db2o_2
		ioc_db2o_2: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(2), -- padout (X2)
			do(0) => db2o_i(2), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_2, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_2,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_2

		-- Generated Instance Port Map for ioc_db2o_3
		ioc_db2o_3: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(3), -- padout (X2)
			do(0) => db2o_i(3), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_3, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_3,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_3

		-- Generated Instance Port Map for ioc_db2o_4
		ioc_db2o_4: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(4), -- padout (X2)
			do(0) => db2o_i(4), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_4, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_4,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_4

		-- Generated Instance Port Map for ioc_db2o_5
		ioc_db2o_5: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(5), -- padout (X2)
			do(0) => db2o_i(5), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_5, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_5,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_5

		-- Generated Instance Port Map for ioc_db2o_6
		ioc_db2o_6: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(6), -- padout (X2)
			do(0) => db2o_i(6), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_6, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_6,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_6

		-- Generated Instance Port Map for ioc_db2o_7
		ioc_db2o_7: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(7), -- padout (X2)
			do(0) => db2o_i(7), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_7, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_7,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_7

		-- Generated Instance Port Map for ioc_db2o_8
		ioc_db2o_8: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(8), -- padout (X2)
			do(0) => db2o_i(8), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_8, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_8,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_8

		-- Generated Instance Port Map for ioc_db2o_9
		ioc_db2o_9: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => db2o_o(9), -- padout (X2)
			do(0) => db2o_i(9), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => db2o_9, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_db2o_9,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_db2o_9

		-- Generated Instance Port Map for ioc_dbo_0
		ioc_dbo_0: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(0), -- padout
			do(0) => dbo_i(0), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_0, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_0,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_0

		-- Generated Instance Port Map for ioc_dbo_1
		ioc_dbo_1: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(1), -- padout
			do(0) => dbo_i(1), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_1, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_1,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_1

		-- Generated Instance Port Map for ioc_dbo_2
		ioc_dbo_2: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(2), -- padout
			do(0) => dbo_i(2), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_2, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_2,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_2

		-- Generated Instance Port Map for ioc_dbo_3
		ioc_dbo_3: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(3), -- padout
			do(0) => dbo_i(3), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_3, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_3,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_3

		-- Generated Instance Port Map for ioc_dbo_4
		ioc_dbo_4: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(4), -- padout
			do(0) => dbo_i(4), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_4, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_4,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_4

		-- Generated Instance Port Map for ioc_dbo_5
		ioc_dbo_5: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(5), -- padout
			do(0) => dbo_i(5), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_5, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_5,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_5

		-- Generated Instance Port Map for ioc_dbo_6
		ioc_dbo_6: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(6), -- padout
			do(0) => dbo_i(6), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_6, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_6,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_6

		-- Generated Instance Port Map for ioc_dbo_7
		ioc_dbo_7: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(7), -- padout
			do(0) => dbo_i(7), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_7, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_7,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_7

		-- Generated Instance Port Map for ioc_dbo_8
		ioc_dbo_8: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(8), -- padout
			do(0) => dbo_i(8), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_8, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_8,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_8

		-- Generated Instance Port Map for ioc_dbo_9
		ioc_dbo_9: ioc
		port map (
			bypass(0) => rgbout_byp_i, -- __I_BIT_TO_BUSPORT
			bypass(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			clk(0) => varclk_i, -- __I_BIT_TO_BUSPORT
			clk(1) => clkf81, -- __I_BIT_TO_BUSPORT
			clockdr_i => clockdr_i,
			di => dbo_o(9), -- padout
			do(0) => dbo_i(9), -- padin (X2)
			do(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			en(0) => rgbout_sio_i, -- __I_BIT_TO_BUSPORT
			en(1) => mix_logic0, -- __I_BIT_TO_BUSPORT
			iddq(0) => rgbout_iddq_i, -- __I_BIT_TO_BUSPORT
			iddq(1) => mix_logic1, -- __I_BIT_TO_BUSPORT
			mode_1_i => mode_1_i,
			mode_2_i => mode_2_i,
			mode_3_i => mode_3_i,
			mux_sel_p(0) => default, -- __I_BIT_TO_BUSPORT
			mux_sel_p(1) => pmux_sel_por, -- __I_BIT_TO_BUSPORT
			pad => dbo_9, -- Flat Panel
			res_n => res_f81_n,
			scan_en_i => scan_en_i,
			scan_i => mix_logic0,
			scan_o => open,
			serial_input_i => s_in_dbo_9,
			serial_output_o => open, -- __I_OUT_OPEN
			shiftdr_i => shiftdr_i,
			tck_i => tck_i,
			updatedr_i => updatedr_i
		);
		-- End of Generated Instance Port Map for ioc_dbo_9



end struct;

--
--!End of Architecture/s
-- --------------------------------------------------------------
