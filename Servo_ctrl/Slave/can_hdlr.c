// Dependencies
#include "globals.h"
#include "gpio_hdlr.h"
#include "can_hdlr.h"
#include "motor_wrapper.h"	// For set point 

// Include CAN header file
#include <can.h>

// Addresses
// For RX0
#define RX_M0_SID ((~CAN_ADDR_HEAD_ANGLE) & 0x7FF)	// Mask to accept for address fields (pass the ID, it'll be filtered)
#define RX_F0_SID ((CAN_ADDR_HEAD_ANGLE | COMB_ADDR) & 0x07FF)	// Filter 0 is used for receiving angles
#define RX_F1_SID ((unsigned int)(0) & 0x7FF)	// Filter 1 is not used
// For RX1
#define RX_M1_SID ((~CAN_ADDR_HEAD_FBK) & 0x7F0)	// Mask to accept for QEI feedback field (ID will be ignored, for now)
#define RX_F2_SID ((CAN_ADDR_HEAD_FBK) & 0x7FF )	// Filter 2 is used for receiving feedback requests
#define RX_F3_SID ((unsigned int)(0) & 0x7FF)	// Filter 3 is not used
#define RX_F4_SID ((unsigned int)(0) & 0x7FF)	// Filter 4 is not used
#define RX_F5_SID ((unsigned int)(0) & 0x7FF)	// Filter 5 is not used

/*
 * Initialize the CAN interface
 */
