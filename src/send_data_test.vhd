----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:09:05 03/22/2020 
-- Design Name: 
-- Module Name:    send_data_test - Behavioral 
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
use ieee.numeric_std.all;


-- BLOQUE PARA GENERAR SENIAL SENOIDAL Y PROBAR EL FILTRO
entity send_data_test is
	generic(
		N	:	integer 	:= 2	-- Cant de muestras de señal de prueba
	 );
    Port ( i_clk 			: 	in  	STD_LOGIC;
           i_rst 			: 	in  	STD_LOGIC;
			  i_start		:	in		STD_LOGIC;
			  o_clk_test	:	out 	STD_LOGIC;
           o_data 		: 	out	STD_LOGIC_VECTOR (17 downto 0);
           o_data_ready : 	out  	STD_LOGIC);
end send_data_test;

architecture Behavioral of send_data_test is

type ram_array is array (0 to N-1) of std_logic_vector(17 downto 0);
type states is (ini,e0,e1);

signal ram : ram_array;

-- SIGNAL DEFINITION
signal present_state,next_state : states;

signal data : std_logic_vector(17 downto 0);-- := (others => '0');
signal index : integer;-- range 0 to 1999 := 0;--3125 := 0;
signal clk16 : std_logic := '0';
signal contador: integer :=0;--range 0 to 156294 := 0;--Para 625khz (tomado del clk que va de entrada a los filtros)
signal s_o_clk_test : std_logic;

constant divisor : integer := 2500;	-- 20 khz


begin

