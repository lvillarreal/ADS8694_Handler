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
library std;
use std.textio.all;
USE ieee.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY send_data_test_tb IS
END send_data_test_tb;
 
ARCHITECTURE behavior OF send_data_test_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT send_data_test
	 GENERIC(
		N : integer := 200);
	PORT(
		i_clk 			:	IN std_logic;
		i_rst 			:	IN std_logic;  
		i_start 			: 	IN std_logic;	
		o_clk_test		:	out std_logic;
		o_data 			: 	OUT std_logic_vector(17 downto 0);
		o_data_ready 	:	OUT std_logic
		);
	END COMPONENT;
    

   --Inputs
   signal s_clk : std_logic := '0';
   signal s_rst : std_logic := '0';

 	--Outputs
   signal s_o_data : std_logic_vector(17 downto 0);
   signal s_o_data_ready : std_logic;

   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
 	type IntFile is file of integer;	
	file f_resul : IntFile;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: send_data_test 
	GENERIC MAP (
		N => 200
	)
	PORT MAP (
          i_clk => s_clk,
          i_rst => s_rst,
          o_data => s_o_data,
			 i_start => '1',
          o_data_ready => s_o_data_ready
        );

   -- Clock process definitions
   i_clk_process :process
   begin
		s_clk <= '0';
		wait for i_clk_period/2;
		s_clk <= '1';
		wait for i_clk_period/2;
   end process;
 
process(s_o_data_ready)

      variable status : file_open_status;
begin
		
		if rising_edge(s_o_data_ready) then
			file_open(status,f_resul,"C:/Users/lucia/OneDrive/Documentos/send_data_test_file.bin",append_mode);
			assert status=open_ok
			report "No se pudo crear send_data_test_file.bin"
			severity failure;
			write(f_resul,to_integer(unsigned(s_o_data)));
			
			File_Close(f_resul);
		end if;
		
end process;


--   Stimulus process
   stim_proc: process
		
   begin		
		
	
      --hold reset state for 100 ns.
      s_rst <= '1';
		wait for 100 ns;	
		s_rst <= '0';
      wait for 1000 ms;

      -- insert stimulus here 

      wait;
   end process;

END;
