#include <math.h>

#ifdef JCC
extern char* _style;
#else
#include "jccdummy.h"
#endif

#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "netdata.h"
#include "util.h"
#include "dynit.h"
#include "svc99.h"

extern RX_ENVIRONMENT_CTX_PTR environment;

/* internal function prototypes */
int receive(char sInputDataSetNameÝ45¨, char sOutputDataSetNameÝ45¨);
int transmit(char sFileNameInÝ45¨, char sFileNameOutÝ45¨);

int checkHeaderRecord(P_ND_SEGMENT pSegment);
int checkFileUtilCtrlRecord(P_ND_SEGMENT pSegment);
int checkDataCtrlRecord(P_ND_SEGMENT pSegment);
int checkDataRecord(P_ND_SEGMENT pSegment);

int readHeaderRecord(FILE *pFile, P_ND_HEADER_RECORD pHeaderRecord);
int readFileUtilCtrlRecord(FILE *pFile, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord);
int readDataCtrlRecord(FILE *pFile, P_ND_DATA_CTRL_RECORD pDataCtrlRecord);
int readDataRecord(FILE *pFile, P_ND_DATA_RECORD pDataRecord);

unsigned int calculateTracks(long lFileSize, unsigned int uiBlkSize);

int receivePO(FILE *pF_IN, char sTargetDataSetNameÝ45¨, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord);
int receivePS(FILE *pF_IN, char sOutputDataSetNameÝ45¨, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord);

int receiveRecords(FILE *pFileIn, FILE *pFileOut, ND_RECFM recfm, unsigned int uiMaxLRECL);
void writeRecord(FILE *pFileOut, BYTE *pRecord, unsigned int uiBytesToWrite, ND_RECFM recfm);

int allocateTargetDataSet(char *sDataSetName, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pSourceFile, int add);

int dinfo(const char *ddname, char *dsname, char *memname);
int dfree(char * ddn);
int allocateSYSIN();
int allocateSYSUT1(char *sDataSetName);
int allocateSYSUT2(char *sDataSetName, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pF_IN);
int allocateTMPSEQ(P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pF_IN);

/* rexx functions */
void R_receive(int func)
{
    char sFileNameInÝ44 + 1¨;
    char sFileNameOutÝ44 + 1¨;

    int iErr;

    char* _style_old = _style;

    if (ARGN != 2) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    get_s(1)
    get_s(2)

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)

#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif

    bzero(sFileNameIn,  45);
    bzero(sFileNameOut, 45);

    _style = "//DSN:";

    // #1 get the correct dsn for the input file
    iErr = getDatasetName(environment, (const char*)LSTR(*ARG1), sFileNameIn);

    // #2 get the correct dsn for the output file
    if (iErr == 0) {
        iErr = getDatasetName(environment, (const char *) LSTR(*ARG2), sFileNameOut);
    }

    // #3 receive the input dataset into the output dataset
    if (iErr == 0) {
        iErr = receive(sFileNameIn, sFileNameOut);
    }

    Licpy(ARGR, iErr);

    _style = _style_old;
} /* R_receive() */

void R_transmit(int func)
{
    char sFileNameInÝ44 + 1¨;
    char sFileNameOutÝ44 + 1¨;

    int iErr;

    char* _style_old = _style;

    if (ARGN != 2) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    get_s(1)
    get_s(2)

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)

#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif

    bzero(sFileNameIn, 45);
    bzero(sFileNameOut, 45);

    _style = "//DSN:";

    // get the correct dsn for the input file
    iErr = getDatasetName(environment, (const char*)LSTR(*ARG1), sFileNameIn);

    // get the correct dsn for the output file
    if (iErr == 0)
        iErr = getDatasetName(environment, (const char*)LSTR(*ARG2), sFileNameOut);

    if (iErr == 0) {
        printf("ERR> function <transmit()> not yet implemented.\n");
    }

    Licpy(ARGR, iErr);

    _style = _style_old;
} /* R_transmit() */

