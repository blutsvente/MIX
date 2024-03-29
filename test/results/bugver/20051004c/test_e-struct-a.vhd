-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for struct of test_e
--
-- Generated
--  by:  wig
--  on:  Thu Oct  6 12:55:50 2005
--  cmd: /cygdrive/h/work/eclipse/MIX/mix_0.pl -strip -nodelta ../../bugver.xls
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- $Author: wig $
-- $Id: test_e-struct-a.vhd,v 1.1 2005/10/06 13:36:57 wig Exp $
-- $Date: 2005/10/06 13:36:57 $
-- $Log: test_e-struct-a.vhd,v $
-- Revision 1.1  2005/10/06 13:36:57  wig
-- New testcase or generics
--
--
-- Based on Mix Architecture Template built into RCSfile: MixWriter.pm,v 
-- Id: MixWriter.pm,v 1.59 2005/10/06 11:21:44 wig Exp 
--
-- Generator: mix_0.pl Revision: 1.37 , wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- No project specific VHDL libraries/arch


--
--
-- Start of Generated Architecture struct of test_e
--
architecture struct of test_e is 

	-- Generated Constant Declarations


	--
	-- Components
	--

	-- Generated Components
	component inst_bug_e
		generic (
		-- Generated Generics for Entity inst_bug_e
			CHROMA_GROUP_DELAY2_G	: integer	:= 1;
			CHROMA_GROUP_DELAY_G	: integer	:= 12;
			CHROMA_LINE_DELAY2_G	: integer	:= 3;
			CHROMA_LINE_DELAY_G	: integer	:= 0;
			CHROMA_PIPE_DELAY2_G	: integer	:= 2;
			CHROMA_PIPE_DELAY_G	: integer	:= 1
		-- End of Generated Generics for Entity inst_bug_e
		);
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
		-- Generated Instance Port Map for inst_7_ar_chroma_delay
		inst_7_ar_chroma_delay: inst_bug_e
		generic map (
			CHROMA_GROUP_DELAY2_G => 4,
			CHROMA_GROUP_DELAY_G => 12,
			CHROMA_LINE_DELAY2_G => 6,
			CHROMA_LINE_DELAY_G => 0,
			CHROMA_PIPE_DELAY2_G => 5,
			CHROMA_PIPE_DELAY_G => 1
		)

		;
		-- End of Generated Instance Port Map for inst_7_ar_chroma_delay

		-- Generated Instance Port Map for inst_9_ar_chroma_delay
		inst_9_ar_chroma_delay: inst_bug_e
		generic map (
			CHROMA_GROUP_DELAY2_G => 7,
			CHROMA_GROUP_DELAY_G => 8,
			CHROMA_LINE_DELAY2_G => 9,
			CHROMA_LINE_DELAY_G => 3,
			CHROMA_PIPE_DELAY2_G => 8,
			CHROMA_PIPE_DELAY_G => 3
		)

		;
		-- End of Generated Instance Port Map for inst_9_ar_chroma_delay



end struct;


--
--!End of Architecture/s
-- --------------------------------------------------------------
