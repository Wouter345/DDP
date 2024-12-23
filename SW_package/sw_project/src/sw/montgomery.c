/*
 * montgomery.c
 *
 */

#include "montgomery.h"
#include <inttypes.h>
#include <math.h>
#include "mp_arith.h"
#include "common.h"



//Subtract n array from u if u is larger than n. u has SIZE+1 elements, n has SIZE+1 elements, n[SIZE] =0
void SUB_COND(uint32_t *u, uint32_t *n, uint32_t *res, uint32_t size)
{
	if (u[32]!=0) {
		mp_sub(u,n,res,size);
		return 0;
	}
	for(int i=size-1; i>=0; i--){
	// if a > b then do a-b<n
		if (u[i]>n[i]){
			mp_sub(u,n,res,size);
			return 0;
		}

		// if a < b then do n+a-b
		if (u[i]<n[i]){
			for (int j=0; j<size; j++){
				res[j] = u[j];
			}
			return 0;
		}
	}
}




// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elementsx6,
void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{
	uint32_t t[size+2];
	for (int i=0; i<size+2; i++) {
		t[i] = 0;
	}

	uint64_t m;
	uint32_t C;
	uint64_t sum;


	for (int i=0; i<size; i++) {

		C = 0;
		for (int j=0; j<size-i; j++) {
			sum = ((uint64_t)t[i+j]) + ((uint64_t)a[j])*((uint64_t)b[i]) + ((uint64_t)C);
			C = (uint32_t)(sum>>32);
			t[i+j] = (uint32_t)sum;
		}

		sum = ((uint64_t)t[size])+((uint64_t)C);
		C = (uint32_t)(sum>>32);
		t[size] = (uint32_t)sum;
		t[size+1] = (uint32_t)(((uint64_t)t[size+1]) + ((uint64_t)C));
	}

	for (int i = 0; i<size; i++){
		m = (uint32_t)(((uint64_t)t[0])*((uint64_t)n_prime[0]));
		sum = ((uint64_t)t[0]) + (uint64_t)((uint64_t)m)*((uint64_t)n[0]);
		C = (uint32_t)(sum>>32);

		for (int j=1; j<size; j++){
			sum = ((uint64_t)t[j]) + ((uint64_t)m)*((uint64_t)n[j])+((uint64_t)C);
			C = (uint32_t)(sum>>32);
			t[j-1] = (uint32_t)sum;
		}

		sum = ((uint64_t)t[size]) + ((uint64_t)C);
		C = (uint32_t)(sum>>32);
		t[size-1] = (uint32_t)(sum);
		t[size] = (uint32_t)(((uint64_t)t[size+1]) + ((uint64_t)C));
		t[size+1] = 0;
		for (int j=i+1; j<size; j++){
			sum = ((uint64_t)t[size-1]) + ((uint64_t)b[j])*((uint64_t)a[size-j+i]);
			C = (uint32_t)(sum>>32);
			t[size-1] = (uint32_t)sum;

			sum = ((uint64_t)t[size]) + ((uint64_t)C);
			C = (uint32_t)(sum>>32);
			t[size] = (uint32_t)sum;
			t[size+1] = (uint32_t)(((uint64_t)t[size+1]) + ((uint64_t)C));
		}
	}

	SUB_COND(t,n,res,size);

}

// Calculates res = a * b * r^(-1) mod n4e56b7b63.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
// Optimised ASM version
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{
	uint32_t t[size+2];
	opt4(t, size+2);

	opt5(size,t,a,b);


	for (int i = 0; i<size; i++){
		opt2(t, n, n_prime, size);

		opt3(i, t, a, b, size);
	}

	SUB_COND(t,n,res,size);

}


