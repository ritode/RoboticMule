#ifndef __CAN_HDLR_H
#define __CAN_HDLR_H

// MACRO definitions
// CAN address heads
#define CAN_ADDR_ANGLE_BIT 6    // Bit position of Address bit in SID head
#define CAN_ADDR_FBK_BIT 5      // Bit position of Feedback bit in SID head
// Address IDs
#define CAN_FBK_QEI_CURR (unsigned int) 100    // Address ID of QEI (current)
//#define CAN_FBK_TX_BUFFER 1     // Use TX1 to transmit feedback messages  // TODO: Find a way to implement this
// Address head for an angle message (returns head in bit number 4 to 10 (inclusive), zeros in bit number 0 to 3)
#define CAN_ADDR_HEAD_ANGLE ( (~( (unsigned int)(0b1 << (CAN_ADDR_ANGLE_BIT + 4)) )) & 0x07F0 )
// Address head for a QEI Feedback message (returns head in bit number 4 to 10 (inclusive), zeros in bit number 0 to 3)
#define CAN_ADDR_HEAD_FBK ( (~( (unsigned int)(0b1 << (CAN_ADDR_FBK_BIT + 4)) )) & 0x07F0 )
/* 
 * CAN angle address (SID) for joint `x`
 * Address packet for angle of joint x
 * Parameters:
 *  - x: 4 bits, `abcd`:
 *                  `ab`: Leg number (0b00, 0b01, 0b10 or 0b11)
 *                  `cd`: Joint number (0b00, 0b01 or 0b10)
 * Output:
 * - Attaches address head for angle and puts `x` in bit 0 to 3 (inclusive)
 */
#define CAN_ADDR_ANGLE(x) (unsigned int) ( CAN_ADDR_HEAD_ANGLE | ((x) & 0xF) )
/*
 * CAN Feedback address (SID) for joint `x`
 * Address packet for getting the Feedback value of joint `x`
 * Parameters:
 *  - x: 4 bits, `abcd`:
 *                  `ab`: Leg number (0b00, 0b01, 0b10 or 0b11)
 *                  `cd`: Joint number (0b00, 0b01 or 0b10)
 *                  `abcd` is `1111` for master
 * Output:
 * - Attaches address head for Feedback and puts `x` in bit 0 to 3 (inclusive).
 */
#define CAN_ADDR_FBK(x) (unsigned int) ( CAN_ADDR_HEAD_FBK | ((x) & 0xF) )
// Parameters
// CAN operation modes
#define CAN_OPMODE C1CTRLbits.OPMODE    // Operation mode register
#define CAN_OPCODE_CONFIG 0b100         // Configuration mode
#define CAN_OPCODE_NORMAL 0b000         // Normal operation mode
// Addresses
#define CAN_MASTER_ADDR 0b1111      // Address of CAN master
// ISRs
// CAN1 interrupt service routine
#ifdef _USING_VSCODE_
#define _ISR_CAN1 _C1Interrupt
#else
#define _ISR_CAN1 __attribute__((interrupt, no_auto_psv)) _C1Interrupt
#endif

// Functions
void init_can();    // Initialize CAN

#endif
