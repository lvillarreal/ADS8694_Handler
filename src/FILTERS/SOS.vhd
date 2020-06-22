----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:17 06/16/2020 
-- Design Name: 
-- Module Name:    SOS - Behavioral 
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


-- SECOND ORDER SECTION BLOCK
--        |
--  x[n]--|--w1--(+)---
--
--
--
--
--
--
--
--
--
--



entity SOS is
-- 32 bits, 1 signo, 2 parte entera, 29 parte decimal
	 generic(
		b0	:	signed(31 downto 0) := "00100000000000000000000000000000";
		b1	:	signed(31 downto 0) := "01000000000000000000000000000000";
		b2	:	signed(31 downto 0) := "00100000000000000000000000000000";
		a1	:	signed(31 downto 0) := "11000000001000101011101011011111";
		a2	:	signed(31 downto 0) := "00011111110111100011000001001001";
		g	:	signed(31 downto 0) := "00000000000000000011101011001010"
	 );
    Port ( clk     		: 	in  	STD_LOGIC;
           reset   		: 	in  	STD_LOGIC;
           data_i 		: 	in  	STD_LOGIC_VECTOR (17 downto 0);
           data_o  		: 	out 	STD_LOGIC_VECTOR (18 downto 0);
			  data_o_en		:	out 	STD_LOGIC
	);
end SOS;

architecture Behavioral of SOS is

-- SIGNAL DEFINITION
type ram_array is array (0 to 2) of signed(39 downto 0);

signal delay : ram_array;

signal w1  : signed(18 downto 0);
signal w2  : signed(39 downto 0);
signal w3  : signed(39 downto 0);
signal w4  : signed(39 downto 0);
signal w5  : signed(39 downto 0);
signal w6  : signed(39 downto 0);
signal w7  : signed(39 downto 0);
signal w8  : signed(39 downto 0);
signal w9  : signed(39 downto 0);
signal w10 : signed(39 downto 0);
signal w11 : signed(39 downto 0);
signal w12 : signed(39 downto 0);
signal w13 : signed(18 downto 0);
--signal w13 : signed(39 downto 0);


begin


--process(clk, reset,w2)
--begin
--	if rising_edge(clk)then
--		if (reset <= '1') then
--			w3 <= to_signed(0,40);
--			w6 <= to_signed(0,40);
--			data_o <= (others => '0');
--		else
--			w3 <= w2;
--			w6 <= w3;
--			data_o <= std_logic_vector(w13);
--		end if;
--	end if;
--end process;




w1 <= signed('0'&data_i);
w2 <= w5 + w1;
w3 <= delay(1);
w4 <= shift_right(a1*w3,29)(39 downto 0);
w6 <= delay(2);
w7 <= shift_right(a2*w6,29)(39 downto 0);
w5 <= w4 + w7;
--
w8  <= shift_right(b2*w6,29)(39 downto 0);
w9  <= shift_right(b1*w3,29)(39 downto 0);
w10 <= w9 + w8;
w11 <= shift_right(b0*w2,29)(39 downto 0); 
w12 <= w11 + w10;
w13 <= shift_right(w12*g,29)(18 downto 0);

data_o_en <= clk;
--
filt:process(clk,reset)
begin
--
	if rising_edge(clk) then
		if(reset = '1') then
			
			delay(0) <= (others => '0');
			delay(1) <= (others => '0');
			delay(2) <= (others => '0');
		else
			
			delay(0) <= w2;
			delay(1) <= delay(0);
			delay(2) <= delay(1);
--			
--	
			data_o <= std_logic_vector(w13);
		end if;
	end if;

end process;




end Behavioral;