void R_submit(int func)
{
    int rc;
    __dyn_t dyn_parms;
    FILE *pF_RDR;


    dyninit(&dyn_parms);

    dyn_parms.__ddname      = "MYRDR";
    dyn_parms.__sysout      = 'H';
    dyn_parms.__sysoutname  = "INTRDR";

    rc = dynalloc(&dyn_parms);

    if (rc == 0) {
        char* _style_old = _style;
        _style = "//DDN:";

        pF_RDR = fopen("MYRDR", "wb,recfm=f,reclen=80");

        _style = _style_old;

        if (pF_RDR == NULL) {
            rc = -2;
        }
    } else {
        printf("FOO> Allocation of the INTRDR failed.\n");
    }

    if (rc == 0) {
        fputs("//BR14C    JOB CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID\n",             pF_RDR);
        fputs("//         EXEC PGM=IEFBR14\n",                                  pF_RDR);
        fputs("//SYSPRINT DD SYSOUT=*\n",                                       pF_RDR);
        fputs("//NEWDS    DD DISP=(NEW,CATLG),DSN=MIG.C.SRC2,UNIT=SYSDA,\n",    pF_RDR);
        fputs("//            SPACE=(TRK,(5,5)),\n",                             pF_RDR);
        fputs("//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=32760,DSORG=PS)\n", pF_RDR);

        rc = fflush(pF_RDR);
        printf("FOO> FFLUSH RC(%d\n", rc);

        rc = fclose(pF_RDR);
        printf("FOO> FCLOSE RC(%d\n", rc);
    } else {
        printf("FOO> MYRDR couldn't be opened. \n");
    }

    LICPY(*ARGR, rc)
} /* R_submit() */

/* register rexx functions to brexx/370 */
void RxNetDataRegFunctions()
{
    RxRegFunction("RECEIVE",	R_receive,	0);
    RxRegFunction("TRANSMIT",	R_transmit,	0);
    RxRegFunction("SUBMIT",	R_submit,	0);
} /* RxNetDataRegFunctions() */

/* internal functions */
int receive(char sInputDataSetNameÝ44 + 1¨, char sOutputDataSetNameÝ44 + 1¨)
{
    int iErr = 0;

    FILE                        *pF_IN;

    ND_HEADER_RECORD            headerRecord;
    P_ND_HEADER_RECORD          pHeaderRecord       = &headerRecord;

    ND_FILE_UTIL_CTRL_RECORD    fileUtilCtrlRecord;
    P_ND_FILE_UTIL_CTRL_RECORD  pFileUtilCtrlRecord = &fileUtilCtrlRecord;

    // #1 try to open the input dataset
    printf("DBG> #1 opening input data set '%s' \n", sInputDataSetName);
    pF_IN = FOPEN(sInputDataSetName, "r+b");
    if (pF_IN == NULL) {
        printf("ERR> Input data set could not be opened.\n");
        iErr = -1;
    }
    //

    // #2 read the header record
    if (iErr == 0) {
        iErr = readHeaderRecord(pF_IN, pHeaderRecord);
    }
    //

    // #3 read the first file utility control record from the input data set
    if (iErr == 0) {
        iErr = readFileUtilCtrlRecord(pF_IN, pFileUtilCtrlRecord);
    }
    //

    // #4 handle the payload
    if (iErr == 0) {
        switch (pFileUtilCtrlRecord->INMDSORG) {
            case PO:
                iErr = receivePO(pF_IN, sOutputDataSetName, pFileUtilCtrlRecord);
                break;
            case PS:
                iErr = allocateTargetDataSet(sOutputDataSetName, pFileUtilCtrlRecord, pF_IN, 1);
                if (iErr != 0) {
                    printf("ERR> Output data set could not be allocated.\n");
                } else {
                    printf("DBG> Output data set '%s' allocated.\n", sOutputDataSetName);
                }
                //
                iErr = receivePS(pF_IN, sOutputDataSetName, pFileUtilCtrlRecord);
                break;
            default:
                break;
        }
    }
    //

    // #5 close the input data set
    iErr = FCLOSE(pF_IN);

    return iErr;
}

int transmit(char sFileNameInÝ45¨, char sFileNameOutÝ45¨)
{
    int iErr = 0;

    FILE *pFile = NULL;

    // try to open the input dataset

    pFile = FOPEN(sFileNameIn, "r+b");
    if (pFile == NULL) {
        iErr = -1;
    }

    iErr = FCLOSE(pFile);

    return iErr;
}

int checkHeaderRecord(P_ND_SEGMENT pSegment)
{
    int iErr = 0;

    if (isControlRecord(pSegment)) {
        if (getControlRecordFormat(pSegment) != INMR01) {
            iErr = -2;
        }
    } else {
        iErr = -1;
    }

    return iErr;
}

