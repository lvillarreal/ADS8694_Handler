----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:32:55 06/24/2020 
-- Design Name: 
-- Module Name:    deconv_data - Behavioral 
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


-- Bloque que se utiliza para redimensionar el rango del dato.
-- Si se envía en formato fixdt(1,19,14), se están desperdiciando bits
-- ya que el rango es de [-16,16) y el dato como máximo será de 10.24

-- V_in = V_ADC * Vmax * 2^-17 - Vmax

-- La entrada al bloque deconv_data será v_in (que es la salida del bloque data_conv)
-- Por lo tanto
-- V_ADC = (V_in+V_max)*2^17/V_max
entity deconv_data is
	 GENERIC(
			V_FS : integer := 167772	-- valor de fondo de escala, en representacion fixdt(1,19,14), en este caso 10.24*2^14 
	 );
    Port ( clk_i 		: in  STD_LOGIC;
           reset_i 		: in  STD_LOGIC;
           data_i 	: in  STD_LOGIC_VECTOR (18 downto 0);
           data_i_en : in  STD_LOGIC;
           data_o 	: out STD_LOGIC_VECTOR (17 downto 0);
           data_o_en : out	STD_LOGIC);
end deconv_data;

architecture Behavioral of deconv_data is

type state is (e0,e1,e2,e3);--,e4,e5,e6);

-- CONSTANT DEFINITION
constant c_vfs : signed(19 downto 0) := to_signed(V_FS,20);	--  V_max
constant coef  : signed(18 downto 0)  := to_signed(12800,19);	-- (2^17*2^14)/V_max, luego se divide por 2^14
-- SIGNAL DEFINITION

signal present_state, next_state : state;

signal s_data_i 	:	signed(18 downto 0);
signal s_sum1		:	signed(19 downto 0);
signal s_mult1		:	signed(38 downto 0);
--signal s_mult2    :  signed(43 downto 0);
signal s_data_o	:	std_logic_vector(17 downto 0);

begin


	s_sum1  <= s_data_i+c_vfs;
	s_mult1 <= shift_right(s_sum1 * coef,14);
	s_data_o <= std_logic_vector(s_mult1(17 downto 0));

process(clk_i)
begin
	s_data_i <=  signed(data_i);
	data_o <= s_data_o;
end process;

--
--process(clk_i,data_i_en,reset_i)
--begin
--	if rising_edge(clk_i) then
--		if reset_i = '1' then
--			s_data_i <=  to_signed(0,19);
--			s_sum1		<= (others => '0');
--			s_mult1   <= (others => '0');
--			s_data_o <= (others => '0');
--		elsif data_i_en = '1' then
--			s_data_i <=  signed(data_i);
--			s_sum1  <= s_data_i+c_vfs;
--			s_mult1 <= shift_right(s_sum1 * coef,14);
--			s_data_o <= std_logic_vector(s_mult1(17 downto 0));
--		end if;
--	end if;
--end process;




fsm	:process(present_state, data_i_en, data_i)
begin

case present_state is
	
	when e0 =>
		data_o_en <= '0';
		if(data_i_en = '1') then
			next_state <= e1;
		else
			next_state <= e0;
		end if;
		
	when e1 => next_state <= e2;
	
	when e2 =>
		data_o_en <= '1';
	   next_state <= e3;
	
	when e3 => 
		
		next_state <= e0;	
	
	when others => next_state <= e0;
end case;
end process;



p_StateAssignmet :process(clk_i,reset_i,next_state) is
begin
	if rising_edge(clk_i) then
		if reset_i = '1' then
			present_state <= e0;
		else
			present_state <= next_state;
		end if;
	end if;
		
end process;


end Behavioral;

