library IEEE;

use IEEE.std_logic_1164.all;

-- bloque que simula la respuesta del ADS8694

entity miso_rta_simul is
  port (
    clk : in std_logic;
    reset : in std_logic;
    cs : in std_logic;

    miso : out std_logic
  );
end miso_rta_simul;

architecture Behavioral of miso_rta_simul is

-- type definition

type state_type is (ini,e0);

-- signal definition

signal present_state,next_state : state_type;
signal data : std_logic_vector(17 downto 0);
signal i : integer range 0 to 36;
signal flag,flag1 : std_logic;

begin

data <= "011111010111110000"; -- dato de respuesta

process(reset,cs,flag1,i)
begin
  if reset = '1' then
    flag <= '0';
  elsif falling_edge(cs) then
    flag <= '1';
  end if;
  if flag1 = '1' and i = 34 then
    flag <= '0';
  end if;
end process;

process(clk,reset,flag)
begin
  if reset = '1' then
    i <= 0;
    flag1 <= '0';
  elsif falling_edge(clk) and flag = '1' then
    i <= i+1;
    flag1 <= '0';
  end if;
  if i = 33 then
    flag1 <= '1';
  elsif i = 34 then
    i <= 0;
    flag1 <= '0';
  end if;
end process;




fsm:process(present_state,next_state,flag1,i)
begin
  case present_state is

    when ini =>
      miso <= '0';
      if i = 15 then
        next_state <= e0;
      else
        next_state <= present_state;
      end if;

    when e0 =>
      miso <= data(33-i);
      if flag1 = '1' then
        next_state <= ini;
      else
        next_state <= present_state;
      end if;
    end case;
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

end architecture;
