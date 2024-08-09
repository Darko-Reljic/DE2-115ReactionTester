----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : Count4
-- Description   : 4 bit up counter note this is the exact same file as from our lab 6
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-07-29
----------------------------------------------------------------------------------
-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Count4 IS
	PORT (
		load		: IN STD_LOGIC;
		enable	: IN STD_LOGIC;
		clock		: IN STD_LOGIC;
		D			: IN STD_LOGIC_VECTOR(3 downto 0);
		Q			: OUT UNSIGNED(3 downto 0));
END Count4;

ARCHITECTURE BEHAVIOUR OF Count4 IS
	
	-- internal signal for counter value
	SIGNAL Qinter	: STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
	SIGNAL QXOR 	: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL MUX		: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL QAND		: STD_LOGIC_VECTOR(2 downto 0);
	
BEGIN

	--using generate statements just like in our labs to use as little assignments as possible
	QAND(0) <= enable AND Qinter(0);
	genAND : FOR i IN 1 TO 2 GENERATE
		QAND(i) <= QAND(i-1) AND Qinter(i);
	END GENERATE genAND;
		
	QXOR(0) <= enable XOR Qinter(0);
	genXOR : FOR i in 1 TO 3 GENERATE
		QXOR(i) <= QAND(i-1) XOR Qinter(i);
	END GENERATE genXOR;
		
	
	
	PROCESS(clock)
		BEGIN
									
			IF RISING_EDGE(clock) THEN
				
				IF load = '0' THEN 
					MUX <= QXOR;
				ELSE
				-- load counter with data from BUS 'D'
					MUX <= D;
				END IF;
						
			END IF;
			
	END PROCESS;
	--output counter value 
	Q <= UNSIGNED(MUX);
	
	Qinter <= MUX;
	
END BEHAVIOUR;