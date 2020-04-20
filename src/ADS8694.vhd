library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ADS8694 is
	GENERIC(
		MISO_width	:	integer := 18;
	   MOSI_width	:	integer := 16
		--divisor 		: integer := 5		-- la frecuencia de clock de spi puede ser una fraccion del clock del bloque general
);

    Port ( 	 clk 						: 	in	STD_LOGIC;
				 reset 					: 	in	STD_LOGIC;
				 data_in					:	in std_logic_vector(17 downto 0);	-- dato recibido por spi
				 data_in_ready			:	in	std_logic;	-- indica que el dato recibido por spi esta listo
				 spi_busy				:	in	std_logic;	-- indica que el modulo spi esta ocupado

				 start 					: 	out std_logic;	-- comienza la transmision
				 data_out				:	out std_logic_vector(15 downto 0);	-- dato que se quiere enviar por spi
				 --sclk 					: 	out STD_LOGIC;	-- clock para el modulo spi
				 data_received			:	out std_logic_vector(17 downto 0);	-- dato recibido por spi
				 data_received_ready	:	out std_logic
				 );

end ADS8694;

architecture Behavioral of ADS8694 is

type 	state_type is (ini,e0,e1);

-- componentes


-- signals


signal 	present_state,next_state   : state_type;

signal dato: std_logic_vector(MISO_width-1 downto 0);
signal s_data_in_ready	:	std_logic;

begin

data_received <= dato;
s_data_in_ready <= data_in_ready;
--registro del dato entrante

data_reg:process (clk,s_data_in_ready, data_in)
BEGIN
	if falling_edge(clk) THEN
			dato <= data_in;
			data_received_ready <= s_data_in_ready;

	end if;
end process;


-- fsm
proc1 : PROCESS (present_state,spi_busy) IS


BEGIN

  CASE present_state IS

  	WHEN ini =>
	
			start <= '0';
	--		data_out <= "0000101100000000";  --comando para seleccionar +-2.5 Vref
			data_out <= "0000101100000010";	--comando para seleccionar +-0.625Vref

			if spi_busy = '0' then	-- modulo spi disponble para transmitir
				next_state <= e0;
			else
				next_state <= present_state;
			end if;

	-- Se transmite
--		when e0 =>
--			start <= '1';
--			next_state <= e1;

		when e0 =>
		   start <= '1';

			if spi_busy = '0' then -- el modulo spi termino la transmision y ya esta listo el dato de respuesta
				next_state <= e1;
			else
				next_state <= present_state;
			end if;

		when e1 =>
		  start <= '0';
			data_out <= X"C000";	-- selecciona ch0
			next_state <= e0;
			
		when others => next_state <= ini;
		

  END CASE;

END PROCESS proc1;


-- Proceso de reset sincrono y de asignacion de estado presente

proc3 : PROCESS (clk, reset, next_state) IS

BEGIN

  IF (falling_edge(clk))  THEN
    IF reset = '1' THEN
    	present_state <= ini;
  	ELSE
    	present_state <= next_state;
  	END IF;
  END IF;
END PROCESS proc3;






end Behavioral;
