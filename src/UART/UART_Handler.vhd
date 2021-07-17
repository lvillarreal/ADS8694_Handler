----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:03:18 02/13/2020 
-- Design Name: 
-- Module Name:    UART_Handler - Behavioral 
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


entity UART_Handler is
	generic(
		SAMPLE_RATE	:	std_logic_vector(23 downto 0) := X"003E80";
		BAUD_RATE	:	integer := 500000
	);
	port(
			i_rst				:	in std_logic;
			i_Clk				:	in std_logic;
			i_TX_Byte		:	in	std_logic_vector(7 downto 0);		-- Byte a transmitir por uart
			i_TX_ready		:	in std_logic;								-- el dato tx esta listo para ser transmitido
			
			o_RX_Byte		:	out std_logic_vector(7 downto 0);	-- Byte recibido por uart
			o_RX_Ready		:	out std_logic;								-- el byte recibido esta listo
			
			o_TX_Busy		:	out std_logic;	 							-- modulo transmitiendo
			o_TX_Ready		:	out std_logic;  							-- modulo listo para transmitir  
			o_Comm_Ready	:	out std_logic;	 							-- '1' conexion establecida con Serial Plotter. Si es '1' se puede enviar dato por uart
			
			o_pwr_down		:	out std_logic;								-- '1' para encender adc, '0' para apagar
		
			TX					: 	out std_logic;
			RX					:	in	 std_logic;
			
			
			led				:	out std_logic_vector(7 downto 0)		-- debug
	);
end UART_Handler;

architecture Behavioral of UART_Handler is

-- COMPONENTS

   COMPONENT Comm_Control
	 GENERIC(
		g_SAMPLE_RATE	:	std_logic_vector(23 downto 0) := X"0030D4"; 
		g_CANT_BITS		:	std_logic_Vector(7 downto 0)	:=	X"12"		 
		
	 );
    PORT(
         i_rst 		: IN  std_logic;
         i_Clk 		: IN  std_logic;
         i_RX_Byte 	: IN  std_logic_vector(7 downto 0);
         i_RX_ready 	: IN  std_logic;
         i_TX_Done 	: IN  std_logic;
         o_rd			: OUT std_logic;
			o_TX_Byte 	: OUT std_logic_vector(7 downto 0);
         o_TX_ready 	: OUT std_logic;
			led 			: OUT std_logic_vector(7 downto 0);
         o_control 	: OUT std_logic
        );
    END COMPONENT;
    
	 

	COMPONENT uart
	GENERIC(
	    BAUD_RATE     : integer := 256000 -- Default (or hardwired) baud rate 
	);
	PORT(
		rxd_i 	: IN  std_logic;
		data_i 	: IN  std_logic_vector(7 downto 0);
		addr_i 	: IN  std_logic_vector(1 downto 0);
		wr_i 		: IN  std_logic;
		rd_i 		: IN  std_logic;
		ce_i 		: IN  std_logic;
		clk_i 	: IN  std_logic;
		reset_i 	: IN  std_logic;          
		txd_o 	: OUT std_logic;
		tx_irq_o : OUT std_logic;
		rx_irq_o	: OUT std_logic;
		TxRdy		: OUT std_logic;
		data_o 	: OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	 
	 
--	Signal definition
	
	
	signal s_CommControl_i_RX_byte  : std_logic_vector(7 downto 0);
	signal s_CommControl_i_RX_ready : std_logic;
	signal s_CommControl_i_TX_done  : std_logic;
	signal s_CommControl_o_TX_byte  : std_logic_vector(7 downto 0);
	signal s_CommControl_o_TX_ready : std_logic;
	signal s_CommControl_control 	  : std_logic;
	signal s_CommControl_o_rd		  : std_logic;
	signal s_CommControl_o_rst		  : std_logic;
	
	signal s_uart_TX 		: 	std_logic;
	signal s_uart_RX		:	std_logic;
	signal s_uart_DBIN	:	std_logic_vector(7 downto 0);
	signal s_uart_DBOUT	:	std_logic_vector(7 downto 0);
	signal s_uart_RDA		:	std_logic;
	signal s_uart_TDR		:	std_logic;	-- Transfer Data Ready
	signal s_uart_RD		:	std_logic;
	signal s_uart_WR		:	std_logic;
	signal s_uart_TBE		:	std_logic;
	signal s_uart_rst		:	std_logic;
	
begin

-- INSTANCIACION DE COMPONENTES

Comm_Control_INST: Comm_Control
    
   generic map(
		g_SAMPLE_RATE	=> SAMPLE_RATE,
		--g_SAMPLE_RATE  => X"0030D4",	-- 12.5 ksps
		g_CANT_BITS		=> X"12"			-- 18 bits
	)      
    port map (
		i_rst			=>	i_rst, 		
		i_Clk 		=>	i_Clk,
		i_RX_Byte	=>	s_CommControl_i_RX_byte,
		i_RX_ready	=>	s_CommControl_i_RX_ready,
		i_TX_Done	=>	s_CommControl_i_TX_done,
		o_TX_Byte	=> s_CommControl_o_TX_byte,
		o_TX_ready	=> s_CommControl_o_TX_ready,	
		o_rd			=>	s_CommControl_o_rd,
		
		led 			=> led,
		
		o_control	=> s_CommControl_control
      );
	


Inst_uart: uart 
	GENERIC MAP(
		BAUD_RATE => BAUD_RATE
	)
	PORT MAP(
		rxd_i 	=> s_uart_RX,
		txd_o 	=> s_uart_TX,
		tx_irq_o => s_uart_TDR,		
		rx_irq_o => s_uart_RDA,
		TxRdy		=> s_uart_TBE,
		data_i 	=> s_uart_DBIN,
		data_o 	=> s_uart_DBOUT,
		addr_i 	=> "00",
		wr_i 		=> s_uart_WR,
		rd_i 		=> s_uart_RD,
		ce_i 		=> '1',
		clk_i 	=> i_clk,
		reset_i 	=> s_uart_rst
	);



-- INTERCONECCION DE COMPONENTES
	
	o_pwr_down <= s_CommControl_control;
	
	s_uart_RD <= s_CommControl_o_rd;
	
	s_CommControl_i_RX_byte		<= s_uart_DBOUT;
	s_CommControl_i_RX_ready	<=	s_uart_RDA;

	
	s_CommControl_i_TX_done    <=  s_uart_TDR;	

	
	o_TX_Ready		<=	s_uart_TBE;
	o_Comm_Ready	<=	s_CommControl_control;
	
	s_uart_rst 		<= i_rst;-- or s_CommControl_o_rd; 
	
	s_uart_RX		<=	RX;
	TX					<=	s_uart_TX;
	o_TX_Busy		<=	not s_uart_TBE;
	
	o_RX_Byte		<=	s_uart_DBOUT;
	o_RX_Ready		<=	s_uart_RDA;


	
	-- MULTIPLEXORES PARA SELECCIONAR TX_BYTE DEL BLOQUE DE CONTROL O TX_BYTE DEL BLOQUE HANDLER (dato del AD)
	
	
	with s_CommControl_control select s_uart_DBIN <=
		s_CommControl_o_TX_byte when '0',
		i_TX_byte					when others;


	with s_CommControl_control select s_uart_WR <=
		s_CommControl_o_TX_ready	when '0',
		i_TX_ready						when others;




end Behavioral;

