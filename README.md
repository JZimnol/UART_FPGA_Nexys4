# UART_FPGA_Nexys4
The project consisted in implementing a simple UART (universal asynchronous receiver-transmitter) TxRx on a FPGA board based on a simple state machine. This circuit can be used for communication between e.g. our FPGA circuit and various peripheral circuits or other FPGA circuits. In my system, the basic version of the interface has been implemented, i.e. when transmitting and receiving a data frame, only one stop bit is assumed, no parity bit and an 8-bit data packet. In further stages, the project may be extended with the possibility of modifying the above-mentioned configuration.

## Functional description
The project was implemented on the Digilent Nexys 4 DDR (Artix-7) development board:
<p align="center">
<img src="https://github.com/JZimnol/UART_FPGA_Nexys4/blob/main/img/Nexys4.png" width="550">
</p>
<p align="center">
Digilent Nexys 4 DDR
</p>

We can distinguish 6 different and most important sections:
  1. SW(15:13) buttons responsible for selecting the baud rate of both the transmitter and the receiver  <br />  

     | __Sw(15:13)__ | "000" | "001" | "010" | "011" | "100" | "101" |  "110" |  "111" |
     |:---------:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:------:|:------:|
     | __Baud Rate__ |  2400 |  4800 |  9600 | 19200 | 38400 | 57600 | 115200 | 115200 |

2. SW(7:0) buttons responsible for the selection of eight bits of data sent by the TX transmitter (in binary format); SW[7] is responsible for the MSB of the sent byte and SW[0] for the LSB of the sent byte
3. two digits of the 7-segment display used to display the received byte; because the received byte can have a value in the range 0-127, it is displayed in hexadecimal notation (e.g. the letter "n" from the terminal will be displayed as "6E")
4. two LEDs responsible for signaling the use of the receiver modules (LED[1]) and the transmitter (LED[0])
5. output of the transmitter and the input of the receiver to the UART-USB FTDI FT2232HQ converter, thanks to which you can use UART communication with a computer without using any external modules; the converter also has LEDs that signal active transmission on the RX and TX lines
6. button section with the BTNC button (middle button), which is responsible for starting the transmission of the TX 

All correctly received data by the system are displayed in hexadecimal format on the 7-segment display; to send a data byte, set the SW(7:0) switches and press the BTNC button (note: one press of the button is responsible for sending one data frame). Depending on the needs and the device with which we communicate, we can choose the transmission speed we are interested in using SW(15:13) switches.

## Block diagram 
<p align="center">
<img src="https://github.com/JZimnol/UART_FPGA_Nexys4/blob/main/img/block_diagram.png" width="800">
</p>
<p align="center">
Block diagram (exported from Active-HDL .bde file)
</p>

In the system, we can distinguish 5 functional blocks:

* __Prescaler__: responsible for rescaling the system clock 1,000,000 times (here: from the 100 MHz input clock it creates a 100 Hz clock)
* __Debouncer__: responsible for the reduction of vibration of the BTNC button contacts; its additional function is to make sure that the high state coming from the button does not last longer than 3 clock ticks of the system clock
* __Receiver__: responsible for receiving data frames from an external device; it is clocked by the system clock and parallel data from its output is decoded into a 7-segment display format
* __Transmitter__: responsible for sending data frames; it is clocked by the system clock and it takes parallel data from switches, which, after receiving the start signal, converts it into serial data
* __seven_seg_decoder__: responsible for converting the parallel data received from the receiver into the segment display format; it is also responsible for controlling the entire 7-segment display (all eight digits)


