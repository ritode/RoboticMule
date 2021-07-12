/*
 * General Purpose Input and Output for the master board
 */
#ifndef __GPIO_H
#define __GPIO_H

// Definition parameters
// GPIO Mode settings
#define OUTPUT 0x0  // TRIS as 0
#define INPUT 0x1   // TRIS as 1
// GPIO I/O levels (For Latch and Port registers)
#define HIGH 0x1
#define LOW 0x0
#define ON HIGH
#define OFF LOW

// Debugger LEDs on board
#define RED_LED_SETUP TRISBbits.TRISB2  // RED LED Setup (TRIS)
#define RED_LED LATBbits.LATB2  // RED LED Output (LATCH)
#define GREEN_LED_SETUP TRISBbits.TRISB1    // GREEN LED Setup (TRIS)
#define GREEN_LED LATBbits.LATB1    // GREEN LED Output (LATCH)

// Functions
/*
 * Initialize debugger LEDs
 */
void dled_init();
/*
 * Indefinite state error occurred
 */
void error_loop();

#endif
