library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

use WORK.divider_const.all;

entity divider_tb is
end entity divider_tb;

architecture UsingTextFiles of divider_tb is
    signal start : std_logic;
    signal dividend : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
    signal divisor : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
    signal quotient : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
    signal remainder : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
    signal overflow : std_logic;

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
    begin
    
    dut: divider 
    port map (
        start => start,
        dividend => dividend,
        divisor => divisor,
        quotient => quotient,
        remainder => remainder,
        overflow => overflow
    );

    process is
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
            
            dividend <= std_logic_vector(to_unsigned(a_i, DIVIDEND_WIDTH));
            divisor <= std_logic_vector(to_unsigned(b_i, DIVISOR_WIDTH));
            start <= '1';
            wait for 100 ns;
            
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
            
            start <= '0';
            wait for 10 ns;
        end loop;
        wait;
    end process;
end architecture UsingTextFiles;
