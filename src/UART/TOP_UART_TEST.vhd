----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:50:23 02/28/2020 
-- Design Name: 
-- Module Name:    TOP_UART_TEST - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_UART_TEST is
		port(
			clk	:	in	std_logic;
			reset	:	in	std_logic;
			TX		:	out std_logic;
			led   :  out std_logic_vector(7 downto 0);
			tx_en :  in	 std_logic;
			TX_o	:	out std_logic;
			RX		:	in	 std_logic
		);
end TOP_UART_TEST;

architecture Behavioral of TOP_UART_TEST is

-- UART

component UART_Handler
   generic(
	 BAUD_RATE	:	integer := 256000
	);
	port(
			i_rst				:	in std_logic;
			i_Clk				:	in std_logic;
			i_TX_Byte		:	in	std_logic_vector(7 downto 0);
			i_TX_ready		:	in std_logic;	-- el dato tx esta listo para ser transmitido
			
			o_RX_Byte		:	out std_logic_vector(7 downto 0);
			o_RX_Ready		:	out std_logic;	-- el dato recibido esta listo
			
			o_TX_Busy		:	out std_logic;	 -- modulo transmitiendo
			o_TX_Ready		:	out std_logic;  -- modulo listo para transmitir  
			o_Comm_Ready	:	out std_logic;	-- '1' conexion establecida con Serial Plotter
			
			led				:	out std_logic_vector(7 downto 0);
			
			TX					: 	out std_logic;
			RX					:	in	 std_logic
	);
end component UART_Handler;



signal s_tx	: std_logic;

begin

TX <= s_TX;
TX_o <= s_TX;

-- MODULO UART

uart: UART_Handler
   generic map(
	 BAUD_RATE => 500
	)
	port map(
			i_rst				=> reset,
			i_Clk				=> clk,
			i_TX_Byte		=> X"55",
			i_TX_ready		=> tx_en,
			
			o_RX_Byte		=> open,
			o_RX_Ready		=> open,
			
			o_TX_Busy		=> open,
			o_TX_Ready		=> open,  
			o_Comm_Ready	=>	open,
			
			led => led,
			
			TX					=> s_TX,
			RX					=>	RX	
	);


end Behavioral;

