#include "globals.h"
#include "gpio.h"

void dled_init() {
    RED_LED_SETUP = OUTPUT;
    RED_LED = OFF;
    GREEN_LED_SETUP = OUTPUT;
    RED_LED = OFF;
}

void raw_delay(unsigned int val) {
    unsigned int i, j;
    for (i = 0; i < val; i++)
        for (j = 0; j < 500; j++);
}

void error_loop() {
    while(1) {
        GREEN_LED = ON;
        RED_LED = OFF;
        raw_delay(1000);
        GREEN_LED = OFF;
        RED_LED = ON;
        raw_delay(1000);
    }
}
