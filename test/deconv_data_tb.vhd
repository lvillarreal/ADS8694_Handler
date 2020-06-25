--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:36:48 06/24/2020
-- Design Name:   
-- Module Name:   C:/LUCIANO/TESIS/ADS8694_Handler/ADS8694_Handler/ADS8694_Handler/test/deconv_data_tb.vhd
-- Project Name:  ADS8694_Handler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: data_convert
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
 
ENTITY deconv_data_tb IS
END deconv_data_tb;
 
ARCHITECTURE behavior OF deconv_data_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
 	COMPONENT deconv_data
	PORT(
		clk_i : IN std_logic;
		reset_i : IN std_logic;
		data_i : IN std_logic_vector(18 downto 0);
		data_i_en : IN std_logic;          
		data_o : OUT std_logic_vector(17 downto 0);
		data_o_en : OUT std_logic
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
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal data_i : std_logic_vector(17 downto 0) := (others => '0');
   signal data_i_en : std_logic := '0';

 	--Outputs
   signal data_o : std_logic_vector(18 downto 0);
   signal data_o_en : std_logic;
	
	signal data_deconv_o	:	std_logic_vector(17 downto 0);
	signal data_deconv_o_en	:	std_logic;
   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
 	type IntFile is file of integer;	
	file f_resul : IntFile;
	file f_data : IntFile;
	file f_readed:	IntFile;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: data_convert PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          data_i => data_i,
          data_i_en => data_i_en,
          data_o => data_o,
          data_o_en => data_o_en
        );

	uut1: deconv_data PORT MAP(
		clk_i => clk_i,
		reset_i => reset_i,
		data_i => data_o,
		data_i_en => data_o_en,
		data_o => data_deconv_o,
		data_o_en => data_deconv_o_en
	);

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		--variable l      : line;
      variable status : file_open_status;
		variable status2 : file_open_status;
		variable status3 : file_open_status;
		variable i : integer;
   begin		
		file_open(status,f_resul,"ADS8694_Handler/test/Matlab/resul_deconv_data.bin",write_mode);
      assert status=open_ok
		report "No se pudo crear resul_iir.bin"
		severity failure;
		
	   file_open(status2,f_data,"ADS8694_Handler/test/Matlab/data.bin",read_mode);
      assert status2=open_ok
		report "No se pudo abrir data.bin"
		severity failure;
		
		file_open(status3,f_readed,"ADS8694_Handler/test/Matlab/data_conv_salida.bin",write_mode);
      assert status2=open_ok
		report "No se pudo abrir data_conv_salida.bin"
		severity failure;
		
		-- hold reset state for 100 ns.
      wait for 100 ns;
		reset_i <= '1';
		wait until rising_edge(clk_i);
		reset_i <= '0';
		wait until rising_edge(clk_i);
		

		while not EndFile(f_data) loop
			Read(f_data,I);
			--readline(f_data,l);
         -- Acá extraemos lo que queremos de la línea
         --read(l,i);
			
			--filter_in <= std_logic_vector(to_signed(i,19));
			data_i <= std_logic_vector(to_unsigned(i,18));
			data_i_en <= '1';
			
			wait until rising_edge(clk_i);

			--wait until rising_edge(clk_100);
			--wait until rising_edge(clk_100);
			data_i_en <= '0';
			wait until rising_edge(clk_i);

			write(f_resul,to_integer(unsigned(data_deconv_o)));
			write(f_readed,to_integer(signed(data_o)));
		end loop;
		File_Close(f_data);
		File_Close(f_resul);
		File_Close(f_readed);
      -- insert stimulus here 

      wait;
   end process;

END;
