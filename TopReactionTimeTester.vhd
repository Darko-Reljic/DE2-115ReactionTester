----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : TopReactionTimeTester
-- Description   : Top level entity to instantiate ReactionTimer to DE2-115 ports
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : ReactionTimeTester

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-07-29
----------------------------------------------------------------------------------
-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TopReactionTimeTester IS
	PORT (	-- 50Mhz clock signal 
				CLOCK_50 : IN STD_LOGIC;
				-- declaring vector for our 3 keys
				KEY 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				-- declaring vector for switches
				SW			: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				--declaring vectors for 
				LEDG		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				LEDR		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				--declaring a 7 bit vector for each HEX display
				HEX7, HEX6, HEX5, HEX4, HEX3, HEX1, HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END TopReactionTimeTester;

ARCHITECTURE BEHAVIOUR OF TopReactionTimeTester IS

	COMPONENT ReactionTimeTester IS
		PORT ( 	clock 	: IN STD_LOGIC;
					inKey	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
					inSw	: IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
					h7, h6, h5, h4, h3, h1, h0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;
BEGIN
	
	--Instantiate Reaction time tester
	RTT : ReactionTimeTester PORT MAP (CLOCK_50, KEY(2 DOWNTO 0), SW(1 DOWNTO 0), HEX7, HEX6, HEX5, HEX4, HEX3, HEX1, HEX0);

	-- Link LEDS to switches and keys
	LEDG(0) <= NOT KEY(0);
	LEDG(2) <= NOT KEY(1);
	LEDG(4) <= NOT KEY(2);
	
	LEDR(1 DOWNTO 0) <= SW(1 DOWNTO 0);
	
END BEHAVIOUR;