
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:27:12 02/12/2020 
-- Design Name: 
-- Module Name:    Comm_Handler - Behavioral 
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

-- Bloque para implementar el protocolo de comunicacion entre el sistema de medición
-- y el Serial Plotter.

-- Protocolo para establecer comunicacion

-- 1. Serial Plotter envia comando STX (ascii 2)
-- 2. Sistema envia ACK (ascii 6)
-- 3. Sistema envia tasa de muestreo en 3 bytes (24 bits)
-- 4. Sistema envia LF (ascii 10)
-- 5. Sistema envia cantidad de bits del AD en un byte (maximo valor admitido por Serial Plotter: 24)
-- 6. Sistema envia Vref en dos bytes, multiplicada por 1000.
-- 6. Sistema envia EOT (ascii 4)
-- 7. Serial Plotter responde con ENQ (ascii 5) y se comienza la transmision de datos, desde Sistema 
--    hacia Serial Plotter.
--
entity Comm_Control is
   generic (
		g_SAMPLE_RATE	: 	std_logic_vector(23 downto 0) := X"0030D4"; -- 12.5 ksps
		g_CANT_BITS		:	std_logic_vector(7 downto 0) 	:= X"12"	-- 18 bits
	);
	port(
		i_rst			:	in std_logic;								-- reset activo por alto
		i_Clk 		:	in std_logic;
		i_RX_Byte	:	in std_logic_vector(7 downto 0);		-- byte recibido por uart
		i_RX_ready	:	in std_logic;								-- '1' si el dato rx esta listo
		i_TX_Done	:	in std_logic;								-- indica que el dato ya se envio
		
		o_rd			:	out std_logic;								-- rd del bloque uart
		o_TX_Byte	:	out std_logic_vector(7 downto 0);	--	byte a transmitir
		o_TX_ready	:	out std_logic;								-- '1' para indicar que el dato esta listo para enviar
		
		led			:  out std_logic_vector(7 downto 0);	-- debug
		
		
		o_control	:	out std_logic								-- controla mux para la entrada al bloque UART_TX. Si es 0 envia datos el modulo, si es 1 envian los datos otro modulo
		
	);
end Comm_Control;

architecture Behavioral of Comm_Control is

type states is (s_VREF_MSB,s_VREF_LSB,s_disconnect,s_connected,s_wait,s_reset,s_control,s_INIT,s_ACK,s_waitTX,s_fsamp1,s_fsamp2,s_fsamp3,s_cantBits,s_LF,s_EOT,s_ENQ);

signal present_state: states := s_INIT;
signal next_state : states;
signal i : integer range 0 to 13 := 0;


constant NAK				:	std_logic_vector(7 downto 0)	:= X"15";	
constant STX				:	std_logic_vector(7 downto 0)	:=	X"02";
constant ACK   			: 	std_logic_vector(7 downto 0) 	:= X"06";
constant LF					:  std_logic_vector(7 downto 0)	:= X"0A";
constant EOT				:	std_logic_vector(7 downto 0)	:= X"04";
constant ENQ				:	std_logic_vector(7 downto 0)	:= X"05";
--	constant VREF				:	std_logic_vector(15 downto 0) := X"0A00";	--2560 para indicar Vref de +-2.56V
constant VREF				:	std_logic_vector(15 downto 0) := X"2800";	--10240 para indicar Vref de +-10.24V

begin


-- Proceso para determinar el proximo estado usando i
cnt:process(i_clk,i_rst,present_state)is
begin

	if rising_edge(i_clk) then
		if i_rst = '1' then
			i <= 9;	-- valor inicial de i
		else
			case (present_state) is
				
				when s_INIT 		=>
					i <= 9;
				when s_connected  =>
					i <= 10;
				when s_control 	=>
					i <= 0;
				when s_ACK			=>
					i <= 1;
				when s_fsamp1 		=> 
					i <= 2;
				when s_fsamp2 		=> 
					i <= 3;
				when s_fsamp3 		=> 
					i <= 4;
				when s_LF			=> 
					i <= 5;
				when s_cantBits	=> 
					i <= 6;
				when s_VREF_MSB	=>
					i <= 12;
				when s_VREF_LSB	=>
					i <= 13;
				when s_EOT 			=> 
					i <= 7;
				when s_ENQ 			=> 
					i <= 8;
				when s_disconnect =>
					i <= 11;
				--when s_NAK			=>
				--	i <= 14;

				
				
				when others 		=>
					i <= i;
			end case;
		end if;
	end if;
		

end process;