ram(0) <= std_logic_vector(to_unsigned(131072, 18)); 
ram(1) <= std_logic_vector(to_unsigned(135189, 18)); 
--ram(2) <= std_logic_vector(to_unsigned(139302, 18)); 
--ram(3) <= std_logic_vector(to_unsigned(143406, 18)); 
--ram(4) <= std_logic_vector(to_unsigned(147499, 18)); 
--ram(5) <= std_logic_vector(to_unsigned(151576, 18)); 
--ram(6) <= std_logic_vector(to_unsigned(155632, 18)); 
--ram(7) <= std_logic_vector(to_unsigned(159664, 18)); 
--ram(8) <= std_logic_vector(to_unsigned(163668, 18)); 
--ram(9) <= std_logic_vector(to_unsigned(167639, 18)); 
--ram(10) <= std_logic_vector(to_unsigned(171575, 18)); 
--ram(11) <= std_logic_vector(to_unsigned(175470, 18)); 
--ram(12) <= std_logic_vector(to_unsigned(179322, 18)); 
--ram(13) <= std_logic_vector(to_unsigned(183126, 18)); 
--ram(14) <= std_logic_vector(to_unsigned(186879, 18)); 
--ram(15) <= std_logic_vector(to_unsigned(190577, 18)); 
--ram(16) <= std_logic_vector(to_unsigned(194216, 18)); 
--ram(17) <= std_logic_vector(to_unsigned(197792, 18)); 
--ram(18) <= std_logic_vector(to_unsigned(201303, 18)); 
--ram(19) <= std_logic_vector(to_unsigned(204745, 18)); 
--ram(20) <= std_logic_vector(to_unsigned(208113, 18)); 
--ram(21) <= std_logic_vector(to_unsigned(211406, 18)); 
--ram(22) <= std_logic_vector(to_unsigned(214620, 18)); 
--ram(23) <= std_logic_vector(to_unsigned(217751, 18)); 
--ram(24) <= std_logic_vector(to_unsigned(220796, 18)); 
--ram(25) <= std_logic_vector(to_unsigned(223753, 18)); 
--ram(26) <= std_logic_vector(to_unsigned(226619, 18)); 
--ram(27) <= std_logic_vector(to_unsigned(229390, 18)); 
--ram(28) <= std_logic_vector(to_unsigned(232064, 18)); 
--ram(29) <= std_logic_vector(to_unsigned(234638, 18)); 
--ram(30) <= std_logic_vector(to_unsigned(237111, 18)); 
--ram(31) <= std_logic_vector(to_unsigned(239478, 18)); 
--ram(32) <= std_logic_vector(to_unsigned(241739, 18)); 
--ram(33) <= std_logic_vector(to_unsigned(243890, 18)); 
--ram(34) <= std_logic_vector(to_unsigned(245930, 18)); 
--ram(35) <= std_logic_vector(to_unsigned(247857, 18)); 
--ram(36) <= std_logic_vector(to_unsigned(249669, 18)); 
--ram(37) <= std_logic_vector(to_unsigned(251363, 18)); 
--ram(38) <= std_logic_vector(to_unsigned(252939, 18)); 
--ram(39) <= std_logic_vector(to_unsigned(254394, 18)); 
--ram(40) <= std_logic_vector(to_unsigned(255728, 18)); 
--ram(41) <= std_logic_vector(to_unsigned(256939, 18)); 
--ram(42) <= std_logic_vector(to_unsigned(258025, 18)); 
--ram(43) <= std_logic_vector(to_unsigned(258986, 18)); 
--ram(44) <= std_logic_vector(to_unsigned(259821, 18)); 
--ram(45) <= std_logic_vector(to_unsigned(260529, 18)); 
--ram(46) <= std_logic_vector(to_unsigned(261109, 18)); 
--ram(47) <= std_logic_vector(to_unsigned(261561, 18)); 
--ram(48) <= std_logic_vector(to_unsigned(261884, 18)); 
--ram(49) <= std_logic_vector(to_unsigned(262078, 18)); 
--ram(50) <= std_logic_vector(to_unsigned(262143, 18)); 
--ram(51) <= std_logic_vector(to_unsigned(262078, 18)); 
--ram(52) <= std_logic_vector(to_unsigned(261884, 18)); 
--ram(53) <= std_logic_vector(to_unsigned(261561, 18)); 
--ram(54) <= std_logic_vector(to_unsigned(261109, 18)); 
--ram(55) <= std_logic_vector(to_unsigned(260529, 18)); 
--ram(56) <= std_logic_vector(to_unsigned(259821, 18)); 
--ram(57) <= std_logic_vector(to_unsigned(258986, 18)); 
--ram(58) <= std_logic_vector(to_unsigned(258025, 18)); 
--ram(59) <= std_logic_vector(to_unsigned(256939, 18)); 
--ram(60) <= std_logic_vector(to_unsigned(255728, 18)); 
--ram(61) <= std_logic_vector(to_unsigned(254394, 18)); 
--ram(62) <= std_logic_vector(to_unsigned(252939, 18)); 
--ram(63) <= std_logic_vector(to_unsigned(251363, 18)); 
--ram(64) <= std_logic_vector(to_unsigned(249669, 18)); 
--ram(65) <= std_logic_vector(to_unsigned(247857, 18)); 
--ram(66) <= std_logic_vector(to_unsigned(245930, 18)); 
--ram(67) <= std_logic_vector(to_unsigned(243890, 18)); 
--ram(68) <= std_logic_vector(to_unsigned(241739, 18)); 
--ram(69) <= std_logic_vector(to_unsigned(239478, 18)); 
--ram(70) <= std_logic_vector(to_unsigned(237111, 18)); 
--ram(71) <= std_logic_vector(to_unsigned(234638, 18)); 
--ram(72) <= std_logic_vector(to_unsigned(232064, 18)); 
--ram(73) <= std_logic_vector(to_unsigned(229390, 18)); 
--ram(74) <= std_logic_vector(to_unsigned(226619, 18)); 
--ram(75) <= std_logic_vector(to_unsigned(223753, 18)); 
--ram(76) <= std_logic_vector(to_unsigned(220796, 18)); 
--ram(77) <= std_logic_vector(to_unsigned(217751, 18)); 
--ram(78) <= std_logic_vector(to_unsigned(214620, 18)); 
--ram(79) <= std_logic_vector(to_unsigned(211406, 18)); 
--ram(80) <= std_logic_vector(to_unsigned(208113, 18)); 
--ram(81) <= std_logic_vector(to_unsigned(204745, 18)); 
--ram(82) <= std_logic_vector(to_unsigned(201303, 18)); 
--ram(83) <= std_logic_vector(to_unsigned(197792, 18)); 
--ram(84) <= std_logic_vector(to_unsigned(194216, 18)); 
--ram(85) <= std_logic_vector(to_unsigned(190577, 18)); 
--ram(86) <= std_logic_vector(to_unsigned(186879, 18)); 
--ram(87) <= std_logic_vector(to_unsigned(183126, 18)); 
--ram(88) <= std_logic_vector(to_unsigned(179322, 18)); 
--ram(89) <= std_logic_vector(to_unsigned(175470, 18)); 
--ram(90) <= std_logic_vector(to_unsigned(171575, 18)); 
--ram(91) <= std_logic_vector(to_unsigned(167639, 18)); 
--ram(92) <= std_logic_vector(to_unsigned(163668, 18)); 
--ram(93) <= std_logic_vector(to_unsigned(159664, 18)); 
--ram(94) <= std_logic_vector(to_unsigned(155632, 18)); 
--ram(95) <= std_logic_vector(to_unsigned(151576, 18)); 
--ram(96) <= std_logic_vector(to_unsigned(147499, 18)); 
--ram(97) <= std_logic_vector(to_unsigned(143406, 18)); 
--ram(98) <= std_logic_vector(to_unsigned(139302, 18)); 
--ram(99) <= std_logic_vector(to_unsigned(135189, 18)); 
--ram(100) <= std_logic_vector(to_unsigned(131072, 18)); 
--ram(101) <= std_logic_vector(to_unsigned(126954, 18)); 
--ram(102) <= std_logic_vector(to_unsigned(122841, 18)); 
--ram(103) <= std_logic_vector(to_unsigned(118737, 18)); 
--ram(104) <= std_logic_vector(to_unsigned(114644, 18)); 
--ram(105) <= std_logic_vector(to_unsigned(110567, 18)); 
--ram(106) <= std_logic_vector(to_unsigned(106511, 18)); 
--ram(107) <= std_logic_vector(to_unsigned(102479, 18)); 
--ram(108) <= std_logic_vector(to_unsigned(98475, 18)); 
--ram(109) <= std_logic_vector(to_unsigned(94504, 18)); 
--ram(110) <= std_logic_vector(to_unsigned(90568, 18)); 
--ram(111) <= std_logic_vector(to_unsigned(86673, 18)); 
--ram(112) <= std_logic_vector(to_unsigned(82821, 18)); 
--ram(113) <= std_logic_vector(to_unsigned(79017, 18)); 
--ram(114) <= std_logic_vector(to_unsigned(75264, 18)); 
--ram(115) <= std_logic_vector(to_unsigned(71566, 18)); 
--ram(116) <= std_logic_vector(to_unsigned(67927, 18)); 
--ram(117) <= std_logic_vector(to_unsigned(64351, 18)); 
--ram(118) <= std_logic_vector(to_unsigned(60840, 18)); 
--ram(119) <= std_logic_vector(to_unsigned(57398, 18)); 
--ram(120) <= std_logic_vector(to_unsigned(54030, 18)); 
--ram(121) <= std_logic_vector(to_unsigned(50737, 18)); 
--ram(122) <= std_logic_vector(to_unsigned(47523, 18)); 
--ram(123) <= std_logic_vector(to_unsigned(44392, 18)); 
--ram(124) <= std_logic_vector(to_unsigned(41347, 18)); 
--ram(125) <= std_logic_vector(to_unsigned(38390, 18)); 
--ram(126) <= std_logic_vector(to_unsigned(35524, 18)); 
--ram(127) <= std_logic_vector(to_unsigned(32753, 18)); 
--ram(128) <= std_logic_vector(to_unsigned(30079, 18)); 
--ram(129) <= std_logic_vector(to_unsigned(27505, 18)); 
--ram(130) <= std_logic_vector(to_unsigned(25032, 18)); 
--ram(131) <= std_logic_vector(to_unsigned(22665, 18)); 
--ram(132) <= std_logic_vector(to_unsigned(20404, 18)); 
--ram(133) <= std_logic_vector(to_unsigned(18253, 18)); 
--ram(134) <= std_logic_vector(to_unsigned(16213, 18)); 
--ram(135) <= std_logic_vector(to_unsigned(14286, 18)); 
--ram(136) <= std_logic_vector(to_unsigned(12474, 18)); 
--ram(137) <= std_logic_vector(to_unsigned(10780, 18)); 
--ram(138) <= std_logic_vector(to_unsigned(9204, 18)); 
--ram(139) <= std_logic_vector(to_unsigned(7749, 18)); 
--ram(140) <= std_logic_vector(to_unsigned(6415, 18)); 
--ram(141) <= std_logic_vector(to_unsigned(5204, 18)); 
--ram(142) <= std_logic_vector(to_unsigned(4118, 18)); 
--ram(143) <= std_logic_vector(to_unsigned(3157, 18)); 
--ram(144) <= std_logic_vector(to_unsigned(2322, 18)); 
--ram(145) <= std_logic_vector(to_unsigned(1614, 18)); 
--ram(146) <= std_logic_vector(to_unsigned(1034, 18)); 
--ram(147) <= std_logic_vector(to_unsigned(582, 18)); 
--ram(148) <= std_logic_vector(to_unsigned(259, 18)); 
--ram(149) <= std_logic_vector(to_unsigned(65, 18)); 
--ram(150) <= std_logic_vector(to_unsigned(0, 18)); 
--ram(151) <= std_logic_vector(to_unsigned(65, 18)); 
--ram(152) <= std_logic_vector(to_unsigned(259, 18)); 
--ram(153) <= std_logic_vector(to_unsigned(582, 18)); 
--ram(154) <= std_logic_vector(to_unsigned(1034, 18)); 
--ram(155) <= std_logic_vector(to_unsigned(1614, 18)); 
--ram(156) <= std_logic_vector(to_unsigned(2322, 18)); 
--ram(157) <= std_logic_vector(to_unsigned(3157, 18)); 
--ram(158) <= std_logic_vector(to_unsigned(4118, 18)); 
--ram(159) <= std_logic_vector(to_unsigned(5204, 18)); 
--ram(160) <= std_logic_vector(to_unsigned(6415, 18)); 
--ram(161) <= std_logic_vector(to_unsigned(7749, 18)); 
--ram(162) <= std_logic_vector(to_unsigned(9204, 18)); 
--ram(163) <= std_logic_vector(to_unsigned(10780, 18)); 
--ram(164) <= std_logic_vector(to_unsigned(12474, 18)); 
--ram(165) <= std_logic_vector(to_unsigned(14286, 18)); 
--ram(166) <= std_logic_vector(to_unsigned(16213, 18)); 
--ram(167) <= std_logic_vector(to_unsigned(18253, 18)); 
--ram(168) <= std_logic_vector(to_unsigned(20404, 18)); 
--ram(169) <= std_logic_vector(to_unsigned(22665, 18)); 
--ram(170) <= std_logic_vector(to_unsigned(25032, 18)); 
--ram(171) <= std_logic_vector(to_unsigned(27505, 18)); 
--ram(172) <= std_logic_vector(to_unsigned(30079, 18)); 
--ram(173) <= std_logic_vector(to_unsigned(32753, 18)); 
--ram(174) <= std_logic_vector(to_unsigned(35524, 18)); 
--ram(175) <= std_logic_vector(to_unsigned(38390, 18)); 
--ram(176) <= std_logic_vector(to_unsigned(41347, 18)); 
--ram(177) <= std_logic_vector(to_unsigned(44392, 18)); 
--ram(178) <= std_logic_vector(to_unsigned(47523, 18)); 
--ram(179) <= std_logic_vector(to_unsigned(50737, 18)); 
--ram(180) <= std_logic_vector(to_unsigned(54030, 18)); 
--ram(181) <= std_logic_vector(to_unsigned(57398, 18)); 
--ram(182) <= std_logic_vector(to_unsigned(60840, 18)); 
--ram(183) <= std_logic_vector(to_unsigned(64351, 18)); 
--ram(184) <= std_logic_vector(to_unsigned(67927, 18)); 
--ram(185) <= std_logic_vector(to_unsigned(71566, 18)); 
--ram(186) <= std_logic_vector(to_unsigned(75264, 18)); 
--ram(187) <= std_logic_vector(to_unsigned(79017, 18)); 
--ram(188) <= std_logic_vector(to_unsigned(82821, 18)); 
--ram(189) <= std_logic_vector(to_unsigned(86673, 18)); 
--ram(190) <= std_logic_vector(to_unsigned(90568, 18)); 
--ram(191) <= std_logic_vector(to_unsigned(94504, 18)); 
--ram(192) <= std_logic_vector(to_unsigned(98475, 18)); 
--ram(193) <= std_logic_vector(to_unsigned(102479, 18)); 
--ram(194) <= std_logic_vector(to_unsigned(106511, 18)); 
--ram(195) <= std_logic_vector(to_unsigned(110567, 18)); 
--ram(196) <= std_logic_vector(to_unsigned(114644, 18)); 
--ram(197) <= std_logic_vector(to_unsigned(118737, 18)); 
--ram(198) <= std_logic_vector(to_unsigned(122841, 18)); 
--ram(199) <= std_logic_vector(to_unsigned(126954, 18)); 


 


