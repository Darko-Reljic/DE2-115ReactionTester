----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : VarPreScale
-- Description   : Prescaler which takes in an extra signal to multiply the clock speed so its easy to change 
--						 for each individual speed mode though one variable
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-08-05
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VarPreScale IS

	GENERIC (aLength : integer := 25); -- set number of bits to store accumulated number, if speedIn is 1, clockOut freq = (clockIn freq)/(2^(aLength))Hz

	PORT (
		clockIn	: IN STD_LOGIC;
		speedIn	: IN UNSIGNED(1 downto 0); -- number to add to ACCUMULATOR each clock cycle, if aLength is 1, clockOut freq = (clockIn freq) * (speedIn)Hz
		clockOut	: OUT STD_LOGIC);
END VarPreScale;

ARCHITECTURE BEHAVIOR OF VarPreScale IS
    SIGNAL ACCUMULATOR : UNSIGNED(aLength - 1 DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	PROCESS(clockIn)
		BEGIN
			IF RISING_EDGE(clockIn) THEN
            ACCUMULATOR <= ACCUMULATOR + speedIn; 
			END IF;
	END PROCESS;

   clockOut <= ACCUMULATOR(aLength - 1);
	
END BEHAVIOR;
