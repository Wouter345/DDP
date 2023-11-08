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
                R_N[32],  // 2^1024 mod N
                R2_N[32];// (2^1024)^2 mod N

#define ISFLAGSET(REG,BIT) ( (REG & (1<<BIT)) ? 1 : 0 )

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
      src[i+3], src[i+2], src[i+1], src[i]);
}

int main() {

  init_platform();
  init_performance_counters(0);

  xil_printf("Begin\n\r");

  // Register file shared with FPGA
  volatile uint32_t* HWreg = (volatile uint32_t*)0x40400000;

  #define COMMAND 0
  #define RXADDR  1
  #define TXADDR  2
  #define STATUS  0

  // Aligned input and output memory shared with FPGA
  alignas(128) uint32_t idata[32];
  alignas(128) uint32_t odata[32];

  // Initialize odata to all zero's
  memset(odata,0,128);

  for (int i=0; i<32; i++) {
    idata[i] = i+1;
  }

  HWreg[0] = (uint32_t)&idata; // store address idata in reg1
  HWreg[1] = (uint32_t)&idata; // store address odata in reg2
  HWreg[2] = (uint32_t)&idata; // store address odata in reg3


  printf("RXADDR %08X\r\n", (unsigned int)HWreg[RXADDR]);
  printf("TXADDR %08X\r\n", (unsigned int)HWreg[TXADDR]);

  printf("STATUS %08X\r\n", (unsigned int)HWreg[STATUS]);
  printf("REG[3] %08X\r\n", (unsigned int)HWreg[3]);
  printf("REG[4] %08X\r\n", (unsigned int)HWreg[4]);

START_TIMING
  HWreg[COMMAND] = 0x01;
  // Wait until FPGA is done
  while((HWreg[STATUS] & 0x01) == 0);
STOP_TIMING
  
  HWreg[COMMAND] = 0x00;

  printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
  printf("STATUS 1 %08X\r\n", (unsigned int)HWreg[1]);
  printf("STATUS 2 %08X\r\n", (unsigned int)HWreg[2]);
  printf("STATUS 3 %08X\r\n", (unsigned int)HWreg[3]);
  printf("STATUS 4 %08X\r\n", (unsigned int)HWreg[4]);
  printf("STATUS 5 %08X\r\n", (unsigned int)HWreg[5]);
  printf("STATUS 6 %08X\r\n", (unsigned int)HWreg[6]);
  printf("STATUS 7 %08X\r\n", (unsigned int)HWreg[7]);

  printf("\r\nI_Data:\r\n"); print_array_contents(idata);
  printf("\r\nO_Data:\r\n"); print_array_contents(odata);


  cleanup_platform();

  return 0;
}
