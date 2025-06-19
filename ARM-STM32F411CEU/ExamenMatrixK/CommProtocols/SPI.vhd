----------- Code -----------
------ Orlando Reyes ------
--------- Auf Das ---------
-------- SPI Protocol --------
-------- 23/04/2025 --------
------- Main Library -------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_Master_Concurrent is
    Port (
        clk_in, rst, start : in  STD_LOGIC;
        data_in         : in  STD_LOGIC_VECTOR(7 downto 0);
        mosi, clk_o, cs : out STD_LOGIC
    );
end SPI_Master_Concurrent;

architecture FSM of SPI_Master_Concurrent is

    -- Memory signals
    signal a_cnt       : integer range 0 to 7 := 0;
    signal a_shift     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal a_clk    : integer range 0 to 3 := 0;
    signal a_clkout    : STD_LOGIC := '0';
    signal a_sending   : STD_LOGIC := '0';

    -- Next state signals
    signal n_cnt       : integer range 0 to 7;
    signal n_shift     : STD_LOGIC_VECTOR(7 downto 0);
    signal n_clock    : integer range 0 to 3;
    signal n_clkout    : STD_LOGIC;
    signal n_sending   : STD_LOGIC;

begin

    -- ============ MEMORY ============
    a_cnt     <= n_cnt     when clk_in'event and clk_in = '1';
    a_shift   <= n_shift   when clk_in'event and clk_in = '1';
    a_clk     <= n_clock   when clk_in'event and clk_in = '1';
    a_clkout  <= n_clkout  when clk_in'event and clk_in = '1';
    a_sending <= n_sending when clk_in'event and clk_in = '1';

    -- ============ n STATE LOGIC ============

    n_clock   <= a_clk+1      when not (a_clk=3)  else 0;
    n_clkout  <= not a_clkout when a_clk = 3 else a_clkout;

    -- Sending flag
    n_sending <= 
                    '1' when a_sending = '0' and start = '1'  else
                    '0' when a_sending = '1' and a_cnt = 7 and a_clk = 3 else
                    a_sending;

    -- Shift register
    n_shift <= 
                    data_in                   when a_sending = '0' and start = '1' else
                    a_shift(6 downto 0) & '0' when a_sending = '1' and a_clk = 3 else
                    a_shift;

    -- Bit counter
    n_cnt <= 
                    0         when a_sending = '0' and start = '1'  else
                    a_cnt + 1 when a_sending = '1' and a_clk = 3 and a_cnt < 7 else
                    a_cnt;

    -- ============ OUTPUT LOGIC ============
    mosi  <= a_shift(7);
    clk_o <= a_clkout when a_sending = '1' else '0';
    cs    <= '0' when a_sending = '1' else '1';

end FSM;
