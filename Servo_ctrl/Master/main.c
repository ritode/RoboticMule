#include "globals.h"
#include "gpio.h"
#include "can_hdlr.h"
#include "uart_hdlr.h"

// Configurations for the microcontroller
_FOSC(CSW_FSCM_OFF & XT_PLL8);
_FWDT(WDT_OFF);

void delay_ms(unsigned int ms) {    // TODO: Fix this, very unprofessional
    unsigned int i, j;
    for (i = 0; i < ms; i++)
        for (j = 0; j < 4000; j++);
}

int main()
{
    // Initialize everything
    init_periphs();
    while(1);
    return 0;
}
