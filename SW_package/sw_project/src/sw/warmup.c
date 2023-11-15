/******************************************************************
 * This is the warmup file for the Software Session #1
 *
 */

#include <stdint.h>
#include <inttypes.h>

#include "common.h"

void customprint(uint32_t *in, int length) {
    int l = 32*length;
    char str[l];
    char numberStr[32];
    str[0] = '\0';
    numberStr[0] = '\0';
    for (int i=length-1; i>=0; i--){
        sprintf(numberStr, "%08x", in[i]); // Convert the number to a string
        strcat(str, numberStr); // Concatenate the number string with the existing string
    }
    int len = strlen(str);
    int i, j;

    // Find the index of the first non-zero digit
    for (i = 0; i < len; i++) {
        if (str[i] != '0') {
            break;
        }
    }

    // Shift the digits to remove leading zeros
    for (j = 0; i < len; i++, j++) {
        str[j] = str[i];
    }

    str[j] = '\0'; // Null-terminate the string
    xil_printf("0x");
    xil_printf("%s\n\r", str);
}

void customp(uint32_t *in)
{
    int32_t i;

    xil_printf("=");
    for (i = 0; i < 32; i++) {
    	xil_printf("0x%x,", in[i]);
    }
    xil_printf("\n\r");
}



