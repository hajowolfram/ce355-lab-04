library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library STD;
use STD.textio.all;

use WORK.divider_const.all;
for all : divider use entity WORK.divider (behavioral_sequential);

entity divider_tb is
end entity divider_tb;

architecture UsingTextFiles of divider_tb is
    signal clk : std_logic := '0';
    signal start : std_logic := '0';
    signal dividend : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
    signal divisor : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
    signal quotient : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
    signal remainder : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
    signal overflow : std_logic := '0';

    component divider is 
        port(
            --Inputs
            clk : in std_logic;
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
    begin
    
    dut: divider 
    port map (
        clk => clk,
        start => start,
        dividend => dividend,
        divisor => divisor,
        quotient => quotient,
        remainder => remainder,
        overflow => overflow
    );

    process 
    begin
        loop
            clk <= '1';
            wait for clk_period / 2;
            clk <= '0';
            wait for clk_period / 2;
        end loop;
    end process;

    process
        file infile: text open read_mode is "divider32.in";
        file outfile: text open write_mode is "divider32.out";

        variable line_in: line;
        variable line_out: line;

        variable a_i : integer;
        variable b_i : integer;
        variable quotient_i : integer;
        variable remainder_i : integer;
        
    begin
        while not endfile(infile) loop
            readline(infile, line_in);
            read(line_in, a_i);
            readline(infile, line_in);
            read(line_in, b_i);

            wait until rising_edge(clk);
            dividend <= std_logic_vector(to_unsigned(a_i, DIVIDEND_WIDTH));
            divisor <= std_logic_vector(to_unsigned(b_i, DIVISOR_WIDTH));
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            wait for 200 ns;
            wait until rising_edge(clk);
            quotient_i := to_integer(unsigned(quotient));
            remainder_i := to_integer(unsigned(remainder));
            
            write(line_out, a_i);
            write(line_out, string'("/"));
            write(line_out, b_i);
            write(line_out, string'(" = "));
            write(line_out, quotient_i);
            write(line_out, string'("--"));
            write(line_out, remainder_i);
            
            if overflow = '1' then
                write(line_out, string'(" overflow"));
            end if;
            
            writeline(outfile, line_out);
            
            wait for 10 ns;
        end loop;
        wait;
    end process;
end architecture UsingTextFiles;
