--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:29:19 02/13/2020
-- Design Name:   
-- Module Name:   C:/Xilinx/Workspace/ADS8694_v1/test/UART_Handler_tb.vhd
-- Project Name:  ADS8694_v1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART_Handler
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UART_Handler_tb IS
END UART_Handler_tb;
 
ARCHITECTURE behavior OF UART_Handler_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_Handler
--   generic(
--	 g_baudDivide	:	std_logic_vector(8 downto 0) := "101000110"	-- 9600 bauds con clk de 100 MHz
--	);			
	PORT(
		i_rst : IN std_logic;
		i_Clk : IN std_logic;
		i_TX_Byte : IN std_logic_vector(7 downto 0);
		i_TX_ready : IN std_logic;
		RX : IN std_logic;          
		o_RX_Byte : OUT std_logic_vector(7 downto 0);
		o_RX_Ready : OUT std_logic;
		o_TX_Busy : OUT std_logic;
		o_TX_Ready : OUT std_logic;
		o_Comm_Ready : OUT std_logic;
		TX : OUT std_logic;
		led : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
 
 
 	COMPONENT uart232
--	generic(
--		baudDivide : std_logic_vector(8 downto 0) := "101000110" 	--Baud Rate dividor, set now for a rate of 9600.
--																						--Found by dividing 100MHz by 9600 and 16.
--	 );
	PORT(
		RXD : IN std_logic;
		CLK : IN std_logic;
		DBIN : IN std_logic_vector(7 downto 0);
		RD : IN std_logic;
		WR : IN std_logic;
		RST : IN std_logic;    
		RDA : INOUT std_logic;
		TBE : INOUT std_logic;      
		TXD : OUT std_logic;
		DBOUT : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
 
 	signal s_uart_TX 	: 	std_logic;
	signal s_uart_RX	:	std_logic;
-- 	signal s_uart_TX2 	: 	std_logic;
--	signal s_uart_RX2	:	std_logic;
	
	signal s_uart_DBIN	:	std_logic_vector(7 downto 0);
	signal s_uart_DBOUT	:	std_logic_vector(7 downto 0);
	signal s_uart_RDA	:	std_logic;
	signal s_uart_TBE	:	std_logic;
	signal s_uart_RD	:	std_logic;
	signal s_uart_WR	:	std_logic;
	
--	signal s_uart_DBIN2	:	std_logic_vector(7 downto 0);
--	signal s_uart_DBOUT2	:	std_logic_vector(7 downto 0);
--	signal s_uart_RDA2	:	std_logic;
--	signal s_uart_TBE2	:	std_logic;
--	signal s_uart_RD2	:	std_logic;
--	signal s_uart_WR2	:	std_logic;
  
	signal 	s_uartH_i_TX_byte	:	std_logic_vector(7 downto 0);
  	signal	s_uartH_i_TX_ready	:	std_logic;
	signal	s_uartH_o_RX_Byte		:	std_logic_vector(7 downto 0);
	signal	s_uartH_o_RX_ready	:	std_logic;
	signal	s_uartH_o_TX_busy		:	std_logic;
	signal	s_uartH_o_TX_ready	:	std_logic;
	signal	s_uartH_o_Comm_Ready	:	std_logic;
	signal	s_uartH_TX				:	std_logic;
	signal	s_uartH_RX				:	std_logic;
	signal	s_uartH_led				:	std_logic_vector(7 downto 0);
   
	signal i_Clk,i_clk1 : std_logic;
	signal i_rst : std_logic;
  
   -- Clock period definitions
   constant i_Clk_period : time := 10 ns;
   constant g_baudDivide : std_logic_vector(8 downto 0) := "101000110";

BEGIN

	
		  
		  	-- Instantiate the Unit Under Test (UUT)
	uut1: uart232 
--	GENERIC MAP(
--		baudDivide => g_baudDivide
--	)
	PORT MAP(
		TXD => s_uart_TX,
		RXD => s_uart_RX,
		CLK => i_Clk,
		DBIN => s_uart_DBIN,
		DBOUT => s_uart_DBOUT,
		RDA => s_uart_RDA,
		TBE => s_uart_TBE,
		RD => s_uart_RD,
		WR => s_uart_WR,
		RST => i_rst
	);
	
	
	
	Inst_UART_Handler: UART_Handler 
	
	PORT MAP(
		i_rst => 			i_rst,
		i_Clk => 			i_clk,
		i_TX_Byte => 		s_uartH_i_TX_byte,
		i_TX_ready => 		s_uartH_i_TX_ready,
		o_RX_Byte => 		s_uartH_o_RX_Byte,
		o_RX_Ready => 		s_uartH_o_RX_ready,
		o_TX_Busy => 		s_uartH_o_TX_busy,
		o_TX_Ready => 		s_uartH_o_TX_ready,
		o_Comm_Ready => 	s_uartH_o_Comm_Ready,
		TX => 				s_uartH_TX,
		RX => 				s_uartH_RX,
		led => 				s_uartH_led
	);
	
	
	

--
--	uut2: uart232 
--	GENERIC MAP(
--		baudDivide => g_baudDivide
--	)
--	PORT MAP(
--		TXD => s_uart_TX2,
--		RXD => s_uart_RX2,
--		CLK => i_Clk,
--		DBIN => s_uart_DBIN2,
--		DBOUT => s_uart_DBOUT2,
--		RDA => s_uart_RDA2,
--		TBE => s_uart_TBE2,
--		RD => s_uart_RD2,
--		WR => s_uart_WR2,
--		RST => i_rst
--	);




 s_uartH_RX <= s_uart_TX;
 s_uart_RX  <= s_uartH_TX;

 
 
process
begin
	i_clk <= '1';
	wait for 5 ns;
	i_clk <= '0';
	wait for 5 ns;
end process;


--process
--begin
--	i_clk1 <= '1';
--	wait for 5 ns;
--	i_clk1 <= '0';
--	wait for 5 ns;
--end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      i_rst <= '1';
		
		s_uart_RD  <= '0';
		s_uart_wr <= '0';
		s_uart_DBIN <= X"00";
		
		s_uartH_i_TX_byte <= X"00";
		s_uartH_i_TX_Ready	<= '0';
		
		
		wait until rising_edge(i_clk);	
		i_rst <= '0';
		s_uart_DBIN <= X"02";

		s_uart_TBE <= 'Z';
		s_uart_RDA <= 'Z';
		wait until rising_edge(i_clk);


		
		s_uart_WR	<= '1';	
		wait until rising_edge(i_clk);
		s_uart_WR	<= '0';	
      
		wait until s_uartH_o_TX_ready = '1';
	   
		wait until rising_edge(i_clk);
		s_uat_RD <= '1';
		wait until rising_edge(i_clk);
		s_uart_RD <= '0';
		wait until rising_edge(i_clk);
		s_uart_WR	<= '1';	
		wait until rising_edge(i_clk);
		s_uart_WR	<= '0';
		
--		wait until rising_edge(i_clk);
		
--		
--		wait until rising_edge(i_clk);
--
--		s_uart_WR <= '0';
--		
--		wait until s_uart_RDA2 = '1';	-- llego el dato
--		wait until rising_edge(i_clk);
--		s_uart_RD2 <= '1';
--		wait until rising_edge(i_clk);
--		s_uart_RD2 <= '0';
--		wait until rising_edge(i_clk);
--      s_uart_DBIN2 <= X"34";
--		s_uart_wr2 <= '1';
--		wait until rising_edge(i_clk);
--		s_uart_wr2 <= '0';
--		wait until s_uart_tbe2 = '1';
--		
--		s_uart_DBIN2 <= X"43";
--		s_uart_wr2 <= '1';
--		wait until rising_edge(i_clk);
--		s_uart_wr2 <= '0';
--		wait until s_uart_tbe2 = '1';
--		
		
--		wait until o_RX_dv = '1';
--		wait until o_RX_dv = '1';
--		wait until o_RX_dv = '1';
--		wait until o_RX_dv = '1';
--		wait until o_RX_dv = '1';
--		wait until o_RX_dv = '1';
--
--		
--		r_TX_byte <= X"05";
--		r_TX_dv <= '1';
--		wait until rising_edge(i_clk);
--		r_TX_dv <= '0';
--		
--		wait until o_Comm_Ready = '1';
--		
--		i_TX_Byte <= X"CC";
--		i_TX_ready <= '1';
--		wait until rising_edge(i_clk);
--		i_TX_Ready <= '0';
	
		
      -- insert stimulus here 

      wait;
   end process;

END;
