----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:55:48 04/20/2020 
-- Design Name: 
-- Module Name:    Promedio - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Promedio is
	 generic(
				DATA_WIDTH 		:	integer	:= 18;
				CANT_MUESTRAS	:	integer	:=	2
	 );
    Port ( i_clk 			: 	in		STD_LOGIC;
           i_reset 		: 	in		STD_LOGIC;
           i_data 		:	in		STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  i_data_ready	:	in		STD_LOGIC;
           
			  o_data 		:	out	STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  o_data_ready	:	out	STD_LOGIC
	);
end Promedio;

architecture Behavioral of Promedio is

type states is (s_init, s_e0,s_sumData,s_dataReady);
type ram is array (0 to CANT_MUESTRAS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
-- Signal definition
signal ram_mem : ram;

signal present_state,next_state : states;
signal i 		:	integer range 0 to CANT_MUESTRAS-1;
signal flag,flag1		:	std_logic;

begin

-- count_i contabiliza la cantidad de muestras que llegan
count_i: process(i_clk,i_reset,flag)
begin
	if(rising_edge(i_clk)) then
		if(i_reset = '1') then
			i <= 0;
		elsif(flag = '1') then
			i <= i+1;
		elsif(flag1 = '1') then
			i <= 0;
		end if;
	end if;
end process;

FSM: process(present_state, i_data, i_data_ready,i) is
variable dat_sum	: 	integer range 0 to ((2**DATA_WIDTH)-1)*CANT_MUESTRAS;	

begin
	case(present_state) is
	
		when s_init =>
			flag 	<= '0';
			flag1 <= '0';
			dat_sum := 0;
			o_data_ready <= '0';
			
			if(i_data_ready = '1') then
				next_state <= s_e0;
			elsif(i = CANT_MUESTRAS) then
				next_state <= s_sumData;
			else
				next_state <= s_init;
			end if;
			
		when s_e0 =>
			o_data_ready <= '0';
			flag <= '1';	-- para que en otro proceso incremente i en 1
			flag1 <= '0';
			ram_mem(i) <= i_data;	-- guardo el dato
			next_state <= s_e1;
		
		when s_e1 =>
			o_data_ready <= '0';
			flag <= '0';
			flag1 <= '0';
			if(i_data_ready = '0') then
				next_state <= s_init;
			else
				next_state <= s_e1;
			end if;
			
		when s_sumData =>
			o_data_ready <= '0';
			flag1 <= '1';
			flag <= '0';
			for a in 0 to CANT_MUESTRAS-1 loop
				dat_sum := dat_sum + ram_mem(a);
			end loop;
			o_data <= std_logic_vector(to_unsigned(dat_sum,DATA_WIDTH));
			next_state <= s_dataReady;
			
		when s_dataReady =>
			flag1 <= '0';
			flag 	<= '0';
			o_data_ready <= '1';
			next_state <= s_init;
			
--		when others => next_state <= s_init;
	
	end case;
end process;

p_StateAssignmet: process(i_clk,i_reset, next_state)
begin

	if(rising_edge(i_clk)) then
		if(i_reset = '1') then
			present_state <= s_init;
		else
			present_state <= next_state;
		end if;
	end if;
end process;

end Behavioral;

