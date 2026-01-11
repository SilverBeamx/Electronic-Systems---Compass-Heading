library ieee;
  use ieee.std_logic_1164.all;

entity atan2_piecewise_sync is
    port (
        clk             : in  std_logic;
        resetn          : in  std_logic;
        x               : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
        y               : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
        fraction_result : in  std_logic_vector(11 downto 0); -- y/x fraction for LUT addressing
        atan2_out  : out std_logic_vector(7 downto 0)  -- output angle in fixed-point format
    );
end entity;

architecture behavioral of atan2_piecewise_sync is

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

    component atan2_piecewise_async is
        port (
            x               : in  std_logic_vector(7 downto 0);  -- input x coordinate (twos complement)
            y               : in  std_logic_vector(7 downto 0);  -- input y coordinate (twos complement)
            fraction_result : in  std_logic_vector(11 downto 0); -- y/x fraction for LUT addressing
            atan2_out       : out std_logic_vector(7 downto 0)  -- output angle in fixed-point format
        );
    end component;

    signal x_ext : std_logic_vector(7 downto 0);
    signal y_ext : std_logic_vector(7 downto 0);
    signal fraction_result_ext : std_logic_vector(11 downto 0);
    signal atan2_out_ext : std_logic_vector(7 downto 0);

begin
    x_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => x,
            do      => x_ext
    );

    y_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => y,
            do      => y_ext
    );

    fraction_result_register : DFF_N
        generic map (
            Nbit => 12
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => fraction_result,
            do      => fraction_result_ext
    );

    atan2_piecewise_async_inst : atan2_piecewise_async
        port map (
            x               => x_ext,
            y               => y_ext,
            fraction_result => fraction_result_ext,
            atan2_out       => atan2_out_ext
        );

    atan2_out_register : DFF_N
        generic map (
            Nbit => 8
        )
        port map (
            clk     => clk,
            resetn  => resetn,
            en      => '1',
            di      => atan2_out_ext,
            do      => atan2_out
    );


end architecture;