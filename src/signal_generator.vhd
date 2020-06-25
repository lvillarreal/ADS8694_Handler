----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:30:03 06/24/2020 
-- Design Name: 
-- Module Name:    signal_generator - Behavioral 
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


-- BLOQUE PARA PROBAR LA COMUNICACION

entity signal_generator is
    Port ( i_clk 			: 	in  	STD_LOGIC;
           i_rst 			: 	in  	STD_LOGIC;
			  i_start		:	in		STD_LOGIC;
			  o_clk_test	:	out 	STD_LOGIC;
           o_data 		: 	out	STD_LOGIC_VECTOR (15 downto 0);
           o_data_ready : 	out  	STD_LOGIC);
end signal_generator;

architecture Behavioral of signal_generator is

type states is (ini,e0,e1);

-- SIGNAL DEFINITION
signal present_state,next_state : states;
--signal data : integer range 0 to 65535 := 0;
signal data : unsigned(15 downto 0);-- := (others => '0');
signal i : integer range 0 to 100001 := 0;--3125 := 0;
signal clk16 : std_logic := '0';
--signal contador: integer range 0 to 78124 := 0;--Para 312.5khz
signal contador: integer :=0;--range 0 to 156294 := 0;--Para 625khz (tomado del clk que va de entrada a los filtros)
signal s_o_clk_test : std_logic;

-- CONSTANT DEFINITION

--	constant divisor : integer := 3125;	-- para 16 khz
--	constant divisor : integer := 4000;	-- para 12500 khz
--	constant divisor : integer := 8000;	-- para 6250;
--	constant divisor : integer := 9091;	-- para 5500 hz
--	constant divisor : integer := 142857;	-- 350 hz
	constant divisor : integer := 2500;	-- 20 khz


begin

o_data <= std_logic_vector(data);



divisor_frecuencia: process (i_rst, i_clk) 
begin
		if rising_edge(i_clk) then
			if (i_rst = '1') then
				clk16 <= '0';
            contador <= 1;
			else
				if (contador = divisor) then
              clk16 <= NOT(clk16);
              contador <= 1;
				else
			     contador <= contador + 1;
				end if;
			end if;
		end if;
end process;

s_o_clk_test <= clk16;
process(clk16,i_rst,data)is
begin

if rising_edge(clk16) then
	if i_rst = '1' then
		data <= X"0000";
--		s_o_clk_test <= '0';
	elsif data >= 65535 then
		data <= X"0000";
--	elsif i_start = '1' then
--		data <= X"0055";
	else
--		data <= X"0055";
		data <= data + X"0001";
	end if;
end if;
end process;

-- clok de salida para test
o_clk_test <= s_o_clk_test;
--process(i_rst,data)
--begin
--	if i_rst = '1' then
--		s_o_clk_test <= '0';
--	else
--		s_o_clk_test <= not s_o_clk_test;
--	end if;
--end process;


fsm:process(present_state, clk16)is
begin
	case (present_state) is
		when ini =>
			o_data_ready <= '0';
			if clk16 = '1' then
				next_state <= e0;
			else 
				next_state <= ini;
			end if;
			
		when e0 =>
			o_data_ready <= '1';
			next_state <= e1;
		
		when e1 =>
			o_data_ready <= '0';
			if clk16 = '0' then
				next_state <= ini;
			else 
				next_state <= e1;
			end if;
		
	end case;
end process;

p_StateAssignmet :process(i_Clk,i_rst,next_state) is
begin
	if rising_edge(i_Clk) then

		if i_rst = '1' then
			present_state <= ini;
		else
			present_state	<= next_state;
		end if;
	end if;
		
end process;

end Behavioral;

