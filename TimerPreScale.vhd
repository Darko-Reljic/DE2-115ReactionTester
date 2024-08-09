----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : TimerPreScale
-- Description   : This prescaler will scale the clock to around 10 ms as we found that with two displays available as it
-- 					 allows for our reaction time range to be from 10 ms to 990 ms which we think is reasonable as the average
-- 					 human reaction is around 265 ms according to google searches
--
-- 					 Please note that the cycle loops around so if you are more than 990 ms the timer is not accurate
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-08-05
----------------------------------------------------------------------------------
-- 100 hz = 10 ms

-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TimerPreScale IS
	-- generic integer that will allow us to create a 24 bit vector
	GENERIC (size	: integer := 23);

	PORT (
		InClock	: IN STD_LOGIC;
		OutClock	: OUT STD_LOGIC);
END TimerPreScale;

ARCHITECTURE BEHAVIOR OF TimerPreScale IS
	-- defining  24 BIT signal and assigning all bits to 0
    SIGNAL ACCUMULATOR : UNSIGNED(size DOWNTO 0) := (OTHERS => '0'); 
	 
BEGIN
	PROCESS(InClock)
		BEGIN
			IF RISING_EDGE(InClock) THEN
			-- on every clock cycle we increment the unsigned vector by 34
            ACCUMULATOR <= ACCUMULATOR + 34; 
			END IF;
	END PROCESS;

	-- setting the MSB of the accumulator to the output clock signal
   OutClock <= ACCUMULATOR(size);
	
END BEHAVIOR;
