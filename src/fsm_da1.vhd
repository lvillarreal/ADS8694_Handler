----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    20:00:15 12/14/2012
-- Design Name:
-- Module Name:    fsm_da1 - Behavioral
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

entity fsm_ad8694 is
    generic (
          MISO_width : integer := 18;
          MOSI_width : integer := 16
    );
    Port ( clk 	    	:	in  STD_LOGIC;
           reset 	    	:	in  STD_LOGIC;
			  data_in		: 	in  STD_LOGIC_VECTOR (MOSI_width-1 downto 0);  -- dato que se desea transmitir por spi
           MISO		  	: 	IN std_logic;
			  start	  		: 	IN std_logic;

           busy     		:   out std_logic;  -- indica que el modulo esta ocupado
			  MOSI		  	: 	out std_logic;
			  data_out 	  	: 	out  STD_LOGIC_VECTOR (MISO_width-1 downto 0);   -- dato recibido por spi
			  fin		  		: 	out  std_logic;                         -- flag que indica que termino el ciclo de envio+recepcion
           cs		    	: 	out  STD_LOGIC;
			  sclk     		: 	out  std_logic
           );

end fsm_ad8694;

architecture Behavioral of fsm_ad8694 is
type 		state_type is (ini,e0,e1,e2,e3,e4);
signal 	present_state,next_state   : state_type;
signal 	i				: integer range 0 to 35;
signal 	dato_aux    : std_logic_vector(15 downto 0);
signal 	dato_out    : std_logic_vector(17 downto 0);
signal	cnt_rst		: std_logic;


begin
dato_aux<= data_in;
sclk <=  clk;

--Dato que se va a enviar al conversor

proc_1: process(present_state,i,start,dato_aux,dato_out)
	 begin
     case present_state is
       	when ini =>     --Reset state
					cs <='1';
					cnt_rst <='1';
					fin<='0';
					busy <= '0';
					if start= '1' then
						next_state <= e0;
					else
						next_state <= ini;
					end if;
-- start conversion
        when e0 =>
					cs <='1';
					cnt_rst <='1';
					fin<='0';
					busy <= '1';
					next_state <= e1;

--
        when e1 =>
					busy <= '1';
					cs <='0';
					cnt_rst <='0';
					fin<='0';
					MOSI <= dato_aux(15-i);

					if i=15 then
						next_state <= e2;
					else
						next_state <= e1;
					end if;
        
		  when e2 =>
					busy <= '1';
					cs <='0';
					cnt_rst <='0';

					fin<='0';
					if i=33 then
						next_state <= e3;
					else
						next_state <= e2;
					end if;

        when e3 =>
					cs <= '1';
					next_state <= e4;

       when e4 =>
					cs <='1';
					cnt_rst <='1';
					fin<='1';
					busy <= '0';
					data_out<= dato_out;
					next_state <= ini;
		 
		 when others => next_state <= ini;
		
     end case;
end process proc_1;


proc_2: process(CLK,reset, next_state)  -- update the state of FSM
    begin
    if (CLK'event and CLK='1') then
		if reset ='1' then
			present_state<= ini;
		else
          present_state <= next_state;
		end if;
	 end if;
end process proc_2;


-- set value for sync
proc_3: process(CLk, reset,present_state,cnt_rst,i)  -- update the state of FSM
    begin
    if (CLK'event and CLK='1') then
		if cnt_rst='1' then
			i<=0;
		elsif i=34 then
			i<=0;
		elsif (present_state=e0 or present_state=e1 or present_state=e2) then
			i<=i+1;
		end if;
	end if;
end process proc_3;

proc_5:process(clk, reset,i,MISO,present_state)
begin
	if falling_edge(clk) then
		if reset='1' then
		dato_out <= (others =>'0');
		elsif present_state=e2 then
		dato_out(33-i)<= MISO ;
		end if;
	end if;
end process;

end Behavioral;
