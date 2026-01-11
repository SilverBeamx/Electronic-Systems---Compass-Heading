library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.fixed_pkg.all;

entity compass_heading is
    port (
        clk         : in  std_logic;
        resetn      : in  std_logic;
        a           : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
        a_bias      : in  std_logic;  -- input a bias enable
        b           : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
        b_bias      : in  std_logic;  -- input b bias enable
        theta_out : out std_logic_vector(7 downto 0)   -- output compass heading in fixed-point format
    );
    end entity;

architecture behavioral of compass_heading is

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

    component ripple_carry_adder is
        generic (
            Nbit : integer := 8 
        );
        port (
            a    : in  std_logic_vector(Nbit-1 downto 0);
            b    : in  std_logic_vector(Nbit-1 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(Nbit-1 downto 0);
            cout : out std_logic
        );
    end component;

    component DFF_N is
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
    end component;

    signal a_saved_bias     : std_logic_vector(7 downto 0);
    signal b_saved_bias     : std_logic_vector(7 downto 0);
    signal a_inverted_bias  : std_logic_vector(7 downto 0);
    signal b_inverted_bias  : std_logic_vector(7 downto 0);
    signal y                : std_logic_vector(7 downto 0);
    signal x                : std_logic_vector(7 downto 0);
    signal fraction_result  : sfixed(5 downto -6);
    signal atan2_result     : std_logic_vector(7 downto 0);

    constant input_integer_bits    : integer := 4;
    constant input_fractional_bits : integer := -3;

begin

    -- Check if the current coordinates should also be saved as bias
    a_bias_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => a_bias,
            di      => a,
            do      => a_saved_bias
    );
    b_bias_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => b_bias,
            di      => b,
            do      => b_saved_bias
    );

    -- Sum previously saved bias (if not saved it is 0 thanks to the reset)
    -- So if bias is enabled, we subtract the saved bias from the current inputs
    -- Note: subtracting bias is adding the two's complement (inverting bits + 1)
    a_inverted_bias <= not a_saved_bias;
    b_inverted_bias <= not b_saved_bias;
    a_bias_adder : ripple_carry_adder
        generic map (
            Nbit => 8
        )
        port map (
            a    => a,
            b    => a_inverted_bias,
            cin  => '1',
            sum  => y,
            cout => open
    );
    b_bias_adder : ripple_carry_adder
        generic map (
            Nbit => 8
        )
        port map (
            a    => b,
            b    => b_inverted_bias,
            cin  => '1',
            sum  => x,
            cout => open
    );

    -- Compute the fraction y/x
    fraction_result <= resize((
                       to_sfixed(y, input_integer_bits, input_fractional_bits) /
                       to_sfixed(x, input_integer_bits, input_fractional_bits)
                       ), fraction_result'high, fraction_result'low);

    -- Get the atan2 result
    atan2_inst : atan2_piecewise_sync
        port map (
            clk             => clk,
            resetn          => resetn,
            x               => x,
            y               => y,
            fraction_result => to_slv(fraction_result), -- convert sfixed to slv
            atan2_out       => atan2_result
    );

    -- Output the final compass heading
    theta_out <= atan2_result;

end architecture;