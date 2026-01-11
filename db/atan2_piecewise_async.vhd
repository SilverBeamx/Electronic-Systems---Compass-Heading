library ieee;
  use ieee.std_logic_1164.all;

entity atan2_piecewise_async is
    port (
        x               : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
        y               : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
        fraction_result : in  std_logic_vector(11 downto 0); -- y/x fraction for LUT addressing
        atan2_out       : out std_logic_vector(7 downto 0)  -- output angle in fixed-point format
    );
end entity;

architecture behavioral of atan2_piecewise_async is

    component atan_lut_4096_8bit is
        port (
            address  : in  std_logic_vector(11 downto 0);
            atan_out : out std_logic_vector(7 downto 0)
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

    constant PI : std_logic_vector(7 downto 0)          := "01100100"; -- (3.125   | 011.00100)
    constant NEG_PI : std_logic_vector(7 downto 0)      := "10011011"; -- (-3.125  | 100.11011)
    constant HALF_PI : std_logic_vector(7 downto 0)     := "00110010"; -- (1.5625  | 001.10010)
    constant NEG_HALF_PI : std_logic_vector(7 downto 0) := "11001101"; -- (-1.5625 | 110.01101)

    signal atan_out_lut : std_logic_vector(7 downto 0);
    signal corrected_pi : std_logic_vector(7 downto 0);
    signal adder_carry    : std_logic;
    signal adder_result   : std_logic_vector(7 downto 0);
    signal x_zero       : std_logic;
    signal y_zero       : std_logic;

begin

    -- Instantiate the atan LUT and get the angle for the fraction
    atan_lut_inst : atan_lut_4096_8bit
        port map (
            address  => fraction_result,
            atan_out => atan_out_lut
        );

    -- Check y's sign and adjust pi accordingly (pi is positive for y > 0)
    corrected_pi <= PI when y(7) = '0' else NEG_PI;

    -- Sum corrected pi and LUT output
    adder_inst : ripple_carry_adder
        generic map (
            Nbit => 8
        )
        port map (
            a    => atan_out_lut,
            b    => corrected_pi,
            cin  => adder_carry,
            sum  => adder_result,
            cout => adder_carry
        );

    -- Check for special cases where x or y is zero
    x_zero <= '1' when x = "00000000" else '0';
    y_zero <= '1' when y = "00000000" else '0';

    -- Output angle correction based on the quadrant
    atan2_out <=  "00000000"   when (x_zero = '1' and y_zero = '1') else -- x = 0, y = 0, undefined, return 0
                  HALF_PI      when (x_zero = '1' and y_zero = '0' and y(7) = '0') else -- x = 0, y > 0
                  NEG_HALF_PI  when (x_zero = '1' and y_zero = '0' and y(7) = '1') else -- x = 0, y < 0
                  adder_result when (x_zero = '0' and y_zero = '0' and x(7) = '1') else -- x < 0
                  atan_out_lut when (x_zero = '0' and y_zero = '0' and x(7) = '0') else -- x >= 0
                  "00000000"; -- default case (should not occur)

end architecture;