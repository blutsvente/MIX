-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of vgca
--
-- Generated
--  by:  wig
--  on:  Thu Jul  6 16:43:58 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: vgca-struct-a.vhd,v 1.3 2006/07/10 07:30:09 wig Exp $
-- $Date: 2006/07/10 07:30:09 $
-- $Log: vgca-struct-a.vhd,v $
-- Revision 1.3  2006/07/10 07:30:09  wig
-- Updated more testcasess.
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.91 2006/07/04 12:22:35 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.46 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
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

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component adc
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component bsr
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component clkgen
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component dac
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component padframe
		-- No Generated Generics
		port (
		-- Generated Port for Entity padframe
			mix_logic0_0	: in	std_ulogic;	-- padin
			mix_logic0_bus_4	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_i	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_i2	: in	std_ulogic_vector(31 downto 0);	-- padin
			ramd_o	: out	std_ulogic_vector(31 downto 0);	-- padout
			ramd_o2	: out	std_ulogic_vector(31 downto 0);	-- padout
			ramd_o3	: out	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity padframe
		);
	end component;
	-- ---------

	component tap_con
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_cpu
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_di
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_dp
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_fe
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------

	component vgca_mm
		-- No Generated Generics
		port (
		-- Generated Port for Entity vgca_mm
			ramd_i	: in	std_ulogic_vector(31 downto 0);
			ramd_i2	: in	std_ulogic_vector(31 downto 0);
			ramd_i3	: in	std_ulogic_vector(31 downto 0)
		-- End of Generated Port for Entity vgca_mm
		);
	end component;
	-- ---------

	component vgca_rc
		-- No Generated Generics
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	mix_logic0_0	: std_ulogic; 
		signal	mix_logic0_bus_4	: std_ulogic_vector(31 downto 0); 
		signal	mm_ramd	: std_ulogic_vector(31 downto 0); 
		signal	mm_ramd2	: std_ulogic_vector(31 downto 0); 
		signal	mm_ramd3	: std_ulogic_vector(31 downto 0); 
		-- __I_NODRV_I signal	ramd_i	: std_ulogic_vector(31 downto 0); 
		-- __I_NODRV_I signal	ramd_i2	: std_ulogic_vector(31 downto 0); 
		--  __I_OUT_OPEN signal	ramd_o	: std_ulogic_vector(31 downto 0); 
		--  __I_OUT_OPEN signal	ramd_o2	: std_ulogic_vector(31 downto 0); 
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
		mix_logic0_0	<=	'0';
		mix_logic0_bus_4	<=	( others => '0' );


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for i_adc
		i_adc: adc

		;

		-- End of Generated Instance Port Map for i_adc

		-- Generated Instance Port Map for i_bsr
		i_bsr: bsr

		;

		-- End of Generated Instance Port Map for i_bsr

		-- Generated Instance Port Map for i_clkgen
		i_clkgen: clkgen

		;

		-- End of Generated Instance Port Map for i_clkgen

		-- Generated Instance Port Map for i_dac
		i_dac: dac

		;

		-- End of Generated Instance Port Map for i_dac

		-- Generated Instance Port Map for i_padframe
		i_padframe: padframe
		port map (

			mix_logic0_0 => mix_logic0_0,	-- padin
			mix_logic0_bus_4 => mix_logic0_bus_4,	-- padin
			-- __I_NODRV_I -- __I_NODRV_I ramd_i =>   __nodrv__/ramd_i2/ramd_i,	-- padin (X4)
			-- __I_NODRV_I ramd_i2 =>  __nodrv__/ramd_i2,	-- padin (X4)
			ramd_o => mm_ramd,
			-- __I_RECONN -- __I_RECONN ramd_o => open,	-- padout (X4) -- __I_OUT_OPEN
			ramd_o2 => mm_ramd2,
			-- __I_RECONN ramd_o2 => open,	-- padout (X4) -- __I_OUT_OPEN
			ramd_o3 => mm_ramd3
		);

		-- End of Generated Instance Port Map for i_padframe

		-- Generated Instance Port Map for i_tap_con
		i_tap_con: tap_con

		;

		-- End of Generated Instance Port Map for i_tap_con

		-- Generated Instance Port Map for i_vgca_cpu
		i_vgca_cpu: vgca_cpu

		;

		-- End of Generated Instance Port Map for i_vgca_cpu

		-- Generated Instance Port Map for i_vgca_di
		i_vgca_di: vgca_di

		;

		-- End of Generated Instance Port Map for i_vgca_di

		-- Generated Instance Port Map for i_vgca_dp
		i_vgca_dp: vgca_dp

		;

		-- End of Generated Instance Port Map for i_vgca_dp

		-- Generated Instance Port Map for i_vgca_fe
		i_vgca_fe: vgca_fe

		;

		-- End of Generated Instance Port Map for i_vgca_fe

		-- Generated Instance Port Map for i_vgca_mm
		i_vgca_mm: vgca_mm
		port map (
			ramd_i => mm_ramd,
			ramd_i2 => mm_ramd2,
			ramd_i3 => mm_ramd3
		);

		-- End of Generated Instance Port Map for i_vgca_mm

		-- Generated Instance Port Map for i_vgca_rc
		i_vgca_rc: vgca_rc

		;

		-- End of Generated Instance Port Map for i_vgca_rc



end struct;


--
--!End of Architecture/s
-- --------------------------------------------------------------