library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.decoder.all;
use WORK.divider_const.all;

entity display_divider is
    port(
        start : in std_logic;
        dividend : in std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
        divisor : in std_logic_vector(DIVISOR_WIDTH - 1 downto 0);

        -- quotient : out std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
        -- remainder : out std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
        -- overflow : out std_logic;

        segments_q : out std_logic_vector((( ((DIVIDEND_WIDTH + 3) / 4) * 7) - 1) downto 0);
        segments_r : out std_logic_vector((( ((DIVISOR_WIDTH  + 3) / 4) * 7) - 1) downto 0);
        segments_overflow : out std_logic_vector(6 downto 0)
    );
end entity display_divider;

architecture structural of display_divider is
    constant HEX_Q : integer := (DIVIDEND_WIDTH + 3) / 4;
    constant HEX_R : integer := (DIVISOR_WIDTH  + 3) / 4;

    signal q_int  : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
    signal r_int  : std_logic_vector(DIVISOR_WIDTH  - 1 downto 0);
    signal ovf_int: std_logic;
    signal q_pad  : std_logic_vector((HEX_Q * 4) - 1 downto 0);
    signal r_pad  : std_logic_vector((HEX_R * 4) - 1 downto 0);

    component divider is 
        port(
            --Inputs
            -- clk : in std_logic;
            --COMMENT OUT clk signal for Part A.
            start : in std_logic;
            dividend : in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
            divisor : in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
            --Outputs
            quotient : out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
            remainder : out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
            overflow : out std_logic
        );
    end component divider;

    component leddcd is
        port(
			data_in : in std_logic_vector(3 downto 0);
			segments_out : out std_logic_vector(6 downto 0)
		); 
    end component leddcd;

begin
    udiv : divider
        port map(
            start => start,
            dividend => dividend,
            divisor => divisor,
            quotient => q_int,
            remainder => r_int,
            overflow => ovf_int
        );

    q_pad <= std_logic_vector(resize(unsigned(q_int), HEX_Q * 4));
    r_pad <= std_logic_vector(resize(unsigned(r_int), HEX_R * 4));
   
    gen_q: for i in 0 to (HEX_Q - 1) generate
        uq : leddcd
            port map(
                data_in => q_pad(i * 4 + 3 downto i * 4),
                segments_out => segments_q(i * 7 + 6 downto i * 7)
            );
    end generate;
    
    gen_r: for i in 0 to (HEX_R - 1) generate
        ur : leddcd
            port map(
                data_in => r_pad(i * 4 + 3 downto i * 4),
                segments_out => segments_r(i * 7 + 6 downto i * 7)
            );
    end generate;
    
    segments_overflow <= "1111111" when ovf_int = '0' else "0111111";

end architecture structural;