-------------------------------------------------------------------------------
--
-- Title       : Top
-- Design      : UART_PSC
-- Author      : J.Zimnol
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- File        : -file_path-
-- Generated   : -generation_time-
-- From        : Top.bde
-- By          : ActiveHDL
--
-------------------------------------------------------------------------------
--
-- Description : file generated automatically by the ActiveHDL program
--
-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;

entity Top is
  port(
       in_CLK : in STD_LOGIC;
       in_RxBit : in STD_LOGIC;
       in_BeginSend : in STD_LOGIC;
       in_TxData : in STD_LOGIC_VECTOR(7 downto 0);
       in_ClockDivide : in STD_LOGIC_VECTOR(2 downto 0);
       out_TxIsBusy : out STD_LOGIC;
       out_RxIsBusy : out STD_LOGIC;
       out_TxBit : out STD_LOGIC;
       out_FirstAnode : out STD_LOGIC;
       out_SecondAnode : out STD_LOGIC;
       out_LED : out STD_LOGIC_VECTOR(6 downto 0);
       out_StaticAnodes : out STD_LOGIC_VECTOR(5 downto 0)
  );
end Top;

architecture Top of Top is

---- Component declarations -----

component Debouncer
  port(
       CLK : in STD_LOGIC;
       CLK_FAST : in STD_LOGIC;
       PUSH : in STD_LOGIC;
       PE : out STD_LOGIC
  );
end component;
component Prescaler
  port(
       CLK : in STD_LOGIC;
       CEO : out STD_LOGIC
  );
end component;
component Receiver
  generic(
       DataLen : INTEGER := 8
  );
  port(
       in_CLK : in STD_LOGIC;
       in_ClockDivide : in STD_LOGIC_VECTOR(2 downto 0);
       in_RxBit : in STD_LOGIC;
       out_RxData : out STD_LOGIC_VECTOR(DataLen-1 downto 0);
       out_RxIsBusy : out STD_LOGIC
  );
end component;
component seven_seg_decoder
  port(
       in_CLK : in STD_LOGIC;
       in_FirstDigit : in STD_LOGIC_VECTOR(3 downto 0);
       in_SecondDigit : in STD_LOGIC_VECTOR(3 downto 0);
       out_FirstAnode : out STD_LOGIC;
       out_SecondAnode : out STD_LOGIC;
       out_StaticAnodes : out STD_LOGIC_VECTOR(5 downto 0);
       out_LED : out STD_LOGIC_VECTOR(6 downto 0)
  );
end component;
component Transmitter
  generic(
       DataLen : INTEGER := 8
  );
  port(
       in_CLK : in STD_LOGIC;
       in_ClockDivide : in STD_LOGIC_VECTOR(2 downto 0);
       in_TxData : in STD_LOGIC_VECTOR(DataLen-1 downto 0);
       in_BeginSend : in STD_LOGIC;
       out_TxBit : out STD_LOGIC;
       out_TxIsBusy : out STD_LOGIC
  );
end component;

---- Signal declarations used on the diagram ----

signal CEO : STD_LOGIC;
signal NET741 : STD_LOGIC;
signal out_RxData : STD_LOGIC_VECTOR(7 downto 0);

begin

----  Component instantiations  ----

U1 : Receiver
  port map(
       in_CLK => in_CLK,
       in_ClockDivide => in_ClockDivide,
       in_RxBit => in_RxBit,
       out_RxData => out_RxData(7 downto 0),
       out_RxIsBusy => out_RxIsBusy
  );

U2 : Transmitter
  port map(
       in_CLK => in_CLK,
       in_ClockDivide => in_ClockDivide,
       in_TxData => in_TxData(7 downto 0),
       in_BeginSend => NET741,
       out_TxBit => out_TxBit,
       out_TxIsBusy => out_TxIsBusy
  );

U3 : Debouncer
  port map(
       CLK => CEO,
       CLK_FAST => in_CLK,
       PUSH => in_BeginSend,
       PE => NET741
  );

U4 : Prescaler
  port map(
       CLK => in_CLK,
       CEO => CEO
  );

U5 : seven_seg_decoder
  port map(
       in_CLK => CEO,
       in_FirstDigit(3) => out_RxData(7),
       in_FirstDigit(2) => out_RxData(6),
       in_FirstDigit(1) => out_RxData(5),
       in_FirstDigit(0) => out_RxData(4),
       in_SecondDigit(3) => out_RxData(3),
       in_SecondDigit(2) => out_RxData(2),
       in_SecondDigit(1) => out_RxData(1),
       in_SecondDigit(0) => out_RxData(0),
       out_FirstAnode => out_FirstAnode,
       out_SecondAnode => out_SecondAnode,
       out_StaticAnodes => out_StaticAnodes,
       out_LED => out_LED
  );


end Top;
