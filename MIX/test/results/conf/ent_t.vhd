-- -------------------------------------------------------------
--
--  Entity Declaration for ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:57:35 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\conf.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t.vhd,v 1.1 2004/04/06 11:12:17 wig Exp $
-- $Date: 2004/04/06 11:12:17 $
-- $Log: ent_t.vhd,v $
-- Revision 1.1  2004/04/06 11:12:17  wig
-- Adding result/conf
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.17 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/enty

--

--
-- Start of Generated Entity ent_t
--
entity ent_t is
        -- Generics:
		-- No Generated Generics for Entity ent_t

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ent_t
			sig_i_a	: in	std_ulogic;
			sig_i_a2	: in	std_ulogic;
			sig_i_ae	: in	std_ulogic_vector(6 downto 0);
			sig_o_a	: out	std_ulogic;
			sig_o_a2	: out	std_ulogic;
			sig_o_ae	: out	std_ulogic_vector(7 downto 0)
		-- End of Generated Port for Entity ent_t
		);
end ent_t;
--
-- End of Generated Entity ent_t
--

--
--!End of Entity/ies
-- --------------------------------------------------------------
-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for rtl of ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:57:35 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\conf.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t.vhd,v 1.1 2004/04/06 11:12:17 wig Exp $
-- $Date: 2004/04/06 11:12:17 $
-- $Log: ent_t.vhd,v $
-- Revision 1.1  2004/04/06 11:12:17  wig
-- Adding result/conf
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
-- Start of Generated Architecture rtl of ent_t
--
architecture rtl of ent_t is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component ent_a	-- 
		-- No Generated Generics
		port (
		-- Generated Port for Entity ent_a
			p_mix_sig_01_go	: out	std_ulogic;
			p_mix_sig_03_go	: out	std_ulogic;
			p_mix_sig_04_gi	: in	std_ulogic;
			p_mix_sig_05_2_1_go	: out	std_ulogic_vector(1 downto 0);
			p_mix_sig_06_gi	: in	std_ulogic_vector(3 downto 0);
			p_mix_sig_i_ae_gi	: in	std_ulogic_vector(6 downto 0);
			p_mix_sig_o_ae_go	: out	std_ulogic_vector(7 downto 0);
			port_i_a	: in	std_ulogic;
			port_o_a	: out	std_ulogic;
			sig_07	: in	std_ulogic_vector(5 downto 0);
			sig_08	: out	std_ulogic_vector(8 downto 2);
			sig_13	: out	std_ulogic_vector(4 downto 0);
			sig_i_a2	: in	std_ulogic;
			sig_o_a2	: out	std_ulogic
		-- End of Generated Port for Entity ent_a
		);
	end component;
	-- ---------

	component ent_b	-- 
		-- No Generated Generics
		-- Generated Generics for Entity ent_b
		-- End of Generated Generics for Entity ent_b
		port (
		-- Generated Port for Entity ent_b
			port_b_1	: in	std_ulogic;
			port_b_3	: in	std_ulogic;
			port_b_4	: out	std_ulogic;
			port_b_5_1	: in	std_ulogic;
			port_b_5_2	: in	std_ulogic;
			port_b_6i	: in	std_ulogic_vector(3 downto 0);
			port_b_6o	: out	std_ulogic_vector(3 downto 0);
			sig_07	: in	std_ulogic_vector(5 downto 0);
			sig_08	: in	std_ulogic_vector(8 downto 2)
		-- End of Generated Port for Entity ent_b
		);
	end component;
	-- ---------



	--
	-- Nets
	--

		--
		-- Generated Signal List
		--
			signal	sig_01	: std_ulogic; 
			signal	sig_03	: std_ulogic; 
			signal	sig_04	: std_ulogic; 
			signal	sig_05	: std_ulogic_vector(3 downto 0); 
			signal	sig_06	: std_ulogic_vector(3 downto 0); 
			signal	sig_07	: std_ulogic_vector(5 downto 0); 
			signal	sig_08	: std_ulogic_vector(8 downto 2); 
			--  __I_OUT_OPEN signal	sig_13	: std_ulogic_vector(4 downto 0); 
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
		-- Generated Instance Port Map for inst_a
		inst_a: ent_a
		port map (
			p_mix_sig_01_go => sig_01, -- Use internally test1Will create p_mix_sig_1_go port
			p_mix_sig_03_go => sig_03, -- Interhierachy link, will create p_mix_sig_3_go
			p_mix_sig_04_gi => sig_04, -- Interhierachy link, will create p_mix_sig_4_gi
			p_mix_sig_05_2_1_go => sig_05(2 downto 1), -- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,
			p_mix_sig_06_gi => sig_06, -- Conflicting definition (X2)
			p_mix_sig_i_ae_gi => sig_i_ae, -- Input Bus
			p_mix_sig_o_ae_go => sig_o_ae, -- Output Bus
			port_i_a => sig_i_a, -- Input Port
			port_o_a => sig_o_a, -- Output Port
			sig_07 => sig_07, -- Conflicting definition, IN false!
			sig_08 => sig_08, -- VHDL intermediate needed (port name)
			sig_13 => open, -- Create internal signal name -- __I_OUT_OPEN
			sig_i_a2 => sig_i_a2, -- Input Port
			sig_o_a2 => sig_o_a2 -- Output Port
		);
		-- End of Generated Instance Port Map for inst_a

		-- Generated Instance Port Map for inst_b
		inst_b: ent_b
		port map (
			port_b_1 => sig_01, -- Use internally test1Will create p_mix_sig_1_go port
			port_b_3 => sig_03, -- Interhierachy link, will create p_mix_sig_3_go
			port_b_4 => sig_04, -- Interhierachy link, will create p_mix_sig_4_gi
			port_b_5_1 => sig_05(2), -- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,
			port_b_5_2 => sig_05(1), -- Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBus,
			port_b_6i => sig_06, -- Conflicting definition (X2)
			port_b_6o => sig_06, -- Conflicting definition (X2)
			sig_07 => sig_07, -- Conflicting definition, IN false!
			sig_08 => sig_08 -- VHDL intermediate needed (port name)
		);
		-- End of Generated Instance Port Map for inst_b



end rtl;

--
--!End of Architecture/s
-- --------------------------------------------------------------
-- -------------------------------------------------------------
--
-- Generated Configuration for ent_t
--
-- Generated
--  by:  wig
--  on:  Thu Nov  6 15:57:35 2003
--  cmd: H:\work\mix\mix_0.pl -nodelta ..\conf.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: ent_t.vhd,v 1.1 2004/04/06 11:12:17 wig Exp $
-- $Date: 2004/04/06 11:12:17 $
-- $Log: ent_t.vhd,v $
-- Revision 1.1  2004/04/06 11:12:17  wig
-- Adding result/conf
--
--
-- Based on Mix Entity Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.31 2003/10/23 12:13:17 wig Exp 
--
-- Generator: mix_0.pl Version: Revision: 1.17 , wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/conf


--
-- Start of Generated Configuration ent_t_rtl_config / ent_t
--
configuration ent_t_rtl_config of ent_t is
        for rtl

	    	-- Generated Configuration
			for inst_a : ent_a
				use configuration work.ent_a_rtl_config;
			end for;
			-- __I_NO_CONFIG_VERILOG --for inst_b : ent_b
			-- __I_NO_CONFIG_VERILOG --	use configuration work.ent_b_rtl_config;
			-- __I_NO_CONFIG_VERILOG --end for;


	end for; 
end ent_t_rtl_config;
--
-- End of Generated Configuration ent_t_rtl_config
--

--
--!End of Configuration/ies
-- --------------------------------------------------------------