----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:43:36 11/06/2012 
-- Design Name: 
-- Module Name:    fsm_tx - Behavioral 
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

entity fsm_tx4 is
    Port ( clk 	: in  STD_LOGIC;
           rst 	: in  STD_LOGIC;
           tbe 	: in  STD_LOGIC;
			  wr_i	: in	STD_LOGIC;	-- indica que el dato en la entrada esta disponible	
			  
			  sel : out std_logic_vector(1 downto 0);
			  wr 	: out  STD_LOGIC
			  
			  );
end fsm_tx4;

architecture Behavioral of fsm_tx4 is

type state_type is (ini,w0,w1,w2); 

signal present_state,next_state    	: state_type;
signal rst_c,over,inc_c,rst_o			: std_logic;
signal cuenta								: unsigned(1 downto 0);
signal cuenta_o							: unsigned(22 downto 0);


begin
proc_1: process(present_state,tbe,cuenta,over,wr_i)
begin 
   case present_state is
--Reset state
       	when ini =>
			rst_c <= '1';
			inc_c <= '0';
			wr  <= '0';
			rst_o <= '1';
					next_state <= w0;
         when w0 =>
			rst_c <= '0';
			inc_c <= '0';
			wr  <= '0';
			rst_o <= '0';
			
				if (tbe='1' and wr_i = '1' ) then
					next_state 	<= w1;
				else
					next_state 	<= w0;
				end if;
			when  w1 =>
			rst_c <= '0';
			inc_c <= '1';
			wr  <= '1';
			rst_o <= '0';
				if cuenta ="00" then
					next_state <= w2;	
				else
					next_state <= w0;	
				end if;
			
			when w2 =>
			rst_c <= '0';
			inc_c <= '0';
			wr  <= '0';
			rst_o <= '0';
				if (over = '1') then 
					next_state <= ini;
				else
					next_state <= w2;
				end if;
								
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
process(clk)
begin

if (clk'event and clk='1') then
	if (rst= '1' or rst_o = '1')	 then
		cuenta_o <=( others => '0');
	else
		cuenta_o <= cuenta_o +1;
	end if;
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

