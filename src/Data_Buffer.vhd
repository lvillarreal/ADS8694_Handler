library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Bloque que recibe el dato de 16 bits y lo envia en dos bytes al modulo uart

entity Data_Buffer is
	generic (
			DATA_WIDTH	: integer := 16 
	);
	port(
	
			i_clk				:	in std_logic;
			i_reset			:	in std_logic;
			
			i_data			:	in std_logic_vector(DATA_WIDTH-1 downto 0);	-- dato a enviar
			i_data_en		:	in std_logic;		-- '1', dato de entrada valido
			
			i_uart_busy		:	in	std_logic;		-- '0' modulo uart diponible para enviar
			i_comm_control	:	in std_logic;		-- '1' conexion establecida con signal plotter
			
			o_byte			: 	out std_logic_vector(7 downto 0);	-- byte a enviar
			o_byte_ready	:	out std_logic		-- byte listo para enviar
			
	);
end Data_Buffer;

architecture Behavioral of Data_Buffer is

type state is (s_ini,s_envByte1,s_wait,s_envByte2);

-- SIGNAL DEFINITION

signal present_state, next_state : state;

signal data_buffer	:	std_logic_vector(DATA_WIDTH-1 downto 0);

begin


-- maquina de estados, envio por uart
fsm: process( present_state,i_data_en, i_comm_control, i_data, i_uart_busy, data_buffer)
begin
	case present_state is
		
		when s_ini =>
			data_buffer  <= i_data; 
			o_byte_ready <= '0';

			-- Si hay dato listo para enviar, si hay conexion con Serial Plotter y si el modulo
			-- esta disponible, se envia el dato, sino se descarta
			if (i_data_en = '1' and i_comm_control = '1' and i_uart_busy = '0') then
				next_state <= s_envByte1;
			else
				next_state <= s_ini;
			end if;
	
		
		when s_envByte1 =>
			o_byte <= data_buffer(DATA_WIDTH-1 downto DATA_WIDTH-8);
			o_byte_ready <= '1';
			if i_uart_busy = '1' then	-- cuando se empieze a transmitir se cambia de estado
				next_state <= s_wait;
			else 
				next_state <= s_envByte1;
			end if;
			
		 when s_wait =>
			o_byte_ready <= '0';
			-- cuando se termina de transmitir se cambia de estado
			if i_uart_busy = '0' then
				next_state <= s_envByte2;
			else
				next_state <= s_wait;
			end if;
		
		 when s_envByte2	=>
			o_byte <= data_buffer(DATA_WIDTH-9 downto DATA_WIDTH-16);
			o_byte_ready <= '1';
			if i_uart_busy = '1' then	-- cuando se empieze a transmitir se cambia de estado
				next_state <= s_ini;
			else 
				next_state <= s_envByte2;
			end if;
			
		  when others => next_state <= s_ini;
		  
		end case;	
		
end process;



--  Asignacion de estado siguiente
p_StateAssignmet :process(i_clk,i_reset,next_state, present_state) is
begin
	if rising_edge(i_Clk) then
		if i_reset = '1' then
			present_state <= s_ini;
		else
			present_state <= next_state;
		end if;
	end if;
		
end process;

end Behavioral;

