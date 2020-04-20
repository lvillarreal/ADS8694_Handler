------------------------------------------------------------------------
--  uart232.vhd
------------------------------------------------------------------------
-- Author:  Dan Pederson
--          Copyright 2004 Digilent, Inc.
------------------------------------------------------------------------
-- Description:  	This file defines a UART which tranfers data from 
--				serial form to parallel form and vice versa.			
------------------------------------------------------------------------
-- Revision History:
--  07/15/04 (Created) DanP
--	 02/25/08 (Created) ClaudiaG: made use of the baudDivide constant
--											in the Clock Dividing Processes
------------------------------------------------------------------------
-- Se ha modificado para sacar el bita de paridad 08/10/2012
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity uart232 is
--	 generic(
--		baudDivide : std_logic_vector(8 downto 0) := "101000110" 	--Baud Rate dividor, set now for a rate of 9600.
--																						--Found by dividing 100MHz by 9600 and 16.
--	 );
    Port ( 
		TXD 	: out std_logic  	:= '1';
    	RXD 	: in  std_logic;					
    	CLK 	: in  std_logic;								--Master Clock
		DBIN 	: in  std_logic_vector (7 downto 0);	--Data Bus in
		DBOUT : out std_logic_vector (7 downto 0);	--Data Bus out
		RDA	: inout std_logic;							--Read Data Available
		TBE	: inout std_logic 	:= '1';				--Transfer Bus Empty
		RD		: in  std_logic;								--Read Strobe
		WR		: in  std_logic;								--Write Strobe
		RST	: in  std_logic	:= '0');					--Master Reset
end uart232;

architecture Behavioral of uart232 is
------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------

------------------------------------------------------------------------
--  Local Type Declarations
------------------------------------------------------------------------
	--Receive state machine
	type rstate is (					  
		strIdle,			--Idle state
		strEightDelay,	--Delays for 8 clock cycles
		strGetData,		--Shifts in the 8 data bits, and checks parity
		strCheckStop	--Sets framing error flag if Stop bit is wrong
	);

	type tstate is (
		sttIdle,			--Idle state
		sttTransfer,	--Move data into shift register
		sttShift			--Shift out data
		);

	type TBEstate is (
		stbeIdle,
		stbeSetTBE,
		stbeWaitLoad,
		stbeWaitWrite
		);
		

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
	constant baudDivide : std_logic_vector(8 downto 0) := "101000110"; 	--Baud Rate dividor, set now for a rate of 9600.
																								--Found by dividing 100MHz by 9600 and 16.
	signal rdReg	:  std_logic_vector(7 downto 0) := "00000000";			--Receive holding register
	signal rdSReg	:  std_logic_vector(8 downto 0) := "111111111";		--**R Receive shift register
	signal tfReg	:  std_logic_vector(7 downto 0);								--Transfer holding register

--	signal tfSReg  :  std_logic_vector(9 downto 0) 	:= "1111111111";	--Transfer shift register
	signal tfSReg  :  std_logic_vector(8 downto 0) 	:= "111111111";	--Transfer shift register
	
	signal clkDiv	:  std_logic_vector(8 downto 0)	:= "000000000";		--used for rClk
	signal rClkDiv :  std_logic_vector(3 downto 0)	:= "0000";				--used for tClk
	signal ctr	:  std_logic_vector(3 downto 0)	:= "0000";					--used for delay times
	signal tfCtr	:  std_logic_vector(3 downto 0)	:= "0000";				--used to delay in transfer
	signal rClk	:  std_logic := '0';							--Receiving Clock
	signal tClk	:  std_logic;									--Transfering Clock
	signal dataCtr :  std_logic_vector(3 downto 0)	:= "0000";		--Counts the number of read data bits
	signal CE		:  std_logic;									--Clock enable for the latch
	signal ctRst	:  std_logic := '0';
	signal load	:  std_logic := '0';
	signal shift	:  std_logic := '0';
   signal tClkRST	:  std_logic := '0';
	signal rShift	:  std_logic := '0';
	signal dataRST :  std_logic := '0';
	signal dataIncr:  std_logic := '0';
	signal tclki   :  std_logic;

	signal strCur	:  rstate	:= strIdle; 				--Current state in the Receive state machine
	signal strNext	:  rstate;									--Next state in the Receive state machine
	signal sttCur  :  tstate := sttIdle;					--Current state in the Transfer state machine
	signal sttNext :  tstate;									--Next state in the Transfer staet machine
	signal stbeCur :  TBEstate := stbeIdle;
	signal stbeNext:  TBEstate;
	
