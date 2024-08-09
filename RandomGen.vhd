----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : RandomGen
-- Description   : Uses a linear feedback shift register to return a pseudorandom 4 bit vector every clock cycle
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : none

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-08-05
----------------------------------------------------------------------------------

-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RandomGen IS
    PORT (
        clk     : IN STD_LOGIC;
        enable  : IN STD_LOGIC;
        output  : OUT STD_LOGIC_VECTOR(3 downto 0)
    );
END RandomGen;

ARCHITECTURE BEHAVIOUR OF RandomGen IS

	 -- Initialize LFSR with a non-zero value, making the sequence varied between 0 & 1 as it makes the sequence harder to predict
    SIGNAL lfsr : STD_LOGIC_VECTOR(15 downto 0) := "1110100010101001";

BEGIN

    PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF enable = '1' THEN
                -- LFSR logic for pseudo random number generation
					 -- we use the concatenate operator to add the result of the four XOR Gates to the MSB of the linear
					 -- feedbackshift register 
                lfsr <= lfsr(14 downto 0) & (lfsr(15) XOR lfsr(14) XOR lfsr(13) XOR lfsr(11));
					 
					 -- here we convert the std_logic_vector lfsr to an unsigned int as addition is not defined for 
					 -- std_logic_vector types, after the addition is completed we assign the value to the output signal which must be
					 -- a std_logic_vector type
                output <= std_logic_vector(unsigned(lfsr(5 downto 2)) + unsigned(lfsr(14 downto 11))); -- Output the lower 4 bits of the LFSR
            END IF;
        END IF;
    END PROCESS;

END BEHAVIOUR;
