-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of pad_tb
--
-- Generated
--  by:  wig
--  on:  Wed Jul  5 17:16:56 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pad_tb-struct-a.vhd,v 1.5 2006/07/10 07:30:09 wig Exp $
-- $Date: 2006/07/10 07:30:09 $
-- $Log: pad_tb-struct-a.vhd,v $
-- Revision 1.5  2006/07/10 07:30:09  wig
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
-- Start of Generated Architecture struct of pad_tb
--
architecture struct of pad_tb is 

	--
	-- Generated Constant Declarations
	--


	--
	-- Generated Components
	--
	component padframe
		-- No Generated Generics
		port (
		-- Generated Port for Entity padframe
			db2o_0	: inout	std_ulogic;	-- Flat Panel
			db2o_1	: inout	std_ulogic;	-- Flat Panel
			db2o_10	: inout	std_ulogic;	-- Flat Panel
			db2o_11	: inout	std_ulogic;	-- Flat Panel
			db2o_12	: inout	std_ulogic;	-- Flat Panel
			db2o_13	: inout	std_ulogic;	-- Flat Panel
			db2o_14	: inout	std_ulogic;	-- Flat Panel
			db2o_15	: inout	std_ulogic;	-- Flat Panel
			db2o_2	: inout	std_ulogic;	-- Flat Panel
			db2o_3	: inout	std_ulogic;	-- Flat Panel
			db2o_4	: inout	std_ulogic;	-- Flat Panel
			db2o_5	: inout	std_ulogic;	-- Flat Panel
			db2o_6	: inout	std_ulogic;	-- Flat Panel
			db2o_7	: inout	std_ulogic;	-- Flat Panel
			db2o_8	: inout	std_ulogic;	-- Flat Panel
			db2o_9	: inout	std_ulogic;	-- Flat Panel
			db2o_i	: in	std_ulogic_vector(15 downto 0);	-- padin
			db2o_o	: out	std_ulogic_vector(15 downto 0);	-- padout
			dbo_0	: inout	std_ulogic;	-- Flat Panel
			dbo_1	: inout	std_ulogic;	-- Flat Panel
			dbo_10	: inout	std_ulogic;	-- Flat Panel
			dbo_11	: inout	std_ulogic;	-- Flat Panel
			dbo_12	: inout	std_ulogic;	-- Flat Panel
			dbo_13	: inout	std_ulogic;	-- Flat Panel
			dbo_14	: inout	std_ulogic;	-- Flat Panel
			dbo_15	: inout	std_ulogic;	-- Flat Panel
			dbo_2	: inout	std_ulogic;	-- Flat Panel
			dbo_3	: inout	std_ulogic;	-- Flat Panel
			dbo_4	: inout	std_ulogic;	-- Flat Panel
			dbo_5	: inout	std_ulogic;	-- Flat Panel
			dbo_6	: inout	std_ulogic;	-- Flat Panel
			dbo_7	: inout	std_ulogic;	-- Flat Panel
			dbo_8	: inout	std_ulogic;	-- Flat Panel
			dbo_9	: inout	std_ulogic;	-- Flat Panel
			dbo_i	: in	std_ulogic_vector(15 downto 0);	-- padin
			dbo_o	: out	std_ulogic_vector(15 downto 0)	-- padout
		-- End of Generated Port for Entity padframe
		);
	end component;
	-- ---------



	--
	-- Generated Signal List
	--
		signal	db2o_i	: std_ulogic_vector(15 downto 0); 
		--  __I_OUT_OPEN signal	db2o_o	: std_ulogic_vector(15 downto 0); 
		signal	dbo_i	: std_ulogic_vector(15 downto 0); 
		--  __I_OUT_OPEN signal	dbo_o	: std_ulogic_vector(15 downto 0); 
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
		-- Generated Instance Port Map for i_padframe
		i_padframe: padframe
		port map (

			db2o_0 => db2o_0,	-- Flat Panel
			db2o_1 => db2o_1,	-- Flat Panel
			db2o_10 => db2o_10,	-- Flat Panel
			db2o_11 => db2o_11,	-- Flat Panel
			db2o_12 => db2o_12,	-- Flat Panel
			db2o_13 => db2o_13,	-- Flat Panel
			db2o_14 => db2o_14,	-- Flat Panel
			db2o_15 => db2o_15,	-- Flat Panel
			db2o_2 => db2o_2,	-- Flat Panel
			db2o_3 => db2o_3,	-- Flat Panel
			db2o_4 => db2o_4,	-- Flat Panel
			db2o_5 => db2o_5,	-- Flat Panel
			db2o_6 => db2o_6,	-- Flat Panel
			db2o_7 => db2o_7,	-- Flat Panel
			db2o_8 => db2o_8,	-- Flat Panel
			db2o_9 => db2o_9,	-- Flat Panel
			db2o_i => db2o_i,	-- padin (X2)
			db2o_o => open,	-- padout (X2) -- __I_OUT_OPEN
			dbo_0 => dbo_0,	-- Flat Panel
			dbo_1 => dbo_1,	-- Flat Panel
			dbo_10 => dbo_10,	-- Flat Panel
			dbo_11 => dbo_11,	-- Flat Panel
			dbo_12 => dbo_12,	-- Flat Panel
			dbo_13 => dbo_13,	-- Flat Panel
			dbo_14 => dbo_14,	-- Flat Panel
			dbo_15 => dbo_15,	-- Flat Panel
			dbo_2 => dbo_2,	-- Flat Panel
			dbo_3 => dbo_3,	-- Flat Panel
			dbo_4 => dbo_4,	-- Flat Panel
			dbo_5 => dbo_5,	-- Flat Panel
			dbo_6 => dbo_6,	-- Flat Panel
			dbo_7 => dbo_7,	-- Flat Panel
			dbo_8 => dbo_8,	-- Flat Panel
			dbo_9 => dbo_9,	-- Flat Panel
			dbo_i => dbo_i,	-- padin (X2)
			dbo_o => open	-- padout -- __I_OUT_OPEN
		);

		-- End of Generated Instance Port Map for i_padframe



end struct;


--
--!End of Architecture/s
-- --------------------------------------------------------------
