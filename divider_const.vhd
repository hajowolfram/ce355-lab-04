library IEEE;
use IEEE.std_logic_1164.all;

package divider_const is
	constant DIVIDEND_WIDTH : natural := 32;
	constant DIVISOR_WIDTH : natural := 16;
	constant CLK_PERIOD : time := 10 ns;
end package divider_const;
