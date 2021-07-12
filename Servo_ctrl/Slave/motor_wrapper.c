// Dependencies
#include "globals.h"
#include "gpio_hdlr.h"
// Peripheral libraries
#include <pwm.h>
#include <qei.h>

#include "motor_wrapper.h"

// Variables
volatile int num_rollovers = 0; // Keep track of rollovers
// Controller parameters
volatile float SP = 0;  // Set point
volatile float CP = 0;  // Current point
float error, previous_error = 0, motor_pwm_dc; 
volatile float KP = 1, KD = 0;

void motor_init() {
    // Motor Driver initialization
    motor_pwm_init();
    motor_qei_init();
    M_DRV_RESET = HIGH; // Enable motor driver
}

void motor_pwm_init() {
    // Set I/O pins
    M_DRV_RESET_SETUP = OUTPUT; // Motor Driver RESET pin
    M_DRV_RESET = LOW;  // Set it HIGH after all configuration is done
    M_DIR_SETUP = OUTPUT;   // Direction pin
    M_DIR = POSITIVE;   // Positive direction
    // Initialize PWM
    OpenMCPWM(
		T_PERIOD
		,
		0x0
		,
		PWM_EN & 
		PWM_MOD_FREE & 
		PWM_IPCLK_SCALE1 
		, 
		PWM_MOD3_IND & 
		PWM_PEN3H & 
		PWM_PDIS3L & 
		PWM_PDIS2H & 
		PWM_PDIS2L
		, 
		PWM_UEN & 
		PWM_OSYNC_PWM
	);
}

void motor_qei_init() {
    // Set ADC pins miltiplexed with QEI channels
    // to Digital Input.
    ADPCFGbits.PCFG3 = 1;
    ADPCFGbits.PCFG4 = 1;
    ADPCFGbits.PCFG5 = 1;
    POSCNT = 0x8000;    // Zero position of the encoder
    MAXCNT =0xFFFF;
    ConfigIntQEI(QEI_INT_ENABLE & QEI_INT_PRI_1);   // Configure QEI interrupt with LOW priority
    OpenQEI(
        QEI_INT_CLK &
        QEI_INDEX_RESET_DISABLE &
        QEI_GATED_ACC_DISABLE   &
        QEI_NORMAL_IO   &
        QEI_INPUTS_NOSWAP   &
        QEI_MODE_x2_MATCH   &
        QEI_UP_COUNT    &
        QEI_DIR_SEL_CNTRL   &
        QEI_IDLE_CON
        ,
        0
    );
}

void _ISR_QEI() {
    // Overflow has occurred in the position count register
    if (_UPDN == 1) {   // Up counting
        num_rollovers += 1;
    } else if (_UPDN == 0) {    // Down counting
        num_rollovers -= 1;
    }
    POSCNT = 0x8000;    // Reset position count
    _QEIIF = 0; // Clear interrupt flag
}

void motor_ctrl_loop_single() {
    CP = current_enc_pos();
    error = SP - CP;
    float p_part = KP * error;
    float d_part = KD * (error - previous_error);
    float pwm = p_part - d_part;
    if (pwm >= 0) {
        M_DIR = POSITIVE;
    } else if (pwm < 0) {
        pwm = -pwm; // Make PWM always positive
        M_DIR = NEGATIVE;
    }
    motor_set_dc(pwm);
    motor_pwm_dc = pwm;
    previous_error = error;
}

void motor_set_dc(float dc) {
    unsigned int val = T_PERIOD * dc / 100.0;   // Calculate the duty cycle to be written in the register
    SetDCMCPWM(M_PWM_NO, val << 1, 0);
}

float current_enc_pos() {
    // If the MSB of POSCNT is 1, then the number is positive. If it's 0, then negative. Toggle the MSB and convert to 16 bit signed integer
    // The 16 bit signed integer is then extended to a 32 bit floating point number (32 bits) for further use
    float enc_current_pos = (float)((int)(ReadQEI() ^ (1 << 15))); 
    float enc_rollover_pulses = (float)num_rollovers * ROLLOVER_BW;
    float total_pulses = enc_current_pos + enc_rollover_pulses;
    float angle_deg = total_pulses / ENC_PPD;
    return angle_deg;   // Return angle in degrees
}

void set_pos_SP(float value) {
    SP = value; // Set the set point
}
