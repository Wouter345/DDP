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



int main()
{
    init_platform();
    init_performance_counters(1);

    // Hello World template
    //----------------------
    xil_printf("Begin\n\r");
	for (int k=0; k<10; k++){
		uint32_t res[32] = {0};

	START_TIMING;
		//montMul(a,b,n,n_prime,res,32);
		montMulOpt(a,b,n,n_prime,res,32);
	STOP_TIMING;

		xil_printf("\n\n\r");
		int length = sizeof(res) / sizeof(res[0]);
		customprint(res, length);

		int correct = 1;
		for (int i=0; i<length; i++) {
			if (expected[i] != res[i]) {
				correct = 0;
			}
		}

		if (correct) {
			xil_printf("Correct\n\r");
		}
		else {
			xil_printf("Wrong\n\r");
			customp(expected);
			customp(res);
		}
	}

	xil_printf("End\n\r");

    cleanup_platform();

    return 0;
}
