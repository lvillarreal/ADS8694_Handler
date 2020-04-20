----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:45:39 07/31/2012 
-- Design Name: 
-- Module Name:    fsm_rx - Behavioral 
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

entity fsm_rx4 is
port (
   clk			: in std_logic;
	rst			: in std_logic;
	rda			: in std_logic;
	rd				: out std_logic;
	new4			: out std_logic;
	data_av		: out std_logic;	-- data available
	sel			: out std_logic_vector(1 downto 0)
	 );

end fsm_rx4;

architecture Behavioral of fsm_rx4 is

type state_type is (ini,r0,r1,r2,r3); 
signal present_state,next_state    : state_type;

signal inc_c,rst_c		: std_logic;
signal rst_o,over			: std_logic;
signal cuenta				: unsigned(1 downto 0);
signal cuenta_o			: unsigned(22 downto 0);


begin
proc_1: process(present_state,rda,over,cuenta)
begin 
   case present_state is
--Reset state
       	when ini =>
			data_av <= '0';
			rd 	<= '0';
			rst_c	<= '1';
			rst_o	<= '1';
			inc_c	<= '0';
			new4	<= '0';
			next_state <= r0;
         
       	when r0 =>
			rd 	<= '0';
			rst_c	<= '0';
			rst_o	<= '0';
			inc_c	<= '0';
			new4	<= '0';
			if over = '1' then
					next_state <= ini;
			elsif (rda ='1') then
					next_state 	<= r1;
			else 
					next_state 	<= r0;
			end if;
			
			when  r1 =>
			rd 	<= '1';
			data_av <= '1';
			rst_c	<= '0';
			rst_o	<= '0';
			inc_c	<= '1';
			new4	<= '0';
				if cuenta= "00" then
					next_state <= r2;	
				else
					next_state <= r0;
				end if;
			
			when r2 =>
			data_av <= '0';
			rd 	<= '0';
			rst_c	<= '0';
			rst_o	<= '0';
			inc_c	<= '0';
			new4	<= '0';
			
				next_state <= r3; 
			
			when r3 =>
			rd 	<= '0';
			rst_c	<= '0';
			rst_o	<= '0';
			inc_c	<= '0';
			new4	<= '1';
			
			next_state <= ini; 
			
			
       end case;
    end process proc_1;

proc_2: process(CLK,next_state,rst)
    begin
        if (CLK'event and CLK='1') then
			if rst='1' then
				present_state <= ini;
			else
            present_state <= next_state;
        end if;
    end if;
	 end process proc_2;


--Proceso para overtime
process(clk,rst_o)
begin
if rst_o= '1' then
	cuenta_o <=( others => '0');
elsif (clk'event and clk='1') then
	cuenta_o <= cuenta_o +1;
end if;
end process;
over <= '1' when cuenta_o >=   "10000000000000000000000" else '0';

-- proceso para selccionar el lugar del byte recibido dentro de la palabra

process(clk)
begin
	if (clk'event and clk='1' ) then
		if (rst= '1' or rst_c='1') then
			cuenta <=( others => '0');
		elsif  inc_c ='1' then
			cuenta <= cuenta +1;
		end if;
end if;
end process;

sel <= std_logic_vector( cuenta);



end Behavioral;