int checkFileUtilCtrlRecord(P_ND_SEGMENT pSegment)
{
    int iErr = 0;

    if (isControlRecord(pSegment)) {
        if (getControlRecordFormat(pSegment) != INMR02) {
            iErr = -2;
        }
    } else {
        iErr = -1;
    }

    return iErr;
}

int checkDataCtrlRecord(P_ND_SEGMENT pSegment)
{
    int iErr = 0;

    if (isControlRecord(pSegment)) {
        if (getControlRecordFormat(pSegment) != INMR03) {
            iErr = -2;
        }
    } else {
        iErr = -1;
    }

    return iErr;
}

int checkDataRecord(P_ND_SEGMENT pSegment)
{
    int iErr = 0;

    if (!isDataRecord(pSegment)) {
        iErr = -1;
    }

    return iErr;
}

int readHeaderRecord(FILE *pFile, P_ND_HEADER_RECORD pHeaderRecord)
{
    int                         iErr;

    ND_SEGMENT                  segment;
    P_ND_SEGMENT                pSegment = &segment;

    // #1 read next segment from input dataset
    bzero(pSegment, sizeof(ND_SEGMENT));
    iErr = readSegment(pFile, pSegment);

    // #2 check if it is an header record
    if (iErr == 0) {
        iErr = checkHeaderRecord(pSegment);
    }

    // #3 get header record (INMR01)
    if (iErr == 0) {
        bzero(pHeaderRecord, sizeof(ND_HEADER_RECORD));
        iErr = getHeaderRecord(pSegment, pHeaderRecord);
    }

    return iErr;
}

int readFileUtilCtrlRecord(FILE *pFile, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord)
{
    int                         iErr;

    ND_SEGMENT                  segment;
    P_ND_SEGMENT                pSegment = &segment;

    // #1 read next segment from input dataset
    bzero(pSegment, sizeof(ND_SEGMENT));
    iErr = readSegment(pFile, pSegment);

    // #2 check if it is an file util control  record
    if (iErr == 0) {
        iErr = checkFileUtilCtrlRecord(pSegment);
    }

    // #3 get file util control record (INMR02)
    if (iErr == 0) {
        bzero(pFileUtilCtrlRecord, sizeof(ND_FILE_UTIL_CTRL_RECORD));
        iErr = getFileUtilCtrlRecord(pSegment, pFileUtilCtrlRecord);
    }

    return iErr;
}

int readDataCtrlRecord(FILE *pFile, P_ND_DATA_CTRL_RECORD pDataCtrlRecord)
{
    int                         iErr;

    ND_SEGMENT                  segment;
    P_ND_SEGMENT                pSegment = &segment;

    // #1 read next segment from input dataset
    bzero(pSegment, sizeof(ND_SEGMENT));
    iErr = readSegment(pFile, pSegment);

    // #2 check if it is an data control record
    if (iErr == 0) {
        iErr = checkDataCtrlRecord(pSegment);
    }

    // #3 get data control record (INMR03)
    if (iErr == 0) {
        bzero(pDataCtrlRecord, sizeof(ND_DATA_CTRL_RECORD));
        iErr = getDataCtrlRecord(pSegment, pDataCtrlRecord);
    }

    return iErr;
}

int readDataRecord(FILE *pFile, P_ND_DATA_RECORD pDataRecord)
{
    int                         iErr;

    ND_SEGMENT                  segment;
    P_ND_SEGMENT                pSegment = &segment;

    unsigned int                uiCurrentPosition;
    unsigned int                uiNumberOfBytes;
    unsigned int                uiBufferSize;

    // #1 read next segment from input dataset
    bzero(pSegment, sizeof(ND_SEGMENT));
    iErr = readSegment(pFile, pSegment);

    // #2 check if it is an data control record
    if (iErr == 0) {
        iErr = checkDataRecord(pSegment);
    }

    // #3
    if (iErr == 0) {
        getDataRecord(pSegment, pDataRecord);
    }

    return iErr;
}

unsigned int calculateTracks(long lFileSize, unsigned int uiBlkSize)
{
    unsigned int uiTracks;

    const int TRACK_SIZE = 35616;

    unsigned int uiBlkTrk;
    unsigned int uiBlocks;

    uiBlkTrk = TRACK_SIZE / uiBlkSize;

    uiBlocks = ceil(((1.0 * (unsigned int)lFileSize) / uiBlkSize));
    uiTracks = ceil(((1.1 * uiBlocks) / uiBlkTrk));

    return uiTracks;
}

