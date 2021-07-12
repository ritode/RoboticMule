// Main header files
#include "globals.h"
#include <uart.h>
#include "uart_hdlr.h"
// Header files for extended functionality
#include "gpio.h"   // GPIO: LED access
#include "can_hdlr.h"   // CAN: Forward messages to slaves

// Global data to this file
UART_rx_data uart_rx_msg;   // The latest received message in the UART buffer
RX_packet rx_packet;        // The main receive message packet

void uart_init() {
    // Close existing UART port
    CloseUART2();
    // Configure interrupt
    ConfigIntUART2(
        UART_RX_INT_EN & UART_RX_INT_PR1    &   // Enable RX interrupt (low priority)
        UART_TX_INT_DIS & UART_TX_INT_PR0       // Disable TX interrupt
    );
    // Start UART
    OpenUART2(
    	UART_EN & UART_IDLE_CON &	    // Enable UART and continu in IDLE
    	UART_RX_TX & UART_EN_WAKE &	    // Don't use ATX and ARX and enable wakeup from sleep mode when RX
    	UART_DIS_LOOPBACK &	            // Disabled Loopback mode
    	UART_EN_ABAUD & 	            // Auto baud rate (don't care)
    	UART_NO_PAR_8BIT &	            // 8-bit, no parity mode
    	UART_1STOPBIT	                // 1 stop bit
    	,
    	UART_INT_TX_BUF_EMPTY &	    // Interrupt when entire buffer gets empty (don't care)
    	UART_TX_PIN_NORMAL &	    // Normal resting state of TX pin
		UART_INT_RX_BUF_FUL  &	    // Interrupt when receive buffer full
		UART_ADR_DETECT_DIS &	    // Address detect (don't care, care only in 9 bit mode)
		UART_RX_OVERRUN_CLEAR	    // Clear receive buffer
		,
		UART2_BRG_VAL
    );  // UART opened in loopback, 8-N-1
    empty_rx_packet(&rx_packet);
}

void empty_rx_packet(RX_packet *packet) {
    packet->rx_completed = TRUE;    // Completed previous message, clear for the next one
    packet->len = 0;                // Reset length and size
    packet->size = 0;
}

void _ISR_UART() {
    _U2RXIF = 0;    // Clear UART2 interrupt flag
    /* Main interrupt handler code */
    RED_LED = ON;
    while (DataRdyUART2()) {    // While there is data in UART receive buffer
        getsUART2(4, (unsigned int *)&uart_rx_msg, 40); // 40 inst. cycle wait for timeout
        if (rx_packet.rx_completed) {
            // A new fresh message has been received
            rx_packet.rx_completed = FALSE; // More messages to come
            rx_packet.size = uart_rx_msg.uidata[0]; // Size of data to be received
            rx_packet.len = RESET_LEN;
        } else {
            // The value received is a part of an ongoing receive packet
            rx_packet.data_msg[rx_packet.len] = uart_rx_msg;
            rx_packet.addrs[rx_packet.len] = ((unsigned int)(rx_packet.len/3) << 2) | (rx_packet.len % 3);  // of the form 0xabcd -> ab is leg number and cd is joint number
            rx_packet.len += 1; // Increment length
            if (rx_packet.len == rx_packet.size) {  // Completed packet
                // Packet received, upload to motors
                upload_rx_motors();
            }
        }
    }
    RED_LED = OFF;  // ISR ended
}

void upload_rx_motors() {
    unsigned int i;
    for (i = 0; i < rx_packet.size; i++) {
        can_send_angle_joint_addr(rx_packet.data_msg[i].fdata, rx_packet.addrs[i]);
    }
    empty_rx_packet(&rx_packet);
}

void uart_send_float(float number) {
    while (BusyUART2());    // Wait for current TX to be free
    // Send a 4 first (4 bytes)
    WriteUART2(0x04);
    while (BusyUART2());    // Wait for transmission to complete
    UART_rx_data data_obj;
    data_obj.fdata = number;
    // Send values in data_obj (byte by byte)
    unsigned int i;
    for (i = 0; i < 4; i++) {
        WriteUART2(data_obj.cdata[i]);
    }
    while (BusyUART2());    // Wait for transmission to complete
}
