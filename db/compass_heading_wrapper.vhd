library ieee;
  use ieee.std_logic_1164.all;

entity compass_heading_wrapper is
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

architecture behavioral of compass_heading_wrapper is

    component compass_heading is
        port (
            clk         : in  std_logic;
            resetn      : in  std_logic;
            a           : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
            a_bias      : in  std_logic;  -- input a bias enable
            b           : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
            b_bias      : in  std_logic;  -- input b bias enable
            theta_out   : out std_logic_vector(7 downto 0)   -- output compass heading in fixed-point format
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

    signal a_wrapper            : std_logic_vector(7 downto 0);
    signal b_wrapper            : std_logic_vector(7 downto 0);
    signal a_bias_wrapper       : std_logic;
    signal b_bias_wrapper       : std_logic;
    signal theta_out_wrapper    : std_logic_vector(7 downto 0);

begin

    -- Check if the current coordinates should also be saved as bias
    a_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => a,
            do      => a_wrapper
    );
    a_bias_register : DFF_N
        generic map (
            Nbit => 1
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di(0)      => a_bias,
            do(0)      => a_bias_wrapper
    );
    b_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => b,
            do      => b_wrapper
    );
    b_bias_register : DFF_N
        generic map (
            Nbit => 1
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di(0)      => b_bias,
            do(0)      => b_bias_wrapper
    );
    wrapped_component: compass_heading
        port map (
            clk => clk,
            resetn => resetn,
            a => a_wrapper,
            a_bias => a_bias_wrapper,
            b => b_wrapper,
            b_bias => b_bias_wrapper,
            theta_out => theta_out_wrapper
    );
    theta_out_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => theta_out_wrapper,
            do      => theta_out
    );
    

end architecture;