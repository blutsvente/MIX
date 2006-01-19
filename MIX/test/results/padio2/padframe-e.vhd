-- -------------------------------------------------------------
--
--  Entity Declaration for padframe
--
-- Generated
--  by:  wig
--  on:  Thu Jan 19 07:44:48 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../padio2.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: padframe-e.vhd,v 1.4 2006/01/19 08:50:40 wig Exp $
-- $Date: 2006/01/19 08:50:40 $
-- $Log: padframe-e.vhd,v $
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

-- No project specific VHDL libraries/enty


--

--
-- Start of Generated Entity padframe
--
entity padframe is

	-- Generics:
		-- No Generated Generics for Entity padframe

	-- Generated Port Declaration:
		port(
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
end padframe;
--
-- End of Generated Entity padframe
--


--
--!End of Entity/ies
-- --------------------------------------------------------------
