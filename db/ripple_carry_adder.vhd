library IEEE;
use IEEE.std_logic_1164.all; 

entity ripple_carry_adder is
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
end entity; 

architecture structural of ripple_carry_adder is 

    component full_adder is
        port (
            a    : in std_logic;
            b    : in std_logic;
            cin  : in std_logic;
            cout : out std_logic;
            s    : out std_logic
        );
    end component;

    signal carry : std_logic_vector(Nbit-1 downto 0);

begin 
    generate_RCA: for i in 0 to Nbit-1 generate
        generate_FA_first: if i = 0 generate
           instance_FA_first: full_adder
                port map (
                    a    => a(0),
                    b    => b(0),
                    cin  => cin,
                    cout => carry(1),
                    s    => sum(0)
                ); 
        end generate;
        generate_FA_others: if i > 0 and i < Nbit-1 generate
           instance_FA_others: full_adder
                port map (
                    a    => a(i),
                    b    => b(i),
                    cin  => carry(i),
                    cout => carry(i+1),
                    s    => sum(i)
                ); 
        end generate;
        generate_FA_last: if i = Nbit-1 generate
           instance_FA_last: full_adder
                port map (
                    a    => a(Nbit-1),
                    b    => b(Nbit-1),
                    cin  => carry(Nbit-1),
                    cout => cout,
                    s    => sum(Nbit-1)
                ); 
        end generate;
    end generate generate_RCA;

end architecture;

