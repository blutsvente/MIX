-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of padframe
--
-- Generated
--  by:  wig
--  on:  Thu Jan 19 07:44:48 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: padframe-struct-a.vhd,v 1.4 2006/01/19 08:50:40 wig Exp $
-- $Date: 2006/01/19 08:50:40 $
-- $Log: padframe-struct-a.vhd,v $
-- Revision 1.4  2006/01/19 08:50:40  wig
-- Updated testcases, left 6 failing now (constant, bitsplice/X, ...)
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.75 2006/01/18 16:59:29 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of padframe
--
architecture struct of padframe is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component pads_eastnord
		-- No Generated Generics
		port (
		-- Generated Port for Entity pads_eastnord
			clkf81_gi	: in	std_ulogic;
			clockdr_i_gi	: in	std_ulogic;
			db2o_10	: inout	std_ulogic;	-- Flat Panel
			db2o_11	: inout	std_ulogic;	-- Flat Panel
			db2o_12	: inout	std_ulogic;	-- Flat Panel
			db2o_13	: inout	std_ulogic;	-- Flat Panel
			db2o_14	: inout	std_ulogic;	-- Flat Panel
			db2o_15	: inout	std_ulogic;	-- Flat Panel
			db2o_i	: in	std_ulogic_vector(15 downto 10);	-- padin
			db2o_o	: out	std_ulogic_vector(15 downto 10);	-- padout
			dbo_10	: inout	std_ulogic;	-- Flat Panel
			dbo_11	: inout	std_ulogic;	-- Flat Panel
			dbo_12	: inout	std_ulogic;	-- Flat Panel
			dbo_13	: inout	std_ulogic;	-- Flat Panel
			dbo_14	: inout	std_ulogic;	-- Flat Panel
			dbo_15	: inout	std_ulogic;	-- Flat Panel
			dbo_i	: in	std_ulogic_vector(15 downto 10);	-- padin
			dbo_o_15_10_go	: out	std_ulogic_vector(5 downto 0);
			default_gi	: in	std_ulogic;
			mode_1_i_gi	: in	std_ulogic;
			mode_2_i_gi	: in	std_ulogic;
			mode_3_i_gi	: in	std_ulogic;
			pmux_sel_por_gi	: in	std_ulogic;
			res_f81_n_gi	: in	std_ulogic;
			rgbout_byp_i_gi	: in	std_ulogic;
			rgbout_iddq_i_gi	: in	std_ulogic;
			rgbout_sio_i_gi	: in	std_ulogic;
			scan_en_i_gi	: in	std_ulogic;
			shiftdr_i_gi	: in	std_ulogic;
			tck_i_gi	: in	std_ulogic;
			updatedr_i_gi	: in	std_ulogic;
			varclk_i_gi	: in	std_ulogic
		-- End of Generated Port for Entity pads_eastnord
		);
	end component;
	-- ---------

	component pads_eastsouth
		-- No Generated Generics
		port (
		-- Generated Port for Entity pads_eastsouth
			clkf81_gi	: in	std_ulogic;
			clockdr_i_gi	: in	std_ulogic;
			default_gi	: in	std_ulogic;
			mode_1_i_gi	: in	std_ulogic;
			mode_2_i_gi	: in	std_ulogic;
			mode_3_i_gi	: in	std_ulogic;
			pmux_sel_por_gi	: in	std_ulogic;
			res_f81_n_gi	: in	std_ulogic;
			scan_en_i_gi	: in	std_ulogic;
			shiftdr_i_gi	: in	std_ulogic;
			tck_i_gi	: in	std_ulogic;
			updatedr_i_gi	: in	std_ulogic
		-- End of Generated Port for Entity pads_eastsouth
		);
	end component;
	-- ---------

	component pads_nordeast
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component pads_nordwest
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component pads_southeast
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component pads_southwest
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component pads_westsouth
		-- No Generated Generics
		port (
		-- Generated Port for Entity pads_westsouth
			clkf81_gi	: in	std_ulogic;
			clockdr_i_gi	: in	std_ulogic;
			db2o_0	: inout	std_ulogic;	-- Flat Panel
			db2o_1	: inout	std_ulogic;	-- Flat Panel
			db2o_2	: inout	std_ulogic;	-- Flat Panel
			db2o_3	: inout	std_ulogic;	-- Flat Panel
			db2o_4	: inout	std_ulogic;	-- Flat Panel
			db2o_5	: inout	std_ulogic;	-- Flat Panel
			db2o_6	: inout	std_ulogic;	-- Flat Panel
			db2o_7	: inout	std_ulogic;	-- Flat Panel
			db2o_8	: inout	std_ulogic;	-- Flat Panel
			db2o_9	: inout	std_ulogic;	-- Flat Panel
			db2o_i	: in	std_ulogic_vector(9 downto 0);	-- padin
			db2o_o	: out	std_ulogic_vector(9 downto 0);	-- padout
			dbo_0	: inout	std_ulogic;	-- Flat Panel
			dbo_1	: inout	std_ulogic;	-- Flat Panel
			dbo_2	: inout	std_ulogic;	-- Flat Panel
			dbo_3	: inout	std_ulogic;	-- Flat Panel
			dbo_4	: inout	std_ulogic;	-- Flat Panel
			dbo_5	: inout	std_ulogic;	-- Flat Panel
			dbo_6	: inout	std_ulogic;	-- Flat Panel
			dbo_7	: inout	std_ulogic;	-- Flat Panel
			dbo_8	: inout	std_ulogic;	-- Flat Panel
			dbo_9	: inout	std_ulogic;	-- Flat Panel
			dbo_i	: in	std_ulogic_vector(9 downto 0);	-- padin
			dbo_o_9_0_go	: out	std_ulogic_vector(9 downto 0);
			default_gi	: in	std_ulogic;
			mode_1_i_gi	: in	std_ulogic;
			mode_2_i_gi	: in	std_ulogic;
			mode_3_i_gi	: in	std_ulogic;
			pmux_sel_por_gi	: in	std_ulogic;
			res_f81_n_gi	: in	std_ulogic;
			rgbout_byp_i_gi	: in	std_ulogic;
			rgbout_iddq_i_gi	: in	std_ulogic;
			rgbout_sio_i_gi	: in	std_ulogic;
			scan_en_i_gi	: in	std_ulogic;
			shiftdr_i_gi	: in	std_ulogic;
			tck_i_gi	: in	std_ulogic;
			updatedr_i_gi	: in	std_ulogic;
			varclk_i_gi	: in	std_ulogic
		-- End of Generated Port for Entity pads_westsouth
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	clkf81	: std_ulogic; 
			signal	clockdr_i	: std_ulogic; 
			signal	default	: std_ulogic; 
			signal	mode_1_i	: std_ulogic; 
			signal	mode_2_i	: std_ulogic; 
			signal	mode_3_i	: std_ulogic; 
			signal	pmux_sel_por	: std_ulogic; 
			signal	res_f81_n	: std_ulogic; 
			signal	rgbout_byp_i	: std_ulogic; 
			signal	rgbout_iddq_i	: std_ulogic; 
			signal	rgbout_sio_i	: std_ulogic; 
			signal	scan_en_i	: std_ulogic; 
			signal	shiftdr_i	: std_ulogic; 
			signal	tck_i	: std_ulogic; 
			signal	updatedr_i	: std_ulogic; 
			signal	varclk_i	: std_ulogic; 
		--
		-- End of Generated Signal List
		--




begin


	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for i_pads_en
		i_pads_en: pads_eastnord
		port map (

			clkf81_gi => clkf81,
			clockdr_i_gi => clockdr_i,
			db2o_10 => db2o_10,	-- Flat Panel
			db2o_11 => db2o_11,	-- Flat Panel
			db2o_12 => db2o_12,	-- Flat Panel
			db2o_13 => db2o_13,	-- Flat Panel
			db2o_14 => db2o_14,	-- Flat Panel
			db2o_15 => db2o_15,	-- Flat Panel
			db2o_i => db2o_i(15 downto 10),	-- padin (X2)
			db2o_o => db2o_o(15 downto 10),	-- padout (X2)
			dbo_10 => dbo_10,	-- Flat Panel
			dbo_11 => dbo_11,	-- Flat Panel
			dbo_12 => dbo_12,	-- Flat Panel
			dbo_13 => dbo_13,	-- Flat Panel
			dbo_14 => dbo_14,	-- Flat Panel
			dbo_15 => dbo_15,	-- Flat Panel
			dbo_i => dbo_i(15 downto 10),	-- padin (X2)
			dbo_o_15_10_go => dbo_o(15 downto 10),	-- padout
			default_gi => default,
			mode_1_i_gi => mode_1_i,
			mode_2_i_gi => mode_2_i,
			mode_3_i_gi => mode_3_i,
			pmux_sel_por_gi => pmux_sel_por,
			res_f81_n_gi => res_f81_n,
			rgbout_byp_i_gi => rgbout_byp_i,
			rgbout_iddq_i_gi => rgbout_iddq_i,
			rgbout_sio_i_gi => rgbout_sio_i,
			scan_en_i_gi => scan_en_i,
			shiftdr_i_gi => shiftdr_i,
			tck_i_gi => tck_i,
			updatedr_i_gi => updatedr_i,
			varclk_i_gi => varclk_i
		);
		-- End of Generated Instance Port Map for i_pads_en

		-- Generated Instance Port Map for i_pads_es
		i_pads_es: pads_eastsouth
		port map (
			clkf81_gi => clkf81,
			clockdr_i_gi => clockdr_i,
			default_gi => default,
			mode_1_i_gi => mode_1_i,
			mode_2_i_gi => mode_2_i,
			mode_3_i_gi => mode_3_i,
			pmux_sel_por_gi => pmux_sel_por,
			res_f81_n_gi => res_f81_n,
			scan_en_i_gi => scan_en_i,
			shiftdr_i_gi => shiftdr_i,
			tck_i_gi => tck_i,
			updatedr_i_gi => updatedr_i
		);
		-- End of Generated Instance Port Map for i_pads_es

		-- Generated Instance Port Map for i_pads_ne
		i_pads_ne: pads_nordeast

		;
		-- End of Generated Instance Port Map for i_pads_ne

		-- Generated Instance Port Map for i_pads_nw
		i_pads_nw: pads_nordwest

		;
		-- End of Generated Instance Port Map for i_pads_nw

		-- Generated Instance Port Map for i_pads_se
		i_pads_se: pads_southeast

		;
		-- End of Generated Instance Port Map for i_pads_se

		-- Generated Instance Port Map for i_pads_sw
		i_pads_sw: pads_southwest

		;
		-- End of Generated Instance Port Map for i_pads_sw

		-- Generated Instance Port Map for i_pads_ws
		i_pads_ws: pads_westsouth
		port map (

			clkf81_gi => clkf81,
			clockdr_i_gi => clockdr_i,
			db2o_0 => db2o_0,	-- Flat Panel
			db2o_1 => db2o_1,	-- Flat Panel
			db2o_2 => db2o_2,	-- Flat Panel
			db2o_3 => db2o_3,	-- Flat Panel
			db2o_4 => db2o_4,	-- Flat Panel
			db2o_5 => db2o_5,	-- Flat Panel
			db2o_6 => db2o_6,	-- Flat Panel
			db2o_7 => db2o_7,	-- Flat Panel
			db2o_8 => db2o_8,	-- Flat Panel
			db2o_9 => db2o_9,	-- Flat Panel
			db2o_i => db2o_i(9 downto 0),	-- padin (X2)
			db2o_o => db2o_o(9 downto 0),	-- padout (X2)
			dbo_0 => dbo_0,	-- Flat Panel
			dbo_1 => dbo_1,	-- Flat Panel
			dbo_2 => dbo_2,	-- Flat Panel
			dbo_3 => dbo_3,	-- Flat Panel
			dbo_4 => dbo_4,	-- Flat Panel
			dbo_5 => dbo_5,	-- Flat Panel
			dbo_6 => dbo_6,	-- Flat Panel
			dbo_7 => dbo_7,	-- Flat Panel
			dbo_8 => dbo_8,	-- Flat Panel
			dbo_9 => dbo_9,	-- Flat Panel
			dbo_i => dbo_i(9 downto 0),	-- padin (X2)
			dbo_o_9_0_go => dbo_o(9 downto 0),	-- padout
			default_gi => default,
			mode_1_i_gi => mode_1_i,
			mode_2_i_gi => mode_2_i,
			mode_3_i_gi => mode_3_i,
			pmux_sel_por_gi => pmux_sel_por,
			res_f81_n_gi => res_f81_n,
			rgbout_byp_i_gi => rgbout_byp_i,
			rgbout_iddq_i_gi => rgbout_iddq_i,
			rgbout_sio_i_gi => rgbout_sio_i,
			scan_en_i_gi => scan_en_i,
			shiftdr_i_gi => shiftdr_i,
			tck_i_gi => tck_i,
			updatedr_i_gi => updatedr_i,
			varclk_i_gi => varclk_i
		);
		-- End of Generated Instance Port Map for i_pads_ws



end struct;


--
--!End of Architecture/s
-- --------------------------------------------------------------
