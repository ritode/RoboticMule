#include "globals.h"
// Wrapper libraries
#include "motor_wrapper.h"  // Libraries for Motor: Driver + Encoder

_FOSC(CSW_FSCM_OFF & XT_PLL8);
_FWDT(WDT_OFF);

int main() {
	init_periphs();
	while(1) {
		motor_ctrl_loop_single();
	}
	return 0;
}
