-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_t_e
--
-- Generated
--  by:  wig
--  on:  Thu Apr 27 05:43:23 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_t_e-rtl-a.vhd,v 1.4 2006/06/22 07:20:00 wig Exp $
-- $Date: 2006/06/22 07:20:00 $
-- $Log: inst_t_e-rtl-a.vhd,v $
-- Revision 1.4  2006/06/22 07:20:00  wig
-- Updated testcases and extended MixTest.pl to also verify number of created files.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.83 2006/04/19 07:32:08 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.44 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


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
	component inst_a_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_a_e
			p_mix_test1_go	: out	std_ulogic;
			unsplice_a1_no3	: out	std_ulogic_vector(127 downto 0);	-- leaves 3 unconnected
			unsplice_a2_all128	: out	std_ulogic_vector(127 downto 0);	-- full 128 bit port
			unsplice_a3_up100	: out	std_ulogic_vector(127 downto 0);	-- connect 100 bits from 0
			unsplice_a4_mid100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_a5_midp100	: out	std_ulogic_vector(127 downto 0);	-- connect mid 100 bits
			unsplice_bad_a	: out	std_ulogic_vector(127 downto 0);
			unsplice_bad_b	: out	std_ulogic_vector(127 downto 0);
			widemerge_a1	: out	std_ulogic_vector(31 downto 0);
			widesig_o	: out	std_ulogic_vector(31 downto 0);
			widesig_r_0	: out	std_ulogic;
			widesig_r_1	: out	std_ulogic;
			widesig_r_10	: out	std_ulogic;
			widesig_r_11	: out	std_ulogic;
			widesig_r_12	: out	std_ulogic;
			widesig_r_13	: out	std_ulogic;
			widesig_r_14	: out	std_ulogic;
			widesig_r_15	: out	std_ulogic;
			widesig_r_16	: out	std_ulogic;
			widesig_r_17	: out	std_ulogic;
			widesig_r_18	: out	std_ulogic;
			widesig_r_19	: out	std_ulogic;
			widesig_r_2	: out	std_ulogic;
			widesig_r_20	: out	std_ulogic;
			widesig_r_21	: out	std_ulogic;
			widesig_r_22	: out	std_ulogic;
			widesig_r_23	: out	std_ulogic;
			widesig_r_24	: out	std_ulogic;
			widesig_r_25	: out	std_ulogic;
			widesig_r_26	: out	std_ulogic;
			widesig_r_27	: out	std_ulogic;
			widesig_r_28	: out	std_ulogic;
			widesig_r_29	: out	std_ulogic;
			widesig_r_3	: out	std_ulogic;
			widesig_r_30	: out	std_ulogic;
			widesig_r_4	: out	std_ulogic;
			widesig_r_5	: out	std_ulogic;
			widesig_r_6	: out	std_ulogic;
			widesig_r_7	: out	std_ulogic;
			widesig_r_8	: out	std_ulogic;
			widesig_r_9	: out	std_ulogic
		-- End of Generated Port for Entity inst_a_e
		);
	end component;
	-- ---------

	component inst_b_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_b_e
			port_b_1	: in	std_ulogic
		-- End of Generated Port for Entity inst_b_e
		);
	end component;
	-- ---------

	component inst_c_e
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_d_e
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_e_e
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_e_e
			p_mix_unsplice_a1_no3_125_0_gi	: in	std_ulogic_vector(125 downto 0);
			p_mix_unsplice_a1_no3_127_127_gi	: in	std_ulogic;
			p_mix_unsplice_a2_all128_127_0_gi	: in	std_ulogic_vector(127 downto 0);
			p_mix_unsplice_a3_up100_100_0_gi	: in	std_ulogic_vector(100 downto 0);
			p_mix_unsplice_a4_mid100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_a5_midp100_99_2_gi	: in	std_ulogic_vector(97 downto 0);
			p_mix_unsplice_bad_a_1_1_gi	: in	std_ulogic;
			p_mix_unsplice_bad_b_1_0_gi	: in	std_ulogic_vector(1 downto 0);
			p_mix_widemerge_a1_31_0_gi	: in	std_ulogic_vector(31 downto 0);
			p_mix_widesig_r_0_gi	: in	std_ulogic;
			p_mix_widesig_r_10_gi	: in	std_ulogic;
			p_mix_widesig_r_11_gi	: in	std_ulogic;
			p_mix_widesig_r_12_gi	: in	std_ulogic;
			p_mix_widesig_r_13_gi	: in	std_ulogic;
			p_mix_widesig_r_14_gi	: in	std_ulogic;
			p_mix_widesig_r_15_gi	: in	std_ulogic;
			p_mix_widesig_r_16_gi	: in	std_ulogic;
			p_mix_widesig_r_17_gi	: in	std_ulogic;
			p_mix_widesig_r_18_gi	: in	std_ulogic;
			p_mix_widesig_r_19_gi	: in	std_ulogic;
			p_mix_widesig_r_1_gi	: in	std_ulogic;
			p_mix_widesig_r_20_gi	: in	std_ulogic;
			p_mix_widesig_r_21_gi	: in	std_ulogic;
			p_mix_widesig_r_22_gi	: in	std_ulogic;
			p_mix_widesig_r_23_gi	: in	std_ulogic;
			p_mix_widesig_r_24_gi	: in	std_ulogic;
			p_mix_widesig_r_25_gi	: in	std_ulogic;
			p_mix_widesig_r_26_gi	: in	std_ulogic;
			p_mix_widesig_r_27_gi	: in	std_ulogic;
			p_mix_widesig_r_28_gi	: in	std_ulogic;
			p_mix_widesig_r_29_gi	: in	std_ulogic;
			p_mix_widesig_r_2_gi	: in	std_ulogic;
			p_mix_widesig_r_30_gi	: in	std_ulogic;
			p_mix_widesig_r_3_gi	: in	std_ulogic;
			p_mix_widesig_r_4_gi	: in	std_ulogic;
			p_mix_widesig_r_5_gi	: in	std_ulogic;
			p_mix_widesig_r_6_gi	: in	std_ulogic;
			p_mix_widesig_r_7_gi	: in	std_ulogic;
			p_mix_widesig_r_8_gi	: in	std_ulogic;
			p_mix_widesig_r_9_gi	: in	std_ulogic;
			video_i	: in	std_ulogic_vector(3 downto 0);
			widesig_i	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity inst_e_e
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
	signal	test1	: std_ulogic; 
	signal	unsplice_a1_no3	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_a2_all128	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_a3_up100	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_a4_mid100	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_a5_midp100	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_bad_a	: std_ulogic_vector(127 downto 0); 
	signal	unsplice_bad_b	: std_ulogic_vector(127 downto 0); 
	-- __I_NODRV_I signal	video_i	: std_ulogic_vector(3 downto 0); 
	signal	widemerge_a1	: std_ulogic_vector(31 downto 0); 
	signal	widesig	: std_ulogic_vector(31 downto 0); 
	signal	widesig_r_0	: std_ulogic; 
	signal	widesig_r_1	: std_ulogic; 
	signal	widesig_r_10	: std_ulogic; 
	signal	widesig_r_11	: std_ulogic; 
	signal	widesig_r_12	: std_ulogic; 
	signal	widesig_r_13	: std_ulogic; 
	signal	widesig_r_14	: std_ulogic; 
	signal	widesig_r_15	: std_ulogic; 
	signal	widesig_r_16	: std_ulogic; 
	signal	widesig_r_17	: std_ulogic; 
	signal	widesig_r_18	: std_ulogic; 
	signal	widesig_r_19	: std_ulogic; 
	signal	widesig_r_2	: std_ulogic; 
	signal	widesig_r_20	: std_ulogic; 
	signal	widesig_r_21	: std_ulogic; 
	signal	widesig_r_22	: std_ulogic; 
	signal	widesig_r_23	: std_ulogic; 
	signal	widesig_r_24	: std_ulogic; 
	signal	widesig_r_25	: std_ulogic; 
	signal	widesig_r_26	: std_ulogic; 
	signal	widesig_r_27	: std_ulogic; 
	signal	widesig_r_28	: std_ulogic; 
	signal	widesig_r_29	: std_ulogic; 
	signal	widesig_r_3	: std_ulogic; 
	signal	widesig_r_30	: std_ulogic; 
	signal	widesig_r_4	: std_ulogic; 
	signal	widesig_r_5	: std_ulogic; 
	signal	widesig_r_6	: std_ulogic; 
	signal	widesig_r_7	: std_ulogic; 
	signal	widesig_r_8	: std_ulogic; 
	signal	widesig_r_9	: std_ulogic; 
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


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for inst_a
		inst_a: inst_a_e
		port map (
			p_mix_test1_go => test1,	-- Use internally test1
			unsplice_a1_no3 => unsplice_a1_no3,	-- leaves 3 unconnected
			unsplice_a2_all128 => unsplice_a2_all128,	-- full 128 bit port
			unsplice_a3_up100 => unsplice_a3_up100,	-- connect 100 bits from 0
			unsplice_a4_mid100 => unsplice_a4_mid100,	-- connect mid 100 bits
			unsplice_a5_midp100 => unsplice_a5_midp100,	-- connect mid 100 bits
			unsplice_bad_a => unsplice_bad_a,
			unsplice_bad_b => unsplice_bad_b,	-- # conflict
			widemerge_a1 => widemerge_a1,
			widesig_o => widesig,
			widesig_r_0 => widesig_r_0,
			widesig_r_1 => widesig_r_1,
			widesig_r_10 => widesig_r_10,
			widesig_r_11 => widesig_r_11,
			widesig_r_12 => widesig_r_12,
			widesig_r_13 => widesig_r_13,
			widesig_r_14 => widesig_r_14,
			widesig_r_15 => widesig_r_15,
			widesig_r_16 => widesig_r_16,
			widesig_r_17 => widesig_r_17,
			widesig_r_18 => widesig_r_18,
			widesig_r_19 => widesig_r_19,
			widesig_r_2 => widesig_r_2,
			widesig_r_20 => widesig_r_20,
			widesig_r_21 => widesig_r_21,
			widesig_r_22 => widesig_r_22,
			widesig_r_23 => widesig_r_23,
			widesig_r_24 => widesig_r_24,
			widesig_r_25 => widesig_r_25,
			widesig_r_26 => widesig_r_26,
			widesig_r_27 => widesig_r_27,
			widesig_r_28 => widesig_r_28,
			widesig_r_29 => widesig_r_29,
			widesig_r_3 => widesig_r_3,
			widesig_r_30 => widesig_r_30,
			widesig_r_4 => widesig_r_4,
			widesig_r_5 => widesig_r_5,
			widesig_r_6 => widesig_r_6,
			widesig_r_7 => widesig_r_7,
			widesig_r_8 => widesig_r_8,
			widesig_r_9 => widesig_r_9
		);
		-- End of Generated Instance Port Map for inst_a

		-- Generated Instance Port Map for inst_b
		inst_b: inst_b_e
		port map (
			port_b_1 => test1	-- Use internally test1
		);
		-- End of Generated Instance Port Map for inst_b

		-- Generated Instance Port Map for inst_c
		inst_c: inst_c_e

		;
		-- End of Generated Instance Port Map for inst_c

		-- Generated Instance Port Map for inst_d
		inst_d: inst_d_e

		;
		-- End of Generated Instance Port Map for inst_d

		-- Generated Instance Port Map for inst_e
		inst_e: inst_e_e
		port map (
			p_mix_unsplice_a1_no3_125_0_gi => unsplice_a1_no3(125 downto 0),	-- leaves 3 unconnected
			p_mix_unsplice_a1_no3_127_127_gi => unsplice_a1_no3(127),	-- leaves 3 unconnected
			p_mix_unsplice_a2_all128_127_0_gi => unsplice_a2_all128,	-- full 128 bit port
			p_mix_unsplice_a3_up100_100_0_gi => unsplice_a3_up100(100 downto 0),	-- connect 100 bits from 0
			p_mix_unsplice_a4_mid100_99_2_gi => unsplice_a4_mid100(99 downto 2),	-- connect mid 100 bits
			p_mix_unsplice_a5_midp100_99_2_gi => unsplice_a5_midp100(99 downto 2),	-- connect mid 100 bits
			p_mix_unsplice_bad_a_1_1_gi => unsplice_bad_a(1),
			p_mix_unsplice_bad_b_1_0_gi => unsplice_bad_b(1 downto 0),	-- # conflict
			p_mix_widemerge_a1_31_0_gi => widemerge_a1,
			p_mix_widesig_r_0_gi => widesig_r_0,
			p_mix_widesig_r_10_gi => widesig_r_10,
			p_mix_widesig_r_11_gi => widesig_r_11,
			p_mix_widesig_r_12_gi => widesig_r_12,
			p_mix_widesig_r_13_gi => widesig_r_13,
			p_mix_widesig_r_14_gi => widesig_r_14,
			p_mix_widesig_r_15_gi => widesig_r_15,
			p_mix_widesig_r_16_gi => widesig_r_16,
			p_mix_widesig_r_17_gi => widesig_r_17,
			p_mix_widesig_r_18_gi => widesig_r_18,
			p_mix_widesig_r_19_gi => widesig_r_19,
			p_mix_widesig_r_1_gi => widesig_r_1,
			p_mix_widesig_r_20_gi => widesig_r_20,
			p_mix_widesig_r_21_gi => widesig_r_21,
			p_mix_widesig_r_22_gi => widesig_r_22,
			p_mix_widesig_r_23_gi => widesig_r_23,
			p_mix_widesig_r_24_gi => widesig_r_24,
			p_mix_widesig_r_25_gi => widesig_r_25,
			p_mix_widesig_r_26_gi => widesig_r_26,
			p_mix_widesig_r_27_gi => widesig_r_27,
			p_mix_widesig_r_28_gi => widesig_r_28,
			p_mix_widesig_r_29_gi => widesig_r_29,
			p_mix_widesig_r_2_gi => widesig_r_2,
			p_mix_widesig_r_30_gi => widesig_r_30,
			p_mix_widesig_r_3_gi => widesig_r_3,
			p_mix_widesig_r_4_gi => widesig_r_4,
			p_mix_widesig_r_5_gi => widesig_r_5,
			p_mix_widesig_r_6_gi => widesig_r_6,
			p_mix_widesig_r_7_gi => widesig_r_7,
			p_mix_widesig_r_8_gi => widesig_r_8,
			p_mix_widesig_r_9_gi => widesig_r_9,
			-- __I_NODRV_I video_i => __nodrv__/video_i,
			widesig_i => widesig
		);
		-- End of Generated Instance Port Map for inst_e



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
