-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_ec_e
--
-- Generated
--  by:  wig
--  on:  Mon Apr 10 13:27:22 2006
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -nodelta ../../bitsplice.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_ec_e-rtl-a.vhd,v 1.1 2006/04/10 15:42:05 wig Exp $
-- $Date: 2006/04/10 15:42:05 $
-- $Log: inst_ec_e-rtl-a.vhd,v $
-- Revision 1.1  2006/04/10 15:42:05  wig
-- Updated testcase (__TOP__)
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.79 2006/03/17 09:18:31 wig Exp 
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
-- Start of Generated Architecture rtl of inst_ec_e
--
architecture rtl of inst_ec_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_eca_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_eca_e
		-- End of Generated Generics for Entity inst_eca_e
		-- No Generated Port
	end component;
	-- ---------

	component inst_ecb_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ecb_e
		-- End of Generated Generics for Entity inst_ecb_e
		-- No Generated Port
	end component;
	-- ---------

	component inst_ecc_e
		-- No Generated Generics
		-- Generated Generics for Entity inst_ecc_e
		-- End of Generated Generics for Entity inst_ecc_e
		-- No Generated Port
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
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
		-- Generated Instance Port Map for inst_eca
		inst_eca: inst_eca_e

		;
		-- End of Generated Instance Port Map for inst_eca

		-- Generated Instance Port Map for inst_ecb
		inst_ecb: inst_ecb_e

		;
		-- End of Generated Instance Port Map for inst_ecb

		-- Generated Instance Port Map for inst_ecc
		inst_ecc: inst_ecc_e

		;
		-- End of Generated Instance Port Map for inst_ecc



end rtl;


--
--!End of Architecture/s
-- --------------------------------------------------------------
