library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.fixed_pkg.all;

entity atan_LUT_tb is
end entity;

architecture testbench of atan_LUT_tb is

  constant clk_period : time     := 100 ns; 

  component atan_lut_4096_8bit is
    port (
      address  : in  std_logic_vector(11 downto 0);
      atan_out : out std_logic_vector(7 downto 0)
    );
  end component;

    signal clk            : std_logic := '0';
    signal address_ext    : std_logic_vector(11 downto 0) := (others => '0');
    signal atan_out_ext   : std_logic_vector(7 downto 0);
    signal testing        : boolean := true;

begin
    clk <= not clk after clk_period/2 when testing else '0';

    i_DUT: atan_lut_4096_8bit
        port map (
            address => address_ext,
            atan_out => atan_out_ext
    );

    p_STIMULUS: process begin 
        -- Check that the LUT works with integers
        -- Expected output: 0
        address_ext <= std_logic_vector(to_unsigned(1, 12));
        wait until rising_edge(clk);
        -- Expected output: 000.10001 | 17
        address_ext <= std_logic_vector(to_unsigned(40, 12));
        wait until rising_edge(clk);
        -- Expected output: 001.00000 | 32
        address_ext <= std_logic_vector(to_unsigned(100, 12));
        wait until rising_edge(clk);

        -- Check that the LUT works with fixed-point numbers
        -- Expected output: (000001.100000 | 1.5) => (000.11111 | 0.96875)
        address_ext <= std_logic_vector(to_sfixed(1.5, 5, -6));
        wait until rising_edge(clk);
        -- Expected output: (110001.000111 | -14.890625) => (110.01111 | -1.53125)
        address_ext <= std_logic_vector(to_sfixed(-14.890625, 5, -6));
        wait until rising_edge(clk);

        -- Finish simulation
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;
