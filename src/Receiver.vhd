-------------------------------------------------------------------------------
--
-- Title       : Receiver
-- Design      : UART_PSC
-- Author      : J.Zimnol
-- Company     : AGH Krakow
--
-------------------------------------------------------------------------------
--
-- Description : 
-- Receiver part of UART communication module, part of PSC project design. 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

----------------------------------------------
-- ENTITY RECEIVER
----------------------------------------------
entity Receiver is 
    generic (
        DataLen : integer := 8
        );
    port (
        in_CLK         : in  STD_LOGIC;  -- input clock
        in_ClockDivide : in  STD_LOGIC_VECTOR(2 downto 0); -- clock divider value (for different bauds)
        in_RxBit       : in  STD_LOGIC;  -- serial data in
        out_RxData     : out STD_LOGIC_VECTOR(DataLen-1 downto 0); -- parallel data out
        out_RxIsBusy   : out STD_LOGIC   -- active transmission info
        );
end Receiver;

----------------------------------------------
-- ARCHITECTURE OF RECEIVER
----------------------------------------------
architecture Receiver of Receiver is      

    -- basic states for basic state machine 
    type RX_States is (st_RX_Idle,     -- nothing to receive (high state)
                       st_RX_StartBit, -- start bit (low state) 
                       st_RX_DataBits, -- data to receive (low/high state)
                       st_RX_StopBit,  -- stop bit (high state)
                       st_RX_Error,    -- error occured
                       st_RX_End);     -- wait for second half of a stop bit  
    signal RX_State : RX_States := st_RX_End;
    
    -- integer clock counter from 0 to 41666
    -- lowest baud rate is 2400, so each bit lasts 41666 clock cycles (for 100 MHz clock)
    signal s_ClockCounter : integer range 1 to 41667 := 1;
    signal s_ClkPerBit    : integer range 1 to 41667 := 2;
    -- index of currently received bit 
    signal s_BitIndex : integer range 0 to DataLen-1 := 0;
    -- parallel data out signal 
    signal s_RxData : STD_LOGIC_VECTOR(DataLen-1 downto 0) := (others => '0');
    -- active reception signal 
    signal s_RxIsBusy : STD_LOGIC := '0';
    
begin

    -------------------------------
    -- SET BAUD RATE
    -------------------------------
    process (in_CLK)   
    begin
        -- only in "idle" state
        if RX_State = st_RX_Idle then 
            case in_ClockDivide is 
                when "000"  => s_ClkPerBit <= 41666; -- baud rate 2400
                when "001"  => s_ClkPerBit <= 20832; -- baud rate 4800
                when "010"  => s_ClkPerBit <= 10416; -- baud rate 9600 
                when "011"  => s_ClkPerBit <= 5208;  -- baud rate 19200
                when "100"  => s_ClkPerBit <= 2604;  -- baud rate 38400
                when "101"  => s_ClkPerBit <= 1736;  -- baud rate 57600
                when others => s_ClkPerBit <= 868;   -- baud rate 115200
            end case;
        end if;
    end process; -- SET BAUD RATE
    
    -------------------------------
    -- RECEIVE FRAME
    -------------------------------
    process(in_CLK) 
    begin
    
        if in_CLK'event and in_CLK = '1' then 
            
            case RX_State is
                ------------------
                -- IDLE
                ------------------
                when st_RX_Idle =>
                    s_RxIsBusy <= '0';
                    s_ClockCounter <= 1;
                    if in_RxBit = '0' then -- detect falling edge (beginning of a start bit) 
                        s_RxIsBusy <= '1';
                        RX_State <= st_RX_StartBit;
                    end if;
                ------------------
                -- START BIT
                ------------------
                when st_RX_StartBit =>
                    s_RxIsBusy <= '1';
                    if s_ClockCounter < (s_ClkPerBit/2) then -- count until middle of a start bit 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else
                        if in_RxBit = '0' then -- if still '0', start reading data bits 
                            s_ClockCounter <= 1;
                            RX_State <= st_RX_DataBits;
                        else -- reception error, abort and go to idle 
                            RX_State <= st_Rx_Idle;
                        end if;
                    end if;
                ------------------
                -- DATA BITS
                ------------------
                when st_RX_DataBits =>
                    s_RxIsBusy <= '1';
                    if s_ClockCounter < s_ClkPerBit then -- count until middle of a next bit 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else 
                        s_RxData(s_BitIndex) <= in_RxBit; -- save bit into out RX byte
                        s_ClockCounter <= 1;
                        if s_BitIndex = DataLen-1 then -- if last bit in byte has been saved 
                            s_BitIndex <= 0;
                            RX_State <= st_RX_StopBit;
                        else 
                            s_BitIndex <= s_BitIndex + 1;
                        end if;
                    end if;
                ------------------
                -- STOP BIT
                ------------------    
                when st_RX_StopBit =>
                    s_RxIsBusy <= '1';
                    if s_ClockCounter < s_ClkPerBit then -- count until middle of a stop bit
                        s_ClockCounter <= s_ClockCounter + 1;
                    else 
                        if in_RxBit = '1' then -- check if stop bit is still '1' 
                            s_ClockCounter <= 1;
                            RX_State <= st_RX_End;
                        else -- reception error, no proper stop bit has been detected
                            RX_State <= st_RX_Error;
                        end if;
                    end if;
                ------------------
                -- ERROR
                ------------------
                when st_RX_Error => 
                    s_RxIsBusy <= '1';
                    if in_RxBit = '1' then -- wait unti next '1' in bit 
                        RX_State <= st_RX_Idle;
                        s_RxIsBusy <= '0';
                    end if;
                ------------------
                -- END
                ------------------
                when st_RX_End => 
                    s_RxIsBusy <= '1';
                    if s_ClockCounter < (s_ClkPerBit/2) then -- wait second half of a stop bit 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else 
                        s_ClockCounter <= 1;
                        RX_State <= st_RX_Idle;
                        s_RxIsBusy <= '0';
                    end if;
            end case; -- RX_State
            
        end if;  
    end process; -- RECEIVE FRAME
    
    out_RxData <= s_RxData when RX_State = st_RX_End; -- send data out only if there was no errors (important!)
    out_RxIsBusy <= s_RxIsBusy;

end RECEIVER; -- ARCHITECTURE RECEIVER