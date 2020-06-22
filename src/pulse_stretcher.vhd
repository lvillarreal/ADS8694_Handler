----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:03:25 06/21/2020 
-- Design Name: 
-- Module Name:    pulse_stretcher - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulse_stretcher is
	 generic(
		FREQ_IN	:	integer 	:= 100000000;	-- frecuencia clk in
		FREQ_OUT	:	integer	:=	20000		--	frecuencia clk out
	 );
    Port ( clk   		: 	in  STD_LOGIC;
           reset 		: 	in  STD_LOGIC;
           pulse_in	:	in	 STD_LOGIC;
			  clk_o 		: 	out  STD_LOGIC
	 );
end pulse_stretcher;

architecture Behavioral of pulse_stretcher is

	constant divisor	:	integer := FREQ_IN/(FREQ_OUT*2);


	type state is (e0,e1);
	signal present_state, next_state : state;
	
	signal	s_pulse_in	:	std_logic;
	signal	s_clk_o 		: 	std_logic 	:= '0';
	signal	i				:	integer		:=	0;
	
begin
cnt	:process(clk,reset,present_state)
begin
	if rising_edge(clk) then
		if(present_state = e0) then
			i <= 0;
		else
			i <= i+1;
		end if;
	end if;
end process;
	
fsm	:process(present_state, s_pulse_in,i)
begin

case present_state is
	
	when e0 =>
		s_clk_o <= '0';
		if(s_pulse_in = '1') then
			next_state <= e1;
		else
			next_state <= e0;
		end if;
	
	when e1 =>
		s_clk_o <= '1';
		if(i = divisor) then
			next_state <= e0;
		else 
			next_state <= e1;
		end if;
		
	when others => next_state <= e0;
end case;


end process;


p_StateAssignmet :process(clk,reset,next_state) is
begin
	if rising_edge(clk) then
		if reset = '1' then
			present_state <= e0;
		else
			present_state <= next_state;
		end if;
	end if;
end process;

s_pulse_in <= pulse_in;
clk_o <= s_clk_o;

end Behavioral;

