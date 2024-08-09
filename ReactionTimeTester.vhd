----------------------------------------------------------------------------------
-- Project		  : Reaction Timer

-- Design Name   : ReactionTimeTester
-- Description   : 8 state FSM implementing a two player "reaction test"
-- Purpose		  : SFU ENSC 252 Bonus Project
-- Dependencies  : SegDecoder, RandomGen, BCDCount2, VarPreScale, InputPreScale, TimerPreScale

-- Authors		  : Jack Hinderager - 301604320, Darko Reljic - 301561341
-- Last Modified : 2024-08-05
----------------------------------------------------------------------------------

-- including necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ReactionTimeTester IS
				-- we declared KEY 0, 1, 2 as our menu/interactive keys
				-- we delcared Switches 0, 1 as our input switches for speed selection
				-- h 0, 1... 7 are 7 SEG display outputs
	PORT ( 	clock 	: IN STD_LOGIC;
				inKey		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				inSw		: IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
				h7, h6, h5, h4, h3, h1, h0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END ReactionTimeTester;

ARCHITECTURE BEHAVIOUR OF ReactionTimeTester IS


--declaring each component according to their original file port map

	COMPONENT SegDecoder IS -- Convert 4 bit to 7 bit 7-seg displays values
		PORT ( 	D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
					Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;

	COMPONENT RandomGen IS -- Generates pseudorandom 4 bit vector
		PORT ( 	clk    : IN STD_LOGIC;
					enable : IN STD_LOGIC;
					output : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT BCDCount2 IS -- 2 digit BCD counter
		PORT ( 	clear  : IN STD_LOGIC;
					clock  : IN STD_LOGIC;
					enable : IN STD_LOGIC;
					BCD0   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
					BCD1   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT VarPreScale IS -- Prescaler with variable counting speed
		PORT ( 	clockIn  : IN STD_LOGIC;
					speedIn  : IN UNSIGNED(1 DOWNTO 0);
					clockOut : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT InputPreScale IS -- Prescaler for input polling
		PORT ( 	InClock	: IN STD_LOGIC;
					OutClock	: OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT TimerPreScale IS -- Prescaler for the player's timers
		PORT ( 	InClock	: IN STD_LOGIC;
					OutClock	: OUT STD_LOGIC);
	END COMPONENT;
	
	SIGNAL STATE, NEXT_STATE : STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	CONSTANT SPEED_SELECT 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "000" ; -- Speed selection
	CONSTANT SHOW_PLAYER1_TURN : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001" ; -- Show selected speed and what digit P1 is looking for 
	CONSTANT PLAYER1_TURN 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "011" ; -- Show 'random' sequence of digits 
	CONSTANT PLAYER1_REACT 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "010" ; -- When digit of interest appears, stop cycling through digits and start the reaction timer
	CONSTANT SHOW_PLAYER2_TURN : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110" ; -- Show selected speed and what digit P2 is looking for 
	CONSTANT PLAYER2_TURN 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "111" ; -- Show 'random' sequence of digits
	CONSTANT PLAYER2_REACT 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "101" ; -- When digit of interest appears, stop cycling through digits and start the reaction timer
	CONSTANT WINNER				: STD_LOGIC_VECTOR(2 DOWNTO 0) := "100" ; -- Show winner and by how much 
	
	SIGNAL COUNT1, COUNT2 	: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'); -- Reaction times for P1 and P2 respectively
	SIGNAL WINNERNUM			: STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => '0'); -- 7seg to output depending on winner
	SIGNAL WCOUNT, LCOUNT	: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'); -- respective winner and loser times
	
	SIGNAL VARCLOCKOUT		: STD_LOGIC; -- Variably prescaled clock to run the 'random' number generator
	SIGNAL INPUTCLOCKOUT		: STD_LOGIC; -- Prescaled clock to run the input polling
	SIGNAL TIMERCLOCKOUT		: STD_LOGIC; -- Prescaled clock to run the timer
	SIGNAL SPEED				: STD_LOGIC_VECTOR(1 DOWNTO 0); -- 'Speed' of clock: Number VarPreScale will add to accumulator each clock cycle

	SIGNAL RCLEAR 				: STD_LOGIC := '0'; -- Reset the "random" number generator to its initial value
	SIGNAL RENABLE 			: STD_LOGIC := '0'; -- Enable the "random" number generator
	SIGNAL RNUMBER 			: STD_LOGIC_VECTOR(3 DOWNTO 0); -- Current random number

	SIGNAL C1CLEAR 			: STD_LOGIC := '0'; -- Clear the current count, must be individual for soft reset functionality
	SIGNAL C2CLEAR 			: STD_LOGIC := '0';
	SIGNAL C1ENABLE 			: STD_LOGIC := '0'; -- Lets the counter count up when active
	SIGNAL C2ENABLE 			: STD_LOGIC := '0';

	SIGNAL D0, D1, D4, D5 : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input for SegDecoder(s)
	SIGNAL S0, S1, S4, S5 : STD_LOGIC_VECTOR(6 DOWNTO 0); -- Output from SegDecoder(s)

BEGIN
	PROCESS(clock)
	BEGIN
		IF (clock'EVENT AND clock = '1') THEN 
			STATE <= NEXT_STATE; -- Update the state every clock cycle
		END IF;
	END PROCESS;


	PROCESS (INPUTCLOCKOUT)
	BEGIN
		IF RISING_EDGE(INPUTCLOCKOUT) THEN
			CASE STATE IS
				WHEN SPEED_SELECT =>
					IF inKey(1) = '0' THEN -- Check for button press every clock cycle
						NEXT_STATE <= SHOW_PLAYER1_TURN;
					END IF;
						
				WHEN SHOW_PLAYER1_TURN =>
					IF inKey(1) = '0' THEN
						NEXT_STATE <= PLAYER1_TURN;
					ELSIF inKey(0) = '0' THEN
						NEXT_STATE <= SPEED_SELECT; -- Hard reset to go back to the SPEED_SELECT state
					END IF;
					
				WHEN PLAYER1_TURN =>
					IF RNUMBER = "0001" THEN
						NEXT_STATE <= PLAYER1_REACT;
					ELSIF inKey(0) = '0' THEN				-- Hard reset to go back to speed select
						NEXT_STATE <= SPEED_SELECT;
					ELSIF inKey(2) = '0' THEN
						NEXT_STATE <= SHOW_PLAYER1_TURN; -- Soft reset to go back to the start of P1's turn and reset timer
					END IF;
						
				WHEN PLAYER1_REACT =>
					IF inKey(1) = '0' THEN
						NEXT_STATE <= SHOW_PLAYER2_TURN;
					ELSIF inKey(0) = '0' THEN					-- Hard reset to go back to speed select
						NEXT_STATE <= SPEED_SELECT;
					ELSIF inKey(2) = '0' THEN
						NEXT_STATE<= SHOW_PLAYER1_TURN;
					END IF;

				WHEN SHOW_PLAYER2_TURN =>
					IF inKey(1) = '0' THEN
						NEXT_STATE <= PLAYER2_TURN;
					ELSIF inKey(0) = '0' THEN					-- Hard reset to go back to speed select
						NEXT_STATE <= SPEED_SELECT;
					END IF;
					
				WHEN PLAYER2_TURN =>
					IF RNUMBER = "0001" THEN
						NEXT_STATE <= PLAYER2_REACT;
					ELSIF inKey(0) = '0' THEN					-- Hard reset to go back to speed select
						NEXT_STATE <= SPEED_SELECT;
					ELSIF inKey(2) = '0' THEN
						NEXT_STATE<= SHOW_PLAYER2_TURN;
					END IF;

				WHEN PLAYER2_REACT =>
					IF inKey(1) = '0' THEN
						NEXT_STATE <= WINNER;
					ELSIF inKey(0) = '0' THEN					-- Hard reset to go back to speed select
						NEXT_STATE <= SPEED_SELECT;
					ELSIF inKey(2) = '0' THEN
						NEXT_STATE<= SHOW_PLAYER2_TURN;
					END IF;
							
				WHEN WINNER =>
					IF inKey(1) = '0' THEN						-- proceed to speed select
						NEXT_STATE <= SPEED_SELECT;			-- Hard reset to go back to speed select
					ELSIF inKey(0) = '0' THEN
						NEXT_STATE <= SPEED_SELECT;
					END IF;
					
				WHEN OTHERS =>										-- backup default case
					STATE <= SPEED_SELECT;
					
			END CASE;
		END IF;
	END PROCESS;
	 
	-- Hot-one encoding for speed selection
	SPEED <= "11" WHEN inSw(1) = '1' ELSE
				"10" WHEN inSw(0) = '1' ELSE
				"01"; -- Default speed is 1
	 
	-- Variable speed clock instantiation
	VCLOCK : VarPreScale PORT MAP (clock, UNSIGNED(SPEED), VARCLOCKOUT);
	
	-- Prescaled clocks instantiation
	ICLOCK : InputPreScale	PORT MAP (clock, INPUTCLOCKOUT);
	TCLOCK : TimerPreScale	PORT MAP (clock, TIMERCLOCKOUT);
	
	-- Keep track of reaction times instantiation
	P1C : BCDCount2 PORT MAP (C1CLEAR, TIMERCLOCKOUT, C1ENABLE, COUNT1(3 DOWNTO 0), COUNT1(7 DOWNTO 4));
	P2C : BCDCount2 PORT MAP (C2CLEAR, TIMERCLOCKOUT, C2ENABLE, COUNT2(3 DOWNTO 0), COUNT2(7 DOWNTO 4));
	
	-- 'Random' number generator instantiation
	RNGEN : RandomGen PORT MAP (VARCLOCKOUT, RENABLE, RNUMBER);
	
	WITH STATE SELECT
		RENABLE <=
			'0'	WHEN PLAYER1_REACT, -- When the target number has appeared, stop number generation
			'0'	WHEN PLAYER2_REACT,
			'1'	WHEN OTHERS;
	 
	WITH STATE SELECT
		C1CLEAR <= -- Clear is active low
			'0'	WHEN SHOW_PLAYER1_TURN, -- For soft reset functionality, reset the count when the players "show turn" state is active
			'1'	WHEN OTHERS;
			
	WITH STATE SELECT 
		C2CLEAR <=
			'0'	WHEN SHOW_PLAYER2_TURN,
			'1'	WHEN OTHERS;
			
	WITH STATE SELECT
		C1ENABLE <=
			'1' 	WHEN PLAYER1_REACT, -- When the target number appears, start incrementing the reaction timer
			'0'	WHEN OTHERS;
			
	WITH STATE SELECT
		C2ENABLE <=
			'1' 	WHEN PLAYER2_REACT,
			'0'	WHEN OTHERS;
				
	PROCESS (COUNT1, COUNT2) -- Determine who shows up on the WINNER state 
	BEGIN
		IF COUNT1 < COUNT2 THEN
			WINNERNUM <= "1111001"; -- P1 wins
			WCOUNT <= COUNT1;
			LCOUNT <= COUNT2;
      ELSIF COUNT1 > COUNT2 THEN
			WINNERNUM <= "0100100"; -- P2 wins
			WCOUNT <= COUNT2;
			LCOUNT <= COUNT1;
		ELSE
			WINNERNUM <= "0000111"; -- Tie
			WCOUNT <= COUNT1;
			LCOUNT <= COUNT2;
		END IF;
	END PROCESS;
				
	-- PORT MAPs for converting vectors of bits to 7-seg (respective HEX on DE2-115)
	SEG0 : SegDecoder PORT MAP (D0, S0);
	SEG1 : SegDecoder PORT MAP (D1, S1);
	SEG4 : SegDecoder PORT MAP (D4, S4);
	SEG5 : SegDecoder PORT MAP (D5, S5);
	
	WITH STATE SELECT -- What the SegDecoder for HEX0 recieve as input for each state:
		D0 <= 
			"00" & SPEED(1 DOWNTO 0)	WHEN SPEED_SELECT,
			RNUMBER							WHEN PLAYER1_TURN,
			RNUMBER							WHEN PLAYER1_REACT,
			RNUMBER							WHEN PLAYER2_TURN,
			RNUMBER							WHEN PLAYER2_REACT,
			LCOUNT(3 DOWNTO 0)			WHEN WINNER,
			"0000"							WHEN OTHERS;
	 
	 WITH STATE SELECT -- What HEX0 should recieve for each state:
		h0 <=
			S0 			WHEN SPEED_SELECT,
			"1111001"	WHEN SHOW_PLAYER1_TURN, -- 1
			S0 			WHEN PLAYER1_TURN,
			S0 			WHEN PLAYER1_REACT,
			"1111001"	WHEN SHOW_PLAYER2_TURN, -- 1
			S0				WHEN PLAYER2_TURN,
			S0 			WHEN PLAYER2_REACT,
			S0 			WHEN WINNER,
			"1111111"	WHEN OTHERS;
			
			
	WITH STATE SELECT -- What the SegDecoder for HEX1 recieve as input for each state:
		D1 <= 
			LCOUNT(7 DOWNTO 4)	WHEN WINNER,
			"0000"					WHEN OTHERS;
	
	WITH STATE SELECT -- What HEX1 should recieve for each state:
		h1 <= 
			S1 			WHEN WINNER,
			"1111111"	WHEN OTHERS;
			
			
	WITH STATE SELECT -- What HEX3 should recieve for each state: (mostly for debug purposes, shows current state numerically)
		h3 <= 
			"1000000"	WHEN SPEED_SELECT, -- 0
			"1111001"	WHEN SHOW_PLAYER1_TURN, -- 1
			"0100100" 	WHEN PLAYER1_TURN, -- 2
			"0110000" 	WHEN PLAYER1_REACT, -- 3 
			"0011001" 	WHEN SHOW_PLAYER2_TURN, -- 4
			"0010010" 	WHEN PLAYER2_TURN, -- 5
			"0000010" 	WHEN PLAYER2_REACT, -- 6
			"1111000" 	WHEN WINNER, -- 7
			"1010101"	WHEN OTHERS;
			
	WITH STATE SELECT -- What the SegDecoder for HEX4 recieve as input for each state:
		D4 <=
			"00" & SPEED			WHEN SHOW_PLAYER1_TURN,
			COUNT1(3 DOWNTO 0)	WHEN PLAYER1_TURN,
			COUNT1(3 DOWNTO 0)	WHEN PLAYER1_REACT,
			"00" & SPEED			WHEN SHOW_PLAYER2_TURN,
			COUNT2(3 DOWNTO 0)	WHEN PLAYER2_TURN,
			COUNT2(3 DOWNTO 0)	WHEN PLAYER2_REACT,
			WCOUNT(3 DOWNTO 0)	WHEN WINNER,
			"0000"					WHEN OTHERS;
			
	WITH STATE SELECT -- What HEX4 should recieve for each state:
		h4 <= 
			"1000111"	WHEN SPEED_SELECT, -- L
			S4				WHEN SHOW_PLAYER1_TURN,
			S4 			WHEN PLAYER1_TURN,
			S4 			WHEN PLAYER1_REACT,
			S4				WHEN SHOW_PLAYER2_TURN,
			S4				WHEN PLAYER2_TURN,
			S4				WHEN PLAYER2_REACT,
			S4				WHEN WINNER,
			"1111111" 	WHEN OTHERS;
			
	
	WITH STATE SELECT -- What the SegDecoder for HEX5 recieve as input for each state:
		D5 <=
			COUNT1(7 DOWNTO 4)	WHEN PLAYER1_TURN,
			COUNT1(7 DOWNTO 4)	WHEN PLAYER1_REACT,
			COUNT2(7 DOWNTO 4)	WHEN PLAYER2_TURN,
			COUNT2(7 DOWNTO 4)	WHEN PLAYER2_REACT,
			WCOUNT(7 DOWNTO 4)	WHEN WINNER,
			"0000"					WHEN OTHERS;
	
	WITH STATE SELECT -- What HEX5 should recieve for each state:
		h5 <=
			"0010010"	WHEN SPEED_SELECT, -- S
			S5				WHEN PLAYER1_TURN,
			S5				WHEN PLAYER1_REACT,
			S5				WHEN PLAYER2_TURN,
			S5				WHEN PLAYER2_REACT,
			S5 			WHEN WINNER,
			"1111111" 	WHEN OTHERS;
	
	
	WITH STATE SELECT -- What HEX6 should recieve for each state:
		h6 <=
			"0001100"	WHEN SPEED_SELECT, -- P
			"1111001"	WHEN SHOW_PLAYER1_TURN, -- 1
			"1111001"	WHEN PLAYER1_TURN, -- 1
			"1111001"	WHEN PLAYER1_REACT, -- 1
			"0100100"	WHEN SHOW_PLAYER2_TURN, -- 2
			"0100100"	WHEN PLAYER2_TURN, -- 2
			"0100100"	WHEN PLAYER2_REACT, -- 2
			WINNERNUM	WHEN WINNER, -- 1, 2, or t
			"1111111" 	WHEN OTHERS;
	
			
	WITH STATE SELECT -- What HEX7 should recieve for each state:
		h7 <=
			"0010010"	WHEN SPEED_SELECT, -- S
			"0001100"	WHEN SHOW_PLAYER1_TURN, -- P
			"0001100"	WHEN PLAYER1_TURN, -- P
			"0001100"	WHEN PLAYER1_REACT, -- P
			"0001100"	WHEN SHOW_PLAYER2_TURN, -- P
			"0001100"	WHEN PLAYER2_TURN, -- P
			"0001100"	WHEN PLAYER2_REACT, -- P
			"0001100"	WHEN WINNER, -- P
			"1111111" 	WHEN OTHERS;
			
END BEHAVIOUR;