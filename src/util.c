#include "util.h"

#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include "lstring.h"
#include "lerror.h"
#include "rxmvsext.h"

int IsReturnCode(char * input) {
    int iRet = 0;

    if (isdigit(input[0])) {
        iRet = 1;
    } else if (input[0] == '-' && isdigit(input[1])) {
        iRet = 1;
    }

    return iRet;
}

QuotationType CheckQuotation(const char *sDSName)
{
    bool bQuotationMarkAtBeginning  = FALSE;
    bool bQuotationMarkAtEnd        = FALSE;
    QuotationType quotationType     = UNQUOTED;

    /* define possible quotation mark positions */
    size_t iFirstCharPos = 0;
    size_t iLastCharPos  = (strlen(sDSName) > 0) ? (strlen(sDSName) - 1) : 0;

    /* get chars at defined positions */
    unsigned char cFirstChar = (unsigned char)sDSName[iFirstCharPos];
    unsigned char cLastChar  = (unsigned char)sDSName[iLastCharPos];

    if (cFirstChar == '\'' || cFirstChar == '\"') {
        bQuotationMarkAtBeginning = TRUE;
    }

    if (cLastChar == '\'' || cLastChar == '\"') {
        bQuotationMarkAtEnd = TRUE;
    }

    if ((bQuotationMarkAtBeginning) && (bQuotationMarkAtEnd)) {
        quotationType = FULL_QUOTED;
    } else if ((bQuotationMarkAtBeginning) || (bQuotationMarkAtEnd)) {
        quotationType = PARTIALLY_QUOTED;
    }

    return quotationType;
}

int getDatasetName(RX_ENVIRONMENT_CTX_PTR pEnvironmentCtx,  const char *datasetNameIn, char datasetNameOut[54 + 1])
{
    int iErr = 0;

    bzero(datasetNameOut, 55);

    switch (CheckQuotation(datasetNameIn)) {
        case UNQUOTED:
            if (pEnvironmentCtx->SYSPREF[0] != '\0') {
                strcat(datasetNameOut, pEnvironmentCtx->SYSPREF);
                strcat(datasetNameOut, ".");
                strcat(datasetNameOut, datasetNameIn);
                strcat(datasetNameOut, "\0");
            }
            break;
        case FULL_QUOTED:
            strncpy(datasetNameOut, datasetNameIn + 1,strlen(datasetNameIn) - 2);
            strcat(datasetNameOut, "\0");
            break;
        default:
            iErr = -1;
    }

    return iErr;
}

// -------------------------------------------------------------------------------------
// Split DSN in DSN and Member (if coded)
// -------------------------------------------------------------------------------------
// Return string at a certain position til it's end and continued substring before starting position
void splitDSN(PLstr dsn, PLstr member, PLstr fromDSN) {
    int slen,dsni,dsnl=0, memi=0,dsnm=0;

    LINITSTR(*dsn);
    LINITSTR(*member);
    Lfx(dsn,44+1);
    Lfx(member,8+1);

    slen=LLEN(*fromDSN);
    if (slen<1) {                  // is string empty? then return null string
        LZEROSTR(*dsn);
        LZEROSTR(*member);
        return;
    }

    for (dsni=0;dsni<slen;dsni++) {
        if (LSTR(*fromDSN)[dsni] == '(') dsnm = 1;
        else if (LSTR(*fromDSN)[dsni] == ')') dsnm = 0;
        else if (dsnm == 0) {
            LSTR(*dsn)[dsnl]    = LSTR(*fromDSN)[dsni];
            dsnl++;
        } else {
            LSTR(*member)[memi] = LSTR(*fromDSN)[dsni];
            memi++;
        }
    }
    LLEN(*dsn) = (size_t) dsnl;
    LTYPE(*dsn) = LSTRING_TY;
    LLEN(*member) = (size_t) memi;
    LTYPE(*member) = LSTRING_TY;
}


int  createDataset(char *sNAME, char *sMODE, char *sRECFM, unsigned int uiLRECL, unsigned int uiBLKSIZE,
                    unsigned int uiDIR, unsigned int uiPRI, unsigned int uiSEC)
{
    int iErr = 0;

    FILE *pFile;

    char sDCBString[256];

    sprintf(sDCBString, "%s,recfm=%s,lrecl=%d,blksize=%d,dirblks=%d,pri=%d,sec=%d,unit=sysda,rlse"  , sMODE
                                                                                                    , sRECFM
                                                                                                    , uiLRECL
                                                                                                    , uiBLKSIZE
                                                                                                    , uiDIR
                                                                                                    , uiPRI
                                                                                                    , uiSEC);

    pFile = fopen(sNAME, sDCBString);
    if (pFile == NULL) {
        iErr = -1;
    } else {
        iErr = fclose(pFile);
    }

    return iErr;
}

long getFileSize(FILE *pFile)
{
    int iErr;

    long lFileSize;
    long lOldFilePos;

    lOldFilePos = ftell(pFile);

    iErr = fseek(pFile, 0L, SEEK_END);

    if (iErr == 0) {
        lFileSize = ftell(pFile);
        iErr = fseek(pFile, lOldFilePos, SEEK_SET);
    }

    if (iErr != 0) {
        lFileSize = -1;
    }

    return lFileSize;
}