int receivePS(FILE *pF_IN, char sOutputDataSetNameÝ44 + 1¨, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord)
{
    int                         iErr            = 0;

    FILE                        *pF_OUT         = NULL;

    ND_DATA_CTRL_RECORD         dataCtrlRecord;
    P_ND_DATA_CTRL_RECORD       pDataCtrlRecord = &dataCtrlRecord;

    unsigned int                uiLRECL         = 0;

    // #1 read over the data control record
    iErr = readDataCtrlRecord(pF_IN, pDataCtrlRecord);
    //

    // #1 try to open the output data set
    pF_OUT = FOPEN(sOutputDataSetName, "wb,vmode=1");
    if (pF_OUT == NULL) {
        printf("ERR> Output data set could not be opened.\n");
        iErr = -1;
    }
    //

    uiLRECL = pFileUtilCtrlRecord->INMLRECL;
    // #8 receive records into output dataset
    if (iErr == 0) {
        receiveRecords(pF_IN, pF_OUT, pFileUtilCtrlRecord->INMRECFM, uiLRECL);
    }
    //

    // #9 close the output dataset
    iErr = FCLOSE(pF_OUT);
    //

    return iErr;
}

int receivePO(FILE *pF_IN, char sTargetDataSetNameÝ44 + 1¨, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord)
{
    int                         iErr = 0;

    ND_FILE_UTIL_CTRL_RECORD    fileUtilCtrlRecordPS;
    P_ND_FILE_UTIL_CTRL_RECORD  pFileUtilCtrlRecordPS = &fileUtilCtrlRecordPS;

    // #1 read the next file utility control record from input data set
    printf("DBG> #2 reading file utility control record from input data set\n");
    iErr = readFileUtilCtrlRecord(pF_IN, pFileUtilCtrlRecordPS);
    //

    // #2 allocate the temporary data set
    if (iErr == 0) {
        printf("DBG> #3 allocating temp data set\n");
        iErr = allocateTMPSEQ(pFileUtilCtrlRecordPS, pF_IN);
        if (iErr != 0) {
            printf("ERR> temp data set could not be allocated.\n");
        }
    }
    //

    // #3 extract the sequential part to the temp data set
    if (iErr == 0) {
        char sTempDataSetNameÝ44 + 1¨;
        bzero(sTempDataSetName, 45);
        dinfo("TMPSEQ", sTempDataSetName,  "");
        printf("DBG> #4 extracting the sequential part to the temp data set\n");
        iErr = receivePS(pF_IN, sTempDataSetName, pFileUtilCtrlRecordPS);
        if (iErr != 0) {
            printf("ERR> sequential file could not be extracted.\n");
        }
    }
    //

    if (iErr == 0) {

        printf("DBG> #5 freeing SYSIN\n");
        dfree("SYSIN");

        printf("DBG> #6 allocating SYSIN to DUMMY\n");
        iErr = allocateSYSIN();

        if (iErr == 0) {
            char sTempDataSetNameÝ44 + 1¨;
            bzero(sTempDataSetName, 45);
            dinfo("TMPSEQ", sTempDataSetName,  "");
            printf("DBG> #7 allocating SYSUT1\n");
            iErr = allocateSYSUT1(sTempDataSetName);
        }

        if (iErr == 0) {
            printf("DBG> #8 allocating SYSUT2\n");
            iErr = allocateSYSUT2(sTargetDataSetName, pFileUtilCtrlRecord, pF_IN);
        }

        if (iErr == 0) {
            printf("DBG> #8 calling IEBCOPY\n");
            system("IEBCOPY");
        }

        printf("DBG> #10 freeing temp data set\n");

    }

    dfree("SYSUT1");
    dfree("SYSUT2");
    dfree("TMPSEQ");

    return iErr;
}