-- maquina de estados
FSM1: process(present_state, i_RX_Byte,i_RX_Ready, i_TX_Done,i)is
begin
	case (present_state) is
		
		-- Espera recibir el comando STX
		when s_INIT =>
				led <= X"F0";
				o_control <= '0';
				o_TX_Byte <= X"00";
				o_TX_Ready <= '0';
				o_rd <= '0';

				if i_RX_ready = '1' then
					if i_RX_Byte = STX then
						next_state <= s_control;
					--elsif i_RX_Byte = STX and i_conn_succ = '0' then
					--	next_state <= s_NAK;
					else
						next_state <= s_reset;
					end if;
				else
					next_state <= s_INIT;
				end if;		
		
					
		
		-- Selecciona multiplexor para que envie datos internos				
		when s_control =>
				o_control <= '0';
				next_state <= s_reset;


				
		-- Estado que se utiliza para esperar que se envie el dato
		when s_waitTX =>
				o_TX_ready <= '0';
				
				if(i_TX_Done = '1') then	-- se termino de enviar el comando
					next_state <= s_reset;
				else
					next_state <= s_waitTX;
				end if;
		
		-- Resetea el modulo uart
		when s_reset =>
				o_rd <= '1';
				next_state <= s_wait;
		
		when s_wait =>
			   o_rd <= '0';
				
				case(i) is
					
					when 0 	=>		-- viene del estado s_INIT
						next_state <= s_ACK;
					when 1	=>		-- viene del estado s_ACK
						next_state <= s_fsamp1;
					when 2	=>		-- viene del estado s_fsamp1
						next_state <= s_fsamp2;
					when 3	=>
						next_state <= s_fsamp3;
					when 4	=>		-- viene de s_fsamp3
						next_state <= s_LF;
					when 5	=>		-- viene de s_LF
						next_state <= s_cantBits;
					when 6	=>		-- viene de s_cantBits
						next_state <= s_VREF_MSB;
					when 7	=> 	-- viene de s_EOT
						next_state <= s_ENQ;
					when 8	=>
						next_state <= s_connected;
					when 9 	=>		-- significa que estando en s_INIT recibio un comando erroneo (distinto de STX)
						next_state <= s_INIT;
					when 10 	=>		-- significa que estando en s_connected recibio un comando, lo toma como STX
						next_state <= s_control;
					when 11 	=>		-- significa que viene del estado s_disconnect, debe ir al estado s_INIT;
						next_state <= s_INIT;
					when 12 => 		-- viene de s_VREF_MSB
						next_state <= s_VREF_LSB;
					when 13 =>		-- viene de S_VREF_LSB
						next_state <= s_EOT;
				--	when 14 =>		-- el pcb esta desconectado. responde NAK y vuelve a inicio
				--		next_state <= s_INIT;
				end case;
				
		-- responde con NAK
	--	when s_NAK =>
	--			o_rd <= '0';
	--			o_TX_Byte  <= NAK;
	--			o_TX_Ready <= '1';
	--			next_state <= s_waitTX;
				
		-- Responde con ACK
		when s_ACK =>
				o_rd <= '0';
				o_TX_Byte  <= ACK;
				o_TX_Ready <= '1';
				next_state <= s_waitTX;


		-- Envia el byte mas significativo (3 bytes) de la frecuencia de muestreo(fs)
		when s_fsamp1 =>
				o_rd <= '0'; 
				o_TX_Byte  <= g_SAMPLE_RATE(23 downto 16);
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- Se envía el segundo byte de fs
		when s_fsamp2 =>
				o_rd <= '0'; 
				o_TX_Byte  <= g_SAMPLE_RATE(15 downto 8);
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- se envía el byte menos significativo de fs
		when s_fsamp3 =>
				o_rd <= '0'; 
				o_TX_Byte  <= g_SAMPLE_RATE(7 downto 0);
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- se envía LF (ascii 10)
		when s_LF =>
				o_rd <= '0'; 
				o_TX_Byte  <= LF;
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- se envia cantidad de bits (maximo 24 bits)
		when s_cantBits =>
				o_rd <= '0'; 
				o_TX_Byte  <= g_CANT_BITS;
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- se envia el MSB de VREF
		when s_VREF_MSB =>
				o_rd <= '0'; 
				o_TX_Byte  <= VREF(15 downto 8);
				o_TX_ready <= '1';
				next_state <= s_waitTX;

		-- se envia el LSB de VREF
		when s_VREF_LSB =>
				o_rd <= '0'; 
				o_TX_Byte  <= VREF(7 downto 0);
				o_TX_ready <= '1';
				next_state <= s_waitTX;		
				
		-- se envia EOT para indicar que finaliza el envio de datos de configuracion
		when s_EOT =>
				o_rd <= '0'; 
				o_TX_Byte  <= EOT;
				o_TX_ready <= '1';
				next_state <= s_waitTX;
		
		-- Se espera recibir el comando ENQ para comenzar a transmitir los datos capturados por el AD
		when s_ENQ =>
				o_rd <= '0';
				if(i_RX_ready = '1') then
					next_state 		<= s_reset;
				else
					next_state <= s_ENQ;
				end if;
		
		-- El modulo esta conectado
		when s_connected =>
				o_control <= '1';
				o_TX_Byte <= X"00";
				o_TX_Ready <= '0';
				o_rd <= '0';

				
				if i_RX_ready = '1' then
					if i_RX_Byte = EOT then
						next_state <= s_disconnect;
					else 
						next_state <= s_reset;
					end if;
				else
					next_state <= s_connected;
				end if;		
		
		when s_disconnect =>
				next_state <= s_reset;
		
		when others =>
				next_state 		<= s_INIT;
	end case;
	
		
end process;


p_StateAssignmet :process(i_Clk,i_rst,next_state) is
begin
	if rising_edge(i_Clk) then

		if i_rst = '1' then
			present_state <= s_INIT;
		else
			present_state	<= next_state;
		end if;
	end if;
		
end process;

end Behavioral;