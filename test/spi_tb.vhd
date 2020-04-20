
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY spi_tb IS
END spi_tb;

ARCHITECTURE testbench OF spi_tb IS


COMPONENT SPI_module

    generic (MISO_width : integer :=18;
    		 MOSI_width : integer := 16);

    Port (
              data_in : in std_logic_vector(MOSI_width-1 downto 0);	-- dato que se desea transmitir por SPI
              din_en  : in std_logic;								    -- flag que indica que el dato a transmitir esta listo
              clk		: in std_logic;									-- entrada de clock, maximo 18MHz en ADS8694
              MISO	: in std_logic;									-- canal MISO (Master Input Slave Output) de comunicacion SPI, serial
 			        reset	: in std_logic;     							-- reset activo por alto

 			        data_out 	: out std_logic_vector(MISO_width-1 downto 0);	-- dato recibido, completo y en paralelo (vector)
 			        dout_ready 	: out std_logic;								-- flag que indica que el dato recibido esta listo
 	            busy		: out std_logic;								-- flag que indica que el bloque esta ocupado
 		          CS			: out std_logic;                            	-- chip-select, activo por bajo
              MOSI		: out std_logic;                          		-- canal MOSI, salida serial (SPI)
              SCLK		: out std_logic);                               -- clock de comunicacion spi

END COMPONENT;

      	constant MISO_width	:	integer	:=	18;
      	constant MOSI_width	:	integer	:=	16;
      	constant clk_period	:	time	:=	1000 ns;	-- medio periodo, ns

      	signal clk,din_en,MOSI,MISO,reset,send_flag,dout_ready_flag,dat,busy	:  	std_logic;
      	signal data_in					:	std_logic_vector(MOSI_width-1 downto 0);
		    signal dato_ADC					: 	std_logic_vector(MISO_width-1 downto 0);
		    signal i						: 	integer range 0 to MISO_width + MOSI_width;
BEGIN

	dato_ADC	<= "100110011001101111";


  miso_gen: process
  begin
  		MISO <= '1';
  		wait for clk_period;
  		MISO <= '0';
  		wait for clk_period;
  end process;


 uut:SPI_module
		 generic map(MISO_width,
                 MOSI_width)
		 PORT MAP(
					data_in	=>	data_in,
					din_en	=> 	din_en,
					clk		=>	clk,
					MOSI	=>	MOSI,
          MISO  =>  MISO,
					reset	=>	reset,
          busy => busy
					);




--cta	:	process(clk,reset,dout_ready_flag)
--begin
--     if reset = '1' then
--     	i	<=	0;
--    elsif falling_edge(clk) and send_flag = '1' then
--     	i <= i+1;
--     end if;
--end process;


--rta: process(clk,i,send_flag)
--begin
--  if reset = '1' THEN
--    dat <= '0';
--  elsif falling_edge(clk) then-- and i > 15 then
--		MISO <= not dat;--dato_ADC(i-MISO_width+1);
--    dat <= not dat;
--  end if;
--end process;


clk_gen: process
begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
end process;




stim_proc: process

begin

  send_flag <= '0';
	reset 	<= 	'1';
	data_in	<=	x"C000";
	din_en	<=	'0';
	wait for 1000 ns;
	reset <= '0';
  --wait for 1000 ns;
  din_en <= '1';
  send_flag <= '1';

  wait for 100*clk_period;

  wait;

	end process;



END;