int receiveRecords(FILE *pFileIn, FILE *pFileOut, ND_RECFM recfm, unsigned int uiMaxLRECL)
{
    int                 iErr                = 0;

    ND_DATA_RECORD      dataRecord;
    P_ND_DATA_RECORD    pDataRecord         = &dataRecord;

    unsigned long       uiBytesToCopy       = 0;
    unsigned long       uiBytesToWrite      = 0;
    unsigned long       uiBytesLeftInRecord = 0;
    unsigned long       uiBytesLeftInData   = 0;
    unsigned long       uiDataPos           = 0;

    BYTE *pRecord = malloc(uiMaxLRECL);
    BYTE *pRecordPos;

    while (iErr == 0) {

        bzero(pRecord, uiMaxLRECL);
        pRecordPos = pRecord;
        uiBytesLeftInRecord = uiMaxLRECL;
        uiBytesToWrite      = 0;

        while (uiBytesLeftInRecord > 0 && iErr == 0) {

            if (uiBytesLeftInData == 0)
            {
                iErr = readDataRecord(pFileIn, pDataRecord);
                uiBytesLeftInData   = pDataRecord->length;
                uiDataPos           = 0;

                if (pDataRecord->first && pRecordPos > pRecord) {
                    writeRecord(pFileOut, pRecord, uiBytesToWrite, recfm);
                    bzero(pRecord, uiMaxLRECL);
                    pRecordPos = pRecord;
                    uiBytesLeftInRecord = uiMaxLRECL;
                    uiBytesToWrite      = 0;
                }
            }

            if (iErr == 0) {
                uiBytesToCopy = MIN(uiBytesLeftInRecord, uiBytesLeftInData);

                memcpy(pRecordPos, &pDataRecord->dataÝuiDataPos¨, uiBytesToCopy);

                uiBytesLeftInRecord -= uiBytesToCopy;
                pRecordPos          += uiBytesToCopy;

                uiBytesLeftInData   -= uiBytesToCopy;
                uiDataPos           += uiBytesToCopy;

                uiBytesToWrite      += uiBytesToCopy;
            }

            if (uiBytesLeftInData == 0 && pDataRecord->first && pDataRecord->last)
                break;
        }

        if (pRecordPos > pRecord) {
            writeRecord(pFileOut, pRecord, uiBytesToWrite, recfm);
        }
    }

    fflush(pFileOut);
}

void writeRecord(FILE *pFileOut, BYTE *pRecord, unsigned int uiBytesToWrite, ND_RECFM recfm)
{
    if (pFileOut != NULL) {

        // #1 write rdw if RECFM is V/VB/VBS
        if (recfm == V || recfm == VB || recfm == VS || recfm == VBS) {
            short length = (short) uiBytesToWrite;
            fwrite(&length, 2, 1, pFileOut);
        }
        //

        // #2 write record to disk
        fwrite(pRecord, uiBytesToWrite, 1, pFileOut);
        //
    }
}

int allocateTargetDataSet(char *sDataSetName, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pSourceFile, int add)
{
    int iErr = 0;

    unsigned int                uiFSIZE         = 0;
    unsigned int                uiLRECL         = 0;
    unsigned int                uiBLKSIZE       = 0;
    unsigned int                uiDIR           = 0;
    unsigned int                uiPRI           = 0;
    unsigned int                uiSEC           = 0;
    char                        sRECFMÝ3¨;
    char                        sMODEÝ4¨;

    // #1 get the record format
    bzero(sRECFM, sizeof(sRECFM));
    switch (pFileUtilCtrlRecord->INMRECFM) {
        case F:
            strcpy(sRECFM, "f");
            break;
        case FB:
            strcpy(sRECFM, "fb");
            break;
        case V:
            strcpy(sRECFM, "v");
            break;
        case VB:
            strcpy(sRECFM, "vb");
            break;
        case VS:
            strcpy(sRECFM, "vs");
            break;
        case VBS:
            strcpy(sRECFM, "vbs");
            break;
        case U:
            strcpy(sRECFM, "u");
            break;
        default:
            printf("ERR> Unknown RECFM found \n");
            strcpy(sRECFM, "u");
            break;
    }
    //

    // #2 get the logical record length
    uiLRECL = pFileUtilCtrlRecord->INMLRECL;
    // TODO: check the 0x02 flag in recfm to decide wether to add 4 byte to lrecl or not
    if (pFileUtilCtrlRecord->INMRECFM == V ||
        pFileUtilCtrlRecord->INMRECFM == VB) {
        if (add) {
            uiLRECL += 4;
        }
    }
    //

    // #3 get the directory blocks
    uiDIR = pFileUtilCtrlRecord->INMDIR;
    //

    // #4 get the block size
    uiBLKSIZE = pFileUtilCtrlRecord->INMBLKSZ;
    //

    // #5 calculate number of tracks for the primary allocation
    uiFSIZE = pFileUtilCtrlRecord->INMSIZE;
    if (uiFSIZE <= 0) {
        // if no file size was specified, we have to use the original xmit file size
        uiFSIZE = getFileSize(pSourceFile);
    }
    uiPRI = calculateTracks(uiFSIZE, uiBLKSIZE);
    uiSEC = uiPRI;
    //

    bzero(sMODE, sizeof(sMODE));
    strcat(sMODE, "wb");

    iErr = createDataset(sDataSetName, sMODE, sRECFM, uiLRECL, uiBLKSIZE, uiDIR, uiPRI, uiSEC);

    return iErr;
}

