#ifndef __MOTOR_WRAPPER_H
#define __MOTOR_WRAPPER_H

// Gearbox
#define GEAR_RATIO 230.0
// Encoder
#define ENC_PPR 256.0   // Counts per revolution
#define MATCH_COUNT 2.0 // 2x mode or 4x mode (see in motor_eqi_init function)
#define ENC_PPD ((MATCH_COUNT*GEAR_RATIO*ENC_PPR)/(360.0))  // Number of pulses per degree of rotation
#define ROLLOVER_BW 0x7FFF  // Number of pulses in one rollover
// Polulu Motor driver (MCPWM)
// Motor Direction pin
#define M_DIR_SETUP TRISEbits.TRISE4    // Direction pin TRIS bit (direction)
#define M_DIR LATEbits.LATE4	// Direction bit is 3L (or RE4)
#define POSITIVE ON // Positive rotation direction
#define NEGATIVE LOW    // Negative rotation direction
// PWM
#define M_PWM_NO 3	// PWM on 3H
// Drive RESET
#define M_DRV_RESET_SETUP TRISEbits.TRISE3  // Drive reset TRIS pin (direction)
#define M_DRV_RESET LATEbits.LATE3	// Motor Driver reset pin
// Motor driver PWM configurations
#define T_PERIOD 0x320

// ISRs
// Motor QEI interrupt service routine
#ifdef _USING_VSCODE_
#define _ISR_QEI _QEIInterrupt
#else
#define _ISR_QEI __attribute__((interrupt, no_auto_psv)) _QEIInterrupt
#endif

// Functions
/*
 * Initialize everything in motor driver
 * motor_pwm_init()
 * motor_qei_init()
 */
void motor_init();
/* 
 * Initialize QEI (Encoder feedback)
 * Connections:
 *  PHA -> QEA
 *  PHB -> QEB
 *  PHC -> INDX
 */
void motor_qei_init();
// Initialize Motor PWM
void motor_pwm_init();
// Motor control loop (single pass)
void motor_ctrl_loop_single();
/*
 * Set motor duty cycle
 * dc: Duty cycle (0 to 100 percent)
 */
void motor_set_dc(float dc);
/*
 * Current Encoder Position
 * Read the current position on the encoder and accordingly return the angle (in degrees)
 * Number of rollovers are also adjusted
 */
float current_enc_pos();
/*
 * Set the set point to a new value
 * value: New set point
 * 
 * This function guarantees execution and return
 */
void set_pos_SP(float value);
#endif
