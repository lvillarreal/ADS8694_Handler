library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- ADS8694_TOP: Bloque que nuclea todo el sistema, donde se realizan las instanciaciones e interconexiones

--	Los datos en punto fijo se representaras de la forma fixdt(signed,cantBits,bitsDecimal)
--	donde signed (1 o 0) indica si es signado o no, bitEntero cantidad de bits parte entera,
--	bitsDecimal cantidad de bits parte decimal


entity ADS8694_top is

  port (
        clk           : in std_logic;
        reset         : in std_logic;
        
		  -- SPI
		  MISO          : in std_logic;
        MOSI          : out std_logic;
        SCLK          : out std_logic;
        CS            : out std_logic;
		  
		  PWR_DWN		 : out std_logic;
		  -- UART
		  TX				 : out std_logic;
		  RX				 :	in std_logic;
		  

		  
		  -- salidas/entradas adicionales para debug
		  an 			   : out  STD_LOGIC_VECTOR (3 downto 0);
        seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
		  led0			: out  STD_LOGIC;
		  led1			: out  STD_LOGIC;
  		  RX_test			: out std_logic;
		  TX_test			: out std_logic;
		  select_filter 	: in 	std_logic;
		  sel 				: in  STD_LOGIC;
		  led					: out STD_LOGIC_VECTOR (7 downto 0);
		  sal_test			: out STD_LOGIC_VECTOR (17 downto 0)


  );
end ADS8694_top;

architecture Behavioral  of ADS8694_top  is

-- components definition



-- PULSE STRETCHER
	COMPONENT pulse_stretcher
	GENERIC(
		FREQ_IN	:	integer 	:= 100000000;	-- frecuencia clk in
		FREQ_OUT	:	integer	:=	20000			--	frecuencia clk out
	 );
	PORT(
		clk : IN std_logic;
		reset : IN std_logic; 
      pulse_in	:	in	 STD_LOGIC;
		clk_o : OUT std_logic
		);
	END COMPONENT;


-- IIR FILTER
    COMPONENT filter
    PORT(
         clk : IN  std_logic;
         clk_enable : IN  std_logic;
         reset : IN  std_logic;
         filter_in : IN  std_logic_vector(18 downto 0);
         filter_out : OUT  std_logic_vector(18 downto 0)
        );
    END COMPONENT;


-- ADC data converter
	COMPONENT data_convert
	GENERIC(
		V_FS : integer := 167772
	);
	PORT(
		clk_i : IN std_logic;
		reset_i : IN std_logic;
		data_i : IN std_logic_vector(17 downto 0);
		data_i_en : IN std_logic;          
		data_o : OUT std_logic_vector(18 downto 0);
		data_o_en : OUT std_logic
		);
	END COMPONENT;

-- Data Buffer

	COMPONENT Data_Buffer
	GENERIC(
		DATA_WIDTH : integer := 16
	);
	PORT(
		i_clk 			: IN std_logic;
		i_reset 			: IN std_logic;
		i_data 			: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		i_data_en 		: IN std_logic;
		i_uart_busy 	: IN std_logic;
		i_comm_control : IN std_logic;          
		o_byte 			: OUT std_logic_vector(7 downto 0);
		o_byte_ready 	: OUT std_logic
		);
	END COMPONENT;


-- UART

component UART_Handler
   generic(
	 SAMPLE_RATE	:	std_logic_vector(23 downto 0) := X"003E80";
	 BAUD_RATE		:	integer := 500000
	);
	port(
			i_rst				:	in std_logic;
			i_Clk				:	in std_logic;
			i_TX_Byte		:	in	std_logic_vector(7 downto 0);
			i_TX_ready		:	in std_logic;	-- el dato tx esta listo para ser transmitido
			
			o_RX_Byte		:	out std_logic_vector(7 downto 0);
			o_RX_Ready		:	out std_logic;	-- el dato recibido esta listo
			
			o_pwr_down		:	out std_logic;
			
			o_TX_Busy		:	out std_logic;	 -- modulo transmitiendo
			o_TX_Ready		:	out std_logic;  -- modulo listo para transmitir  
			o_Comm_Ready	:	out std_logic;	-- '1' conexion establecida con Serial Plotter
			
			led				:	out std_logic_vector(7 downto 0);-- debug
			TX					: 	out std_logic;
			RX					:	in	 std_logic
	);
end component UART_Handler;


