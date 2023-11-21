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
	uint32_t liste_len[50] = {e_len0, e_len1, e_len2, e_len3, e_len4, e_len5, e_len6, e_len7, e_len8, e_len9, e_len10, e_len11, e_len12, e_len13, e_len14, e_len15, e_len16, e_len17, e_len18, e_len19, e_len20, e_len21, e_len22, e_len23, e_len24, e_len25, e_len26, e_len27, e_len28, e_len29, e_len30, e_len31, e_len32, e_len33, e_len34, e_len35, e_len36, e_len37, e_len38, e_len39, e_len40, e_len41, e_len42, e_len43, e_len44, e_len45, e_len46, e_len47, e_len48, e_len49};
	uint32_t listd_len[50] = {d_len0, d_len1, d_len2, d_len3, d_len4, d_len5, d_len6, d_len7, d_len8, d_len9, d_len10, d_len11, d_len12, d_len13, d_len14, d_len15, d_len16, d_len17, d_len18, d_len19, d_len20, d_len21, d_len22, d_len23, d_len24, d_len25, d_len26, d_len27, d_len28, d_len29, d_len30, d_len31, d_len32, d_len33, d_len34, d_len35, d_len36, d_len37, d_len38, d_len39, d_len40, d_len41, d_len42, d_len43, d_len44, d_len45, d_len46, d_len47, d_len48, d_len49};

  init_platform();
  init_performance_counters(0);

  xil_printf("Begin\n\r");

  // Register file shared with FPGA
  volatile uint32_t* HWreg = (volatile uint32_t*)0x40400000;

  #define COMMAND 0
  #define STATUS  0

  for (int k=0; k<50; k++) {
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

	//START_TIMING
	  HWreg[COMMAND] = 0x01;
	  while((HWreg[STATUS] & 0x01) == 0);
	//STOP_TIMING
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

	//START_TIMING
	  HWreg[COMMAND] = 0x01;
	  while((HWreg[STATUS] & 0x01) == 0);
	//STOP_TIMING
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
