--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:37:18 06/16/2020
-- Design Name:   
-- Module Name:   C:/LUCIANO/TESIS/ADS8694_Handler/ADS8694_Handler/ADS8694_Handler/test/iir_tb.vhd
-- Project Name:  ADS8694_Handler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: filter
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
 
ENTITY iir_tb IS
END iir_tb;
 
ARCHITECTURE behavior OF iir_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT filter
    PORT(
         clk : IN  std_logic;
         clk_enable : IN  std_logic;
         reset : IN  std_logic;
         filter_in : IN  std_logic_vector(18 downto 0);
         filter_out : OUT  std_logic_vector(18 downto 0)
        );
    END COMPONENT;
    
    COMPONENT data_convert
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         data_i : IN  std_logic_vector(17 downto 0);
         data_i_en : IN  std_logic;
         data_o : OUT  std_logic_vector(18 downto 0);
         data_o_en : OUT  std_logic
        );
    END COMPONENT;


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

	signal clk_100 : std_logic := '0';
	signal clk_20  : std_logic := '0';

   --Inputs
	signal clk_filter : std_logic := '0';
   signal clk_enable : std_logic := '0';
   signal reset : std_logic := '0';
   signal filter_in : std_logic_vector(18 downto 0) := (others => '0');
	
	signal data_i : std_logic_vector(17 downto 0) := (others => '0');
 	signal data_i_en : std_logic := '0';

	
	--Outputs
   signal filter_out : std_logic_vector(18 downto 0);
	
	signal data_o : std_logic_vector(18 downto 0);
	signal data_o_en : std_logic;
	
	signal pulse_in,clk_o : std_logic;
	
   -- Clock period definitions
   constant clk100mhz : time := 10 ns;	-- 100mhz
	constant clk20khz : time := 50 us;		-- 20 khz
   constant espera	:	time	:=	5 us;
	
	type IntFile is file of integer;	
	file f_resul : IntFile;
	file f_data : IntFile;
	file f_readed : IntFile;
   --file f : IntFile;
BEGIN
 

   -- Clock process definitions
   clk_process :process
   begin
		clk_100 <= '0';
		wait for clk100mhz/2;
		clk_100 <= '1';
		wait for clk100mhz/2;
   end process;
	
	   clk_process1 :process
   begin
		clk_20 <= '0';
		wait for clk20khz/2;
		clk_20 <= '1';
		wait for clk20khz/2;
   end process;
 
 	-- Instantiate the Unit Under Test (UUT)
   uut3: pulse_stretcher 
	GENERIC MAP(
		FREQ_IN 	=> FREQ_IN,
		FREQ_OUT => FREQ_OUT
	)
	PORT MAP (
          clk => clk_100,
          reset => reset,
          pulse_in => pulse_in,
          clk_o => clk_o
        );
 
	-- Instantiate the Unit Under Test (UUT)
   uut: filter PORT MAP (
          clk => clk_filter,
          clk_enable => clk_enable,
          reset => reset,
          filter_in => filter_in,
          filter_out => filter_out
        );

 
 	-- Instantiate the Unit Under Test (UUT)
   uut1: data_convert PORT MAP (
          clk_i => clk_100,
          reset_i => reset,
          data_i => data_i,
          data_i_en => data_i_en,
          data_o => data_o,
          data_o_en => data_o_en
        );
 

 
  filter_in <= data_o;
  clk_filter <= clk_o;
  pulse_in <= data_o_en;
  
  
   -- Stimulus process
   stim_proc: process
		variable l      : line;
      variable status : file_open_status;
		variable status2 : file_open_status;
		variable status3 : file_open_status;
		variable i : integer;
		
   begin		
		file_open(status,f_resul,"ADS8694_Handler/test/Matlab/resul_iir.bin",write_mode);
      assert status=open_ok
		report "No se pudo crear resul_iir.bin"
		severity failure;
		
	   file_open(status2,f_data,"ADS8694_Handler/test/Matlab/data.bin",read_mode);
      assert status2=open_ok
		report "No se pudo abrir data.txt"
		severity failure;
		
		file_open(status,f_readed,"ADS8694_Handler/test/Matlab/data_readed.bin",write_mode);
      assert status3=open_ok
		report "No se pudo crear data_readed.bin"
		severity failure;
		
		-- hold reset state for 100 ns.
      wait for 100 ns;
		clk_enable <= '1';
		reset <= '1';
		wait until rising_edge(clk_100);
		reset <= '0';
		wait until rising_edge(clk_100);
		
		
		while not EndFile(f_data) loop
			Read(f_data,I);
			--readline(f_data,l);
         -- Acá extraemos lo que queremos de la línea
         --read(l,i);
			
			--filter_in <= std_logic_vector(to_signed(i,19));
			data_i <= std_logic_vector(to_unsigned(i,18));
			data_i_en <= '1';
			
			wait until rising_edge(clk_100);
			--wait until rising_edge(clk_100);
			--wait until rising_edge(clk_100);
			data_i_en <= '0';
			wait until rising_edge(clk_20);

			write(f_resul,to_integer(signed(filter_out)));
			write(f_readed,to_integer(signed(data_i)));
		end loop;
		File_Close(f_data);
		File_Close(f_resul);
		File_Close(f_readed);
		
		
	
      -- insert stimulus here 

      wait;
   end process;

END;