component mod_7seg_bis
port (
  clk     : in  STD_LOGIC;
  rst     : in  STD_LOGIC;
  dat1_in : in  STD_LOGIC_VECTOR (15 downto 0);
  dat_out : out STD_LOGIC_VECTOR (7 downto 0);
  an0     : out STD_LOGIC;
  an1     : out STD_LOGIC;
  an2     : out STD_LOGIC;
  an3     : out STD_LOGIC
 

);
end component mod_7seg_bis;


component fsm_ad8694
generic (
  MISO_width : integer := 18;
  MOSI_width : integer := 16
);
port (
  clk     	: in  STD_LOGIC;
  reset     : in  STD_LOGIC;
  data_in 	: in  STD_LOGIC_VECTOR (MOSI_width-1 downto 0);
  MISO    	: IN  std_logic;
  start   	: IN  std_logic;
  busy    	: out std_logic;
  MOSI    	: out std_logic;
  data_out  : out STD_LOGIC_VECTOR (MISO_width-1 downto 0);
  fin     	: out std_logic;
  cs      	: out STD_LOGIC;
  sclk    	: out std_logic

);
end component fsm_ad8694;



 component ADS8694
    generic (
      MISO_width : integer := 18;
      MOSI_width : integer := 16

    );
    port (
      clk           			: in  STD_LOGIC;
      reset         			: in  STD_LOGIC;
      data_in       			: in  std_logic_vector(MISO_width-1 downto 0);
      data_in_ready 			: in  std_logic;
      spi_busy      			: in  std_logic;
		pwr_down_in				:  in	STD_LOGIC;
      start         			: out std_logic;
      data_out      			: out std_logic_vector(MOSI_width-1 downto 0);
      --sclk          			: out STD_LOGIC;
      data_received 			: out std_logic_vector(MISO_width-1 downto 0);
		pwr_down_out			: out	STD_LOGIC;
		data_received_ready	: out std_logic
    );
    end component ADS8694;

    component frequency_divisor
    generic (
      divisor : integer := 2
    );
    port (
      clk     : in  STD_LOGIC;
      rst     : in  STD_LOGIC;
      clk_out : out STD_LOGIC
    );
    end component frequency_divisor;




-- CONSTANTS DEFINITION

-------- CALCULO DE FRECUENCIA DE MUESTREO --------
--
--					          clk
--				fs =  ------------------
--					    2 x divisor x 34
--
--	El clock es de 100 MHz
---------------------------------------------------

-- FRECUENCIA DEL CLOCK
	constant FREQ_CLK					:	integer := 100000000;	-- 100 MHZ

-- 20 ksps
	constant divisor					:	integer range 0 to 200			:=	74;			--	SCLK de 675.68 kHz, Fs de 20 kHz
	constant SAMPLE_RATE				:	std_logic_vector(23 downto 0)	:=	X"004E20";	-- 20 ksps
	constant FREQ_OUT					:	integer := 20000;										-- 20 khz, se utiliza para clk del filtro

-- 16 ksps
--	constant divisor		:	integer range 0 to 200 			:= 92; 			-- Con 92 se logra un SCLK de 543.478 kHz (frecuencia de muestreo de 16 kHz)
--	constant SAMPLE_RATE	:	std_logic_vector(23 downto 0)	:=	X"003E80";	-- 16 ksps

-- 12.5 ksps
--	constant divisor		:	integer range 0 to 200 			:= 118; 			-- Con 118 se logra un SCLK de 427.35 kHz (frecuencia de muestreo de 12.5 kHz)	
--	constant SAMPLE_RATE	:	std_logic_vector(23 downto 0)	:=	X"0030D4";	-- 12.5 ksps


	constant MISO_width	: 	integer range 0 to 18 			:= 18;			-- El AD responde con un dato de 18 bits
	constant MOSI_width	: 	integer range 0 to 16 			:= 16;			--	Los comandos que se envian al AD son de 16 bits
	constant BAUD_RATE	:	integer range 0 to 1000000 	:= 900000;	 	-- Baudios para comunicacion UART

	constant  DATA_WIDTH    : integer range 0 to MISO_width :=  MISO_width;
	constant  cant_muestras : integer range 0 to 1024 :=  1024;
	
	constant V_FS	:	integer range 0 to 167772 := 167772;	-- es el valor maximo del rango de entrada multiplicado por 2^14



-- SIGNALS DEFINITION

signal clk_l1 : std_logic;

signal dato : std_logic_vector(MISO_width-1 downto 0);

signal s_test_or_data 		: std_logic_vector(15 downto 0);

