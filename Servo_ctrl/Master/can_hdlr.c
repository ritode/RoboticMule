#include "globals.h"
#include "can_hdlr.h"
#include "gpio.h"
#include <can.h>
#include <timer.h>

// Can filters and addresses
#define RX_M0_SID ( 0x07FF )	// RX0M0 is not used
#define RX_F0_SID ( (unsigned int)(0) & 0x07FF )	// RX0F0 is not used
#define RX_F1_SID ( (unsigned int)(0) & 0x07FF )	// RX0F1 is not used
#define RX_M1_SID ( (~CAN_ADDR_HEAD_FBK) & 0x7FF )	// RX1M1 used for FBK
#define RX_F2_SID ( (CAN_ADDR_FBK(0b1111)) & 0x7FF )	// RX1F2 used for FBK
#define RX_F3_SID ( (unsigned int)(0) & 0x07FF )	// RX1F3 is not used
#define RX_F4_SID ( (unsigned int)(0) & 0x07FF )	// RX1F4 is not used
#define RX_F5_SID ( (unsigned int)(0) & 0x07FF )	// RX1F5 is not used

void can_init() {
	// CAN Interrupt configurations
	ConfigIntCAN1(
		CAN_INDI_INVMESS_DIS	&	// Disable interrupt on invalid message received
		CAN_INDI_WAK_DIS	&	// Disable Bus wake up activity interrupt
		CAN_INDI_ERR_EN	&		// Enable interrupt on bus error
		CAN_INDI_TXB0_DIS	&	// Disable interrupt on TX0
		CAN_INDI_TXB1_DIS	&	// Disable interrupt on TX1
		CAN_INDI_TXB2_DIS	&	// Disable interrupt on TX2
		CAN_INDI_RXB0_DIS	&	// Disable interrupt on RX0
		CAN_INDI_RXB1_DIS		// Disable interrupt on RX1
		,
		CAN_INT_ENABLE	&		// Enable interrupt on low priority
		CAN_INT_PRI_3
	);
    CAN1SetOperationMode(
        CAN_IDLE_CON    &   		// Continue in idle mode
        CAN_MASTERCLOCK_1   &		//Fcan = Fcy
        CAN_REQ_OPERMODE_CONFIG &	// Configuration mode (to make changes)
        CAN_CAPTURE_DIS				// Disable CAN Capture
    );
    while (CAN_OPMODE != CAN_OPCODE_CONFIG);    // Wait till configuration mode
    /* Start configurations */
    // Initialize
    CAN1Initialize(
		CAN_SYNC_JUMP_WIDTH1 &				// 1Tq Jump width
	 	CAN_BAUD_PRE_SCALE(1)				// Tq = 2/Fcan
	 	,
	 	CAN_WAKEUP_BY_FILTER_DIS & 			// Don't wake up by bus line
		 	// Phase segment lengths (for reading bits)
	 	CAN_PHASE_SEG2_TQ(1) & 	
	 	CAN_PHASE_SEG1_TQ(3) & 
	 	CAN_PROPAGATIONTIME_SEG_TQ(3) & 
	 	CAN_SEG2_FREE_PROG & 				// Freely programmable segment 2
	 	CAN_SAMPLE1TIME						// Sample only once at the same point
	);
    // Set filter addresses and masks
	// RB0
	CAN1SetFilter(0,	// RX0F0
		CAN_FILTER_SID(RX_F0_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetFilter(1,	// RX0F1
		CAN_FILTER_SID(RX_F1_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetMask(0,	// RX0M0
		CAN_MASK_SID(RX_M0_SID) & CAN_MATCH_FILTER_TYPE,
		CAN_MASK_EID(0)
	);
	// RB1
	CAN1SetFilter(2,	// RX1F2
		CAN_FILTER_SID(RX_F2_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetFilter(3,	// RX1F3
		CAN_FILTER_SID(RX_F3_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetFilter(4,	// RX1F4
		CAN_FILTER_SID(RX_F4_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetFilter(5,	// RX1F5
		CAN_FILTER_SID(RX_F4_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetMask(1,	// RX1M1
		CAN_MASK_SID(RX_M1_SID) & CAN_MATCH_FILTER_TYPE,
		CAN_MASK_EID(0)
	);
    // Set TX and RX Modes
    // Tx modes
	CAN1SetTXMode(0,	// TX0
     	CAN_TX_STOP_REQ & CAN_TX_PRIORITY_HIGH
	);
	CAN1SetTXMode(1,	// TX1
		CAN_TX_STOP_REQ & CAN_TX_PRIORITY_HIGH_INTER
	);
	CAN1SetTXMode(2,	// TX2
		CAN_TX_STOP_REQ & CAN_TX_PRIORITY_LOW
	);
	// Rx modes
	CAN1SetRXMode(0,			// RX0
    	CAN_RXFUL_CLEAR & CAN_BUF0_DBLBUFFER_DIS
	);
	CAN1SetRXMode(1,		// RX1
		CAN_RXFUL_CLEAR
	);
    /* Setup complete */
    // Change to normal mode
	CAN1SetOperationMode(
		CAN_IDLE_CON    &				// Continue in idle mode
		CAN_MASTERCLOCK_1   &			// Fcan = Fcy
		CAN_REQ_OPERMODE_NOR    &		// Normal operation mode
		CAN_CAPTURE_DIS					// Disable CAN capture (no timer input capture)
	);
	while(CAN_OPMODE != CAN_OPCODE_NORMAL);	// Wait for mode to change to normal mode (all filters and masks hide)
    // Done configuring CAN
}

void can_send_angle_joint_addr(float txData, unsigned int jaddr) {
	// Encode and send as plain CAN message
	can_send_msg(
		(unsigned char *)&txData,	// Data to send
		4,							// float has 4 bytes data length
		CAN_ADDR_ANGLE(jaddr),		// Joint address (encoded as CAN SID)
		0							// Use TX0
	);
	if (C1INTFbits.TX0IF == 1) {
		C1INTFbits.TX0IF = 0;
	}
}

void can_send_msg(unsigned char *data, unsigned char datalen, unsigned int sid, char msgflag) {
	// Send data through CAN
	CAN1SendMessage(
		(CAN_TX_SID(sid & 0x7FF)) & 	// SID address (unsigned int to 11 bit SID)
		CAN_TX_EID_DIS & 				// No extended ID
		CAN_SUB_NOR_TX_REQ				// No remote transmit request
		, 
		(CAN_TX_EID(0)) & 				// EID is 0 (no EID)
		CAN_NOR_TX_REQ					// No remote transmit request
		, 
		data, datalen, msgflag			// Transmit `data` (length `datalen`) using msgflag TX buffer
	);
	while (!CAN1IsTXReady(msgflag));	// Wait till TX buffer `msgflag` is empty (message is sent)
}

float can_req_fbk(unsigned int jaddr, unsigned int ID) {
	// Send feedback mesage with SID
	can_send_msg(
		(unsigned char*) &ID, 2,	// Send ID of 2 bytes as data
		CAN_ADDR_FBK(jaddr),		// Send to joint address
		1							// Use TX1
	);
	if (C1INTFbits.TX1IF == 1) {
		C1INTFbits.TX1IF = 0;
	}
	// Receive feedback message
	float ret_value;
	while (!CAN1IsRXReady(1));	// Wait till a message comes in RX1 // TODO: Add some sort of timeout here
	CAN1ReceiveMessage((unsigned char*)&ret_value, 4,
		1	// Read feedbacks from RX1
	);
	C1RX1CONbits.RXFUL = 0;	// Message successfully read
	return ret_value;
}

void _ISR_C1() {	// CAN Interrupt occurred
	RED_LED = ON;
	// Fix any errors
	if (C1INTFbits.ERRIF == 1) {
		if (C1INTFbits.RX0OVR == 1) {

			C1INTFbits.RX0OVR = 0;
		}
		if (C1INTFbits.RX1OVR == 1) {
			C1INTFbits.RX1OVR = 0;
		}
		C1INTFbits.ERRIF = 0;	// Errors fixed
		error_loop();	// TODO: Create a fix for this
	}
	RED_LED = OFF;
	_C1IF = 0;
}
