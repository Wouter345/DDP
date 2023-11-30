#include "common.h"
#include <stdalign.h>

// These variables are defined in the testvector.c
// that is created by the testvector generator python script
extern uint32_t N[32],    // modulus
                e[32],    // encryption exponent
                e_len,    // encryption exponent length
                d[32],    // decryption exponent
                d_len,    // decryption exponent length
                M[32],    // message
				Ct[32],
                R_N[32],  // 2^1024 mod N
                R2_N[32];// (2^1024)^2 mod N


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

  // Aligned input and output memory shared with FPGA
  alignas(128) uint32_t encoded_message[32];
  alignas(128) uint32_t decoded_message[32];


  // Initialize res to all zero's
  memset(encoded_message,0,128);
  memset(decoded_message,0,128);


  HWreg[1] = (uint32_t)N;
  HWreg[2] = (uint32_t)e;
  HWreg[3] = (uint32_t)M;
  HWreg[4] = (uint32_t)R_N;
  HWreg[5] = (uint32_t)R2_N;
  HWreg[6] = (uint32_t)e_len;
  HWreg[7] = (uint32_t)encoded_message;




  xil_printf("Start Encoding\n\r");

START_TIMING
  // Start encoding
  HWreg[COMMAND] = 0x01;
  // Wait until FPGA is done
  while((HWreg[STATUS] & 0x01) == 0);
STOP_TIMING
  HWreg[COMMAND] = 0x00;

  xil_printf("Finished Encoding\n\r");

  // set decoding registers
  HWreg[1] = (uint32_t)N;
  HWreg[2] = (uint32_t)d;
  HWreg[3] = (uint32_t)encoded_message;
  HWreg[4] = (uint32_t)R_N;
  HWreg[5] = (uint32_t)R2_N;
  HWreg[6] = (uint32_t)d_len;
  HWreg[7] = (uint32_t)decoded_message;

  // wait for FPGA to be in Idle state
  while(HWreg[STATUS] != 0x02){
	  xil_printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
  }

  xil_printf("Start Decoding\n\r");

START_TIMING
  // Start decoding
  HWreg[COMMAND] = 0x01;
  // Wait until FPGA is done
  while((HWreg[STATUS] & 0x01) == 0);
STOP_TIMING
  HWreg[COMMAND] = 0x00;

  xil_printf("Finished Decoding\n\r");





  //xil_printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));

  xil_printf("\rFinished calculations\n\r");

//  print_array_contents(decoded_message);
//  xil_printf("\n\r");
//  print_array_contents(M);


  int correct1 = compare_arrays(M, decoded_message);
  int correct2 = compare_arrays(Ct, encoded_message);

  	if (correct2) {
  		xil_printf("Encoded_message is CORRECT!\n\r");
  	}
  	else {
  		xil_printf("Encoded_message is WRONG\n\r");
  	}

	if (correct1) {
		xil_printf("Decoded_message is CORRECT!\n\r");
	}
	else {
		xil_printf("Decoded_message is WRONG\n\r");
	}

  cleanup_platform();

  xil_printf("Finished\n\r");

  return 0;
}
