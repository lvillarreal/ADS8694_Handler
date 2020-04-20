----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:06:26 11/10/2012 
-- Design Name: 
-- Module Name:    uart_32_wc - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_32_wc is
Port ( rst_i 		: in  STD_LOGIC;
           clk_i 		: in  STD_LOGIC;
           dat_i		: in std_logic_vector(7 downto 0);
			  stb_i		: in  STD_LOGIC;	-- dato disponible en la entrada
			  cyc_i		: in  STD_LOGIC;
			  we_i		: in  STD_LOGIC;
			  dat_o		: out  STD_LOGIC_vector(7 downto 0);
			  ack_o 		: out  STD_LOGIC;
			  
-- non wishbone signal	
			  tx_data_av	: in	STD_LOGIC;	-- indica que el dato esta disponible para enviar
			  rda_o			: out STD_LOGIC;	-- indica que el dato recibido es valido
			  rxd  			: in  STD_LOGIC;
			  txd 			: out  STD_LOGIC			  
			  );


end uart_32_wc;

architecture Behavioral of uart_32_wc is
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
	
	COMPONENT fsm_tx4
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		tbe : IN std_logic;          
		sel : OUT std_logic_vector(1 downto 0);
		wr  : OUT std_logic;
   	wr_i	: in	STD_LOGIC	-- indica que el dato en la entrada esta disponible	

		);
	END COMPONENT;


	COMPONENT fsm_rx4
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		rda : IN std_logic;          
		rd : OUT std_logic;
		new4 : OUT std_logic;
		sel : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

signal dati,d_aux					: std_logic_vector(7 downto 0);
signal din,dout					: std_logic_vector(7 downto 0);
signal A,B,C,D						: std_logic_vector(7 downto 0);
signal sel_tx,sel_rx				: std_logic_vector(1 downto 0);
signal rst,clk,new4				: std_logic;
signal stb,tbe,rda,rd,wr		: std_logic;
signal s_tx_data_av				: std_logic;
begin
clk <= clk_i;
rst <= rst_i;
stb <= stb_i;-- and we_i and cyc_i;
ack_o <= stb;



	Inst_uart232: uart232 PORT MAP(
		TXD => txd,
		RXD => rxd,
		CLK => clk,
		DBIN => din,
		DBOUT => dout,
		RDA => rda,
		TBE => tbe,
		RD => rd,
		WR => wr,
		RST => rst
	);


	Inst_fsm_tx4: fsm_tx4 PORT MAP(
		clk => clk,
		rst => rst,
		tbe => tbe,
		sel => sel_tx,
		wr => wr,
		wr_i => s_tx_data_av
	);


	Inst_fsm_rx4: fsm_rx4 PORT MAP(
		clk => clk,
		rst => rst,
		rda => rda,
		rd => rd,
		new4 => new4,
		sel => sel_rx 
	);

--proceso para retener el dato a transmitir
process(clk)
begin
	if(clk'event and clk='1' and stb='1') then
		dati <= dat_i;
	end if;
end process;





--
--din <=  dati(31 downto 24) when sel_tx="01" else
--			dati(23 downto 16) when sel_tx="10" else
--			dati(15 downto 8) when sel_tx="11" else
--			dati(7 downto 0);

--proceso para obtener el dato recibido en cuatro bytes
process(clk)
begin
	if(clk'event and clk='1' and rd='1') then
		d_aux <= d_out;
--		if(sel_rx = "00") then
--			A <= dout;
--		elsif(sel_rx="01") then
--			B <= dout;
--		elsif(sel_rx="10") then
--			C <= dout;
--		else
--			D <= dout;
--		end if;
	end if;	
end process;

--d_aux <= A&B&C&D;


process(clk)
begin
	if(clk'event and clk='1' and new4='1') then
			Dat_o <= d_aux;
	end if;	
end process;

end Behavioral;

