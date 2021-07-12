# MPLAB IDE generated this makefile for use with GNU make.
# Project: Master.mcp
# Date: Fri Feb 21 15:57:51 2020

AS = pic30-as.exe
CC = pic30-gcc.exe
LD = pic30-ld.exe
AR = pic30-ar.exe
HX = pic30-bin2hex.exe
RM = rm

Master.hex : Master.cof
	$(HX) "Master.cof"

Master.cof : globals.o gpio.o main.o can_hdlr.o uart_hdlr.o timer_hdlr.o
	$(CC) -mcpu=30F4011 "globals.o" "gpio.o" "main.o" "can_hdlr.o" "uart_hdlr.o" "timer_hdlr.o" "C:\Program Files (x86)\Microchip\MPLAB C30\lib\libp30F4011-coff.a" -o"Master.cof" -Wl,-L"C:\Program Files (x86)\Microchip\MPLAB C30\lib",--script="..\..\..\..\..\..\..\Program Files (x86)\Microchip\MPLAB C30\support\gld\p30f4011.gld",--defsym=__MPLAB_BUILD=1,-Map="Master.map",--report-mem

globals.o : uart_hdlr.h can_hdlr.h timer_hdlr.h gpio.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h globals.c
	$(CC) -mcpu=30F4011 -x c -c "globals.c" -o"globals.o" -g -Wall

gpio.o : gpio.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h gpio.c
	$(CC) -mcpu=30F4011 -x c -c "gpio.c" -o"gpio.o" -g -Wall

main.o : uart_hdlr.h can_hdlr.h gpio.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h main.c
	$(CC) -mcpu=30F4011 -x c -c "main.c" -o"main.o" -g -Wall

can_hdlr.o : ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/peripheral_30F_24H_33F/timer.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/peripheral_30F_24H_33F/can.h gpio.h can_hdlr.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h can_hdlr.c
	$(CC) -mcpu=30F4011 -x c -c "can_hdlr.c" -o"can_hdlr.o" -g -Wall

uart_hdlr.o : can_hdlr.h gpio.h uart_hdlr.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/peripheral_30F_24H_33F/uart.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h uart_hdlr.c
	$(CC) -mcpu=30F4011 -x c -c "uart_hdlr.c" -o"uart_hdlr.o" -g -Wall

timer_hdlr.o : uart_hdlr.h can_hdlr.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/peripheral_30F_24H_33F/timer.h timer_hdlr.h gpio.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30f4011.h ../../../../../../../program\ files\ (x86)/microchip/mplab\ c30/support/h/p30fxxxx.h globals.h timer_hdlr.c
	$(CC) -mcpu=30F4011 -x c -c "timer_hdlr.c" -o"timer_hdlr.o" -g -Wall

clean : 
	$(RM) "globals.o" "gpio.o" "main.o" "can_hdlr.o" "uart_hdlr.o" "timer_hdlr.o" "Master.cof" "Master.hex"

