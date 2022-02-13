-------------------------------------------------------------------------------
--
-- Title       : Prescaler
-- Design      : TutorVHDL
-- Author      : PJR & JK
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- Description : Synchronous prescaler circuit (100 MHz -> 100 Hz)
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity Prescaler is
    port(
        CLK : in STD_LOGIC;
        CEO : out STD_LOGIC
        );       
end Prescaler;

architecture Prescaler of Prescaler is

    signal DIVIDER : std_logic_vector(19 downto 0);  -- internal divider register 
    constant divide_factor : integer := 1000000;     -- divide factor user constant
                                                
begin 
    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            if DIVIDER = (divide_factor-1) then
                DIVIDER <= (others => '0');
            else
                DIVIDER <= DIVIDER + 1;
            end if;
        end if;
    end process;

CEO <= '1' when DIVIDER = (divide_factor-1) else '0';
    
end Prescaler;
