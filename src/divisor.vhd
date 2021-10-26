library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Bloque que genera un clock a partir de otro de mayor frecuencia. 
-- Se utiliza para SCLK de SPI

entity frequency_divisor is
    generic (
      divisor : integer := 2);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
    end frequency_divisor;

architecture Behavioral of frequency_divisor is

signal temporal: STD_LOGIC;

signal contador: integer range 0 to 156294 := 0;--Para 625khz (tomado del clk que va de entrada a los filtros)

begin
    divisor_frecuencia: process (rst, clk) begin
		if rising_edge(clk) then
			if (rst = '1') then
				temporal <= '0';
            contador <= 1;
			else 
		    if (contador = divisor) then
              temporal <= NOT(temporal);
              contador <= 1;
          else
			     contador <= contador + 1;
          end if;
			end if;
		end if;
end process;

clk_out <= temporal;

end Behavioral;