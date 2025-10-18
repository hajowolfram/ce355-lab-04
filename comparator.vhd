library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--Additional standard or custom libraries go here

entity comparator is
    generic(
        DATA_WIDTH : natural := 4
    );
    port(
        --Inputs
        DINL : in std_logic_vector (DATA_WIDTH downto 0);
        DINR : in std_logic_vector (DATA_WIDTH - 1 downto 0);
        --Outputs
        DOUT : out std_logic_vector (DATA_WIDTH - 1 downto 0);
        isGreaterEq : out std_logic
    );
end entity comparator;


architecture behavioral of comparator is
begin
    process(DINL, DINR)
        variable lhs : unsigned(DATA_WIDTH downto 0);
        variable rhs : unsigned(DATA_WIDTH downto 0);
        variable difference : unsigned(DATA_WIDTH downto 0);
    begin
        lhs := unsigned(DINL);
        rhs := resize(unsigned(DINR), DATA_WIDTH + 1);

        if lhs >= rhs then
            difference := lhs - rhs;
            DOUT <= std_logic_vector(difference(DATA_WIDTH - 1 downto 0));
            isGreaterEq <= '1';
        else
            DOUT <= DINL(DATA_WIDTH - 1 downto 0);
            isGreaterEq <= '0';
        end if;
    end process; 
end architecture behavioral;
