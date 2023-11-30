#include "common.h"
#include <stdalign.h>

#include "tests.h"

#define ISFLAGSET(REG,BIT) ( (REG & (1<<BIT)) ? 1 : 0 )

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
      src[i+3], src[i+2], src[i+1], src[i]);
}

int compare_arrays(uint32_t *a1, uint32_t *a2) {
	for (int i=0; i< 32; i++) {
		if(a1[i] != a2[i]) {
			return 0;
		}
	}
	return 1;
}


int main() {

  init_platform();
  init_performance_counters(0);

  xil_printf("Begin\n\r");

  // Register file shared with FPGA
  volatile uint32_t* HWreg = (volatile uint32_t*)0x40400000;

  #define COMMAND 0
  #define STATUS  0

  for (int k=0; k<10; k++) {
	  // Aligned input and output memory shared with FPGA
	  alignas(128) uint32_t encoded_message[32];
	  alignas(128) uint32_t decoded_message[32];

	  // Initialize res to all zero's
	  memset(encoded_message,0,128);
	  memset(decoded_message,0,128);

	  HWreg[1] = (uint32_t)listN[k];
	  HWreg[2] = (uint32_t)liste[k];
	  HWreg[3] = (uint32_t)listM[k];
	  HWreg[4] = (uint32_t)listR_N[k];
	  HWreg[5] = (uint32_t)listR2_N[k];
	  HWreg[6] = (uint32_t)liste_len[k];
	  HWreg[7] = (uint32_t)encoded_message;

	START_TIMING
	  HWreg[COMMAND] = 0x01;
	  while((HWreg[STATUS] & 0x01) == 0);
	STOP_TIMING
	  HWreg[COMMAND] = 0x00;

	  HWreg[1] = (uint32_t)listN[k];
	  HWreg[2] = (uint32_t)listd[k];
	  HWreg[3] = (uint32_t)encoded_message;
	  HWreg[4] = (uint32_t)listR_N[k];
	  HWreg[5] = (uint32_t)listR2_N[k];
	  HWreg[6] = (uint32_t)listd_len[k];
	  HWreg[7] = (uint32_t)decoded_message;

	  // wait for FPGA to be in Idle state
	  while(HWreg[STATUS] != 0x02);

	START_TIMING
	  HWreg[COMMAND] = 0x01;
	  while((HWreg[STATUS] & 0x01) == 0);
	STOP_TIMING
	  HWreg[COMMAND] = 0x00;

	  int correct1 = compare_arrays(listM[k], decoded_message);
	  int correct2 = compare_arrays(listCt[k], encoded_message);

		if (correct2) {
			xil_printf("Encoded_message number %d is CORRECT!\n\r", k);
		}
		else {
			xil_printf("Encoded_message number %d is WRONG\n\r", k);
		}

		if (correct1) {
			xil_printf("Decoded_message number %d is CORRECT!\n\r", k);
		}
		else {
			xil_printf("Decoded_message number %d is WRONG\n\r", k);
		}
  }
  cleanup_platform();

  	  xil_printf("Finished\n\r");

  	  return 0;
}