------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------

begin
 	DBOUT <= rdReg;
	tfReg <= DBIN;

--Clock Dividing Functions--

	process (CLK, clkDiv)	    						--set up clock divide for rClk
		begin
			if (Clk = '1' and Clk'event) then
				if (clkDiv = baudDivide) then
					clkDiv <= "000000000";
				else
					clkDiv <= clkDiv +1;
				end if;
			end if;
		end process;

	process (clkDiv, rClk, CLK)	 					--Define rClk
	begin
		if CLK = '1' and CLK'Event then
			if clkDiv = baudDivide then
				rClk <= not rClk;
			else
				rClk <= rClk;
			end if;
		end if;
	end process;	

	process (rClk)	  								     --set up clock divide for tClk
		begin
			if (rClk = '1' and rClk'event) then
				rClkDiv <= rClkDiv +1;
			end if;
		end process;
-- cambio
	tClki <= rClkDiv(3);									--define tClk

U_BUFG: BUFG
port map (
I => tclki,
O => tClk
);

	process (rClk, ctRst)				   			--set up a counter based on rClk
		begin
			if rClk = '1' and rClk'Event then
				if ctRst = '1' then
					ctr <= "0000";
				else
					ctr <= ctr +1;
				end if;
			end if;
		end process;

	process (tClk, tClkRST)	 							--set up a counter based on tClk
		begin
			if (tClk = '1' and tClk'event) then
				if tClkRST = '1' then
					tfCtr <= "0000";
				else
					tfCtr <= tfCtr +1;
				end if;
			end if;
		end process;

 	--This process controls the error flags--
	process (rClk, RST, RD, CE)
		begin
			if RD = '1' or RST = '1' then
				RDA <= '0';

			elsif rClk = '1' and rClk'event then
				if CE = '1' then
					RDA <= '1';	 
					rdReg(7 downto 0) <= rdSReg (7 downto 0);
				end if;				
			end if;
		end process;

	--This process controls the receiving shift register--
	process (rClk, rShift)
		begin
			if rClk = '1' and rClk'Event then
				if rShift = '1' then
					rdSReg <= (RXD & rdSReg(8 downto 1)); --**R
				end if;
			end if;
		end process;

	--This process controls the dataCtr to keep track of shifted values--
 	process (rClk, dataRST)
		begin
			if (rClk = '1' and rClk'event) then
				if dataRST = '1' then
					dataCtr <= "0000";
				elsif dataIncr = '1' then
					dataCtr <= dataCtr +1;
				end if;
			end if;
		end process;

  	--Receiving State Machine--
	process (rClk, RST)
		begin
			if rClk = '1' and rClk'Event then
				if RST = '1' then
					strCur <= strIdle;
				else
					strCur <= strNext;
				end if;
			end if;
		end process;
			
	--This process generates the sequence of steps needed receive the data
	
	process (strCur, ctr, RXD, dataCtr, rdSReg, rdReg)
		begin   
			case strCur is

				when strIdle =>
					dataIncr <= '0';
					rShift <= '0';
					dataRst <= '0';
				
					CE <= '0';
					if RXD = '0' then
						ctRst <= '1';
						strNext <= strEightDelay;
					else
						ctRst <= '0';
						strNext <= strIdle;
					end if;
				
				when strEightDelay => 
					dataIncr <= '0';
					rShift <= '0';
					CE <= '0';

					if ctr(2 downto 0) = "111" then
						ctRst <= '1';
					   dataRST <= '1';
						strNext <= strGetData;
					else
						ctRst <= '0';
						dataRST <= '0';
						strNext <= strEightDelay;
					end if;
				
				when strGetData =>	
					CE <= '0';
					dataRst <= '0';
					if ctr(3 downto 0) = "1111" then
						ctRst <= '1';
						dataIncr <= '1';
						rShift <= '1';
					else
						ctRst <= '0';
						dataIncr <= '0';
						rShift <= '0';		
					end if;

					if dataCtr = "1001" then  --**R
						strNext <= strCheckStop;
					else
						strNext <= strGetData;
					end if;
				
				when strCheckStop =>
					dataIncr <= '0';
					rShift <= '0';
					dataRst <= '0';
					ctRst <= '0';

					CE <= '1';
					strNext <= strIdle;
									
			end case;
		
		end process;

	--TBE State Machine--
	process (CLK, RST)
		begin
			if (CLK = '1' and CLK'Event) then
				if RST = '1' then
					stbeCur <= stbeIdle;
				else
					stbeCur <= stbeNext;
				end if;
			end if;
		end process;

	--This process gererates the sequence of events needed to control the TBE flag--
	process (stbeCur, CLK, WR, DBIN, load)
		begin

			case stbeCur is

				when stbeIdle =>
					TBE <= '1';
					if WR = '1' then
						stbeNext <= stbeSetTBE;
					else
						stbeNext <= stbeIdle;
					end if;
				
				when stbeSetTBE =>
					TBE <= '0';
					if load = '1' then
						stbeNext <= stbeWaitLoad;
					else
						stbeNext <= stbeSetTBE;
					end if;
				
				when stbeWaitLoad =>
					if load = '0' then
						stbeNext <= stbeWaitWrite;
					else
						stbeNext <= stbeWaitLoad;
					end if;

				when stbeWaitWrite =>
					if WR = '0' then 
						stbeNext <= stbeIdle;
					else
						stbeNext <= stbeWaitWrite;
					end if;
				end case;
			end process;

	--This process loads and shifts out the transfer shift register--
	process (load, shift, tClk, tfSReg)
		begin
			TXD <= tfsReg(0);
			if tClk = '1' and tClk'Event then
				if load = '1' then
				
--					tfSReg (9 downto 0) <= ('1' & tfReg(7 downto 0) &'0');
					tfSReg (8 downto 0) <= ( tfReg(7 downto 0) &'0');
	
				end if;
				if shift = '1' then
								  
--					tfSReg (9 downto 0) <= ('1' & tfSReg(9 downto 1));
					tfSReg (8 downto 0) <= ('1' & tfSReg(8 downto 1));
	
				end if;
			end if;
		end process;

	--  Transfer State Machine--
	process (tClk, RST)
		begin
			if (tClk = '1' and tClk'Event) then
				if RST = '1' then
					sttCur <= sttIdle;
				else
					sttCur <= sttNext;
				end if;
			end if;
		end process;
		
	--  This process generates the sequence of steps needed transfer the data--
	process (sttCur, tfCtr, tfReg, TBE, tclk)
		begin   	   

			case sttCur is
			
				when sttIdle =>
					tClkRST <= '0';
					shift <= '0';
					load <= '0';
					if TBE = '1' then
						sttNext <= sttIdle;
					else
						sttNext <= sttTransfer;
					end if;	

				when sttTransfer =>	
					shift <= '0';
					load <= '1';
					tClkRST <= '1';		
					sttNext <= sttShift;
					

				when sttShift =>
					shift <= '1';
					load <= '0';
					tClkRST <= '0';
					if tfCtr = "1011" then
						sttNext <= sttIdle;
					else
						sttNext <= sttShift;
					end if;
			end case;
		end process;						 	
			
end Behavioral;