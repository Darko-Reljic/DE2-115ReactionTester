----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : SegDecoder
-- Description   : SegDecoder assigns what segments need to be on to represent the corresponding input vector D's value is
-- 					 in hexadecimal
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-07-29
----------------------------------------------------------------------------------
-- including necessary files needed throughout the program
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SegDecoder IS
				-- D is our 4 bit input vector that tells us what hex number 0-F will be displayed
				-- Y is our 7 bit vector that will assign what segments to turn on to display the correct
				-- vector according to our input signal D
    Port (	D : in std_logic_vector(3 downto 0);
				Y : out std_logic_vector(6 downto 0));
END SegDecoder;

ARCHITECTURE BEHAVIOUR OF SegDecoder IS
BEGIN

    WITH D SELECT
        Y <= "1000000" WHEN "0000",	-- display 0
             "1111001" WHEN "0001", -- display 1
             "0100100" WHEN "0010", -- display 2
             "0110000" WHEN "0011", -- display 3
             "0011001" WHEN "0100", -- display 4
             "0010010" WHEN "0101", -- display 5
             "0000010" WHEN "0110", -- display 6
             "1111000" WHEN "0111", -- display 7
             "0000000" WHEN "1000", -- display 8
             "0010000" WHEN "1001", -- display 9
             "0001000" WHEN "1010", -- display A
             "0000011" WHEN "1011", -- display B
             "1000110" WHEN "1100", -- display C
             "0100001" WHEN "1101", -- display D
             "0000110" WHEN "1110", -- display E
             "0001110" WHEN "1111"; -- display F
    
END BEHAVIOUR;