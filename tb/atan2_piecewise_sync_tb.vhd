library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.fixed_pkg.all;

entity atan2_piecewise_sync_tb is
end entity;

architecture testbench of atan2_piecewise_sync_tb is

  constant clk_period : time     := 100 ns; 

  component atan2_piecewise_sync is
    port (
        clk             : in  std_logic;
        resetn          : in  std_logic;
        x               : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
        y               : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
        fraction_result : in  std_logic_vector(11 downto 0); -- y/x fraction for LUT addressing
        atan2_out       : out std_logic_vector(7 downto 0)   -- output angle in fixed-point format
    );
  end component;

    signal clk                  : std_logic := '0';
    signal resetn               : std_logic := '0';
    signal x_ext                : std_logic_vector(7 downto 0) := (others => '0');
    signal y_ext                : std_logic_vector(7 downto 0) := (others => '0');
    signal fraction_result_ext  : std_logic_vector(11 downto 0) := (others => '0');
    signal atan2_out_ext        : std_logic_vector(7 downto 0);
    signal testing              : boolean := true;

begin
    clk <= not clk after clk_period/2 when testing else '0';

    i_DUT: atan2_piecewise_sync
        port map (
            clk => clk,
            resetn => resetn,
            x => x_ext,
            y => y_ext,
            fraction_result => fraction_result_ext,
            atan2_out => atan2_out_ext
    );

    p_STIMULUS: process begin 

        -- Reset the DUT
        resetn <= '0';
        wait for 150 ns;
        resetn <= '1';
        wait until rising_edge(clk);

        -- Check that the LUT results are correct for different quadrants
        -- Quadrant I: x > 0, y > 0
        x_ext <= "00100000"; -- 1.0
        y_ext <= "00100000"; -- 1.0
        fraction_result_ext <= "000001000000"; -- 1
        -- Expected output: 000.11001 | 0.78515625 (pi/4)
        wait until rising_edge(clk);

        -- Quadrant II: x < 0, y > 0
        x_ext <= "11100000"; -- -1.0
        y_ext <= "00100000"; -- 1.0
        fraction_result_ext <= "111111000000"; -- -1
        -- Expected output: 010.01011 | 2.35625 (3pi/4)
        wait until rising_edge(clk);

        -- Quadrant III: x < 0, y < 0
        x_ext <= "11100000"; -- -1.0
        y_ext <= "11100000"; -- -1.0
        fraction_result_ext <= "000001000000"; -- 1
        -- Expected output: 101.10100 | -2.35625 (-3pi/4)
        wait until rising_edge(clk);

        -- Quadrant IV: x > 0, y < 0
        x_ext <= "00100000"; -- 1.0
        y_ext <= "11100000"; -- -1.0
        fraction_result_ext <= "111111000000"; -- -1
        -- Expected output: 111.00110 | -0.78515625 (-pi/4)
        wait until rising_edge(clk);

        -- Test x = 0, y > 0
        x_ext <= "00000000"; -- 0.0
        y_ext <= "00100000"; -- 1.0
        fraction_result_ext <= "000000000000"; -- don't care
        -- Expected output: 001.10010 | 1.5625 (pi/2)
        wait until rising_edge(clk);

        -- Test x = 0, y < 0
        x_ext <= "00000000"; -- 0.0
        y_ext <= "11100000"; -- -1.0
        fraction_result_ext <= "000000000000"; -- don't care
        -- Expected output: 110.01101 | -1.5625 (-pi/2)
        wait until rising_edge(clk);

        -- Test x = 0, y = 0
        x_ext <= "00000000"; -- 0.0
        y_ext <= "00000000"; -- 0.0
        fraction_result_ext <= "000000000000"; -- don't care
        -- Expected output: 000.00000 | 0.0 (undefined, return 0)
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        -- Finish simulation
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;
