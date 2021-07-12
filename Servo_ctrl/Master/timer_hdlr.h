#ifndef __TIMER_HDLR_H
#define __TIMER_HDLR_H

// Definitions
// Values for timer
#define TIMER_ON 1
#define TIMER_OFF 0
// -- Use Timer 4 for periodically collecting joint feedback (JF) --
#define _ISR_JF _ISR_T4 // Interrupt Service Routine for Joint Feedback
#define OpenTimer_JF OpenTimer4 // Setup function for T4
#define ConfigIntTimer_JF ConfigIntTimer4   // Configure interrupt for T4
#define T_JF_INT_PRI T4_INT_PRIOR_2 // Interrupt priority for T4
#define T_JF_INT_STATE T4_INT_ON    // Interrupt state for T4
// Timer for joint feedback (Timer 4) configuration parameters
#define T_JF_TON T4CONbits.TON      // TON in T4CON
#define T_JF_INIT T4_ON             // T4 state at initialization
#define T_JF_IDLE_OPR T4_IDLE_CON   // Continue T4 in idle mode
#define T_JF_GATE_MODE T4_GATE_OFF  // Don't use gate for T4
#define T_JF_PS T4_PS_1_64          // Prescalar for T4 (1:64)
#define T_JF_PRESCALAR (float) 64   // Prescalar for T4 (1:64)
#define T_JF_CLK_SRC T4_SOURCE_INT  // Use internal clock for T4
#define T_JF_FREQ_REQ (float) 100   // Required frequency for JF to run
#define T_JF_PR_REG_VAL (unsigned int) ((F_CY) / (T_JF_FREQ_REQ * T_JF_PRESCALAR))
// Functions
/*
 * Initialize timer interface
 */
void timers_init();

// ISRs
// Timer 4 Interrupt (Joint Feedback)
#ifdef _USING_VSCODE_
#define _ISR_T4 _T4Interrupt
#else
#define _ISR_T4 __attribute__((interrupt, no_auto_psv)) _T4Interrupt
#endif


#endif