void init_can() {
    /* Setup started */
    // Configure interrupt ISR
    ConfigIntCAN1(
		CAN_INDI_RXB0_EN 	&       // Fire when RX0 receives a message
		CAN_INDI_RXB1_EN	&		// Fire when RX1 receives a message
		CAN_INDI_INVMESS_DIS	&	// Invalid Message received interrupt disable
		CAN_INDI_WAK_DIS	&		// Wake bus activity interrupt disable
		CAN_INDI_ERR_EN		&		// Error interrupt enable
		CAN_INDI_TXB2_DIS	&		// Transmit buffer 2 interrupt disable
		CAN_INDI_TXB1_DIS	&		// Transmit buffer 1 interrupt disable
		CAN_INDI_TXB0_DIS			// Transmit buffer 0 interrupt disable
		,
		CAN_INT_ENABLE & 	// Enable interrupt and set priority to 3
		CAN_INT_PRI_3
	);
    // Set operation mode to CONFIGURATION
	CAN1SetOperationMode(
		CAN_IDLE_CON        & 
		CAN_MASTERCLOCK_1   &
		CAN_REQ_OPERMODE_CONFIG &
		CAN_CAPTURE_DIS
	);
	while(CAN_OPMODE != CAN_OPCODE_CONFIG);	// Wait for mode to change to configure mode
	// Initialize CAN
	CAN1Initialize(
		CAN_SYNC_JUMP_WIDTH1	&
		CAN_BAUD_PRE_SCALE(1)	
        ,
		CAN_WAKEUP_BY_FILTER_DIS	&
		CAN_PROPAGATIONTIME_SEG_TQ(1)	&
		CAN_PHASE_SEG1_TQ(3)	&
		CAN_PHASE_SEG2_TQ(3)	&
		CAN_SEG2_FREE_PROG	    &
		CAN_SAMPLE1TIME
	);
	// Set the filters
	// RX0
	CAN1SetFilter(0,	// RX0F0
		CAN_FILTER_SID(RX_F0_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetFilter(1,	// RX0F1
		CAN_FILTER_SID(RX_F1_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetMask(0,	// RX0M0
		CAN_MASK_SID(RX_M0_SID)  &
        CAN_MATCH_FILTER_TYPE	// Match messages as determined by the filter
        ,
		CAN_FILTER_EID(0)
	);
	// RX1
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
		CAN_FILTER_SID(RX_F5_SID) & CAN_RX_EID_DIS,
		CAN_FILTER_EID(0)
	);
	CAN1SetMask(1,	// RX1M1
		CAN_MASK_SID(RX_M1_SID)	& CAN_MATCH_FILTER_TYPE,
		CAN_FILTER_EID(0)
	);
	// Set Tx and Rx buffer modes
	// Tx buffer modes
	CAN1SetTXMode(0,	// TX0
    	CAN_TX_STOP_REQ &
    	CAN_TX_PRIORITY_HIGH 
	);
	CAN1SetTXMode(1,	// TX1
		CAN_TX_STOP_REQ	&
		CAN_TX_PRIORITY_HIGH_INTER
	);
	CAN1SetTXMode(2,	// TX2
		CAN_TX_STOP_REQ &
		CAN_TX_PRIORITY_LOW
	);
	// Rx buffer modes
	CAN1SetRXMode(0,
    	CAN_RXFUL_CLEAR &
    	CAN_BUF0_DBLBUFFER_DIS
	);
	CAN1SetRXMode(1,
		CAN_RXFUL_CLEAR
	);
	// Change to normal mode
	CAN1SetOperationMode(
		CAN_IDLE_CON    &
		CAN_MASTERCLOCK_1   &
		CAN_REQ_OPERMODE_NOR    &
		CAN_CAPTURE_DIS
	);
	while(CAN_OPMODE != CAN_OPCODE_NORMAL);	// Wait for mode to change to normal mode (all filters and masks hide)
	/* Setup complete */
}

/*
 * CAN1 Interrupt Service Routine
 */
void _ISR_CAN1() {
	RED_LED = ON;
	// Fix any errors
	if (C1INTFbits.ERRIF == 1) {	// An error has occured (reset all errors)
		if (C1INTFbits.RX0OVR == 1) {
			C1INTFbits.RX0OVR = 0;
		}
		if (C1INTFbits.RX1OVR == 1) {
			C1INTFbits.RX1OVR = 0;
		}
		C1INTFbits.ERRIF = 0;
		// Go into error loop
		error_loop();	// FIXME: This is to be fixed
	}
	// Check for any messages received
	if (C1INTFbits.RX0IF == 1) {	// Received message in RX0
		C1INTFbits.RX0IF = 0;	// Clear receive message flag
		// Read message
		if (C1RX0CONbits.FILHIT0 == 0) {	// Filter 0 hit (joint angle received)
			float temp;
			CAN1ReceiveMessage((unsigned char *)&temp, 4, 0);
			C1RX0CONbits.RXFUL = 0;	// Clear register read
			set_pos_SP(temp);
		} else if (C1RX0CONbits.FILHIT0 == 1) {	// Filter 1 hit (Not used)
			C1RX0CONbits.RXFUL = 0;	// Discard message
		}
	} else if (C1INTFbits.RX1IF == 1) {	// Received message in RX1
		C1INTFbits.RX1IF = 0;	// Clear receive message flag
		// Read message
		if (C1RX1CONbits.FILHIT == 0b010) {	// Filter 2 hit (feedback request received)
			// Get the ID of feedback
			unsigned int ID = 0;
			CAN1ReceiveMessage((unsigned char *) &ID, 2, 1);
			C1RX1CONbits.RXFUL = 0;	// Clear register read
			unsigned char send_value = 0;	// Transmit if 1 in the end
			float val_tosend = 0;
			// If a valid ID is received, get the value to be sent in val_tosend
			switch (ID) {
				case CAN_FBK_QEI_CURR:	// QEI (Encoder) value - current
					send_value = 1;
					val_tosend = current_enc_pos();
				break;
				default:
					// (Invalid ID)
					send_value = 0;
					val_tosend = 0;
				break;
			}
			// Send message
			if (send_value == 1) {
				CAN1SendMessage(
					CAN_TX_SID(CAN_ADDR_FBK(CAN_MASTER_ADDR) & 0x07FF) &	CAN_SUB_NOR_TX_REQ & CAN_TX_EID_DIS,
					CAN_TX_EID(0),
					(unsigned char *) &val_tosend, 4, 1
				);
				while(!CAN1IsTXReady(1));	// Wait for transmission to complete	// TODO: Have some timeout mechanism here
				if (C1INTFbits.TX1IF == 1) {	// Reset the TX interrupt flag after sending message
					C1INTFbits.TX1IF = 0;
				}
			}
		}
	}
	RED_LED = OFF;
	_C1IF = 0;	// Clear flag
}
