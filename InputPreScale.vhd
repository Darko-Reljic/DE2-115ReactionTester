----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : InputPreScale
-- Description   : Prescaler for input polling
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-07-29
----------------------------------------------------------------------------------

-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY InputPreScale IS

-- declaring generic for size of vector
	GENERIC (size	: integer := 22);

	PORT (
		InClock	: IN STD_LOGIC;
		OutClock	: OUT STD_LOGIC);
END InputPreScale;

ARCHITECTURE BEHAVIOR OF InputPreScale IS
-- signal for our accumulator a 23 bit unsigned vector
    SIGNAL ACCUMULATOR : UNSIGNED(size DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	PROCESS(InClock)
		BEGIN
		-- add one to accumulator signal on every rising edge
			IF RISING_EDGE(InClock) THEN
            ACCUMULATOR <= ACCUMULATOR + 1; 
			END IF;
	END PROCESS;

   OutClock <= ACCUMULATOR(size);
	
END BEHAVIOR;
