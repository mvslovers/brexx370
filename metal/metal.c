#include <string.h>
#include <ctype.h>
#include "printf.h"
#include "metal.h"

const int __libc_arch = 0;

// TODO: implement get line size(tso macro) and cnewBuf(lineSize)
static char line[80];
static int  linePos = 0;

void * _xregs    (unsigned int reg) {
    void ** saveArea = GETSA();
    saveArea = saveArea[1];

    switch (reg) {
        case  0:
            return saveArea[5];
        case  1:
            return saveArea[6];
        case  2:
            return saveArea[7];
        case  3:
            return saveArea[8];
        case  4:
            return saveArea[9];
        case  5:
            return saveArea[10];
        case  6:
            return saveArea[11];
        case  7:
            return saveArea[12];
        case  8:
            return saveArea[13];
        case  9:
            return saveArea[14];
        case 10:
            return saveArea[15];
        case 11:
            return saveArea[16];
        case 12:
            return saveArea[17];
        case 13:
            return saveArea[18];
        case 14:
            return saveArea[3];
        case 15:
            return saveArea[4];
            break;
        default:
            return NULL;
    }
}

void   _tput     (char *data) {
    int R0, R1, R15;

    R0 = (int) strlen(data);
    R1 = (int) (uintptr_t) data & 0x00FFFFFF;
    R15 = 0;

    SVC(93, &R0, &R1, &R15);
}

void   _putchar  (char character) {
    line[linePos] = character;
    linePos++;

    if (character ==  '\n' || linePos == 80) {
        _tput(line);
        bzero(line, 80);
        linePos = 0;
    }
}

void   _clrbuf   (void) {
    if (linePos > 0) {
        _tput(line);
        bzero(line, 80);
        linePos = 0;
    }
}

void * _getm     (size_t size) {
    long *ptr;

    int R0,R1,R15;

    R0 = ((int)size) + AUX_MEM_HEADER_LENGTH;
    R1 = -1;
    R15 = 0;

    SVC(10, &R0, &R1, &R15);

    if (R15 == 0) {
        ptr = (void *) (uintptr_t) R1;
        ptr[0] = (long) AUX_MEM_HEADER_ID;
        ptr[1] = (((long) (ptr)) + AUX_MEM_HEADER_LENGTH);
        ptr[2] = size;
    } else {
        ptr = NULL;
    }

    return (void *) (((uintptr_t) (ptr)) + AUX_MEM_HEADER_LENGTH);
}

void   _freem    (void *ptr) {
    int R0,R1,R15;

    if (ptr != NULL) {
        R0 = 0;
        R1 = ((int) (uintptr_t) ptr) - AUX_MEM_HEADER_LENGTH;
        R15 = -1;

        SVC(10, &R0, &R1, &R15);
    }
}

void * _malloc   (size_t size) {
    return _getm(size);
}

void * _realloc  (void *oldPtr, size_t size) {
    void *newPtr;

    newPtr = _getm(size);

    if (!newPtr) {
        return NULL;
    }

    memcpy(newPtr, oldPtr, _memsize(oldPtr));

    _freem(oldPtr);

    return newPtr;

}

void   _free     (void *ptr) {
    // only call freemain for memory getmained by ourself
    if (ptr != NULL && _ismetal(ptr)) {
        _freem(ptr);
    } else {
        // TODO: maintain a list of orphaned pointers that must be freed by brexx
    }
}

bool   _ismetal  (void *ptr) {
    fword *tmp;

    tmp = (fword *)((byte *)ptr - AUX_MEM_HEADER_LENGTH);

    if (((fword) tmp) / MVS_PAGE_SIZE != ((fword) ptr) / MVS_PAGE_SIZE) {
        return FALSE;
    }

    if (tmp[0] == AUX_MEM_HEADER_ID) {
        if ( (void *)tmp[1] == ptr && tmp[2] > AUX_MEM_HEADER_LENGTH ) {
            return TRUE;
        } else {
            return FALSE;
        }
    } else {
        return FALSE;
    }
}

size_t _memsize  (void *ptr) {
    size_t size = 0;

    if (_ismetal(ptr)) {
        fword *wrkPtr = (fword *) ((byte *) ptr - AUX_MEM_HEADER_LENGTH);
        size = wrkPtr[2]; // 3rd dword contains the length
    } else {
        hword  *wrkPtr = (hword  *) ((byte *) ptr - JCC_MEM_HEADER_LENGTH);

        // check if 1st dword is an address => jcc cell memory
        if (*((fword *)wrkPtr) & 0xFFF) {

            if (wrkPtr[3] >= 0 && wrkPtr[3] != 0xFFFF) {
                size =  wrkPtr[3]; // 4rd word contains the length
            }

        } else {
            //TODO: ???
        }
    }

    return size;
}

void   _dump     (void *data, size_t size, char *heading) {
    char ascii[17];
    size_t i, j;
    bool padded = FALSE;

    ascii[16] = '\0';

    if (heading != NULL) {
        printf("[%s]\n", heading);
    } else {
        printf("[Dumping %lu bytes from address %p]\n", size, data);
    }

    printf("%08X (+%08X) | ", (unsigned) (uintptr_t) data, 0);
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
                    printf("%08X (+%08X) | ", (unsigned) (uintptr_t) &((char *)data)[i+1], (unsigned int) i+1);
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
                    padded = TRUE;
                }
                printf(" | %s \n", ascii);
            }
        }
    }
}

int    _upper    (int c) {
    if(((c >= 'a') && (c <= 'i'))
       ||((c >= 'j') && (c <= 'r'))
       ||((c >= 's') && (c <= 'z')))
    {
        /* make uppercase */
        c+=0x40;
    }

    return c;
}

int    _bldl     (const char8 moduleName) {
    int rc = 0;

    int R0, R1, R15;

    struct bldl_params_t
    {
        unsigned short BLDLF;
        unsigned short BLDLL;
        char8          BLDLN;
        unsigned char  BLDLD[68];
    } bldlParams;

    memset(&bldlParams, 0, sizeof(struct bldl_params_t));

    memcpy(bldlParams.BLDLN, moduleName, sizeof(char8));

    bldlParams.BLDLF = 1;
    bldlParams.BLDLL = 50;

    R0  = (uintptr_t) &bldlParams;
    R1  = 0;
    R15 = 0;

    SVC(18, &R0, &R1, &R15);

    if (R15 == 0) {
        rc = 1;
    }

    return rc;
}

int    _load     (const char8 moduleName, void **pAddress) {
    int rc;

    int R0, R1, R15;

    R0  = (uintptr_t) moduleName;
    R1  = 0;
    R15 = 0;

    SVC(8, &R0, &R1, &R15);

    rc = R15;
    if (rc == 0) {
        *pAddress = (void *) (uintptr_t)R0;
    }

    return rc;
}

int    _link     (const char8 moduleName, void *pParmList, void *GPR0) {
    int R0, R1, R15;

    void *modInfo[2];
    modInfo[0] = (void *) moduleName;
    modInfo[1] = 0;

    R0 = (int) (uintptr_t) GPR0;
    R1 = (int) (uintptr_t) pParmList;
    R15 = (int) (uintptr_t) modInfo;

    SVC(6, &R0, &R1, &R15);

    return R15;
}
