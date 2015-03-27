-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ioblock3_e
--
-- Generated
--  by:  wig
--  on:  Wed Jul  5 16:52:30 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../../padio.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ioblock3_e-rtl-a.vhd,v 1.4 2006/07/10 07:30:08 wig Exp $
-- $Date: 2006/07/10 07:30:08 $
-- $Log: ioblock3_e-rtl-a.vhd,v $
-- Revision 1.4  2006/07/10 07:30:08  wig
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
-- Start of Generated Architecture rtl of ioblock3_e
--
architecture rtl of ioblock3_e is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component ioc_r_iou
		-- No Generated Generics
		port (
		-- Generated Port for Entity ioc_r_iou
			di	: out	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			do	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			en	: in	std_ulogic; -- __I_AUTO_REDUCED_BUS2SIGNAL
			p_di	: in	std_ulogic;	-- data in from pad
			p_do	: out	std_ulogic;	-- data out to pad
			p_en	: out	std_ulogic;	-- pad output enable
			p_pu	: out	std_ulogic;	-- pull-up control
			pu	: in	std_ulogic -- __I_AUTO_REDUCED_BUS2SIGNAL
		-- End of Generated Port for Entity ioc_r_iou
		);
	end component;
	-- ---------

	component ioc_g_i
		-- No Generated Generics
		port (
		-- Generated Port for Entity ioc_g_i
			di	: out	std_ulogic_vector(7 downto 0);
			p_di	: in	std_ulogic;	-- data in from pad
			sel	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ioc_g_i
		);
	end component;
	-- ---------

	component ioc_g_o
		-- No Generated Generics
		port (
		-- Generated Port for Entity ioc_g_o
			do	: in	std_ulogic_vector(7 downto 0);
			p_do	: out	std_ulogic;	-- data out to pad
			p_en	: out	std_ulogic;	-- pad output enable
			sel	: in	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ioc_g_o
		);
	end component;
	-- ---------

	component ioc_r_io3
		-- No Generated Generics
		port (
		-- Generated Port for Entity ioc_r_io3
			do	: in	std_ulogic_vector(3 downto 0);
			en	: in	std_ulogic_vector(3 downto 0);
			p_di	: in	std_ulogic;	-- data in from pad
			p_do	: out	std_ulogic;	-- data out to pad
			p_en	: out	std_ulogic;	-- pad output enable
			sel	: in	std_ulogic_vector(3 downto 0)
		-- End of Generated Port for Entity ioc_r_io3
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	d9_di	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	d9_do	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	d9_en	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	d9_pu	: std_ulogic_vector(1 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	data_i33	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	data_i34	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	data_o35	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	data_o36	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	display_ls	: std_ulogic_vector(7 downto 0); 
		signal	display_ls_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	display_ms_en	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	iosel_0	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	iosel_bus	: std_ulogic_vector(7 downto 0); -- __W_PORT_SIGNAL_MAP_REQ
		signal	ioseldi_0	: std_ulogic; 
		-- __I_NODRV_I signal	ioseldi_1	: std_ulogic; 
		signal	ioseldi_2	: std_ulogic; 
		signal	ioseldi_3	: std_ulogic; 
		signal	pad_di_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_di_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_di_33	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_di_34	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_di_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_di_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_35	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_36	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_do_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_35	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_36	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_39	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_en_40	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_pu_31	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
		signal	pad_pu_32	: std_ulogic; -- __W_PORT_SIGNAL_MAP_REQ
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
		p_mix_d9_di_go	<=	d9_di;  -- __I_O_BUS_PORT
		d9_do	<=	p_mix_d9_do_gi;  -- __I_I_BUS_PORT
		d9_en	<=	p_mix_d9_en_gi;  -- __I_I_BUS_PORT
		d9_pu	<=	p_mix_d9_pu_gi;  -- __I_I_BUS_PORT
		p_mix_data_i33_go	<=	data_i33;  -- __I_O_BUS_PORT
		p_mix_data_i34_go	<=	data_i34;  -- __I_O_BUS_PORT
		data_o35	<=	p_mix_data_o35_gi;  -- __I_I_BUS_PORT
		data_o36	<=	p_mix_data_o36_gi;  -- __I_I_BUS_PORT
		display_ls_en	<=	p_mix_display_ls_en_gi;  -- __I_I_BIT_PORT
		display_ms_en	<=	p_mix_display_ms_en_gi;  -- __I_I_BIT_PORT
		iosel_0	<=	p_mix_iosel_0_gi;  -- __I_I_BIT_PORT
		iosel_bus	<=	p_mix_iosel_bus_gi;  -- __I_I_BUS_PORT
		pad_di_31	<=	p_mix_pad_di_31_gi;  -- __I_I_BIT_PORT
		pad_di_32	<=	p_mix_pad_di_32_gi;  -- __I_I_BIT_PORT
		pad_di_33	<=	p_mix_pad_di_33_gi;  -- __I_I_BIT_PORT
		pad_di_34	<=	p_mix_pad_di_34_gi;  -- __I_I_BIT_PORT
		pad_di_39	<=	p_mix_pad_di_39_gi;  -- __I_I_BIT_PORT
		pad_di_40	<=	p_mix_pad_di_40_gi;  -- __I_I_BIT_PORT
		p_mix_pad_do_31_go	<=	pad_do_31;  -- __I_O_BIT_PORT
		p_mix_pad_do_32_go	<=	pad_do_32;  -- __I_O_BIT_PORT
		p_mix_pad_do_35_go	<=	pad_do_35;  -- __I_O_BIT_PORT
		p_mix_pad_do_36_go	<=	pad_do_36;  -- __I_O_BIT_PORT
		p_mix_pad_do_39_go	<=	pad_do_39;  -- __I_O_BIT_PORT
		p_mix_pad_do_40_go	<=	pad_do_40;  -- __I_O_BIT_PORT
		p_mix_pad_en_31_go	<=	pad_en_31;  -- __I_O_BIT_PORT
		p_mix_pad_en_32_go	<=	pad_en_32;  -- __I_O_BIT_PORT
		p_mix_pad_en_35_go	<=	pad_en_35;  -- __I_O_BIT_PORT
		p_mix_pad_en_36_go	<=	pad_en_36;  -- __I_O_BIT_PORT
		p_mix_pad_en_39_go	<=	pad_en_39;  -- __I_O_BIT_PORT
		p_mix_pad_en_40_go	<=	pad_en_40;  -- __I_O_BIT_PORT
		p_mix_pad_pu_31_go	<=	pad_pu_31;  -- __I_O_BIT_PORT
		p_mix_pad_pu_32_go	<=	pad_pu_32;  -- __I_O_BIT_PORT


	--
	-- Generated Instances and Port Mappings
	--
		-- Generated Instance Port Map for ioc_data_10
		ioc_data_10: ioc_r_iou
		port map (

			di => d9_di(1),	-- d9io
			do => d9_do(1),	-- d9io
			en => d9_en(1),	-- d9io
			p_di => pad_di_32,	-- data in from pad
			p_do => pad_do_32,	-- data out to pad
			p_en => pad_en_32,	-- pad output enable
			p_pu => pad_pu_32,	-- pull-up control
			pu => d9_pu(1)	-- d9io
		);

		-- End of Generated Instance Port Map for ioc_data_10

		-- Generated Instance Port Map for ioc_data_9
		ioc_data_9: ioc_r_iou
		port map (

			di => d9_di(0),	-- d9io
			do => d9_do(0),	-- d9io
			en => d9_en(0),	-- d9io
			p_di => pad_di_31,	-- data in from pad
			p_do => pad_do_31,	-- data out to pad
			p_en => pad_en_31,	-- pad output enable
			p_pu => pad_pu_31,	-- pull-up control
			pu => d9_pu(0)	-- d9io
		);

		-- End of Generated Instance Port Map for ioc_data_9

		-- Generated Instance Port Map for ioc_data_i33
		ioc_data_i33: ioc_g_i
		port map (

			di => data_i33,	-- io data
			p_di => pad_di_33,	-- data in from pad
			sel => iosel_bus	-- io data
		);

		-- End of Generated Instance Port Map for ioc_data_i33

		-- Generated Instance Port Map for ioc_data_i34
		ioc_data_i34: ioc_g_i
		port map (

			di => data_i34,	-- io data
			p_di => pad_di_34,	-- data in from pad
			sel => iosel_bus	-- io data
		);

		-- End of Generated Instance Port Map for ioc_data_i34

		-- Generated Instance Port Map for ioc_data_o35
		ioc_data_o35: ioc_g_o
		port map (

			do => data_o35,	-- io data
			p_do => pad_do_35,	-- data out to pad
			p_en => pad_en_35,	-- pad output enable
			sel => iosel_bus	-- io data
		);

		-- End of Generated Instance Port Map for ioc_data_o35

		-- Generated Instance Port Map for ioc_data_o36
		ioc_data_o36: ioc_g_o
		port map (

			do => data_o36,	-- io data
			p_do => pad_do_36,	-- data out to pad
			p_en => pad_en_36,	-- pad output enable
			sel => iosel_bus	-- io data
		);

		-- End of Generated Instance Port Map for ioc_data_o36

		-- Generated Instance Port Map for ioc_disp_10
		ioc_disp_10: ioc_r_io3
		port map (

			do(0) => display_ls(1),
			do(1) => display_ls(3),
			do(2) => display_ls(5),
			do(3) => display_ls(7),
			en(0) => display_ls_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(2) => display_ms_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			p_di => pad_di_40,	-- data in from pad
			p_do => pad_do_40,	-- data out to pad
			p_en => pad_en_40,	-- pad output enable
			sel(0) => ioseldi_0, -- __I_BIT_TO_BUSPORT
			sel(1) => iosel_0, -- __I_BIT_TO_BUSPORT	-- IO_Select
			sel(2) => ioseldi_2, -- __I_BIT_TO_BUSPORT
			sel(3) => ioseldi_3 -- __I_BIT_TO_BUSPORT
		);

		-- End of Generated Instance Port Map for ioc_disp_10

		-- Generated Instance Port Map for ioc_disp_9
		ioc_disp_9: ioc_r_io3
		port map (

			do(0) => display_ls(0),
			do(1) => display_ls(2),
			do(2) => display_ls(4),
			do(3) => display_ls(6),
			en(0) => display_ls_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(1) => display_ls_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(2) => display_ms_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			en(3) => display_ms_en, -- __I_BIT_TO_BUSPORT	-- io_enable
			p_di => pad_di_39,	-- data in from pad
			p_do => pad_do_39,	-- data out to pad
			p_en => pad_en_39,	-- pad output enable
			sel(0) => ioseldi_0, -- __I_BIT_TO_BUSPORT
			-- __I_NODRV_I sel(1) =>  __nodrv__/ioseldi_1, -- __I_BIT_TO_BUSPORT
			sel(2) => ioseldi_2, -- __I_BIT_TO_BUSPORT
			sel(3) => ioseldi_3 -- __I_BIT_TO_BUSPORT
		);

		-- End of Generated Instance Port Map for ioc_disp_9



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------