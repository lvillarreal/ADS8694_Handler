--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:51:59 03/22/2020
-- Design Name:   
-- Module Name:   C:/Xilinx/Workspace/ADS8694_v1/test/send_data_test_tb.vhd
-- Project Name:  ADS8694_v1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: send_data_test
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY send_data_test_tb IS
END send_data_test_tb;
 
ARCHITECTURE behavior OF send_data_test_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT send_data_test
    PORT(
         i_clk : IN  std_logic;
         i_rst : IN  std_logic;
         o_data : OUT  std_logic_vector(15 downto 0);
         o_data_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_clk : std_logic := '0';
   signal i_rst : std_logic := '0';

 	--Outputs
   signal o_data : std_logic_vector(15 downto 0);
   signal o_data_ready : std_logic;

   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: send_data_test PORT MAP (
          i_clk => i_clk,
          i_rst => i_rst,
          o_data => o_data,
          o_data_ready => o_data_ready
        );

   -- Clock process definitions
   i_clk_process :process
   begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for i_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