divisor_frecuencia: process (i_rst, i_clk,contador,clk16) 
begin
	if (i_rst = '1') then
		clk16 <= '1';
		contador <= 1;
	elsif rising_edge(i_clk) then
		if (contador = divisor) then
		  clk16 <= NOT(clk16);
		  contador <= 1;
		else
	     contador <= contador + 1;
	   end if;
	end if;

end process;

s_o_clk_test <= clk16;

o_data <= data;

process(clk16,i_rst,ram)is
begin
	if i_rst = '1' then
		data <= std_logic_vector(ram(0));
	elsif rising_edge(clk16) then
		data <= ram(index);
	end if;

end process;

process(clk16,index)is
begin
	if i_rst = '1' then
		index <= 0;
	elsif rising_edge(clk16) then
		if(index < N-1) then
			index <= index+1;
		else
			index <= 0;
		end if;
	end if;
end process;


o_clk_test <= s_o_clk_test;



fsm:process(present_state, clk16)is
begin
	case (present_state) is
		when ini =>
			o_data_ready <= '0';
			if clk16 = '1' then
				next_state <= e0;
			else 
				next_state <= ini;
			end if;
			
		when e0 =>
			o_data_ready <= '1';
			next_state <= e1;
		
		when e1 =>
			o_data_ready <= '0';
			if clk16 = '0' then
				next_state <= ini;
			else 
				next_state <= e1;
			end if;
		
	end case;