signal spi_clk     			: STD_LOGIC;
signal spi_reset     		: STD_LOGIC;
signal spi_data_in 			: STD_LOGIC_VECTOR (MOSI_width-1 downto 0);
signal spi_MISO    			: std_logic;
signal spi_start   			: std_logic;
signal spi_busy 				: std_logic;
signal spi_MOSI    		  	: std_logic;
signal spi_data_out    	  	: STD_LOGIC_VECTOR (MISO_width-1 downto 0);
signal spi_dout_ready     	: std_logic;
signal spi_cs      			: STD_LOGIC;
signal spi_sclk    			: std_logic;


signal ads8694_clk           			: 	STD_LOGIC;
signal ads8694_reset         			: 	STD_LOGIC;
signal ads8694_data_in       			: 	std_logic_vector(MISO_width-1 downto 0);
signal ads8694_data_in_ready 			: 	std_logic;
signal ads8694_spi_busy      			: 	std_logic;
signal ads8694_start         			: 	std_logic;
signal ads8694_data_out      			: 	std_logic_vector(MOSI_width-1 downto 0);
signal ads8694_data_received 			: 	std_logic_vector(MISO_width-1 downto 0);
signal ads8694_data_received_ready	:	std_logic;
signal ads8694_in_pwr_down				:	std_logic;
signal ads8694_out_pwr_down			: 	std_logic;





-- PULSE STRETCHER SIGNALS
	signal s_ps_clk_o				:	std_logic;
	signal s_ps_pulse_in			:	std_logic;
	
-- FILTER SIGNALS
	signal s_filter_clk 			: 	std_logic;
	signal s_filter_clk_enable	: 	std_logic;
	signal s_filter_in 			: 	std_logic_vector(18 downto 0);
	signal s_filter_out 			: 	std_logic_vector(18 downto 0);

	
-- DATA BUFFER	 SIGNALS
	
	signal s_datBuff_i_data 			:	std_logic_vector(DATA_WIDTH-3 downto 0);
	signal s_datBuff_i_data_en 		:	std_logic;
	signal s_datBuff_i_uart_busy 	 	:	std_logic;
	signal s_datBuff_i_comm_control  :	std_logic;
	signal s_datBuff_o_byte 			: 	std_logic_vector(7 downto 0);
	signal s_datBuff_o_byte_ready 	:	std_logic;
	
-- UART HANDLER SIGNALS

	signal s_uartHand_i_TX_Byte		:	std_logic_vector(7 downto 0);
	signal s_uartHand_i_TX_ready		:	std_logic;
	
	signal s_uartHand_i_conn_succ		:	std_logic;
	
	signal s_uartHand_o_RX_Byte		:	std_logic_vector(7 downto 0);
	signal s_uartHand_o_RX_Ready		:	std_logic;
	
	signal s_uartHand_o_TX_Busy		:	std_logic;
	signal s_uartHand_o_TX_Ready		: 	std_logic;
	signal s_uartHand_o_Comm_Ready	:	std_logic;
		
	signal s_uartHand_TX					:	std_logic;
	signal s_uartHand_RX					:	std_logic;
	
	signal s_uartHand_pwr_down			:	std_logic;

	
	
begin

--	DEBUG

	RX_test <= MISO;	
	TX_test <= spi_sclk;
	sal_test(17) <= spi_mosi;
	sal_test(16) <= spi_cs;
	
	led <=dato(7 downto 0);
	
	sal_test(15 downto 0) <= dato(15 downto 0);

	dato <= s_filter_out(18 downto 1);
	
  -- SIGNAL INTERCONNECTION
  
  

  PWR_DWN	<=		ads8694_out_pwr_down;
  ads8694_in_pwr_down <= s_uartHand_pwr_down;


  ads8694_clk           	<=  clk_l1;
  ads8694_reset         	<=  reset;
  
  ads8694_data_in      	   <=  spi_data_out;
  
  ads8694_data_in_ready 	<=  spi_dout_ready;
  
  ads8694_spi_busy      	<=  spi_busy;

  spi_data_in 		<=  ads8694_data_out;
  spi_start   		<=  ads8694_start;
  spi_clk	  		<=  clk_l1;
  spi_MISO    		<=  MISO;
  spi_reset   		<=  reset;


 
-- SPI
	MOSI  <=  spi_MOSI;
	CS    <=  spi_CS;
	SCLK  <=  spi_SCLK;

-- UART
	TX					<=	s_uartHand_TX;
	s_uartHand_RX 	<= RX;
	
	
-- FILTER

	s_filter_clk_enable	<= '1';

	
	s_filter_in <= '0' & ads8694_data_received;	
	
	
	s_filter_clk <= s_ps_clk_o;
	
-- PULSE STRETCHER

	s_ps_pulse_in <= ads8694_data_received_ready;



