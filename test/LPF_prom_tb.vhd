library IEEE;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

entity LPF_prom_tb is
end LPF_prom_tb;

architecture testbench of LPF_prom_tb is

  component LPF_prom
  generic (
    DATA_WIDTH    : integer := 18;
    cant_muestras : integer := 16
  );
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    data_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in_ready  : in  std_logic;
    data_out       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out_ready : out std_logic
  );
  end component LPF_prom;

  constant  DATA_WIDTH    : integer :=  18;
  constant  cant_muestras : integer :=  8;

type ram is array (0 to 15) of integer range 0 to (2**DATA_WIDTH)-1;

constant  clk_period    : time    :=  1000 ns;
constant  ram_mem : ram := (12,11,9,10,10,9,11,9,10,10,8,11,12,10,10,8);

    --signal s_data           : integer;
    signal s_clk            : std_logic;
    signal s_reset          : std_logic;
    signal s_data_in        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_data_in_ready  : std_logic;
    signal s_data_out       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_data_out_ready : std_logic;


begin

  LPF_prom_i : LPF_prom
  generic map (
    DATA_WIDTH    => DATA_WIDTH,
    cant_muestras => cant_muestras
  )
  port map (
    clk            => s_clk,
    reset          => s_reset,
    data_in        => s_data_in,
    data_in_ready  => s_data_in_ready,
    data_out       => s_data_out,
    data_out_ready => s_data_out_ready
  );




clk_gen: process
begin
      s_clk  <= '1';
      wait for clk_period/2;
      s_clk  <= '0';
      wait for clk_period/2;
end process;

stimul_proc: PROCESS
variable i : integer range 0 to 30;
begin

  s_reset <= '1';
  s_data_in_ready <=  '0';
  wait for 2*clk_period;
  s_reset <= '0';

  for i in 0 to 15 loop
    s_data_in <= std_logic_vector(to_unsigned(ram_mem(i),s_data_in'length));
    wait for clk_period;
    s_data_in_ready <=  '1';
    wait for clk_period;
    s_data_in_ready <=  '0';
    wait for clk_period;
  end loop;



  wait for 2*clk_period;
  s_reset <= '1';
  wait for 2*clk_period;

  wait;
  --wait for 500*clk_period;





end process;


end testbench;
