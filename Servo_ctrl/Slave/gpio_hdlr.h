#ifndef __GPIO_HDLR_H
#define __GPIO_HDLR_H

// Debugger LEDs on board
#define RED_LED_SETUP TRISBbits.TRISB2
#define RED_LED LATBbits.LATB2
#define GREEN_LED_SETUP TRISBbits.TRISB1
#define GREEN_LED LATBbits.LATB1
// GPIO Mode settings
#define OUTPUT 0x0
#define INPUT 0x1
// GPIO I/O levels
#define HIGH 0x1
#define LOW 0x0
#define ON HIGH
#define OFF LOW

// Functions
/*
 * Initialize debugger LEDs
 */
void dled_init();   // Initialize debugger LEDs

#endif