end process;

p_StateAssignmet: process(i_Clk,i_rst,next_state) is
begin
	if rising_edge(i_Clk) then

		if i_rst = '1' then
			present_state <= ini;
		else
			present_state	<= next_state;
		end if;
	end if;
		
end process;

end Behavioral;

-- BLOQUE PARA PROBAR LA COMUNICACION

--entity send_data_test is
--    Port ( i_clk 			: 	in  	STD_LOGIC;
--           i_rst 			: 	in  	STD_LOGIC;
--			  i_start		:	in		STD_LOGIC;
--			  o_clk_test	:	out 	STD_LOGIC;
--           o_data 		: 	out	STD_LOGIC_VECTOR (17 downto 0);
--           o_data_ready : 	out  	STD_LOGIC);
--end send_data_test;
--
--architecture Behavioral of send_data_test is
--
--type states is (ini,e0,e1);
--type ram_array is array (0 to 2000) of std_logic_vector(17 downto 0);
--signal ram : ram_array;
---- SIGNAL DEFINITION
--signal present_state,next_state : states;
----signal data : integer range 0 to 65535 := 0;
--signal data : unsigned(17 downto 0);-- := (others => '0');
--signal i : integer range 0 to 100001 := 0;--3125 := 0;
--signal clk16 : std_logic := '0';
----signal contador: integer range 0 to 78124 := 0;--Para 312.5khz
--signal contador: integer :=0;--range 0 to 156294 := 0;--Para 625khz (tomado del clk que va de entrada a los filtros)
--signal s_o_clk_test : std_logic;
--
---- CONSTANT DEFINITION
--
----	constant divisor : integer := 3125;	-- para 16 khz
----	constant divisor : integer := 4000;	-- para 12500 khz
----	constant divisor : integer := 8000;	-- para 6250;
----	constant divisor : integer := 9091;	-- para 5500 hz
----	constant divisor : integer := 142857;	-- 350 hz
--	constant divisor : integer := 2500;	-- 20 khz
--
--
--begin
--
--o_data <= std_logic_vector(data);
--
--
--
--divisor_frecuencia: process (i_rst, i_clk) 
--begin
--		if rising_edge(i_clk) then
--			if (i_rst = '1') then
--				clk16 <= '0';
--            contador <= 1;
--			else
--				if (contador = divisor) then
--              clk16 <= NOT(clk16);
--              contador <= 1;
--				else
--			     contador <= contador + 1;
--				end if;
--			end if;
--		end if;
--end process;
--
--s_o_clk_test <= clk16;
--process(clk16,i_rst,data)is
--begin
--
--if rising_edge(clk16) then
--	if i_rst = '1' then
--		data <= to_unsigned(67072,18);
----		s_o_clk_test <= '0';
--	elsif data >= 195072 then
--		data <= to_unsigned(67072,18);
----	elsif i_start = '1' then
----		data <= X"0055";
--	else
----		data <= X"0055";
--		data <= data + to_unsigned(1,18);
--	end if;
--end if;
--end process;
--
---- clok de salida para test
--o_clk_test <= s_o_clk_test;
----process(i_rst,data)
----begin
----	if i_rst = '1' then
----		s_o_clk_test <= '0';
----	else
----		s_o_clk_test <= not s_o_clk_test;
----	end if;
----end process;
--
--
--fsm:process(present_state, clk16)is
--begin
--	case (present_state) is
--		when ini =>
--			o_data_ready <= '0';
--			if clk16 = '1' then
--				next_state <= e0;
--			else 
--				next_state <= ini;
--			end if;
--			
--		when e0 =>
--			o_data_ready <= '1';
--			next_state <= e1;
--		
--		when e1 =>
--			o_data_ready <= '0';
--			if clk16 = '0' then
--				next_state <= ini;
--			else 
--				next_state <= e1;
--			end if;
--		
--	end case;
--end process;
--
--p_StateAssignmet :process(i_Clk,i_rst,next_state) is
--begin
--	if rising_edge(i_Clk) then
--
--		if i_rst = '1' then
--			present_state <= ini;
--		else
--			present_state	<= next_state;
--		end if;
--	end if;
--		
--end process;
--
--end Behavioral;

