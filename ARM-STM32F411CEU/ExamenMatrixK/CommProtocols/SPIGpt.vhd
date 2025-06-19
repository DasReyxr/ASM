library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_SPI_Master_Concurrent is
end tb_SPI_Master_Concurrent;

architecture Behavioral of tb_SPI_Master_Concurrent is

    -- Component declaration
    component SPI_Master_Concurrent
        Port (
            clk_in,rst,start     : in  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR(7 downto 0);
            mosi,clk_o,cs    : out STD_LOGIC
        );
    end component;

    -- Testbench signals
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '1';
    signal start   : STD_LOGIC := '0';
    signal data_in : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal mosi    : STD_LOGIC;
    signal sclk    : STD_LOGIC;
    signal cs      : STD_LOGIC;

    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    uut: SPI_Master_Concurrent
        port map (clk,rst,start,data_in,mosi,sclk,cs);

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        wait for 20 ns;       -- Let the clock settle a bit
        rst <= '0';           -- Deassert reset

        wait for 30 ns;

        data_in <= "10101010";
        start <= '1';
        wait for clk_period;
        start <= '0';

        wait for 500 ns;      -- Wait enough time for transfer to complete

        data_in <= "11001100";
        start <= '1';
        wait for clk_period;
        start <= '0';

        wait for 500 ns;

        wait;
    end process;

end Behavioral;
