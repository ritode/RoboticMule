#ifndef __PERIPHS_H
#define __PERIPHS_H

// The line below is only for VSCode intellisense to work, uncomment if 
// using another IDE or programming to microcontroller
#define _USING_VSCODE_    // ========= VSCode Editor line =========
// Above line if for VSCode Intellisense features only
#ifdef _USING_VSCODE_
    // Guard against multiple declarations
    #ifndef __dsPIC30F__
        #define __dsPIC30F__
    #endif
    #ifndef __dsPIC30F4011__
        #define __dsPIC30F4011__
    #endif
    #error "_USING_VSCODE_ should not be defined while uploading"
#endif
// Main PIC library
#include <p30fxxxx.h>

// Frequencies
#define MHz (float) 1e6                         // 1 MHz = 10^6 Hz
#define OSC_ext (float) (10*(MHz))              // Clock frequency of externally attached clock source
#define PLL_mul (float) 8                       // PLL multiplier mode (x8)
#define F_OSC (float) (PLL_mul * (OSC_ext))     // Oscillator frequency
#define F_CY (float) ( (F_OSC)/((float)4) )      // MIPS frequency
// Addresses
// CAN
// Leg (conventions given based on robot's own frame)
enum LEG_POS {
    LEG_FRONT_LEFT = 0b00,  // (+1, +1) coordinate leg
    LEG_REAR_LEFT = 0b01,   // (-1, +1) coordinate leg
    LEG_REAR_RIGHT = 0b10,  // (-1, -1) coordinate leg
    LEG_FRONT_RIGHT = 0b11  // (+1, -1) coordinate leg
};
// Joint
enum JOINT_POS {
    JOINT_KNEE = 0b00,      // Knee joint
    JOINT_HIP_LOWER = 0b01, // Lower hip joint (hip joint closer to knee)
    JOINT_HIP_UPPER = 0b10  // Upper hip joint (hip joint closer to body frame)
};
// <user configuration area: begin>
#define LEG_NO LEG_FRONT_RIGHT  // Leg on which the slave is
#define JOINT_NO JOINT_KNEE     // Joint for which the slave is
// <user configuration area: end>
#define COMB_ADDR ( ((LEG_NO << 2) | JOINT_NO) & 0x000F )  // Combined address of the leg (4 bits)

// Functions
/*
 * Initialize the peripherals on the board
 */
void init_periphs();    // Initialize all peripherals
/*
 * Error loop (infinite)
 */
void error_loop();
/*
 * Delay
 * Parameters:
 *  - val: Value of delay in ms
 */
void raw_delay(unsigned int val);

#endif
