--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:41:45 06/16/2020
-- Design Name:   
-- Module Name:   C:/LUCIANO/TESIS/ADS8694_Handler/ADS8694_Handler/ADS8694_Handler/test/fixed_test.vhd
-- Project Name:  ADS8694_Handler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SOS
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
library std;
use std.textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY fixed_test IS
END fixed_test;
 
ARCHITECTURE behavior OF fixed_test IS 
 
 signal clk : std_logic;
    -- Component Declaration for the Unit Under Test (UUT)


constant c_vfs : signed(18 downto 0) := to_signed(167772,19);
constant clk_period : time := 10 ns;

		 signal s_mult		:	signed(36 downto 0);
		 signal s_sum		:	signed(19 downto 0);
		 signal data_i		:	std_logic_vector(18 downto 0);
		 signal s_data_i 	:	signed(18 downto 0) := to_signed(-135243,19);
 begin

 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


--    Stimulus process
   stim_proc: process

	begin
		
		wait until rising_edge(clk);

--		s_mult1 <= 
--		s_data_o <= std_logic_vector(s_mult(18 downto 0) - c_vfs);

		

      wait;
   end process;

		
		--s_data_i <=  signed(data_i);
		process(clk)
		begin
			if(rising_edge(clk))then
				s_sum  <= (s_data_i+c_vfs);
				s_mult <= s_sum & (others => '0');
			end if;
		end process;

END;
