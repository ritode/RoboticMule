#ifndef __UART_HDLR_H
#define __UART_HDLR_H

// Definitions
// Parameters
#define UART2_BAUD_RATE (float) 56800                                           // Baud rate of UART2 (9600 bits per second)
#define UART2_BRG_VAL (unsigned int) ((F_CY /(16 * UART2_BAUD_RATE)) - 1)       // Value to be loaded into BRG register
#define UART_RX_PACKET_SZ_MAX 12    // Number of messages that make one UART packet (at max)
#define TRUE 1
#define FALSE 0
#define RESET_LEN 0
// ISRs
#ifdef _USING_VSCODE_
#define _ISR_UART _U2RXInterrupt
#else
#define _ISR_UART __attribute__((interrupt, no_auto_psv)) _U2RXInterrupt
#endif

// Datatypes
// UART message packet received (single packet) [Size = 4 bytes]
typedef union { // 4 bytes of data
    char cdata[4];  // As character
    unsigned int uidata[2]; // As unsigned int
    float fdata;    // As floating point number
} UART_rx_data;
// Entire message received (consisting of multiple messages) -> multiple messages makes a packet
typedef struct RX_packet_tag {
    char rx_completed;  // Receive completed
    unsigned int size;  // The size of data to be received (size of the received packet)
    unsigned int len;   // Length of data received (used length) till now
    UART_rx_data data_msg[UART_RX_PACKET_SZ_MAX];   // Raw data message (actual contents, limited to 5 messages)
    // Addresses of the recipients (buffer, if CAN is going to be used to transmit the messages further then addresses wil be required)
    unsigned int addrs[UART_RX_PACKET_SZ_MAX];
} RX_packet;

// Functions
/*
 * Initialize UART interface
 */
void uart_init();
/*
 * Empties the rx_packet
 */
void empty_rx_packet(RX_packet *packet);
/* 
 * Upload the received joint angles to the slave boards through CAN
 */
void upload_rx_motors();
/*
 * Send a floating point number through UART
 */
void uart_send_float(float num);

#endif
