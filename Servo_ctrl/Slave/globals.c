#include "globals.h"
#include "gpio_hdlr.h"
#include "motor_wrapper.h"
#include "can_hdlr.h"

void init_periphs() {
    /* Start Initialization */
    dled_init();    // LEDs
    // Motor drivers
    RED_LED = ON;
    motor_init();
    RED_LED = OFF;
    // CAN
    RED_LED = ON;
    init_can();
    RED_LED = OFF;
    // End Initialization
    GREEN_LED = ON;
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

void raw_delay(unsigned int val) {
    unsigned int i, j;
    for (i = 0; i < val; i++)
        for (j = 0; j < 500; j++);
}
