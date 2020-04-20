library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

-- Filtro de mediana
-- Realiza la mediana de N numeros ingresados en forma serial (cada numero ingresa
-- en forma paralela, con DATA_WIDTH bits) sincronizados con data_in_ready
-- (cuando data_in_ready = 1, se captura el dato) y cuando el dato de salida
-- esta listo, se coloca en alto la salida data_out_ready.

entity LPF_mediana is
  generic (
        DATA_WIDTH    : integer :=  18;   -- ancho de palabra del dato entrante
        cant_muestras : integer :=  9);   -- cantidad de muestras a promediar
  port (
        clk             : in std_logic;
        reset           : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_in_ready   : in  std_logic;

        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_ready  : out std_logic);
end LPF_mediana;

architecture Behavioral of LPF_mediana is

-- type definition
type state_type is (ini,e0,e1,e2,e3);
type ram is array (0 to cant_muestras-1) of unsigned(DATA_WIDTH-1 downto 0);

-- signals definition
signal i: integer range 0 to cant_muestras;
signal present_state,next_state : state_type;
signal ram_mem : ram;
signal aux : unsigned(DATA_WIDTH-1 downto 0);
signal flag,flag1 : std_logic;


begin

fsm: process(present_state,next_state,data_in_ready,i,aux,flag1)

begin
  case present_state is

    when ini =>
      data_out_ready <= '0';

      for m in 0 to cant_muestras-1 loop
          ram_mem(m) <= (others => '0');
      end loop;

      flag <= '0';
      if i /= 0 then
        next_state <= e0;
      else
        next_state <= present_state;
    end if;

    -- En e0 se ordenan los datos en un array (ram_mem)
    when e0 =>
      data_out_ready <= '0';
      ram_mem(i-1)  <=  aux;
      flag <= '0';
      if i = cant_muestras THEN
        next_state  <=  e1;
      else
        next_state  <=  present_state;
      end if;

    -- En e1 se ordenan de mayor a menor
    when e1 =>
      data_out_ready <= '0';
      flag <= '1';

      if flag1 <= '1' then
        next_state <= e2;
      else
        next_state <= present_state;
      end if;

    when e2 =>
      next_state <= e3;

    when e3 =>

      flag <= '0';
      data_out_ready <= '1';
      next_state <= ini;
  end case;
end process;


mediana: process(flag,reset, clk)
variable k,j,aux1   : integer range 0 to cant_muestras;
variable med : unsigned(DATA_WIDTH-1 downto 0);
variable var : ram;
begin
  if reset = '1' then
    data_out <= (others => '0');
    flag1 <= '0';
    for j in 0 to cant_muestras-1 loop
      var(j) := (others => '0');
    end loop;
    med := (others => '0');

  elsif falling_edge(clk) and flag = '1' then
    --if flag <= '1' then
     var := ram_mem;

      for k in 0 to cant_muestras-1 loop

        med := var(k);

        for j in k to cant_muestras-1 loop

          if var(j) <= med then
            med := var(j);
            aux1 := j;
          end if;

        end loop;

        var(aux1) := var(k);
        var(k)    := med;
      end loop;

      data_out <= std_logic_vector(var((cant_muestras-1)/2));
      flag1 <= '1';
    else
      flag1 <= '0';
    --end if;
  end if;
end process;


cnta: process(data_in_ready)
begin

  if reset = '1' then
    i <= 0;
  elsif rising_edge(data_in_ready) then
    i <= i+1;
    aux  <= unsigned(data_in);
  end if;
  if i = cant_muestras then
    i <= 0;
  end if;
end process;

-- Proceso de reset sincrono y de asignacion de estado presente

proc3 : PROCESS (clk, reset, present_state, next_state) IS
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
