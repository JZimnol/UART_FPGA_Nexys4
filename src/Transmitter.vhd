-------------------------------------------------------------------------------
--
-- Title       : Transmitter
-- Design      : UART_PSC
-- Author      : J.Zimnol
-- Company     : AGH Krakow
--
-------------------------------------------------------------------------------
--
-- Description : 
-- Transmitter part of UART communication module, part of PSC project design. 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;            

----------------------------------------------
-- ENTITY TRANSMITTER
----------------------------------------------
entity Transmitter is 
    generic (
        DataLen : integer := 8  -- length of data frame
        );
    port (
        in_CLK         : in  STD_LOGIC;  -- input clock 
        in_ClockDivide : in  STD_LOGIC_VECTOR(2 downto 0); -- clock divider value (for different bauds)
        in_TxData      : in  STD_LOGIC_VECTOR(DataLen-1 downto 0); -- parallel data in
        in_BeginSend   : in  STD_LOGIC;  -- start transmission 
        out_TxBit      : out STD_LOGIC;  -- serial out bit 
        out_TxIsBusy   : out STD_LOGIC   -- active transmission info
        );
end Transmitter;

----------------------------------------------
-- ARCHITECTURE OF TRANSMITTER
----------------------------------------------
architecture Transmitter of Transmitter is 

    -- basic states for basic state machine 
    type TX_States is (st_TX_Idle,     -- nothing to send (high state)
                       st_TX_StartBit, -- start bit (low state) 
                       st_TX_DataBits, -- data to send (low/high state)
                       st_TX_StopBit); -- stop bit (high state)
    signal TX_State : TX_States := st_TX_Idle;
    
    -- integer clock counter from 0 to 41666
    -- lowest baud rate is 2400, so each bit lasts 41666 clock cycles (for 100 MHz clock)
    signal s_ClockCounter : integer range 1 to 41667 := 1;
    signal s_ClkPerBit    : integer range 1 to 41667 := 10417;
    -- index of currently sent bit 
    signal s_BitIndex: integer range 0 to DataLen-1 := 0;
    -- parallel data in signal, used to save input signal on start bit 
    signal s_TxData : STD_LOGIC_VECTOR(DataLen-1 downto 0) := (others => '0');
    -- serial data out signal
    signal s_TxBit  : STD_LOGIC := '1';
    -- active transmission signal 
    signal s_TxIsBusy : STD_LOGIC := '0';
    
begin  
    
    -------------------------------
    -- SET BAUD RATE
    -------------------------------
    process (in_CLK)   
    begin
        -- only in "idle" state
        if TX_State = st_TX_Idle then 
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
    -- TRANSMIT FRAME
    -------------------------------
    process(in_CLK, in_BeginSend) 
    begin  
    
        if (in_CLK'event and in_CLK = '1') then 
        
            case TX_State is 
                ------------------
                -- IDLE
                ------------------
                when st_TX_Idle =>  
                    s_TxBit  <= '1'; -- "1" in output as the passive state
                    s_TxIsBusy <= '0';
                    s_ClockCounter <= 1;
                    if in_BeginSend = '1' then  
                        s_TxData <= in_TxData;
                        s_TxIsBusy <= '1';
                        s_ClockCounter <= 1; 
                        TX_State <= st_TX_StartBit;
                    end if;
                -----------------
                -- START BIT
                -----------------
                when st_TX_StartBit =>
                    s_TxBit  <= '0'; -- start bit is the first "0" in frame
                    s_TxIsBusy <= '1';
                    if s_ClockCounter < s_ClkPerBit then 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else
                        s_ClockCounter <= 1;
                        TX_State <= st_TX_DataBits;
                    end if;
                -----------------
                -- DATA BITS
                -----------------
                when st_TX_DataBits => 
                    s_TXBit <= s_TxData(s_BitIndex); -- send out given bit
                    s_TxIsBusy <= '1';
                    if s_ClockCounter < s_ClkPerBit then 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else 
                        s_ClockCounter <= 1;
                        if s_BitIndex = DataLen-1 then -- if last bit has been sent 
                            s_BitIndex <= 0;
                            TX_State <= st_TX_StopBit;
                        else 
                            s_BitIndex <= s_BitIndex + 1;
                        end if; 
                    end if;
                -----------------
                -- STOP BIT
                -----------------
                when st_TX_StopBit => 
                    s_TxBit <= '1'; -- stop bit is the last "1" in frame
                    s_TxIsBusy <= '1';
                    if s_ClockCounter < s_ClkPerBit then 
                        s_ClockCounter <= s_ClockCounter + 1;
                    else 
                        TX_State <= st_TX_Idle;
                    end if;
            end case; -- TX_State
            
        end if;
    end process; -- TRANSMIT FRAME
    
    out_TxBit <= s_TxBit;
    out_TxIsBusy <= s_TxIsBusy;    
    
end Transmitter; -- ARCHITECTURE TRANSMITTER
