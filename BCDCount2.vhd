----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : BCDCount2
-- Description   : 2 digit BCD counter
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : Count4

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-07-29
----------------------------------------------------------------------------------
-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY BCDCount2 IS
	PORT (
		clear			: IN STD_LOGIC;
		clock			: IN STD_LOGIC;
		enable		: IN STD_LOGIC;
		BCD0, BCD1	: OUT STD_LOGIC_VECTOR(3 downto 0));
END BCDCount2;

ARCHITECTURE BEHAVIOUR OF BCDCount2 IS

	COMPONENT Count4 IS
		PORT (
			load		: IN STD_LOGIC;
			enable	: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			D			: IN STD_LOGIC_VECTOR(3 downto 0);
			Q			: OUT UNSIGNED(3 downto 0));
	END COMPONENT;
	
	-- signals for carry outs
	SIGNAL R0, R1 	: STD_LOGIC;
	-- signals for counter enables
	SIGNAL C0, C1	: STD_LOGIC;
	-- signals for counter outputs
	SIGNAL Q0, Q1	: UNSIGNED(3 downto 0) := (OTHERS => '0');
	
BEGIN

	-- carry out signals for asynchronous clear
	R0 <= Q0(0) AND Q0(3);
	R1 <= Q1(0) AND Q1(3) AND R0;
	
	-- assigning enables to have asynchronous clear
	C0 <= R0 OR NOT clear;
	C1 <= R1 OR NOT clear;
	
	-- instantiate counters needed for one's unit and tens unit
	Counter0 : Count4 PORT MAP (C0, enable, clock, "0000", Q0);
	Counter1 : Count4 PORT MAP (C1, R0, clock, "0000", Q1);
	
	-- assigning counter outputs to BCD outputs
	BCD0 <= STD_LOGIC_VECTOR(Q0);
	BCD1 <= STD_LOGIC_VECTOR(Q1);

END BEHAVIOUR;