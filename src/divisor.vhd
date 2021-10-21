
----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    10:18:21 02/29/2016
-- Design Name:
-- Module Name:    clk_05seg - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


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