//
//  PillBox.c
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 13/12/23.
//

#include "PillBox.h"
// Checksum.c
#include <stdio.h>
#include <stdlib.h>

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
