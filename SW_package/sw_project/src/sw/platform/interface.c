#include "xpseudo_asm_gcc.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "interface.h"

unsigned int * dma_config;
unsigned int * accelerator_port;

void interface_init()
{
	dma_config 		 = (unsigned int *)0x40400000;
	accelerator_port = (unsigned int *)0x43C00000;

    dma_config[MM2S_DMACR_OFFSET]   = 1;
	dma_config[S2MM_DMACR_OFFSET]   = 1;
}

inline void send_cmd_to_hw(uint32_t cmd)
{
    accelerator_port[0] = cmd;
}

inline int is_done(void)
{
    return accelerator_port[1];
}

inline void send_data_to_hw(uint32_t* data_addr)
{
    // Specify read address
    dma_config[MM2S_SA_OFFSET]      = (int)data_addr;

    // Specify number of bytes
    dma_config[MM2S_LENGTH_OFFSET]  = 128;  // 1024-bits in bytes

    // Wait for the completion of transfer
    while((dma_config[MM2S_DMASR_OFFSET] & 0x02) == 0);
}

inline void read_data_from_hw(uint32_t* data_addr)
{
	// Specify write address
    dma_config[S2MM_SA_OFFSET]      = (int)data_addr;

    // Specify number of bytes
    dma_config[S2MM_LENGTH_OFFSET]  = 128; // 1024-bits in bytes

    // Wait for the completion of transfer
    while((dma_config[S2MM_DMASR_OFFSET] & 0x02) == 0);
}

void print_array_contents(uint32_t* src)
{
    int i;
    for (i=32-4; i>=0; i-=4)
        xil_printf("%08x %08x %08x %08x\n\r",
            src[i+3], src[i+2], src[i+1], src[i]);
}
