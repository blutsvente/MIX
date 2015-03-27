-- -------------------------------------------------------------
--
--  Entity Declaration for pads_westsouth
--
-- Generated
--  by:  wig
--  on:  Thu Jan 19 07:44:48 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: pads_westsouth-e.vhd,v 1.4 2006/01/19 08:50:40 wig Exp $
-- $Date: 2006/01/19 08:50:40 $
-- $Log: pads_westsouth-e.vhd,v $
-- Revision 1.4  2006/01/19 08:50:40  wig
-- Updated testcases, left 6 failing now (constant, bitsplice/X, ...)
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.75 2006/01/18 16:59:29 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.43 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- Generated use statements
library work;
use work.vst_5lm_io_components.all;


--

--
-- Start of Generated Entity pads_westsouth
--
entity pads_westsouth is

	-- Generics:
		-- No Generated Generics for Entity pads_westsouth

	-- Generated Port Declaration:
		port(
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
end pads_westsouth;
--
-- End of Generated Entity pads_westsouth
--


--
--!End of Entity/ies
-- --------------------------------------------------------------