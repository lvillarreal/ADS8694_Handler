--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:34:07 03/23/2020
-- Design Name:   
-- Module Name:   C:/Xilinx/Workspace/ADS8694_v1/test/ADS8694_top_tb.vhd
-- Project Name:  ADS8694_v1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ADS8694_top
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
 
ENTITY ADS8694_top_tb IS
END ADS8694_top_tb;
 
ARCHITECTURE behavior OF ADS8694_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ADS8694_top
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         MISO : IN  std_logic;
         MOSI : OUT  std_logic;
         SCLK : OUT  std_logic;
         CS : OUT  std_logic;
         TX : OUT  std_logic;
         RX : IN  std_logic;
         an : OUT  std_logic_vector(3 downto 0);
         seg : OUT  std_logic_vector(7 downto 0);
         led0 : OUT  std_logic;
         led1 : OUT  std_logic;
         RX_test : OUT  std_logic;
         TX_test : OUT  std_logic;
         sel : IN  std_logic;
         led : OUT  std_logic_vector(7 downto 0);
         sal_test : OUT  std_logic_vector(17 downto 0)
        );
    END COMPONENT;


	COMPONENT uart232
	PORT(
		RXD : IN std_logic;
		CLK : IN std_logic;
		DBIN : IN std_logic_vector(7 downto 0);
		RD : IN std_logic;
		WR : IN std_logic;
		RST : IN std_logic;    
		RDA : INOUT std_logic;
		TBE : INOUT std_logic;      
		TXD : OUT std_logic;
		DBOUT : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

   --Inputs
   signal clk : std_logic;
   signal reset : std_logic;
   signal MISO : std_logic;
   signal sel : std_logic;

 	--Outputs
   signal MOSI : std_logic;
   signal SCLK : std_logic;
   signal CS : std_logic;
   signal s_TX : std_logic;
	signal s_RX : std_logic;
   signal an : std_logic_vector(3 downto 0);
   signal seg : std_logic_vector(7 downto 0);
   signal led0 : std_logic;
   signal led1 : std_logic;
   signal RX_test : std_logic;
   signal TX_test : std_logic;
   signal led : std_logic_vector(7 downto 0);
   signal sal_test : std_logic_vector(17 downto 0);

	signal	DBOUT	:	std_logic_vector(7 downto 0);
	signal	DBIN	:	std_logic_vector(7 downto 0);
	signal	RDA	:	std_logic;
	signal	TBE	:	std_logic;
	signal	RD		:	std_logic;
	signal 	WR		:	std_logic;
	signal   RXD	:	std_logic;
	signal	TXD	:	std_logic;
	
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant SCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ADS8694_top PORT MAP (
          clk => clk,
          reset => reset,
          MISO => MISO,
          MOSI => MOSI,
          SCLK => SCLK,
          CS => CS,
          TX => s_TX,
          RX => s_RX,
          an => an,
          seg => seg,
          led0 => led0,
          led1 => led1,
          RX_test => RX_test,
          TX_test => TX_test,
          sel => sel,
          led => led,
          sal_test => sal_test
        );


	Inst_uart232: uart232 PORT MAP(
		TXD => TXD,
		RXD => RXD,
		CLK => clk,
		DBIN => DBIN,
		DBOUT => DBOUT,
		RDA => RDA,
		TBE => TBE,
		RD => RD,
		WR => WR,
		RST => reset
	);

	s_RX 	<= TXD;
	RXD	<=	s_TX;

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
		reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		DBIN <= X"02";
		RD <= '0';
      wait for clk_period;
		reset <= '0';
		wait for clk_period;
		WR <= '1';
		wait for 2*clk_period;
		WR <= '0';
		
		
		
      -- insert stimulus here 

      wait;
   end process;

END;
