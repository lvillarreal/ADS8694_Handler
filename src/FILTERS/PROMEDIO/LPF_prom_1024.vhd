library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

-- Si se suman N número de R bits, el resultado se debe representar con B bits
-- donde B>=log_2(N(2**R-1)+1)

entity LPF_prom_1024 is
  generic (
        DATA_WIDTH    : integer :=  18;   -- ancho de palabra del dato entrante
        cant_muestras : integer :=  1024);   -- cantidad de muestras a promediar
  port (
        clk             : in std_logic;
        reset           : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_in_ready   : in  std_logic;

        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_ready  : out std_logic);
end LPF_prom_1024;

architecture Behavioral of LPF_prom_1024 is

-- consntant definition

-- si se suman N numeros binarios de R bits, el resultado requiere log2(N)+R bits

constant  B : integer := 28;


-- type definition

type 	state_type  is (ini,e0,e1);


signal present_state,next_state : state_type;
signal aux : unsigned(B-1 downto 0);
signal i  : integer range 0 to cant_muestras+1;
--signal flag : std_logic;
signal s_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

-- fsm
proc1 : PROCESS (present_state,next_state,data_in_ready,i,aux) IS

BEGIN

  CASE present_state IS

  	WHEN ini =>
			--aux <= (others => '0');
      data_out_ready  <=  '0';

			if data_in_ready = '1' then
      	next_state <= e0;
			else
				next_state <= present_state;
			end if;


		when e0 =>
       --aux  <=  aux + unsigned(data_in);
			if i = cant_muestras then
				next_state <= e1;
			else
				next_state <= present_state;
			end if;

    -- realiza la division
		when e1 =>


      data_out <= std_logic_vector(aux(B-1 downto 10));
      --data_out <= std_logic_vector(aux);
      data_out_ready  <=  '1';
      next_state  <=  ini;

  END CASE;

END PROCESS proc1;


cnta: process(data_in_ready,reset,aux,data_in,i)
begin

  if reset = '1' then
    i <= 0;
   -- flag <= '0';
    aux <= (others=>'0');
  elsif rising_edge(data_in_ready) then
    i <= i+1;
   -- flag <= '0';
    aux <= aux + unsigned(data_in);
    ---aux <= aux + unsigned()
  end if;
  if i = cant_muestras+1 then
    i <= 0;
   -- flag <= '1';
    aux <= (others=>'0');
  end if;
end process;

-- Proceso de reset sincrono y de asignacion de estado presente

proc3 : PROCESS (clk, reset, present_state) IS
BEGIN

  IF (falling_edge(clk))  THEN
    IF reset = '1' THEN
    	present_state   <=  ini;
  	ELSE
    	present_state   <=  next_state;
  	END IF;
  END IF;
END PROCESS proc3;


end Behavioral;
