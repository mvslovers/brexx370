#include <string.h>
#include "hashing.h"

unsigned long int digitalRoot(unsigned long int hash)
{
    unsigned long int digitalRoot = 0;

    do {
        digitalRoot += hash % 10;
        hash /= 10;
    } while (hash > 0);

    return digitalRoot;
}

unsigned long int hashKey(char *key)
{
    size_t length = strlen(key);
    unsigned int hashsum = 0;
    unsigned int i;

    for (i = 0; i < length; ++i){
        hashsum += key[i];
    }

    // digitalRoot() is 0 only for 0: an empty key, or a sum that wrapped
    if (hashsum == 0) {
        return 0;
    }

    hashsum *= digitalRoot(hashsum);
    hashsum += digitalRoot(hashsum);
    if (digitalRoot(hashsum) != 0) {
        hashsum /= digitalRoot(hashsum);
    }

    return hashsum;
}
