library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Bloque que se encarga de la gestion de comunicacion con el ADC ADS8694

entity ADS8694 is
	GENERIC(
		MISO_width	:	integer := 18;
	   MOSI_width	:	integer := 16
);

    Port ( 	 clk 						: 	in	STD_LOGIC;
				 reset 					: 	in	STD_LOGIC;
				 data_in					:	in std_logic_vector(17 downto 0);	-- dato recibido por spi
				 data_in_ready			:	in	std_logic;	-- indica que el dato recibido por spi esta listo
				 spi_busy				:	in	std_logic;	-- indica que el modulo spi esta ocupado
				 pwr_down_in			:  in	STD_LOGIC;	-- CommControl indica si adc se enciende('1') o apaga	('0')
				 start 					: 	out std_logic;	-- comienza la transmision
				 data_out				:	out std_logic_vector(15 downto 0);	-- dato que se quiere enviar por spi
				 data_received			:	out std_logic_vector(17 downto 0);	-- dato recibido por spi
				 pwr_down_out			:	out std_logic;	
				 data_received_ready	:	out std_logic
				 );

end ADS8694;

architecture Behavioral of ADS8694 is

type 	state_type is (ini,e0,e1,e2,e3,e4);

-- componentes


-- signals


signal 	present_state,next_state   : state_type;

signal dato: std_logic_vector(MISO_width-1 downto 0);
signal s_data_in_ready	:	std_logic;


constant commCH0: std_logic_vector(MOSI_width - 1 downto 0) := X"C000";
constant commCH1: std_logic_vector(MOSI_width - 1 downto 0) := X"C400";
constant commCH2: std_logic_vector(MOSI_width - 1 downto 0) := X"C800";
constant commCH3: std_logic_vector(MOSI_width - 1 downto 0) := X"CC00";
constant commAUTOSEC: std_logic_vector(MOSI_width - 1 downto 0) := X"A000";
constant commRST: std_logic_vector(MOSI_width - 1 downto 0) := X"8500";
constant commRW: std_logic_vector(MOSI_width - 1 downto 0) := X"1106";	--cambia input range ch3
constant commRD: std_logic_vector(MOSI_width - 1 downto 0) := X"1000";
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
proc1 : PROCESS (present_state,spi_busy,pwr_down_in) IS


BEGIN

  CASE present_state IS

  	WHEN ini =>
			start <= '0';
			data_out <= X"0000";
			pwr_down_out <= '0';
			
			if(pwr_down_in = '1') then
				next_state <= e2;
			else
				next_state <= ini;
			end if;

		-- primer secuencia, se repite solo una vez
		when e2 =>
			pwr_down_out <= '1';
			start <= '0';
			-- Como la configuracion por defecto es +-10.24V, no es estrictamente 
			-- necesario enviar el comando para configurar el rango de entrada; por ello
			-- se envia el comando de seleccion de canal3
			data_out <= commCH3;		
	
			if pwr_down_in = '0' then
				next_state <= ini;
			elsif spi_busy = '0' then	-- modulo spi disponble para transmitir.
				next_state <= e0;
			else
				next_state <= e2;
			end if;
	
	
		when e0 =>
			pwr_down_out <= '1';
		   start <= '1';
			data_out <= commCH3;
			if spi_busy = '0' then -- el modulo spi termino la transmision y ya esta listo el dato de respuesta
				next_state <= e1;
			else
				next_state <= e0;
			end if;


		when e1 =>
			start <= '0';
			data_out <= commCH3;
			next_state <= e3;
		
		when e3 =>
			pwr_down_out <= '1';
			start <= '1';
			data_out <= commCH3;
			if spi_busy = '0' then -- el modulo spi termino la transmision y ya esta listo el dato de respuesta
				next_state <= e1;
			else
				next_state <= e3;
			end if;
			
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
