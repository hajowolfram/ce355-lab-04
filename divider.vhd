library IEEE;
use IEEE.std_logic_1164.all;
use WORK.divider_const.all;
--Additional standard or custom libraries go here
entity divider is
    port(
        --Inputs
        clk : in std_logic;
        start : in std_logic;
        dividend : in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
        divisor : in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
        --Outputs
        quotient : out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
        remainder : out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
        overflow : out std_logic
    );
end entity divider;

architecture behavioral_sequential of divider is
    component comparator is 
        generic (
            DATA_WIDTH : natural := 4 -- dont we have to change this
        );
        port(
            DINL : in std_logic_vector (DATA_WIDTH downto 0);
            DINR : in std_logic_vector (DATA_WIDTH - 1 downto 0);
            DOUT : out std_logic_vector (DATA_WIDTH - 1 downto 0);
            isGreaterEq : out std_logic
        );
    end component;

    signal idx : integer := (DIVIDEND_WIDTH - 1);
    signal remainder_reg : std_logic_vector (DIVISOR_WIDTH - 1 downto 0) := (others => '0');
    signal quotient_reg : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0) := (others => '0');
    signal overflow_reg : std_logic := '0';
    signal end_state : std_logic := '1';
    signal dinl_reg : std_logic_vector (DIVISOR_WIDTH downto 0);
    signal dout_reg : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
    signal gte_reg : std_logic;

begin
    comp : comparator 
        generic map (
            DATA_WIDTH => DIVISOR_WIDTH
        )
        port map (
            DINL => dinl_reg,
            DINR => divisor,
            DOUT => dout_reg,
            isGreaterEq => gte_reg
        );

    process (clk) 
    begin
        if rising_edge(clk) then
            if (start = '1' and end_state = '1') then
                end_state <= '0';
                idx <= DIVIDEND_WIDTH - 1;
                overflow_reg <= '0';
                remainder_reg <= (others => '0');
                quotient_reg <= (others => '0');
                dinl_reg <= (others => '0');
                if divisor = (others => '0') then
                    overflow_reg <= '1';
                    end_state <= '1';
                end if;
            elsif (end_state = '0') then
                dinl_reg <= remainder_reg & dividend(idx);
                quotient_reg(idx) <= gte_reg;

                if (gte_reg = '1') then
                    remainder_reg <= dout_reg;
                else
                    remainder_reg <= dinl_reg(DIVISOR_WIDTH - 1 downto 0);
                end if;
                
                if idx = 0 then
                    end_state <= '1';
                else
                    idx <= idx - 1;
                end if;
            end if;
        end if;
    end process;

    quotient <= quotient_reg;
    remainder <= remainder_reg;
    overflow <= overflow_reg;

end architecture behavioral_sequential;

--
-- combinational implementation
--

architecture structural_combinational of divider is
    component comparator is 
        generic (
            DATA_WIDTH : natural := 4
        );
        port(
            DINL : in std_logic_vector (DATA_WIDTH downto 0);
            DINR : in std_logic_vector (DATA_WIDTH - 1 downto 0);
            DOUT : out std_logic_vector (DATA_WIDTH - 1 downto 0);
            isGreaterEq : out std_logic
        );
    end component;

    signal gte_bit : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
    type remainders_arr is array (0 to DIVIDEND_WIDTH) of std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
    signal remainders : remainders_arr;
    type dinl_arr is array (0 to DIVIDEND_WIDTH - 1) of std_logic_vector(DIVISOR_WIDTH downto 0);
    signal dinls: dinl_arr;
    constant ZERO_DIVISOR : std_logic_vector(DIVISOR_WIDTH - 1 downto 0) := (others => '0');

begin
--Structural design goes here
    remainders(0) <= (others => '0');
    
    prep_dinl: for i in 0 to DIVIDEND_WIDTH - 1 generate
        dinls(i) <= remainders(i) & dividend(DIVIDEND_WIDTH - 1 - i);
    end generate;

    comparator_loop: for i in 0 to DIVIDEND_WIDTH - 1 generate
        comp : comparator 
            generic map (
                DATA_WIDTH => DIVISOR_WIDTH
            )
            port map (
                DINL => dinls(i),
                DINR => divisor,
                DOUT => remainders(i + 1),
                isGreaterEq => gte_bit(DIVIDEND_WIDTH - i - 1)
            );
    end generate;

    overflow <= '1' when (start = '1' and divisor = ZERO_DIVISOR) else '0';
    quotient  <= (others => '0') when (start = '0' or divisor = ZERO_DIVISOR) else gte_bit;
    remainder <= (others => '0') when (start = '0' or divisor = ZERO_DIVISOR) else remainders(DIVIDEND_WIDTH);

    -- quotient  <= gte_bit when start = '1' else (others => '0');
    -- remainder <= remainders(DIVIDEND_WIDTH) when start = '1' else (others => '0');
    -- overflow  <= '1' when (start = '1' and divisor = ZERO_DIVISOR) else '0';

end architecture structural_combinational;