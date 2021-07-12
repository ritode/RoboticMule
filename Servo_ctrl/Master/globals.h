/*
 * Contains global configurations for the robot and code for all files
 */
#ifndef __GLOBALS_H
#define __GLOBALS_H

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
    #error "_USING_VSCODE_ should not be declared while uploading"
#endif
// Main core files
#include <p30fxxxx.h>

// Configuration files
// Frequencies
#define MHz (float) 1e6                         // 1 MHz = 10^6 Hz
#define OSC_ext (float) (10*(MHz))              // Clock frequency of externally attached clock source
#define PLL_mul (float) 8                       // PLL multiplier mode (x8)
#define F_OSC (float) (PLL_mul * (OSC_ext))     // Oscillator frequency
#define F_CY (float) ( (F_OSC)/((float)4) )      // MIPS frequency

// Functions
/*
 * Initialize peripherals on the board
 */
void init_periphs();

#endif
