-- -------------------------------------------------------------
--
-- Generated Entity Declaration for %ENTYNAME%
--
-- Based on Mix Entity Template mix_template-e.vhd
--
-- (C) 2002 Micronas GmbH
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: lutscher $
-- $Id: mix_template-e.vhd,v 1.1 2009/12/15 12:02:53 lutscher Exp $
-- $Date: 2009/12/15 12:02:53 $
-- $Log: mix_template-e.vhd,v $
-- Revision 1.1  2009/12/15 12:02:53  lutscher
-- initial release
--
-- Revision 1.1  2003/03/25 13:49:00  wig
-- VHDL Templates
--
--
-- Generator: %0%%VERSION%, wilfried.gaensheimer@micronas.com
--
-- --------------------------------------------------------------
Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.std_logic_arith.all;

entity %ENTYNAME% is
	generic(
	    -- %GEN% : %TYPE% := %VALUE;
	    -- generic list
	);
	
	port(
	    -- generated
	    %S% : %IO% %TYPE%;
	     -- %IO% := in|out|inout|buffer
	    
--             CLK           :  in std_ulogic;
--	       RESET         :  in std_ulogic;  
--            TEST_SE       :  in std_ulogic;
--            AM_PM_DISPLAY : out std_ulogic;
--	       DISP1         : out std_ulogic_vector(13 downto 0);
--            DISP2         : out std_ulogic_vector(13 downto 0)
             );
end %ENTYNAME%;


