/******************************************************************
 * This is the main file for the Software Sessions
 *
 */

#include <stdint.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>

#include "common.h"

// Uncomment for Session SW1
// extern void warmup();

// Uncomment for Session SW2 onwards
#include "mp_arith.h"
#include "montgomery.h"
#include "asm_func.h"
#include "test.h"
extern void customp();
extern void customprint();




int main()
{
    init_platform();
    init_performance_counters(1);

    // Hello World template
    //----------------------
    xil_printf("Begin\n\r");
	for (int k=0; k<50; k++){
		uint32_t res[32] = {0};

	//START_TIMING;
		//montMul(lista[k],listb[k],listn[k],listn_prime[k],res,32);
		montMulOpt(lista[k],listb[k],listn[k],listn_prime[k],res,32);
	//STOP_TIMING;

		xil_printf("\r");
		int length = sizeof(res) / sizeof(res[0]);
		//customprint(res, length);

		int correct = 1;
		for (int i=0; i<length; i++) {
			if (listexpected[k][i] != res[i]) {
				correct = 0;
			}
		}

		if (correct) {
			xil_printf("test %d Correct\n\r", k);
		}
		else {
			xil_printf("test %d Wrong\n\r", k);
			customp(listexpected[k]);
			customp(res);
		}
	}

	xil_printf("End\n\r");

    cleanup_platform();

    return 0;
}
