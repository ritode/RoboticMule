// Main header files
#include "globals.h"
// Header files for extended functionality
#include "gpio.h"   // GPIO
#include "timer_hdlr.h" // Timers
#include "can_hdlr.h"   // CAN
#include "uart_hdlr.h"  // UART

void init_periphs() {
    // Debugger LEDs
    dled_init();
    // CAN Setup
    RED_LED = ON;
    can_init();
    RED_LED = OFF;
    // Serial Setup
    RED_LED = ON;
    uart_init();
    RED_LED = OFF;
    // Timer Setup
    RED_LED = ON;
    // timers_init();	// TODO: Fix feedback issue
    RED_LED = OFF;
    // Setup completed
    GREEN_LED = ON;
}