void DumpHex(const unsigned char* data, size_t size)
{
    char ascii[17];
    size_t i, j;
    bool padded = FALSE;

    ascii[16] = '\0';

    printf("%08X (+%08X) | ", &data[0], 0);
    for (i = 0; i < size; ++i) {
        printf("%02X", data[i]);

        if ( isprint(data[i])) {
            ascii[i % 16] = data[i];
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
                    printf("%08X (+%08X) | ", &data[i+1], i+1);
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

void PrintErrno()
{
    int errnum = errno;
    fprintf(stderr, "Value of errno: %d\n", errno);
    perror("Error printed by perror");
    fprintf(stderr, "Error opening file: %s\n", strerror( errnum ));
}

static const unsigned char e2a[256] = {
        0,  1,  2,  3,156,  9,134,127,151,141,142, 11, 12, 13, 14, 15,
        16, 17, 18, 19,157,133,  8,135, 24, 25,146,143, 28, 29, 30, 31,
        128,129,130,131,132, 10, 23, 27,136,137,138,139,140,  5,  6,  7,
        144,145, 22,147,148,149,150,  4,152,153,154,155, 20, 21,158, 26,
        32,160,161,162,163,164,165,166,167,168, 91, 46, 60, 40, 43, 33,
        38,169,170,171,172,173,174,175,176,177, 93, 36, 42, 41, 59, 94,
        45, 47,178,179,180,181,182,183,184,185,124, 44, 37, 95, 62, 63,
        186,187,188,189,190,191,192,193,194, 96, 58, 35, 64, 39, 61, 34,
        195, 97, 98, 99,100,101,102,103,104,105,196,197,198,199,200,201,
        202,106,107,108,109,110,111,112,113,114,203,204,205,206,207,208,
        209,126,115,116,117,118,119,120,121,122,210,211,212,213,214,215,
        216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,
        123, 65, 66, 67, 68, 69, 70, 71, 72, 73,232,233,234,235,236,237,
        125, 74, 75, 76, 77, 78, 79, 80, 81, 82,238,239,240,241,242,243,
        92,159, 83, 84, 85, 86, 87, 88, 89, 90,244,245,246,247,248,249,
        48, 49, 50, 51, 52, 53, 54, 55, 56, 57,250,251,252,253,254,255
};

    static const unsigned char a2e[256] = {
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*         	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*         	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*         	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*         	*/
                    0x40,0x4F,0x7F,0x7B,0x5B,0x6C,0x50,0x7D,	/*  !"#$%&'	*/
                    0x4D,0x5D,0x5C,0x4E,0x6B,0x60,0x4B,0x61,	/* ()*+,-./	*/
                    0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,	/* 01234567	*/
                    0xF8,0xF9,0x7A,0x5E,0x4C,0x7E,0x6E,0x6F,	/* 89:;<=>?	*/
                    0x7C,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,	/* @ABCDEFG	*/
                    0xC8,0xC9,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,	/* HIJKLMNO	*/
                    0xD7,0xD8,0xD9,0xE2,0xE3,0xE4,0xE5,0xE6,	/* PQRSTUVW	*/
                    0xE7,0xE8,0xE9,0x4A,0xE0,0x5A,0x5F,0x6D,	/* XYZ[\]^_	*/
                    0x79,0x81,0x82,0x83,0x84,0x85,0x86,0x87,	/* `abcdefg	*/
                    0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96,	/* hijklmno	*/
                    0x97,0x98,0x99,0xA2,0xA3,0xA4,0xA5,0xA6,	/* pqrstuvw	*/
                    0xA7,0xA8,0xA9,0xC0,0x6A,0xD0,0xA1,0x40,	/* xyz{|}~ 	*/
                    0xB9,0xBA,0xED,0xBF,0xBC,0xBD,0xEC,0xFA,	/*              */
                    0xCB,0xCC,0xCD,0xCE,0xCF,0xDA,0xDB,0xDC,	/*             	*/
                    0xDE,0xDF,0xEA,0xEB,0xBE,0xCA,0xBB,0xFE,	/*		*/
                    0xFB,0xFD,0x7d,0xEF,0xEE,0xFC,0xB8,0xDD,	/*		*/
                    0x77,0x78,0xAF,0x8D,0x8A,0x8B,0xAE,0xB2,	/*		*/
                    0x8F,0x90,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F,	/*		*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*	       	*/
                    0xAA,0xAB,0xAC,0xAD,0x8C,0x8E,0x80,0xB6,	/* ����	*/
                    0xB3,0xB5,0xB7,0xB1,0xB0,0xB4,0x76,0xA0,	/* 	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,	/*        	*/
                    0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40 	/*        	*/
            };



void ebcdicToAscii(unsigned char *s, unsigned int length)
{
    unsigned int uiCurrentPosition = 0;
    while (uiCurrentPosition < length)
    {
        s[uiCurrentPosition] = e2a[(int) (s[uiCurrentPosition])];
        uiCurrentPosition++;
    }
}

void AsciiToebcdic(unsigned char *s, unsigned int length)
{
    unsigned int uiCurrentPosition = 0;
    while (uiCurrentPosition < length)
    {
        s[uiCurrentPosition] = a2e[(int) (s[uiCurrentPosition])];
        uiCurrentPosition++;
    }
}
