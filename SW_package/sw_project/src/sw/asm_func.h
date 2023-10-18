/*
 * asm_func.h
 *
 *  Created on: May 13, 2016
 *      Author: dbozilov
 */

#ifndef ASM_FUNC_H_
#define ASM_FUNC_H_

#include <stdint.h>

//C = 0;
//for (int j=0; j<size-i; j++) {
//	sum = ((uint64_t)t[i+j]) + ((uint64_t)a[j])*((uint64_t)b[i]) + ((uint64_t)C);
//	C = (uint32_t)(sum>>32);
//	t[i+j] = (uint32_t)sum;
//}
//
//sum = ((uint64_t)t[size])+((uint64_t)C);
//C = (uint32_t)(sum>>32);
//t[size] = (uint32_t)sum;
//t[size+1] = (uint32_t)(((uint64_t)t[size+1]) + ((uint64_t)C));

void opt1(uint32_t i, uint32_t *t, uint32_t *a, uint32_t *b, uint32_t size);


// a will be in register R0, b in R1, c in R2
// Result is stored in register r0
uint32_t add_3(uint32_t a, uint32_t b, uint32_t c);

//Adds all elements of array
uint32_t add_10(uint32_t *a, uint32_t n);

//Copies array a to array b
uint32_t arr_copy(uint32_t *a, uint32_t *b, uint32_t n);

// Function that calculates {t[i+1], t[i]} = a[0]*b[0] + m[0]*n[0]
// i is in R0, pointer to t array in R1, a array in R2, b array in R3
// pointer to m array is stored in [SP]
// pointer to n array is stored in [SP, #4] (one position above m)
void multiply(int32_t i, uint32_t *t, uint32_t *a, uint32_t *b, uint32_t *m, uint32_t *n);






#endif /* ASM_FUNC_H_ */
