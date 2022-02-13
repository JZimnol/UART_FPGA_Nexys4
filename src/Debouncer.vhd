-------------------------------------------------------------------------------
--
-- Title       : Debouncer
-- Design      : TutorVHDL
-- Author      : PJR & JK
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- Description : Simple debounce circuit
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Debouncer is
    port(
        CLK      : in STD_LOGIC;  -- clk 100...300Hz
        CLK_FAST : in STD_LOGIC;  -- clk 100 MHz
        PUSH     : in STD_LOGIC;  -- pushbutton entry
        PE       : out STD_LOGIC  -- debounced output
        );
end Debouncer;

architecture Debouncer of Debouncer is

    signal DELAY      : std_logic_vector(2 downto 0) := (others => '0'); -- debounce register
    signal COUNTER    : std_logic_vector(2 downto 0) := (others => '0');
    signal SINGLE_BIT : std_logic := '0';

begin

    process(CLK, CLK_FAST)
    begin
        if CLK'event and CLK = '1' then
            DELAY <= DELAY(1 downto 0) & PUSH; -- shift register
        end if;
        if CLK_FAST'event and CLK_FAST = '1' then -- keep high state for max 3 CLK signals
           if DELAY = "011" then
               SINGLE_BIT <= '1';
           else 
               SINGLE_BIT <= '0';
           end if;
           COUNTER <= COUNTER(1 downto 0) & SINGLE_BIT;
        end if;
end process;

PE <= '1' when DELAY = "011" and COUNTER /= "111" else '0';

end Debouncer;
