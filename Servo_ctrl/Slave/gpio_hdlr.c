// Dependencies
#include "globals.h"

#include "gpio_hdlr.h"
/*
 * Initialize the debugger LEDs as OUTPUT
 */
void dled_init() {
    RED_LED_SETUP = OUTPUT;
    RED_LED = OFF;
    GREEN_LED_SETUP = OUTPUT;
    RED_LED = OFF;
}