// SVC99 STUFF
int dinfo(const char *ddname, char *dsname, char *memname)
{
    int rcsvc, len;

    __S99parms parmlist;

    unsigned char tuÝ3¨Ý50¨;
    unsigned char *tupÝ3¨;

    memset(&parmlist, 0, sizeof(parmlist));
    parmlist.__S99RBLN = 20;
    parmlist.__S99VERB = 7;
    parmlist.__S99TXTPP = tup;

    memcpy(tuÝ0¨, "\x00\x01\x00\x01\x00", 5);
    tuÝ0¨Ý5¨ = (unsigned char) strlen(ddname);
    memcpy((void *) &(tuÝ0¨Ý6¨), ddname, strlen(ddname));

    memcpy(tuÝ1¨, "\x00\x05\x00\x01\x00\x2C"
                  "                                            ",
           6 + 44);

    memcpy(tuÝ2¨, "\x00\x06\x00\x01\x00\x08"
                  "        ",
           6 + 8);

    tupÝ0¨ = tuÝ0¨;
    tupÝ1¨ = tuÝ1¨;
    tupÝ2¨ = tuÝ2¨;

    tupÝ2¨ = (unsigned char *) ((unsigned long) tupÝ2¨ | 0x80000000);

    rcsvc = svc99(&parmlist);

    if (rcsvc != 0) {
        printf("ERR> error from svc99: %d/%hu/%hu\n",
               rcsvc,
               parmlist.__S99ERROR,
               parmlist.__S99INFO);
    } else {
        len = (int) (tupÝ1¨Ý5¨);
        sprintf(dsname, "%-*.*s", len, len, &(tupÝ1¨Ý6¨));

        len = (int) (tupÝ2¨Ý5¨);
        sprintf(memname, "%-*.*s", len, len, &(tupÝ2¨Ý6¨));
    }

    return rcsvc;
}

int dfree(char * ddn)
{
    int iErr = 0;

    __dyn_t ip;
    dyninit(&ip);

    ip.__ddname = ddn;

    iErr = dynfree(&ip);

    return iErr;
}

int allocateSYSIN()
{
    int iErr;

    __dyn_t dyn_parms;

    dyninit(&dyn_parms);

    dyn_parms.__ddname      = "SYSIN";
    dyn_parms.__misc_flags  = __DUMMY_DSN;

    iErr = dynalloc(&dyn_parms);

    return iErr;
}

int allocateSYSUT1(char *sDataSetName)
{
    int iErr;

    __dyn_t dyn_parms;

    dyninit(&dyn_parms);

    dyn_parms.__ddname      = "SYSUT1";
    dyn_parms.__dsname      = sDataSetName;
    dyn_parms.__status      = __DISP_SHR;

    iErr = dynalloc(&dyn_parms);

    if (iErr == 0) {
        printf("DBG>    SYSUT1 was allocated to %s\n", sDataSetName);
    }

    return iErr;
}

