#include "globals.h"    // Configurations
#include "gpio.h"       // GPIO Support
#include "timer_hdlr.h" // Main library
#include <timer.h>      // Timer functions
#include "can_hdlr.h"   // CAN functions
#include "uart_hdlr.h"  // UART functions

void timers_init() {
    // Initialize timer for getting joint angle feedbacks
    OpenTimer_JF(
        T_JF_INIT    &      // Initialize mode of JF timer
        T_JF_IDLE_OPR   &   // JF Timer operation in Idle mode
        T_JF_GATE_MODE  &   // JF Timer gate mode
        T_JF_PS         &   // JF Timer prescalar
        // No Synchronous clock for JF timer
        T_JF_CLK_SRC        // JF Timer clock source 
        ,
        T_JF_PR_REG_VAL
    );
    ConfigIntTimer_JF(
        T_JF_INT_PRI    &   // JF Timer interrupt priority
        T_JF_INT_STATE      // JF Timer interrupt state
    );
}

void _ISR_JF() {
    RED_LED = ON;
    // Read Joint Feedback and send to computer
    // TODO: Currently, only one joint. Expand to multiple
    float ang = can_req_fbk(0b0000, CAN_FBK_QEI_CURR);
    uart_send_float(ang);
    RED_LED = OFF;
    _T4IF = 0;  // Exit interrupt with resetting interrupt flag
}
