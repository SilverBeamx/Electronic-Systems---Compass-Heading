library IEEE;
use IEEE.std_logic_1164.all; 

entity DFF_N is
    generic (
        Nbit : integer := 8 
    );
    port (
        clk     : in std_logic;
        resetn  : in std_logic;
        en      : in std_logic;
        di      : in std_logic_vector(Nbit-1 downto 0);
        do      : out std_logic_vector(Nbit-1 downto 0)
    );
end entity;

architecture rtl of DFF_N is
    signal di_s : std_logic_vector(Nbit-1 downto 0);
    signal do_s : std_logic_vector(Nbit-1 downto 0);
begin
    p_DFF_N: process(clk, resetn)
    begin
        if resetn = '0' then
            do_s <= (others => '0');
        elsif rising_edge(clk) then
            do_s <= di_s;
        end if;
    end process;

    di_s <= di when en = '1' else do_s;
    do <= do_s;
end architecture;