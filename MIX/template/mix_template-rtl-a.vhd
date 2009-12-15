-- -------------------------------------------------------------
-- MIX Architecture Template
--
-- (C) 2002 Micronas GmbH

-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: lutscher $
-- $Id: mix_template-rtl-a.vhd,v 1.1 2009/12/15 12:02:53 lutscher Exp $
-- $Date: 2009/12/15 12:02:53 $
-- $Log: mix_template-rtl-a.vhd,v $
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
--weg: Library IEEE;
--weg: Use IEEE.std_logic_1164.all;
--weg: Use IEEE.std_logic_arith.all;

architecture %ARCH% of %ENTY% is 

-- components 
	component %ENTY%  
	port(	-- SET_TIME,HRS,MINS,CLK: in std_ulogic;
		-- RESET    : in std_ulogic;
	     	-- CONNECT6:buffer INTEGER range 1 to 12;
	     	-- CONNECT7:buffer INTEGER range 0 to 59;
	     	-- CONNECT8: buffer std_ulogic
	    ); 
	end component;

-- top level nets
	-- signal KONNECT7,KONNECT10 : INTEGER range 0 to 59; 
	-- signal KONNECT8,KONNECT11,KONNECT12 : std_ulogic; 
	-- signal KONNECT6,KONNECT9 : INTEGER range 1 to 12; 
	-- signal KONNECT13 : unsigned(10 downto 0);

begin

	-- AM_PM_DISPLAY <= KONNECT13(0);

	%INST%: %ENTY%
          PORT MAP(
                 -- SET_TIME  => SET_TIME, pin/port to signal
                 -- HRS       => HRS,
                 -- MINS      => MINS,
                 -- CLK       => CLK,
                 -- RESET     => RESET,
                 -- CONNECT6  => KONNECT6,
                 -- CONNECT7  => KONNECT7,
                 -- CONNECT8  => KONNECT8
		 );


end;

--!End