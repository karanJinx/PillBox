//
//  CRCUtils.c
//  HJBle
//
//  Created by 吴睿智 on 2017/10/22.
//  Copyright © 2017年 wurz. All rights reserved.
//

#include "CRCUtils.h"
#include <stdlib.h>
// Function to calculate checksum
char* calculateChecksum(const char* input) {
    int checksum = 0;

    // Convert each pair of characters to a byte and accumulate the sum
    for (int i = 0; input[i] != '\0'; i += 2) {
        char hexPair[3];
        hexPair[0] = input[i];
        hexPair[1] = input[i + 1];
        hexPair[2] = '\0';

        int value;
        sscanf(hexPair, "%x", &value);

        checksum += value;
    }

    // Apply the 8-bit lower cumulative sum
    checksum &= 0xFF;

    // Allocate memory for the checksum string
    char* result = (char*)malloc(3);

    // Format the checksum as a string with leading zero if needed
    snprintf(result, 3, "%02X", checksum);

    return result;
}

int main(void) {
    const char* input = "bb1108c4080002d002d348";

    // Calculate checksum
    char* checksum = calculateChecksum(input);

    // Print the calculated checksum
    printf("Checksum: %s\n", checksum);

    // Don't forget to free the allocated memory
    free(checksum);

    return 0;
}
