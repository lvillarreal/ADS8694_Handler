----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:47:21 06/16/2020 
-- Design Name: 
-- Module Name:    data_convert - Behavioral 
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

entity data_convert is
	 GENERIC(
			V_FS : integer := 167772	-- valor de fondo de escala, en representacion fixdt(1,4,14), en este caso 10.24*2^14 
	 );
    Port ( clk_i 		: 	in  	STD_LOGIC;
           reset_i 	: 	in  	STD_LOGIC;
           data_i 	: 	in  	STD_LOGIC_VECTOR (17 downto 0);
			  data_i_en	:	in		STD_LOGIC;
           data_o 	: 	out  	STD_LOGIC_VECTOR (18 downto 0);
			  data_o_en	:	out	STD_LOGIC
	 );
end data_convert;

architecture Behavioral of data_convert is

type state is (s_ini,e0,e1);

-- CONSTANT DEFINITION
constant c_vfs : signed(18 downto 0) := to_signed(V_FS,19);

-- SIGNAL DEFINITION

signal present_state, next_state : state;

signal s_data_in 	:	signed(18 downto 0);
signal s_data_out :	signed(
begin

s_data_in <= '0' & signed(data_in);

fsm	:process(present_state, data_i_en)
begin

case present_state is
	when s_ini => 
		data_o <= (others => '0');
		data_o_en <= '0';
		next_state <= e0;
	
	when e0 =>
		data_o_en <= '0';
		if(data_i_en = '1') then
			next_state <= e1;
		else
			next_state <= e0;
		end if;
	
	when e1 =>
		
		
	
	when others => next_state <= e0;
end case;

end process;


p_StateAssignmet :process(clk_i,reset_i,next_state) is
begin
	if rising_edge(clk_i) then
		if reset_i = '1' then
			present_state <= s_ini;
		else
			present_state <= next_state;
		end if;
	end if;
		
end process;

end Behavioral;

