--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:37:13 06/21/2020
-- Design Name:   
-- Module Name:   C:/LUCIANO/TESIS/ADS8694_Handler/ADS8694_Handler/ADS8694_Handler/test/pulse_stretcher_tb.vhd
-- Project Name:  ADS8694_Handler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pulse_stretcher
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
 
ENTITY pulse_stretcher_tb IS
END pulse_stretcher_tb;
 
ARCHITECTURE behavior OF pulse_stretcher_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pulse_stretcher
	 GENERIC(
		FREQ_IN	:	integer 	:= 100000000;	-- frecuencia clk in
		FREQ_OUT	:	integer	:=	20000		--	frecuencia clk out
	 );
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         pulse_in : IN  std_logic;
         clk_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal pulse_in : std_logic;

 	--Outputs
   signal clk_o : std_logic;

   -- Clock period definitions
   constant clk_period 	: 	time	:= 10 ns;
	constant delay			:	time	:=	50 us;
	
	CONSTANT FREQ_IN	:	INTEGER	:=	100000000;
	CONSTANT FREQ_OUT	:	INTEGER	:=	20000;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pulse_stretcher 
	GENERIC MAP(
		FREQ_IN 	=> FREQ_IN,
		FREQ_OUT => FREQ_OUT
	)
	PORT MAP (
          clk => clk,
          reset => reset,
          pulse_in => pulse_in,
          clk_o => clk_o
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '1';
		pulse_in <= '0';
      wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		for i in 0 to 5 loop
				pulse_in <= '1';
				wait until rising_edge(clk);
				pulse_in <= '0';
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
								wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
								wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
				wait until rising_edge(clk);
		end loop;
		
		
      -- insert stimulus here 

      wait;
   end process;

END;