int allocateSYSUT2(char *sDataSetName, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pF_IN)
{
    int iErr;

    __dyn_t dyn_parms;

    unsigned int uiFileSze;
    unsigned int uiFileSze2;
    unsigned int uiPriTracks;
    unsigned int uiSecTracks;
    unsigned int uiBlkSize;
    unsigned int uiDirBlks;

    const int TRACK_SIZE = 19069 - 8; // 3350 track size - 8 byte overhead

    // get block size
    uiBlkSize = pFileUtilCtrlRecord->INMBLKSZ;

    // get directory blocks
    uiDirBlks = pFileUtilCtrlRecord->INMDIR;

    // calculate number of tracks for the primary / secondary allocation
    uiFileSze = pFileUtilCtrlRecord->INMSIZE;
    uiFileSze2 = getFileSize(pF_IN);
    if (uiFileSze <= 0 ||
        (uiFileSze * 1.5 > uiFileSze2)) {
        uiFileSze = uiFileSze2;
    }
    uiPriTracks = calculateTracks(uiFileSze, uiBlkSize);
    uiSecTracks = uiPriTracks / 2;
    //

    dyninit(&dyn_parms);

    dyn_parms.__ddname      = "SYSUT2";
    dyn_parms.__dsname      = sDataSetName;
    dyn_parms.__status      = __DISP_NEW;
    dyn_parms.__normdisp    = __DISP_CATLG;
    dyn_parms.__dsorg       = __DSORG_PO;
    dyn_parms.__alcunit     = __TRK;
    dyn_parms.__misc_flags  = __RELEASE;
    dyn_parms.__primary     = (int) uiPriTracks;
    dyn_parms.__secondary   = (int) uiSecTracks;
    dyn_parms.__dirblk      = (int) uiDirBlks;

    if (dyn_parms.__blksize <= TRACK_SIZE) {
        dyn_parms.__unit        = "SYSDA";
    } else {
        dyn_parms.__unit        = "3390";
    }

    iErr = dynalloc(&dyn_parms);

    if (iErr == 0) {
        printf("DBG>    SYSUT2 was allocated to %s with %d tracks and %d dir blocks\n", sDataSetName, uiPriTracks, uiDirBlks);
    }

    return iErr;
}

int allocateTMPSEQ(P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord, FILE *pF_IN)
{
    int iErr;


    __dyn_t dyn_parms;

    unsigned int uiFSIZE;
    unsigned int uiFSIZE2;

    const int TRACK_SIZE = 19069 - 8; // 3350 track size - 8 byte overhead

    dyninit(&dyn_parms);

    dyn_parms.__ddname      = "TMPSEQ";
    dyn_parms.__dsorg       = __DSORG_PS;
    dyn_parms.__status      = __DISP_NEW;
    dyn_parms.__normdisp    = __DISP_DELETE;
    dyn_parms.__alcunit     = __TRK;
    dyn_parms.__misc_flags  = __RELEASE;

    switch (pFileUtilCtrlRecord->INMRECFM) {
        case F:
            dyn_parms.__recfm = _F_;
            break;
        case FB:
            dyn_parms.__recfm = _FB_;
            break;
        case V:
            dyn_parms.__recfm = _V_;
            break;
        case VB:
            dyn_parms.__recfm = _VB_;
            break;
        case VS:
            dyn_parms.__recfm = _VS_;
            break;
        case VBS:
            dyn_parms.__recfm = _VBS_;
            break;
        case U:
            dyn_parms.__recfm = _U_;
            break;
        default:
            printf("ERR> Unknown RECFM found \n");
            dyn_parms.__recfm = _U_;
            break;
    }

    dyn_parms.__dirblk      = (short) pFileUtilCtrlRecord->INMDIR;
    dyn_parms.__blksize     = (short) pFileUtilCtrlRecord->INMBLKSZ;

    if (dyn_parms.__blksize <= TRACK_SIZE) {
        dyn_parms.__unit        = "WORK";
    } else {
        dyn_parms.__unit        = "3390";
    }

    //
    dyn_parms.__lrecl = pFileUtilCtrlRecord->INMLRECL;
    // TODO: check the 0x02 flag in recfm to decide wether to add 4 byte to lrecl or not
    if (pFileUtilCtrlRecord->INMRECFM == V ||
        pFileUtilCtrlRecord->INMRECFM == VB) {
        dyn_parms.__lrecl += 4;
    }
    //

    //
    uiFSIZE  = pFileUtilCtrlRecord->INMSIZE;
    uiFSIZE2 = getFileSize(pF_IN);
    if (uiFSIZE <= 0 ||
        (uiFSIZE * 1.5 > uiFSIZE2)) {
        uiFSIZE = uiFSIZE2;
    }
    //

    dyn_parms.__primary     = (int) calculateTracks(uiFSIZE, dyn_parms.__blksize);
    dyn_parms.__secondary   = dyn_parms.__primary / 2;
    //

    iErr = dynalloc(&dyn_parms);

    if (iErr == 0) {
        char dsnameÝ44 +1¨;
        dinfo(dyn_parms.__ddname, dsname, "");
        printf("DBG>    TMPSEQ was allocated to %s with %d tracks and %d dir blocks\n", dsname
                                                                                        , dyn_parms.__primary
                                                                                        , dyn_parms.__dirblk);
    }

    return iErr;
}
