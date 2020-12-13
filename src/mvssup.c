#include <stdio.h>
#include <ctype.h>
#include "mvssup.h"

void   _dump     (void *data, size_t size, char *heading) {
    char ascii[17];
    size_t i, j;
    int padded = 0;

    ascii[16] = '\0';

    if (heading != NULL) {
        printf("[%s]\n", heading);
    } else {
        printf("[Dumping %lu bytes from address %p]\n", size, data);
    }

    printf("%08X (+%08X) | ", (unsigned) (unsigned long) data, 0);
    for (i = 0; i < size; ++i) {
        printf("%02X", ((char *)data)[i]);

        if (isprint(((char *) data)[i])) {
            ascii[i % 16] = ((char *)data)[i];
        } else {
            ascii[i % 16] = '.';
        }


        if ((i+1) % 4 == 0 || i+1 == size) {
            if ((i+1) % 4 == 0) {
                printf(" ");
            }

            if ((i+1) % 16 == 0) {
                printf("| %s \n", ascii);
                if (i+1 != size) {
                    printf("%08X (+%08X) | ", (unsigned) (unsigned long) &((char *)data)[i+1], (unsigned int) i+1);
                }
            } else if (i+1 == size) {
                ascii[(i+1) % 16] = '\0';

                for (j = (i+1) % 16; j < 16; ++j) {
                    if ((j) % 4 == 0) {
                        if (padded) {
                            printf(" ");
                        }
                    }
                    printf("  ");
                    padded = 1;
                }
                printf(" | %s \n", ascii);
            }
        }
    }
}
