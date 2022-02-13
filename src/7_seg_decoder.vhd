-------------------------------------------------------------------------------
--
-- Title       : 7_seg_decoder
-- Design      : UART_PSC
-- Author      : J.Zimnol
-- Company     : AGH Krakow
--
-------------------------------------------------------------------------------
--
-- Description : 
-- 7-segment decoder part of UART communication module, part of PSC project design.
-- This module decodes RX bytes into 7-segment display.
-- Note: a decoding function could be used for bigger number of displays. 
--
-- Module characteristics:
--
--          a
--         ___
--      f |   | b      out_LED is a STD_LOGIC_VECTOR(6 downto 0) where diodes are
--        |_g_|        from MSB to LSB => (a, b, c, d, e, f, g)
--      e |   | c
--        |___|
--          d
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;            

----------------------------------------------                                                                                  
-- ENTITY 7_SEG_DECODER
----------------------------------------------
entity seven_seg_decoder is 
    port (
        in_CLK          : in  STD_LOGIC;  -- input clock (about 100 Hz) 
        in_FirstDigit   : in  STD_LOGIC_VECTOR(3 downto 0); -- first digit (upper digit)
        in_SecondDigit  : in  STD_LOGIC_VECTOR(3 downto 0); -- second digit (lower digit)
        out_FirstAnode  : out STD_LOGIC;  -- first digit anode control 
        out_SecondAnode : out STD_LOGIC;  -- second digit anode control
        out_StaticAnodes: out STD_LOGIC_VECTOR(5 downto 0); -- rest of the digits' anodes (constant high state)
        out_LED         : out STD_LOGIC_VECTOR(6 downto 0)  -- output led vector
        );
end seven_seg_decoder;

----------------------------------------------
-- ARCHITECTURE OF 7_SEG_DECODER
----------------------------------------------
architecture seven_seg_decoder of seven_seg_decoder is

    signal s_FirstAnode  : STD_LOGIC := '1';
    signal s_SecondAnode : STD_LOGIC := '0';
    signal s_LED         : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');

begin
    
    process(in_CLK)
    begin
        if in_CLK'event and in_CLK = '1' then 
            if s_FirstAnode = '0' then
                s_FirstAnode <= '1';
                s_SecondAnode <= '0';
                case in_FirstDigit is -- a decoding function can easily be used 
                    when "0000" => s_LED <= "0000001"; -- 0
                    when "0001" => s_LED <= "1001111"; -- 1
                    when "0010" => s_LED <= "0010010"; -- 2
                    when "0011" => s_LED <= "0000110"; -- 3
                    when "0100" => s_LED <= "1001100"; -- 4
                    when "0101" => s_LED <= "0100100"; -- 5
                    when "0110" => s_LED <= "0100000"; -- 6
                    when "0111" => s_LED <= "0001101"; -- 7
                    when "1000" => s_LED <= "0000000"; -- 8
                    when "1001" => s_LED <= "0000100"; -- 9
                    when "1010" => s_LED <= "0001000"; -- A
                    when "1011" => s_LED <= "1100000"; -- b
                    when "1100" => s_LED <= "0110001"; -- C
                    when "1101" => s_LED <= "1000010"; -- d
                    when "1110" => s_LED <= "0110000"; -- E
                    when "1111" => s_LED <= "0111000"; -- F
                    when others => s_LED <= "1000001"; -- U
                end case;
            else 
                s_FirstAnode <= '0';
                s_SecondAnode <= '1';
                case in_SecondDigit is -- a decoding function can easily be used
                    when "0000" => s_LED <= "0000001"; -- 0
                    when "0001" => s_LED <= "1001111"; -- 1
                    when "0010" => s_LED <= "0010010"; -- 2
                    when "0011" => s_LED <= "0000110"; -- 3
                    when "0100" => s_LED <= "1001100"; -- 4
                    when "0101" => s_LED <= "0100100"; -- 5
                    when "0110" => s_LED <= "0100000"; -- 6
                    when "0111" => s_LED <= "0001101"; -- 7
                    when "1000" => s_LED <= "0000000"; -- 8
                    when "1001" => s_LED <= "0000100"; -- 9
                    when "1010" => s_LED <= "0001000"; -- A
                    when "1011" => s_LED <= "1100000"; -- b
                    when "1100" => s_LED <= "0110001"; -- C
                    when "1101" => s_LED <= "1000010"; -- d
                    when "1110" => s_LED <= "0110000"; -- E
                    when "1111" => s_LED <= "0111000"; -- F
                    when others => s_LED <= "1000001"; -- U
                end case;
            end if;
        end if;
    end process;
    
    out_FirstAnode <= s_FirstAnode;
    out_SecondAnode <= s_SecondAnode;
    out_StaticAnodes <= "111111"; -- always ones to turn off other numbers
    out_LED <= s_LED;

end seven_seg_decoder;