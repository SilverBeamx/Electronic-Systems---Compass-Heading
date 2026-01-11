library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.fixed_pkg.all;

entity compass_heading_tb is
end entity;

architecture testbench of compass_heading_tb is

  constant clk_period : time     := 100 ns; 

  component compass_heading is
    port (
        clk         : in  std_logic;
        resetn      : in  std_logic;
        a           : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
        a_bias      : in  std_logic;  -- input a bias enable
        b           : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
        b_bias      : in  std_logic;  -- input b bias enable
        theta_out : out std_logic_vector(7 downto 0)   -- output compass heading in fixed-point format
    );
  end component;

    signal clk                  : std_logic := '0';
    signal resetn               : std_logic := '0';
    signal a_ext                : std_logic_vector(7 downto 0) := (others => '0');
    signal a_bias_ext           : std_logic := '0';
    signal b_ext                : std_logic_vector(7 downto 0) := (others => '0');
    signal b_bias_ext           : std_logic := '0';
    signal theta_out_ext        : std_logic_vector(7 downto 0);
    signal testing              : boolean := true;

begin
    clk <= not clk after clk_period/2 when testing else '0';

    i_DUT: compass_heading
        port map (
            clk => clk,
            resetn => resetn,
            a => a_ext,
            a_bias => a_bias_ext,
            b => b_ext,
            b_bias => b_bias_ext,
            theta_out => theta_out_ext
    );

    p_STIMULUS: process begin 

        -- Reset the DUT
        resetn <= '0';
        wait for 150 ns;
        resetn <= '1';
        wait until rising_edge(clk);

        -- Check that the atan results are correct for different quadrants
        -- Quadrant I: x > 0, y > 0
        b_ext <= "00001000"; -- 1.0
        a_ext <= "00001000"; -- 1.0
        -- Expected output: 000.11001 | 0.78515625 (pi/4)
        wait until rising_edge(clk);

        -- Quadrant IV: x > 0, y < 0
        b_ext <= "00001000"; -- 1.0
        a_ext <= "11111000"; -- -1.0
        -- Expected output: 111.00110 | -0.78515625 (-pi/4)
        wait until rising_edge(clk);

        -- Test x = 0, y > 0
        b_ext <= "00000000"; -- 0.0
        a_ext <= "00001000"; -- 1.0
        -- Expected output: 001.10010 | 1.5625 (pi/2)
        wait until rising_edge(clk);

        -- Test x = 0, y < 0
        b_ext <= "00000000"; -- 0.0
        a_ext <= "11111000"; -- -1.0
        -- Expected output: 110.01101 | -1.5625 (-pi/2)
        wait until rising_edge(clk);

        -- Test x = 0, y = 0
        b_ext <= "00000000"; -- 0.0
        a_ext <= "00000000"; -- 0.0
        -- Expected result: 000.00000
        wait until rising_edge(clk);

        -- Test bias
        -- Enable bias test for the next test
        a_bias_ext <= '1';
        b_bias_ext <= '1';
        b_ext <= "00001000"; --  1.0
        a_ext <= "11111000"; -- -1.0
        -- Expected output: 111.00110 | -0.78515625 (-pi/4)
        wait until rising_edge(clk);

        -- Disable bias saving
        a_bias_ext <= '0';
        b_bias_ext <= '0';
        b_ext <= "00000000"; -- -1.0
        a_ext <= "00000000"; --  1.0
        -- Expected output: 010.01011 | 2.35625 (3pi/4)
        wait until rising_edge(clk);

        b_ext <= "00001000"; --  0.0
        a_ext <= "00000000"; --  1.0
        -- Expected output: 001.10010 | 1.5625 (pi/2)
        wait until rising_edge(clk);


        -- Finish simulation
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;
