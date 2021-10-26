
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Bloque que se utiliza para generar el clock del filtro pasa bajos IIR

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


	type state is (e0,e1,e2);
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
		next_state <= e2;
				
	when e2 =>
		s_clk_o <= '1';
		if(i = divisor) then
			next_state <= e0;
		else 
			next_state <= e2;
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

