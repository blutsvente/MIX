-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for PADS_struct
--
-- Generated by wig
--           on Wed Jan 29 16:39:40 2003
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author$
-- $Id$
-- $Date$
-- $Log$
--
-- Based on Mix Architecture Template
--
-- Generator: mix_0.pl /mix/0.1, wilfried.gaensheimer@micronas.com
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.std_logic_arith.all;

--
--
-- Start of Generated Architecture PADS_struct
--
architecture PADS_struct of PADS is 

	--
	-- Components
	--

	-- Generated Components
			component padcell
			
			port (
			-- generated
			-- NO OUT PORTs	: 	;
			EI	: in	std_ulogic;
			EO	: out	std_ulogic
			-- end of generated port

			);
			end component;
		-- ---------

			component padcell_4_e
			
			port (
			-- generated
			EI	: in	std_ulogic;
			EO	: out	std_ulogic
			-- end of generated port

			);
			end component;
		-- ---------



	--
	-- Nets
	--

			--
			-- Generated Signals
			--
			signal	__LOGIC0__	: __E_TYPE_MISMATCH(3 downto 0);
			signal	pad_conn_1_2	: std_ulogic;
			signal	pad_conn_2_3	: std_ulogic;
			signal	pad_conn_3_4	: std_ulogic;
			signal	pad_conn_4_5	: std_ulogic;
			signal	pad_conn_5_6	: std_ulogic;
			signal	pad_conn_6_7	: std_ulogic;
			signal	pad_conn_7_8	: std_ulogic;
			signal	pad_conn_8_9	: std_ulogic;
			signal	pad_conn_9_10	: std_ulogic;
			--
			-- End of Generated Signals
			--


	-- %CONSTANTS%

begin

	--
	-- Generated Concurrent Statements
	--

	-- Generated Signal Assignments
			__LOGIC0__ <= '0';


	--
	-- Generated Instances
	--

	-- Generated Instances and Port Mappings
			-- Generated Instance Port Map for Pad_1
			Pad_1: padcell PORT MAP(
				EI => __LOGIC0__,
				EO => pad_conn_1_2
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_10
			Pad_10: padcell PORT MAP(
				EI => pad_conn_9_10
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_2
			Pad_2: padcell PORT MAP(
				EI => pad_conn_1_2,
				EO => pad_conn_2_3
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_3
			Pad_3: padcell PORT MAP(
				EI => pad_conn_2_3,
				EO => pad_conn_3_4
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_4
			Pad_4: padcell_4_e PORT MAP(
				EI => pad_conn_3_4,
				EO => pad_conn_4_5
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_5
			Pad_5: padcell PORT MAP(
				EI => pad_conn_4_5,
				EO => pad_conn_5_6
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_6
			Pad_6: padcell PORT MAP(
				EI => pad_conn_5_6,
				EO => pad_conn_6_7
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_7
			Pad_7: padcell PORT MAP(
				EI => pad_conn_6_7,
				EO => pad_conn_7_8
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_8
			Pad_8: padcell PORT MAP(
				EI => pad_conn_7_8,
				EO => pad_conn_8_9
			);
			-- End of Generated Instance Port Map
			-- Generated Instance Port Map for Pad_9
			Pad_9: padcell PORT MAP(
				EI => pad_conn_8_9,
				EO => pad_conn_9_10
			);
			-- End of Generated Instance Port Map


end PADS_struct;

--
--!End of Entity/ies
-- --------------------------------------------------------------
