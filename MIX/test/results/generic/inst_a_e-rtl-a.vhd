-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of inst_a_e
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:55:58 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\generic.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: inst_a_e-rtl-a.vhd,v 1.1 2004/04/06 11:09:19 wig Exp $
-- $Date: 2004/04/06 11:09:19 $
-- $Log: inst_a_e-rtl-a.vhd,v $
-- Revision 1.1  2004/04/06 11:09:19  wig
-- Adding result/generic
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.17 , wilfried.gaensheimer@micronas.com
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
	component inst_1_e	-- 
		generic (
		-- Generated Generics for Entity inst_1_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_1_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_10_e	-- 
		generic (
		-- Generated Generics for Entity inst_10_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_10_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_2_e	-- 
		generic (
		-- Generated Generics for Entity inst_2_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_2_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_3_e	-- 
		generic (
		-- Generated Generics for Entity inst_3_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_3_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_4_e	-- 
		generic (
		-- Generated Generics for Entity inst_4_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_4_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_5_e	-- 
		generic (
		-- Generated Generics for Entity inst_5_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_5_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_6_e	-- 
		generic (
		-- Generated Generics for Entity inst_6_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_6_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_7_e	-- 
		generic (
		-- Generated Generics for Entity inst_7_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_7_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_8_e	-- 
		generic (
		-- Generated Generics for Entity inst_8_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_8_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_9_e	-- 
		generic (
		-- Generated Generics for Entity inst_9_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_9_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_aa_e	-- 
		generic (
		-- Generated Generics for Entity inst_aa_e
			NO_DEFAULT	: string; -- __W_NODEFAULT
			NO_NAME	: string; -- __W_NODEFAULT
			WIDTH	: integer	:= 7
		-- End of Generated Generics for Entity inst_aa_e
		);
		-- No Generated Port
	end component;
	-- ---------

	component inst_ab_e	-- 
		generic (
		-- Generated Generics for Entity inst_ab_e
			FOO	: integer	:= 64
		-- End of Generated Generics for Entity inst_ab_e
		);
		-- No Generated Port
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
		-- Generated Instance Port Map for inst_1
		inst_1: inst_1_e
		generic map (
			FOO => 16
		)

		;
		-- End of Generated Instance Port Map for inst_1

		-- Generated Instance Port Map for inst_10
		inst_10: inst_10_e
		generic map (
			FOO => 32
		)

		;
		-- End of Generated Instance Port Map for inst_10

		-- Generated Instance Port Map for inst_2
		inst_2: inst_2_e
		generic map (
			FOO => 16
		)

		;
		-- End of Generated Instance Port Map for inst_2

		-- Generated Instance Port Map for inst_3
		inst_3: inst_3_e
		generic map (
			FOO => 16
		)

		;
		-- End of Generated Instance Port Map for inst_3

		-- Generated Instance Port Map for inst_4
		inst_4: inst_4_e
		generic map (
			FOO => 16
		)

		;
		-- End of Generated Instance Port Map for inst_4

		-- Generated Instance Port Map for inst_5
		inst_5: inst_5_e
		generic map (
			FOO => 16
		)

		;
		-- End of Generated Instance Port Map for inst_5

		-- Generated Instance Port Map for inst_6
		inst_6: inst_6_e
		generic map (
			FOO => 32
		)

		;
		-- End of Generated Instance Port Map for inst_6

		-- Generated Instance Port Map for inst_7
		inst_7: inst_7_e
		generic map (
			FOO => 32
		)

		;
		-- End of Generated Instance Port Map for inst_7

		-- Generated Instance Port Map for inst_8
		inst_8: inst_8_e
		generic map (
			FOO => 32
		)

		;
		-- End of Generated Instance Port Map for inst_8

		-- Generated Instance Port Map for inst_9
		inst_9: inst_9_e
		generic map (
			FOO => 32
		)

		;
		-- End of Generated Instance Port Map for inst_9

		-- Generated Instance Port Map for inst_aa
		inst_aa: inst_aa_e
		generic map (
			NO_DEFAULT => "nodefault",
			NO_NAME => "noname",
			WIDTH => 15
		)

		;
		-- End of Generated Instance Port Map for inst_aa

		-- Generated Instance Port Map for inst_ab
		inst_ab: inst_ab_e

		;
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
