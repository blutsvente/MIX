-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Tue Mar 30 08:23:00 2004
--  cmd: H:\work\mix_new\MIX\mix_0.pl -strip -nodelta ../constant.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.1 2004/04/06 11:10:45 wig Exp $
-- $Date: 2004/04/06 11:10:45 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:10:45  wig
-- Adding result/constant
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.38 2004/03/25 11:21:34 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.28 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


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
	component inst_aa_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_aa_e
			bit_vector_p	: in	bit_vector(7 downto 0);
			bug20040329a_t1	: in	std_ulogic;
			bug20040329a_t2	: in	std_ulogic;
			bug20040329a_t3	: in	std_ulogic;
			bug20040329a_t4	: in	std_ulogic;
			const_01_p	: in	std_ulogic;
			const_02_p	: in	std_ulogic;
			const_03	: in	std_ulogic_vector(6 downto 0);
			const_05	: in	std_ulogic;
			inst_duo_1	: in	std_ulogic_vector(7 downto 0);
			int_time_p	: in	time;
			integer_p	: in	integer;
			one_p	: in	std_ulogic;
			real_p	: in	real;
			real_time_p	: in	time;
			reale_p	: in	real;
			std_u_11_vport	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_bin_p	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_binv_p	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_hexerr_p	: in	std_ulogic_vector(3 downto 0);
			std_u_logic_octv_p	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_port_02	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_quadv_p	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_vport	: in	std_ulogic_vector(7 downto 0);
			std_u_logic_vport_ext	: in	std_ulogic_vector(10 downto 0);
			std_ulogic_vector_p	: in	std_ulogic_vector(7 downto 0);
			string_p	: in	string;
			under_p	: in	real;
			vector_duo_1	: in	std_ulogic_vector(7 downto 0);
			vector_duo_2	: in	std_ulogic_vector(7 downto 0);
			vhdl_basehex_p	: in	integer;
			vhdlbase2_p	: in	integer;
			zero_p	: in	std_ulogic
		-- End of Generated Port for Entity inst_aa_e
		);
	end component;
	-- ---------

	component inst_ab_e	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity inst_ab_e
			const_04	: in	std_ulogic_vector(3 downto 0);
			const_08_p	: in	std_ulogic_vector(4 downto 0);
			const_09_p	: in	std_ulogic_vector(2 downto 0);
			const_10_2	: in	std_ulogic_vector(3 downto 0);
			inst_duo_2	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity inst_ab_e
		);
	end component;
	-- ---------

	component inst_ac_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_ad_e	-- 
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component inst_ae_e	-- 
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
			constant bug20040329a_t1_c : std_ulogic := 16#0#; -- __I_ConvConstant2:0x0
			signal bug20040329a_t1 : std_ulogic;
			constant bug20040329a_t2_c : std_ulogic := '0';
			signal bug20040329a_t2 : std_ulogic;
			constant bug20040329a_t3_c : std_ulogic := 2#0#; -- __I_ConvConstant3:0b0
			signal bug20040329a_t3 : std_ulogic;
			constant bug20040329a_t4_c : std_ulogic := 2#0101_0101#; -- __I_ConvConstant3:0b0101_0101
			signal bug20040329a_t4 : std_ulogic;
			constant const_01_c : std_ulogic := '0';
			signal const_01 : std_ulogic;
			constant const_02_c : std_ulogic := '1';
			signal const_02 : std_ulogic;
			constant const_03_c : std_ulogic_vector(6 downto 0) := "64"; -- __I_VectorConv
			signal const_03 : std_ulogic_vector(6 downto 0);
			constant const_04_c : std_ulogic_vector(3 downto 0) := "32"; -- __I_VectorConv
			signal const_04 : std_ulogic_vector(3 downto 0);
			constant const_05_c : std_ulogic := '1';
			signal const_05 : std_ulogic;
			constant mix_const_1_c : std_ulogic_vector(4 downto 0) := ( others => '0' );
			signal mix_const_1 : std_ulogic_vector(4 downto 0);
			constant mix_const_10_c : integer := 16#FF#; -- __I_ConstNoconv
			signal mix_const_10 : integer;
			constant mix_const_11_c : integer := 2#1010_1010#; -- __I_ConstNoconv
			signal mix_const_11 : integer;
			constant mix_const_12_c : real := 2.2E-6; -- __I_ConstNoconv
			signal mix_const_12 : real;
			constant mix_const_13_c : time := 10 ns;
			signal mix_const_13 : time;
			constant mix_const_14_c : time := 2.27 us;
			signal mix_const_14 : time;
			constant mix_const_15_c : string := "ein string"; -- __I_ConstNoconv
			signal mix_const_15 : string;
			constant mix_const_16_c : bit_vector(7 downto 0) := "11111111"; -- __I_VectorConv
			signal mix_const_16 : bit_vector(7 downto 0);
			constant mix_const_18_c : std_ulogic_vector(7 downto 0) := "01010101"; -- __I_VectorConv
			signal mix_const_18 : std_ulogic_vector(7 downto 0);
			constant mix_const_2_c : std_ulogic_vector(2 downto 0) := ( others => '1' );
			signal mix_const_2 : std_ulogic_vector(2 downto 0);
			constant mix_const_21_c : std_ulogic_vector(7 downto 0) := "10101100"; -- __I_VectorConv
			signal mix_const_21 : std_ulogic_vector(7 downto 0);
			constant mix_const_22_c : std_ulogic_vector(7 downto 0) := "10101100"; -- __I_VectorConv
			signal mix_const_22 : std_ulogic_vector(7 downto 0);
			constant mix_const_23_c : std_ulogic_vector(7 downto 0) := "11111111"; -- __I_ConvConstant: 16#FF#
			signal mix_const_23 : std_ulogic_vector(7 downto 0);
			constant mix_const_24_c : std_ulogic_vector(7 downto 0) := "00010001"; -- __I_ConvConstant: 16#11#
			signal mix_const_24 : std_ulogic_vector(7 downto 0);
			constant mix_const_25_c : std_ulogic_vector(10 downto 0) := "00011111111"; -- __I_ConvConstant: 16#FF#
			signal mix_const_25 : std_ulogic_vector(10 downto 0);
			constant mix_const_26_c : std_ulogic_vector(7 downto 0) := "11111111"; -- __I_ConvConstant: 0xff
			signal mix_const_26 : std_ulogic_vector(7 downto 0);
			constant mix_const_27_c : std_ulogic_vector(7 downto 0) := "01010101"; -- __I_ConvConstant: 0b01010101
			signal mix_const_27 : std_ulogic_vector(7 downto 0);
			constant mix_const_28_c : std_ulogic_vector(7 downto 0) := "00000111"; -- __I_ConvConstant: 8#07#
			signal mix_const_28 : std_ulogic_vector(7 downto 0);
			constant mix_const_29_c : std_ulogic_vector(7 downto 0) := "11001100"; -- __I_ConvConstant: 2#11001100#
			signal mix_const_29 : std_ulogic_vector(7 downto 0);
			constant mix_const_3_c : std_ulogic_vector(3 downto 0) := ( others => '1' );
			signal mix_const_3 : std_ulogic_vector(3 downto 0);
			constant mix_const_30_c : std_ulogic_vector(7 downto 0) := 4#3030#; -- __I_ConvConstant: 4#3030#
			signal mix_const_30 : std_ulogic_vector(7 downto 0);
			constant mix_const_31_c : std_ulogic_vector(3 downto 0) := "11101110"; -- __E_VECTOR_WIDTH  -- __I_ConvConstant: 16#ee#
			signal mix_const_31 : std_ulogic_vector(3 downto 0);
			constant mix_const_4_c : std_ulogic_vector(3 downto 0) := ( others => '0' );
			signal mix_const_4 : std_ulogic_vector(3 downto 0);
			constant mix_const_5_c : std_ulogic := '0';
			signal mix_const_5 : std_ulogic;
			constant mix_const_6_c : std_ulogic := '1';
			signal mix_const_6 : std_ulogic;
			constant mix_const_7_c : integer := 10; -- __I_ConstNoconv
			signal mix_const_7 : integer;
			constant mix_const_8_c : real := 10.2; -- __I_ConstNoconv
			signal mix_const_8 : real;
			constant mix_const_9_c : real := 1_000_000.0; -- __I_ConstNoconv
			signal mix_const_9 : real;
		--
		-- End of Generated Signal List
		--


begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			bug20040329a_t1 <= bug20040329a_t1_c;
			bug20040329a_t2 <= bug20040329a_t2_c;
			bug20040329a_t3 <= bug20040329a_t3_c;
			bug20040329a_t4 <= bug20040329a_t4_c;
			const_01 <= const_01_c;
			const_02 <= const_02_c;
			const_03 <= const_03_c;
			const_04 <= const_04_c;
			const_05 <= const_05_c;
			mix_const_1 <= mix_const_1_c;
			mix_const_10 <= mix_const_10_c;
			mix_const_11 <= mix_const_11_c;
			mix_const_12 <= mix_const_12_c;
			mix_const_13 <= mix_const_13_c;
			mix_const_14 <= mix_const_14_c;
			mix_const_15 <= mix_const_15_c;
			mix_const_16 <= mix_const_16_c;
			mix_const_18 <= mix_const_18_c;
			mix_const_2 <= mix_const_2_c;
			mix_const_21 <= mix_const_21_c;
			mix_const_22 <= mix_const_22_c;
			mix_const_23 <= mix_const_23_c;
			mix_const_24 <= mix_const_24_c;
			mix_const_25 <= mix_const_25_c;
			mix_const_26 <= mix_const_26_c;
			mix_const_27 <= mix_const_27_c;
			mix_const_28 <= mix_const_28_c;
			mix_const_29 <= mix_const_29_c;
			mix_const_3 <= mix_const_3_c;
			mix_const_30 <= mix_const_30_c;
			mix_const_31 <= mix_const_31_c;
			mix_const_4 <= mix_const_4_c;
			mix_const_5 <= mix_const_5_c;
			mix_const_6 <= mix_const_6_c;
			mix_const_7 <= mix_const_7_c;
			mix_const_8 <= mix_const_8_c;
			mix_const_9 <= mix_const_9_c;


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
		-- Generated Instance Port Map for inst_aa
		inst_aa: inst_aa_e
		port map (
			bit_vector_p => mix_const_16,
			bug20040329a_t1 => bug20040329a_t1,
			bug20040329a_t2 => bug20040329a_t2,
			bug20040329a_t3 => bug20040329a_t3,
			bug20040329a_t4 => bug20040329a_t4,
			const_01_p => const_01,
			const_02_p => const_02,
			const_03 => const_03, -- Constant Wire, wire port const_wire to constant
			const_05 => const_05, -- Constant Wire, wire port const_wire to constant
			inst_duo_1 => mix_const_22,
			int_time_p => mix_const_13,
			integer_p => mix_const_7,
			one_p => mix_const_6,
			real_p => mix_const_8,
			real_time_p => mix_const_14,
			reale_p => mix_const_12,
			std_u_11_vport => mix_const_24,
			std_u_logic_bin_p => mix_const_27,
			std_u_logic_binv_p => mix_const_29,
			std_u_logic_hexerr_p => mix_const_31,
			std_u_logic_octv_p => mix_const_28,
			std_u_logic_port_02 => mix_const_26,
			std_u_logic_quadv_p => mix_const_30,
			std_u_logic_vport => mix_const_23,
			std_u_logic_vport_ext => mix_const_25,
			std_ulogic_vector_p => mix_const_18,
			string_p => mix_const_15,
			under_p => mix_const_9,
			vector_duo_1 => mix_const_21,
			vector_duo_2 => mix_const_21,
			vhdl_basehex_p => mix_const_10,
			vhdlbase2_p => mix_const_11,
			zero_p => mix_const_5
		);
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: inst_ab_e
		port map (
			const_04 => const_04, -- Constant Wire, wire port const_wire to constant
			const_08_p => mix_const_1, -- Set to 0
			const_09_p => mix_const_2, -- Set to 1
			const_10_2(0) => mix_const_3(0),
			const_10_2(1) => mix_const_4(0),
			const_10_2(2) => mix_const_3(0), -- Set two pins to 1
			const_10_2(3) => mix_const_4(0), -- Set two pins to 0
			inst_duo_2 => mix_const_22
		);
		-- End of Generated Instance Port Map for inst_ab

		-- Generated Instance Port Map for inst_ac
		inst_ac: inst_ac_e

		;
		-- End of Generated Instance Port Map for inst_ac

		-- Generated Instance Port Map for inst_ad
		inst_ad: inst_ad_e

		;
		-- End of Generated Instance Port Map for inst_ad

		-- Generated Instance Port Map for inst_ae
		inst_ae: inst_ae_e

		;
		-- End of Generated Instance Port Map for inst_ae



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
