/*
 * CAN Handler
 */
#ifndef __CAN_HDLR_H
#define __CAN_HDLR_H

// Definitions
// Configurations
// Aliases
#define CAN_OPMODE C1CTRLbits.OPMODE
#define CAN_OPCODE_CONFIG 0b100
#define CAN_OPCODE_NORMAL 0b000

// CAN Settings

// MACRO definitions
// CAN address heads
#define CAN_ADDR_ANGLE_BIT 6    // Bit position of Address bit in SID head
#define CAN_ADDR_FBK_BIT 5      // Bit position of Feedback bit in SID head
// Address IDs
#define CAN_FBK_QEI_CURR (unsigned int) 100    // Address ID of QEI (current)
// Address head for an angle message (returns head in bit number 4 to 10 (inclusive))
#define CAN_ADDR_HEAD_ANGLE ( (~( (unsigned int)(0b1 << (CAN_ADDR_ANGLE_BIT + 4)) )) & 0x07F0 )
// Address head for a Feedback message (returns head in bit number 4 to 10 (inclusive))
#define CAN_ADDR_HEAD_FBK ( (~( (unsigned int)(0b1 << (CAN_ADDR_FBK_BIT + 4)) )) & 0x07F0 )
/* 
 * CAN angle address (SID) for joint `x`
 * Address packet for angle of joint `x`
 * Parameters:
 *  - x: 4 bits, `abcd`:
 *                  `ab`: Leg number (0b00, 0b01, 0b10 or 0b11)
 *                  `cd`: Joint number (0b00, 0b01 or 0b10)
 * Output:
 * - Attaches address head for angle and puts `x` in bit 0 to 3 (inclusive)
 *      The entire SID for Angle of joint `x`
 */
#define CAN_ADDR_ANGLE(x) (unsigned int) ( CAN_ADDR_HEAD_ANGLE | ((x) & 0xF) )
/*
 * CAN Feedback address (SID) for joint `x`
 * Address packet for getting the Feedback value of joint `x`
 * Parameters:
 *  - x: 4 bits, `abcd`:
 *                  `ab`: Leg number (0b00, 0b01, 0b10 or 0b11)
 *                  `cd`: Joint number (0b00, 0b01 or 0b10)
 * Output:
 * - Attaches address head for Feedback and puts `x` in bit 0 to 3 (inclusive). 
 *      The entire SID for Feedback of joint `x`
 */
#define CAN_ADDR_FBK(x) (unsigned int) ( CAN_ADDR_HEAD_FBK | ((x) & 0xF) )

// ISRs
// CAN interrupt service routine (_ISR_C1)
#ifdef _USING_VSCODE_
#define _ISR_C1 _C1Interrupt
#else
#define _ISR_C1 __attribute__((interrupt, no_auto_psv)) _C1Interrupt
#endif

// Functions 
/*
 * Initialize CAN interface
 */
void can_init();
/*
 * Send a message containing joint angle through CAN interface to slaves
 * Parameters:
 *  - txData: Floating point number to send
 *  - jaddr: Joint address of form 0xabcd, ab -> leg number and cd -> joint number
 * 
 */
void can_send_angle_joint_addr(float txData, unsigned int jaddr);
/*
 * Send a message through CAN interface
 * Parameters:
 *  - (unsigned char *)data: Address of the data to be sent
 *  - datalen: Length of data to be sent
 *  - sid: Standard 11 bit identifier of the data to be sent (it's unsigned int (16 bits) masked to 11 LSBs)
 *  - msgflag: Message flag (transmit buffer 0, 1, or 2 to use)
 * Note: This function uses 11bit sid address, eid is 0 (23 bits) and is disabled in the transmit bit
 */
void can_send_msg(unsigned char *data, unsigned char datalen, unsigned int sid, char msgflag);
/*
 * Request CAN feedback and receive response as float
 * Parameters:
 *  - jaddr (unsigned int): The joint address as `abcd`. `ab` being leg number and `cd` being joint number
 *  - ID (unsigned int): The address ID of response (The ID of the feedback message)
 *      - Possible Values: CAN_FBK_QEI_CURR
 * 
 * Notes:
 * // TODO: Add some timeout in this to return with no value
 */
float can_req_fbk(unsigned int jaddr, unsigned int ID);

#endif
