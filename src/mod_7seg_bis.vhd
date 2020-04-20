----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:43:54 05/12/2013 
-- Design Name: 
-- Module Name:    mod_7seg_bis - Behavioral 
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
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity mod_7seg_bis is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           dat1_in : in  STD_LOGIC_VECTOR (15 downto 0);
           dat_out : out  STD_LOGIC_VECTOR (7 downto 0);
           an0 : out  STD_LOGIC;   --digito mas sign
           an1 : out  STD_LOGIC;
           an2 : out  STD_LOGIC;
           an3 : out  STD_LOGIC);
end mod_7seg_bis;

architecture Behavioral of mod_7seg_bis is
attribute clock_signal : string;


signal cuenta_aux 	: unsigned(16 downto 0);
signal dat_aux   : std_logic_vector(32 downto 0);
signal an0_aux,an1_aux,an2_aux,an3_aux : std_logic;
signal fin_cuenta	: std_logic;
--attribute clock_signal of clk_aux : signal is "yes";
constant 	divisor_clk : unsigned(16 downto 0):= "11000011010100000" ;


begin

-- divisor de frecuencia 
process(rst,clk)
begin
if(clk'event and clk='1') then
	if rst='1' then
			cuenta_aux <= (others => '0');
			fin_cuenta <= '0';
	elsif cuenta_aux=divisor_clk then 
			cuenta_aux <= (others => '0');
			fin_cuenta <= '1';
	else
			cuenta_aux <= cuenta_aux +1;
			fin_cuenta <= '0';
				end if;
end if;
end process;
--process(fin_cuenta,clk,rst)
--begin
--if(clk'event and clk='1' ) then
--	if rst='1' then
--			clk_aux   <= '0';
--	elsif fin_cuenta='1' then 
--			clk_aux <= not clk_aux;
--	end if;
--end if;
--end process;


-- proceso de refresco
process(clk,rst,dat_aux,fin_cuenta)
begin

		if(rst='1') then
				an3_aux <= '0';
				an2_aux <= '1';
				an1_aux <= '1';
				an0_aux <= '1';
				dat_out <= dat_aux(31 downto 24);
		elsif (clk'event and clk='1' and fin_cuenta='1') then
		
			if(an3_aux = '0') then
				an3_aux <= '1';
				an2_aux <= '0';
				an1_aux <= '1';
				an0_aux <= '1';
				dat_out <= dat_aux(23 downto 16);
			elsif(an2_aux = '0') then
				an3_aux <= '1';
				an2_aux <= '1';
				an1_aux <= '0';
				an0_aux <= '1';
				dat_out <= dat_aux(15 downto 8);
			elsif(an1_aux = '0') then
				an3_aux <= '1';
				an2_aux <= '1';
				an1_aux <= '1';
				an0_aux <= '0';
				dat_out <= dat_aux(7 downto 0);
			else
				an3_aux <= '0';
				an2_aux <= '1';
				an1_aux <= '1';
				an0_aux <= '1';
				dat_out <= dat_aux(31 downto 24);
			end if;
		end if;

end process;
an0 <= an0_aux;
an1 <= an1_aux;
an2 <= an2_aux;
an3 <= an3_aux;
	

-- tabla de conversion

dat_aux(31 downto 24) <= "00000011" when dat1_in(15 downto 12) = x"0" else   
								 "10011111" when dat1_in(15 downto 12) = x"1" else
								 "00100101" when dat1_in(15 downto 12) = x"2" else
								 "00001101" when dat1_in(15 downto 12) = x"3" else
								 "10011001" when dat1_in(15 downto 12) = x"4" else
								 "01001001" when dat1_in(15 downto 12) = x"5" else
								 "01000001" when dat1_in(15 downto 12) = x"6" else
								 "00011111" when dat1_in(15 downto 12) = x"7" else
								 "00000001" when dat1_in(15 downto 12) = x"8" else
								 "00001001" when dat1_in(15 downto 12) = x"9" else
								 "00010001" when dat1_in(15 downto 12) = x"A" else
								 "11000001" when dat1_in(15 downto 12) = x"B" else
								 "01100011" when dat1_in(15 downto 12) = x"C" else
								 "10000101" when dat1_in(15 downto 12) = x"D" else
								 "01100001" when dat1_in(15 downto 12) = x"E" else
								 "01110001";

dat_aux(23 downto 16) <= "00000011" when dat1_in(11 downto 8) = x"0" else   
								 "10011111" when dat1_in(11 downto 8) = x"1" else
								 "00100101" when dat1_in(11 downto 8) = x"2" else
								 "00001101" when dat1_in(11 downto 8) = x"3" else
								 "10011001" when dat1_in(11 downto 8) = x"4" else
								 "01001001" when dat1_in(11 downto 8) = x"5" else
								 "01000001" when dat1_in(11 downto 8) = x"6" else
								 "00011111" when dat1_in(11 downto 8) = x"7" else
								 "00000001" when dat1_in(11 downto 8) = x"8" else
								 "00001001" when dat1_in(11 downto 8) = x"9" else
								 "00010001" when dat1_in(11 downto 8) = x"A" else
								 "11000001" when dat1_in(11 downto 8) = x"B" else
								 "01100011" when dat1_in(11 downto 8) = x"C" else
								 "10000101" when dat1_in(11 downto 8) = x"D" else
								 "01100001" when dat1_in(11 downto 8) = x"E" else
								 "01110001";	

								 
dat_aux(15 downto 8) <= "00000011" when dat1_in(7 downto 4) = x"0" else   
								 "10011111" when dat1_in(7 downto 4) = x"1" else
								 "00100101" when dat1_in(7 downto 4) = x"2" else
								 "00001101" when dat1_in(7 downto 4) = x"3" else
								 "10011001" when dat1_in(7 downto 4) = x"4" else
								 "01001001" when dat1_in(7 downto 4) = x"5" else
								 "01000001" when dat1_in(7 downto 4) = x"6" else
								 "00011111" when dat1_in(7 downto 4) = x"7" else
								 "00000001" when dat1_in(7 downto 4) = x"8" else
								 "00001001" when dat1_in(7 downto 4) = x"9" else
								 "00010001" when dat1_in(7 downto 4) = x"A" else
								 "11000001" when dat1_in(7 downto 4) = x"B" else
								 "01100011" when dat1_in(7 downto 4) = x"C" else
								 "10000101" when dat1_in(7 downto 4) = x"D" else
								 "01100001" when dat1_in(7 downto 4) = x"E" else
								 "01110001";		

dat_aux(7 downto 0) <= "00000011" when dat1_in(3 downto 0) = x"0" else   
								 "10011111" when dat1_in(3 downto 0) = x"1" else
								 "00100101" when dat1_in(3 downto 0) = x"2" else
								 "00001101" when dat1_in(3 downto 0) = x"3" else
								 "10011001" when dat1_in(3 downto 0) = x"4" else
								 "01001001" when dat1_in(3 downto 0) = x"5" else
								 "01000001" when dat1_in(3 downto 0) = x"6" else
								 "00011111" when dat1_in(3 downto 0) = x"7" else
								 "00000001" when dat1_in(3 downto 0) = x"8" else
								 "00001001" when dat1_in(3 downto 0) = x"9" else
								 "00010001" when dat1_in(3 downto 0) = x"A" else
								 "11000001" when dat1_in(3 downto 0) = x"B" else
								 "01100011" when dat1_in(3 downto 0) = x"C" else
								 "10000101" when dat1_in(3 downto 0) = x"D" else
								 "01100001" when dat1_in(3 downto 0) = x"E" else
								 "01110001";		
								 
end Behavioral;

