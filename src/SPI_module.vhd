library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_module is

	GENERIC(
		MISO_width : INTEGER := 18; 	-- ancho de palabra recibida
		MOSI_width : INTEGER := 16);	-- ancho de palabra transmitida

		--(Longitud total de comunicacion MISO_width + MOSI_width)

    Port (
            data_in : in std_logic_vector(MOSI_width-1 downto 0);	-- dato que se desea transmitir por SPI
            din_en  : in std_logic;								    -- flag que indica que el dato a transmitir esta listo
            clk			: in std_logic;									-- entrada de clock, maximo 18MHz en ADS8694
            MISO		: in std_logic;									-- canal MISO (Master Input Slave Output) de comunicacion SPI, serial
 					  reset		: in std_logic;     							-- reset activo por alto

 						data_out 		: out std_logic_vector(MISO_width-1 downto 0);	-- dato recibido, completo y en paralelo (vector)
 						dout_ready 	: out std_logic;								-- flag que indica que el dato recibido esta listo
 						busy				: out std_logic;								-- flag que indica que el bloque esta ocupado
 						CS					: out std_logic;                            	-- chip-select, activo por bajo
 						MOSI				: out std_logic;                          		-- canal MOSI, salida serial (SPI)
 						SCLK				: out std_logic);                               -- clock de comunicacion spi

end SPI_module;

architecture Behavioral of SPI_module is

type 	state_type is (ini,e0,e1,e2,e3);

signal 	present_state,next_state   : state_type;
signal  cnt_reset	: std_logic;
signal  i 			: integer range 0 to MISO_width+MOSI_width;
signal  s_data_out	: std_logic_vector(MISO_width-1 downto 0);	-- se�al que expone lo que se recibe por MISO
--signal  data_flag	: std_logic;								-- flag que se usa para registrar la salida (dato recibido)


begin

sclk  <= clk;

-- Proceso de maquina de estados, implementacion de la transmision y recepcion SPI

fsm : PROCESS (din_en, present_state, next_state,i,data_in,s_data_out) IS

BEGIN

    CASE present_state IS

    	WHEN ini =>
    		CS <= '1';   			-- cs en alto para la no comunicacion
    		mosi <= '1';			-- se deja la linea en alto cuando no hay comunicacion
    		busy <= '0'; 			-- el dispositivo se encuentra disponible para transmitir
    		cnt_reset <= '1';
				dout_ready <= '0';


    		IF din_en = '1' THEN
    			  next_state <= e0;	-- Cuando se indica que el dato esta listo para ser enviado, comienza la transmision
    		ELSE
    		    next_state <= present_state;
    		END IF;

    	-- Comienza transmision
    	WHEN e0 =>
    		CS <= '0';
    		cnt_reset <= '0';
    		busy <= '1';
				--data_flag <= '0';

    	  mosi <= data_in(MOSI_width-1-i);

    		IF i = MOSI_width-1 THEN
    			next_state <= e1;
    		ELSE
    			next_state <= present_state;
    		END IF;


    	-- recepcion
    	WHEN e1 =>
    		CS <= '0';
    		cnt_reset <= '0';
    		busy <= '1';

    		--s_data_out(MISO_width-1-i) <= MISO;

    		IF i = MISO_width-1 THEN
    			--data_flag <= '1'; 		-- flag que indica que el dato ya esta listo
    			next_state <= e2;		-- finaliza secuencia
    		ELSE
    			next_state <= present_state;
    		END IF;

			--se actualiza el dato recibido por MISO
			WHEN e2 =>
					cs <= '1';
					data_out <= s_data_out;
					dout_ready <= '1';
					next_state <= e3;

			WHEN e3 =>
				next_state <= ini;

    END CASE;

END PROCESS fsm;

-- proceso para almacenar dato recibido
proc_5:process(clk,reset,i,MISO,present_state)
begin
	if falling_edge(clk) then
		if reset='1' then
			s_data_out <= (others =>'0');
		elsif present_state=e1 then
			s_data_out(MISO_width-1-i)<= MISO ;
		end if;
	end if;
end process;


-- Proceso para registrar el dato recibido por MISO
--proc1 : PROCESS (clk,data_flag,present_state) IS
--BEGIN
--	IF (falling_edge(clk))  THEN
--		IF data_flag = '1' THEN
--		     dout_ready <= '1';
--   		   data_out <= s_data_out;
				 --data_out <= x"3FFF";
--   		ELSIF present_state /= ini THEN
--   		   dout_ready <= '0';
				 --data_out <= (others => '0');
--   		END IF;
--  	END IF;
--END PROCESS proc1;


-- Proceso para incrementar la cuenta de i y asi determinar cuando se transmite y cuando se recibe
-- (basado en funcionamiento de ADS8694)

proc2 : PROCESS (clk,i,present_state,cnt_reset) IS

BEGIN
   IF (falling_edge(clk))  THEN

   		IF cnt_reset = '1' or (i = MOSI_width-1 and next_state = e1 and present_state = e0) THEN
   			i <= 0;
   		ELSE
   			i <= i + 1;
   		END IF;

  END IF;
END PROCESS proc2;




-- Proceso de reset sincrono y de asignacion de estado presente

proc3 : PROCESS (clk, reset, present_state) IS
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
