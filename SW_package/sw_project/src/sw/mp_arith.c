/*
 * mp_arith.c
 *
 */

#include <stdint.h>

// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size) {
    uint64_t carry = 0;

    for (int i = 0; i < size; i++) {
        uint64_t sum = (uint64_t)a[i] + b[i] + carry;
        res[i] = (uint32_t)sum;

        carry = sum >> 32;
    }

    res[size] = (uint32_t)carry;
}

// Calculates res = a - b. a>=b
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t borrow = 0;
    for (int i = 0; i < size; i++) {
        uint32_t diff = a[i] - b[i] - borrow;
        borrow = (diff > a[i]); //if borrow diff always greater than a[i]
        res[i] = diff;

    }
}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size){

    // sum a and b
    uint64_t carry = 0;
    for (int i = 0; i < size; i++) {
        uint64_t sum = (uint64_t)a[i] + b[i] + carry;
        res[i] = (uint32_t)sum;

        carry = sum >> 32;
    }

    // if carry then res>N
        if (carry) {
        mp_sub(res,N,res,size);

        return 0;
    } else {

        for(int i=size-1; i>=0; i--){
    
            // if res > N then substract N once
            if (res[i]>N[i]){
                mp_sub(res,N,res,size);
                return 0;
            }
    
            // if res < N then nothing needs to be done
            if (res[i]<N[i]){
                return 0;
            }
        }
        // if res is equal to N, result is 0
        for (int i=0; i<size; i++){
            res[i] = 0;
        }
    }
}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t temp;
	uint8_t i;
	uint32_t negative_carry = 0;
	for (i=0; i < size; i++) {
		temp = a[i] - b[i] - negative_carry;
		res[i] = (uint32_t) temp; //Cast to 32 bit
		if (a[i] > b[i] + negative_carry) {
			negative_carry = 0;
		} else {
			negative_carry = 1;
		}
	}
	if (negative_carry==1) { //b is greater than a
		mp_add(res, N, res, size);
	}

}