-- DATA BUFFER

	s_datBuff_i_data_en	<=	ads8694_data_received_ready;
	
	with select_filter select s_datBuff_i_data <=
	s_filter_out(17 downto 2) when '0',
	ads8694_data_received(17 downto 2)  when others;
   	
		
	s_datBuff_i_uart_busy 		<= s_uartHand_o_TX_Busy;
	s_datBuff_i_comm_control	<= s_uartHand_o_Comm_Ready;
	
	s_uartHand_i_TX_Byte 	<=  s_datBuff_o_byte;
	s_uartHand_i_TX_ready	<=	 s_datBuff_o_byte_ready;

-- INSTANCIACIONES



-- PULSE STRETCHER
	Inst_pulse_stretcher: pulse_stretcher 
	GENERIC MAP(
		FREQ_IN	=>	FREQ_CLK,
		FREQ_OUT	=> FREQ_OUT
	)
	PORT MAP(
		clk 		=> clk,
		reset 	=> reset,
		pulse_in	=> s_ps_pulse_in,
		clk_o 	=> s_ps_clk_o
	);	
	
-- IIR FILTER
   LPF_IIR: filter PORT MAP (
          clk => s_filter_clk,
          clk_enable => s_filter_clk_enable,
          reset => reset,
          filter_in => s_filter_in,
          filter_out => s_filter_out
        );	
	


-- DATA BUFFER

	Inst_Data_Buffer: Data_Buffer PORT MAP(
		i_clk 			=> clk,
		i_reset 			=> reset,
		i_data 			=> s_datBuff_i_data,
		i_data_en 		=> s_datBuff_i_data_en,
		i_uart_busy 	=> s_datBuff_i_uart_busy,
		i_comm_control => s_datBuff_i_comm_control,
		o_byte 			=> s_datBuff_o_byte,
		o_byte_ready 	=> s_datBuff_o_byte_ready
	);



-- MODULO UART

uart: UART_Handler
   generic map(
	 SAMPLE_RATE 	=> SAMPLE_RATE,
	 BAUD_RATE 		=> BAUD_RATE
	)
	port map(
			i_rst				=> reset,
			i_Clk				=> clk,
			i_TX_Byte		=> s_uartHand_i_TX_Byte,
			i_TX_ready		=> s_uartHand_i_TX_ready,
			
			o_RX_Byte		=> s_uartHand_o_RX_Byte,
			o_RX_Ready		=> s_uartHand_o_RX_Ready,
			
			o_pwr_down     => s_uartHand_pwr_down,
			
			o_TX_Busy		=> s_uartHand_o_TX_Busy,
			o_TX_Ready		=> s_uartHand_o_TX_Ready,  
			o_Comm_Ready	=>	s_uartHand_o_Comm_Ready,
			
			
			TX					=> s_uartHand_TX,
			RX					=>	s_uartHand_RX	
	);



-- ADS8694 HANDLER

  ADS8694_Handler : ADS8694
  generic map (
    MISO_width => MISO_width,
    MOSI_width => MOSI_width
--    divisor    => divisor
  )
  port map (
    clk           		=> ads8694_clk,
    reset         		=> ads8694_reset,
    data_in       		=> ads8694_data_in,
    data_in_ready 		=> ads8694_data_in_ready,
    spi_busy      		=> ads8694_spi_busy,
    start         		=> ads8694_start,
	 pwr_down_in			=> ads8694_in_pwr_down,
    data_out      		=> ads8694_data_out,
    data_received 		=> ads8694_data_received,
	 pwr_down_out			=>	ads8694_out_pwr_down,
	 data_received_ready	=>	ads8694_data_received_ready
  );


  SPI_Handler : fsm_ad8694
  generic map (
    MISO_width => MISO_width,
    MOSI_width => MOSI_width
  )
  port map (
    clk     => spi_clk,
    reset   => spi_reset,
    data_in => spi_data_in,
    MISO    => spi_MISO,
    start   => spi_start,
    busy    => spi_busy,
    MOSI    => spi_MOSI,
    data_out    => spi_data_out,
    fin     => spi_dout_ready,
    cs      => spi_cs,
    sclk    => spi_sclk
  );


  mod_7seg_bis_i : mod_7seg_bis
  port map (
    clk => clk,
    rst => reset,
    dat1_in => dato(MISO_width-3 downto 0),
    dat_out => seg,
    an0 => an(0),
    an1 => an(1),
    an2 => an(2),
    an3 => an(3)
  );


  frequency_divisor_i : frequency_divisor
  generic map (
    divisor => divisor
  )
  port map (
    clk     => clk,
    rst     => reset,
    clk_out => clk_l1
  );


end Behavioral;
