#include <string.h>
#include "bmem.h"
#include "rexx.h"
#include "lstring.h"
#include "bintree.h"
#include "stack.h"
#include "rxmvsext.h"
#include "fss.h"
#include "util.h"

/*
#define VALLOC(VN,VL) { (VN)=(char *)malloc((VL)); \
                              memset((VN),0,(VL)); }
#define VFREE(VN) { free((VN)); }
#define SNULL(V) { memset((V),0,strlen((V))); }
*/

int RxEXECIO();
int RxVSAMIO();
int RxFSS_INIT();
int RxFSS_TERM();
int RxFSS_RESET();
int RxFSS_TEXT();
int RxFSS_FIELD();
int RxFSS_SET();
int RxFSS_GET();
int RxFSS_REFRESH();
int RxDEMO();

// internal functions
char *rxpull();
void rxqueue(char *s);
long rxqueued();
void remlf(char *s);
void clearcmd();
int parsecmd(char scmdÝ256¨);
int findcmd(char scmdÝ255¨);
int RxForceRC(int rc);

extern RX_ENVIRONMENT_CTX_PTR environment;
char *hcmdargvpÝ128¨;
bool vsamsubtSet = FALSE;

typedef char BYTE;

bool
isHostCmd(PLstr cmd, PLstr env)
{
    bool isHostCmd = FALSE;
    char lclcmdÝ1025¨;

    strcpy(lclcmd, (const char *) LSTR(*cmd));
    parsecmd(lclcmd);

    if (strcasecmp(hcmdargvpÝ0¨, "EXECIO") == 0) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp(hcmdargvpÝ0¨, "VSAMIO") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "INIT") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "TERM") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "RESET") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "TEXT") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "FIELD") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "SET") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "GET") == 0)) {
        isHostCmd = TRUE;
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "REFRESH") == 0)) {
        isHostCmd = TRUE;
    }

    return isHostCmd;
}

int
handleHostCmd(PLstr cmd, PLstr env)
{
    int returnCode = 0;

    char lclcmdÝ1025¨;

    strcpy(lclcmd, (const char *) LSTR(*cmd));
    parsecmd(lclcmd);

    if ( (strcasecmp(hcmdargvpÝ0¨, "EXECIO") == 0)) {
        returnCode = RxEXECIO();
    } else if ( (strcasecmp(hcmdargvpÝ0¨, "VSAMIO") == 0)) {
        returnCode = RxVSAMIO();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                 (strcasecmp(hcmdargvpÝ0¨, "INIT") == 0)) {
        returnCode = RxFSS_INIT();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "TERM") == 0)) {
        returnCode = RxFSS_TERM();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "RESET") == 0)) {
        returnCode = RxFSS_RESET();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "TEXT") == 0)) {
        returnCode = RxFSS_TEXT();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "FIELD") == 0)) {
        returnCode = RxFSS_FIELD();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "SET") == 0)) {
        returnCode = RxFSS_SET();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "GET") == 0)) {
        returnCode = RxFSS_GET();
    } else if ( (strcasecmp((char *)LSTR(*env) , "FSS") == 0) &&
                (strcasecmp(hcmdargvpÝ0¨, "REFRESH") == 0)) {
        returnCode = RxFSS_REFRESH();
    }

    return returnCode;
}

int
RxVSAMIO()
{
    RX_VSAM_PARAMS_PTR params;

    int iErr = 0;

    params =  MALLOC(sizeof(RX_VSAM_PARAMS),"RXVSAM");
    memset(params,0,sizeof(RX_VSAM_PARAMS));
    strcpy(params->VSAMDDN,"        ");

    // OPEN
    if (strcasecmp(hcmdargvpÝ1¨, "OPEN") == 0) {

        // set function code
        if (findcmd("READ") != -1) {
            strcpy(params->VSAMFUNC,"OPENR");
        } else if (findcmd("UPDATE") != -1) {
            strcpy(params->VSAMFUNC,"OPENU");
        } else if (findcmd("LOAD") != -1) {
            strcpy(params->VSAMFUNC,"OPENL");
        } else if (findcmd("RESET") != -1) {
            strcpy(params->VSAMFUNC,"OPENX");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

#ifdef __DEBUG__
        // enable tracing via WTOs
        params->VSAMMOD = 'T';
#else
        // disable tracing
        params->VSAMMOD = 'N';
#endif

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // READ
    } else if (strcasecmp(hcmdargvpÝ1¨, "READ") == 0) {

        unsigned char vnameÝ19¨;
        int pos;
        bool useVar = FALSE;

        // set function code
        pos = findcmd("KEY");
        if (pos != -1) {
            if (findcmd("UPDATE") == -1) {
                strcpy(params->VSAMFUNC, "READK");
            } else {
                strcpy(params->VSAMFUNC, "READKU");
            }
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findcmd("NEXT") != -1) {
            if (findcmd("UPDATE") == -1) {
                strcpy(params->VSAMFUNC, "READN");
            } else {
                strcpy(params->VSAMFUNC, "READNU");
            }
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findcmd("VAR");
        if (pos != -1) {
            useVar = TRUE;
            strcpy(vname, hcmdargvpÝ++pos¨);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        if (iErr == 0 && params->VSAMRECL > 0) {

            char *record;

            record = MALLOC(params->VSAMRECL + 1, "VSAM RECORD");
            memset(record, 0,  params->VSAMRECL + 1);
            memcpy(record,(char *)params->VSAMREC, params->VSAMRECL);
            //strncpy(record,(char *)params->VSAMREC, params->VSAMRECL);

            if (useVar){
                setVariable2(vname, record, params->VSAMRECL);
            } else {
                rxqueue(record);
            }

            FREE(record);
        }

    // LOCATE
    } else if (strcasecmp(hcmdargvpÝ1¨, "LOCATE") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "LOCATE");

        pos = findcmd("KEY");
        if (pos != -1) {
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // POINT
    } else if (strcasecmp(hcmdargvpÝ1¨, "POINT") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "POINT");

        pos = findcmd("KEY");
        if (pos != -1) {
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // WRITE
    } else if (strcasecmp(hcmdargvpÝ1¨, "WRITE") == 0) {

        unsigned char vnameÝ19¨;
        int pos;

        PLstr plsValue;
        bool useVar = FALSE;

        LPMALLOC(plsValue)

        pos = findcmd("KEY");
        if (pos != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "WRITEK");
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findcmd("NEXT") != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "WRITEN");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findcmd("VAR");
        if (pos != -1) {
            useVar = TRUE;
            strcpy(vname, hcmdargvpÝ++pos¨);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // set record
        if (useVar) {
            getVariable(vname,plsValue);
            params->VSAMREC = (unsigned *) plsValue->pstr;
        } else {
            params->VSAMREC = (unsigned *) rxpull();
        }

        params->VSAMRECL = strlen((char *)params->VSAMREC);

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        LPFREE(plsValue)

    // INSERT
    } else if (strcasecmp(hcmdargvpÝ1¨, "INSERT") == 0) {

        unsigned char vnameÝ19¨;
        int pos;

        PLstr plsValue;
        bool useVar = FALSE;

        LPMALLOC(plsValue)

        // set function code
        strcpy(params->VSAMFUNC, "INSERT");

        pos = findcmd("KEY");
        if (pos != -1) {
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findcmd("VAR");
        if (pos != -1) {
            useVar = TRUE;
            strcpy(vname, hcmdargvpÝ++pos¨);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // set record
        if (useVar) {
            getVariable(vname,plsValue);
            params->VSAMREC = (unsigned *) plsValue->pstr;
        } else {
            params->VSAMREC = (unsigned *) rxpull();
        }

        params->VSAMRECL = strlen((char *)params->VSAMREC);

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        LPFREE(plsValue)

    // DELETE
    } else if (strcasecmp(hcmdargvpÝ1¨, "DELETE") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "DELETEK");

        pos = findcmd("KEY");
        if (pos != -1) {
            strcpy(params->VSAMKEY, hcmdargvpÝ++pos¨);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findcmd("NEXT") != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "DELETEN");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
            strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
        } else {
            iErr = -1;
        }

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // CLOSE
    } else if (strcasecmp(hcmdargvpÝ1¨, "CLOSE") == 0) {

        // set function code
        if (strcasecmp(hcmdargvpÝ2¨, "ALL") == 0) {
            strcpy(params->VSAMFUNC,"CLOSEA");
        } else {
            strcpy(params->VSAMFUNC,"CLOSE");

            // set DDN
            if (strlen(hcmdargvpÝ2¨) >= 1 && strlen(hcmdargvpÝ2¨) <= 8) {
                strncpy(params->VSAMDDN, hcmdargvpÝ2¨, strlen(hcmdargvpÝ2¨));
            } else {
                iErr = -1;
            }
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // call rxvsam
        if (iErr == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            iErr = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    } else {
        FREE(params);
        Lerror(ERR_INCORRECT_CALL,0);
    }

    FREE(params);

    return (RxForceRC(iErr));
}

int
RxEXECIO()
{
    int ii;
    char str1Ý64¨;
    unsigned char pbuffÝ1025¨;
    unsigned char vname1Ý19¨;
    unsigned char vname2Ý19¨;
    unsigned char vname3Ý19¨;
    unsigned char obuffÝ4097¨;
    int ip1 = 0;
    int recs = 0;
    FILE *f;
    PLstr plsValue;

    LPMALLOC(plsValue)

    // DISKR
    if (strcasecmp(hcmdargvpÝ2¨, "DISKR") == 0) {
        ip1 = findcmd("STEM");
        if (ip1 != -1) {
            ip1++;
            strcpy(vname1, hcmdargvpÝip1¨);         // name of stem variable
        }
        memset(str1,0,sizeof(str1));
        f = fopen(hcmdargvpÝ3¨, "r");
        if (f == NULL) {
            return (RxForceRC(8));
        }
        recs = 0;
        while (fgets(pbuff, 1024, f)) {
            recs++;
            remlf(&pbuffÝ0¨);                       // remove linefeed
            sprintf(vname2, "%s%d", vname1, recs);  // edited stem name
            if (ip1 != -1) {
                setVariable(vname2, pbuff);         // set rexx variable
            }
            if (ip1 == -1) {
                rxqueue(pbuff);
            }
        }
        if (ip1 > 0) {
            sprintf(vname2, "%s0", vname1);
            sprintf(vname3, "%d", recs);
            setVariable(vname2, vname3);
        }
        fclose(f);
        return (RxForceRC(0));
    }

    // DISKW
    if (strcasecmp(hcmdargvpÝ2¨, "DISKW") == 0) {
        ip1 = findcmd("STEM");
        if (ip1 != -1) {
            ip1++;
            strcpy(vname1, hcmdargvpÝip1¨);  // name of stem variable
        }
        f = fopen(hcmdargvpÝ3¨, "w");
        if (f == NULL) {
            return (RxForceRC(8));
        }
        if (ip1 != -1) {
            sprintf(vname2, "%s0", vname1);
            recs = getIntegerVariable(vname2);
        }
        if (ip1 == -1) {
            recs = rxqueued();
        }
        for (ii = 1; ii <= recs; ii++) {
            if (ip1 != -1) {
                memset(vname2, 0, sizeof(vname2));
                sprintf(vname2, "%s%d", vname1, ii);
                getVariable(vname2, plsValue);
                sprintf(obuff, "%s\n", LSTR(*plsValue));
                fputs(obuff, f);
            }
            if (ip1 == -1) {
                memset(obuff, 0, sizeof(vname2));
                sprintf(obuff, "%s\n", rxpull());
                fputs(obuff, f);
            }
        }
        fclose(f);
        return (RxForceRC(0));
    }

    // DISKA
    if (strcasecmp(hcmdargvpÝ2¨, "DISKA") == 0) {
        ip1 = findcmd("STEM");
        if (ip1 > 0) {
            ip1++;
            strcpy(vname1, hcmdargvpÝip1¨);  // name of stem variable
        }
        f = fopen(hcmdargvpÝ3¨, "a");
        if (f == NULL) {
            return (RxForceRC(8));
        }
        sprintf(vname2, "%s0", vname1);
        recs = getIntegerVariable(vname2);
        for (ii = 1; ii <= recs; ii++) {
            memset(vname2, 0, sizeof(vname2));
            sprintf(vname2, "%s%d", vname1, ii);
            getVariable(vname2, plsValue);
            sprintf(obuff, "%s\n", LSTR(*plsValue));
            fputs(obuff, f);
        }
        fclose(f);
        return (RxForceRC(0));
    }

    LPFREE(plsValue)
}

int
RxFSS_INIT()
{
    // basic 3270 attributes
    setIntegerVariable("#PROT",   fssPROT);
    setIntegerVariable("#NUM",    fssNUM);
    setIntegerVariable("#HI",     fssHI);
    setIntegerVariable("#NON",    fssNON);

    // extended color attributes
    setIntegerVariable("#BLUE",   fssBLUE);
    setIntegerVariable("#RED",    fssRED);
    setIntegerVariable("#PINK",   fssPINK);
    setIntegerVariable("#GREEN",  fssGREEN);
    setIntegerVariable("#TURQ",   fssTURQ);
    setIntegerVariable("#YELLOW", fssYELLOW);
    setIntegerVariable("#WHITE",  fssWHITE);

    // extended highlighting attributes
    setIntegerVariable("#BLINK",   fssBLINK);
    setIntegerVariable("#REVERSE", fssREVERSE);
    setIntegerVariable("#USCORE",  fssUSCORE);

    // 270 AID Characters
    setIntegerVariable("#ENTER",  fssENTER);
    setIntegerVariable("#PFK01",  fssPFK01);
    setIntegerVariable("#PFK02",  fssPFK02);
    setIntegerVariable("#PFK03",  fssPFK03);
    setIntegerVariable("#PFK04",  fssPFK04);
    setIntegerVariable("#PFK05",  fssPFK05);
    setIntegerVariable("#PFK06",  fssPFK06);
    setIntegerVariable("#PFK07",  fssPFK07);
    setIntegerVariable("#PFK08",  fssPFK08);
    setIntegerVariable("#PFK09",  fssPFK09);
    setIntegerVariable("#PFK10",  fssPFK10);
    setIntegerVariable("#PFK11",  fssPFK11);
    setIntegerVariable("#PFK12",  fssPFK12);
    setIntegerVariable("#PFK13",  fssPFK13);
    setIntegerVariable("#PFK14",  fssPFK14);
    setIntegerVariable("#PFK15",  fssPFK15);
    setIntegerVariable("#PFK16",  fssPFK16);
    setIntegerVariable("#PFK17",  fssPFK17);
    setIntegerVariable("#PFK18",  fssPFK18);
    setIntegerVariable("#PFK19",  fssPFK19);
    setIntegerVariable("#PFK20",  fssPFK20);
    setIntegerVariable("#PFK21",  fssPFK21);
    setIntegerVariable("#PFK22",  fssPFK22);
    setIntegerVariable("#PFK23",  fssPFK23);
    setIntegerVariable("#PFK24",  fssPFK24);
    setIntegerVariable("#CLEAR",  fssCLEAR);
    setIntegerVariable("#RESHOW", fssRESHOW);

    return fssInit();
}

int
RxFSS_TERM()
{
    return fssTerm();
}

int
RxFSS_RESET()
{
    return fssReset();
}

int
RxFSS_FIELD()
{
    int iErr = 0;

    PLstr plsFieldName;
    PLstr plsValue;
    int row  = 0;
    int col  = 0;
    int attr = 0;
    int len  = 0;

    LPMALLOC(plsFieldName)
    LPMALLOC(plsValue)

    // check row is numeric
    if (fssIsNumeric(hcmdargvpÝ1¨)) {
        row = atoi(hcmdargvpÝ1¨);
    } else {
        iErr = -1;
    }

    // check col is numeric
    if (fssIsNumeric(hcmdargvpÝ2¨)) {
        col = atoi(hcmdargvpÝ2¨);
    } else {
        iErr = -2;
    }

    // check attr is numeric
    if (fssIsNumeric(hcmdargvpÝ3¨)) {
        attr = atoi(hcmdargvpÝ3¨);
    }

    // check len is numeric
    if (fssIsNumeric(hcmdargvpÝ5¨)) {
        len = atoi(hcmdargvpÝ5¨);
    } else {
        iErr = -5;
    }

    if (iErr == 0) {
        getVariable(hcmdargvpÝ6¨, plsValue);

        iErr = fssFld(row, col, attr, hcmdargvpÝ4¨, len, (char *)LSTR(*plsValue));
    }

    LPFREE(plsFieldName)
    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_TEXT()
{
    int iErr = 0;

    PLstr plsValue;
    int row  = 0;
    int col  = 0;
    int attr = 0;

    LPMALLOC(plsValue)

    // check row is numeric
    if (fssIsNumeric(hcmdargvpÝ1¨)) {
        row = atoi(hcmdargvpÝ1¨);
    } else {
        iErr = -1;
    }

    // check col is numeric
    if (fssIsNumeric(hcmdargvpÝ2¨)) {
        col = atoi(hcmdargvpÝ2¨);
    } else {
        iErr = -2;
    }

    // check attr is numeric
    if (fssIsNumeric(hcmdargvpÝ3¨)) {
        attr = atoi(hcmdargvpÝ3¨);
    } else {
        if (strstr(hcmdargvpÝ3¨, "#ATTR") != NULL) {
            attr = getIntegerVariable("#ATTR");
        } else {
            if(strstr(hcmdargvpÝ3¨, "#PROT") != NULL){
                attr = attr + fssPROT;
            }
            if(strstr(hcmdargvpÝ3¨, "#NUM") != NULL){
                attr = attr + fssNUM;
            }
            if(strstr(hcmdargvpÝ3¨, "#HI") != NULL){
                attr = attr + fssHI;
            }
            if(strstr(hcmdargvpÝ3¨, "#NON") != NULL){
                attr = attr + fssNON;
            }
            if(strstr(hcmdargvpÝ3¨, "#BLUE") != NULL){
                attr = attr + fssBLUE;
            }
            if(strstr(hcmdargvpÝ3¨, "#RED") != NULL){
                attr = attr + fssRED;
            }
            if(strstr(hcmdargvpÝ3¨, "#PINK") != NULL){
                attr = attr + fssPINK;
            }
            if(strstr(hcmdargvpÝ3¨, "#GREEN") != NULL){
                attr = attr + fssGREEN;
            }
            if(strstr(hcmdargvpÝ3¨, "#TURQ") != NULL){
                attr = attr + fssTURQ;
            }
            if(strstr(hcmdargvpÝ3¨, "#YELLOW") != NULL){
                attr = attr + fssYELLOW;
            }
            if(strstr(hcmdargvpÝ3¨, "#WHITE") != NULL){
                attr = attr + fssWHITE;
            }
            if(strstr(hcmdargvpÝ3¨, "#BLINK") != NULL){
                attr = attr + fssBLINK;
            }
            if(strstr(hcmdargvpÝ3¨, "#REVERSE") != NULL){
                attr = attr + fssREVERSE;
            }
            if(strstr(hcmdargvpÝ3¨, "#USCORE") != NULL){
                attr = attr + fssUSCORE;
            }
        }

    }

    if (iErr == 0) {
        getVariable(hcmdargvpÝ4¨, plsValue);

        iErr = fssTxt(row, col, attr, (char *)LSTR(*plsValue));
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_SET()
{
    int iErr = 0;

    PLstr plsValue;

    LPMALLOC(plsValue)

    if (findcmd("CURSOR") == 1)
    {
        iErr = fssSetCursor(hcmdargvpÝ2¨);
    } else if ( findcmd("FIELD") == 1)
    {
        getVariable(hcmdargvpÝ3¨, plsValue);
        iErr = fssSetField(hcmdargvpÝ2¨, (char *)LSTR(*plsValue));
    } else if ( findcmd("COLOR") == 1)
    {
        int color = 0;

        // check color is numeric
        if (fssIsNumeric(hcmdargvpÝ3¨))
        {
            color = atoi(hcmdargvpÝ3¨);
        }
        else
        {
            if(strstr(hcmdargvpÝ3¨, "#BLUE") != NULL)
            {
                color = fssBLUE;
            }
            if(strstr(hcmdargvpÝ3¨, "#RED") != NULL)
            {
                color = fssRED;
            }
            if(strstr(hcmdargvpÝ3¨, "#PINK") != NULL)
            {
                color = fssPINK;
            }
            if(strstr(hcmdargvpÝ3¨, "#GREEN") != NULL)
            {
                color = fssGREEN;
            }
            if(strstr(hcmdargvpÝ3¨, "#TURQ") != NULL)
            {
                color = fssTURQ;
            }
            if(strstr(hcmdargvpÝ3¨, "#YELLOW") != NULL)
            {
                color = fssYELLOW;
            }
            if(strstr(hcmdargvpÝ3¨, "#WHITE") != NULL)
            {
                color = fssWHITE;
            }
        }

        getVariable(hcmdargvpÝ3¨, plsValue);
        iErr = fssSetColor(hcmdargvpÝ2¨, color);
    } else
    {
        iErr = -1;
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_GET()
{
    int iErr = 0;

    PLstr plsValue;
    char *  tmp = NULL;

    LPMALLOC(plsValue)

    if (findcmd("AID") == 1) {
        setIntegerVariable(hcmdargvpÝ2¨, fssGetAID());
    } else if (findcmd("WIDTH") == 1) {
        setIntegerVariable(hcmdargvpÝ2¨, fssGetAlternateScreenWidth());
    } else if (findcmd("HEIGHT") == 1) {
        setIntegerVariable(hcmdargvpÝ2¨, fssGetAlternateScreenHeight());
    } else if (findcmd("FIELD") == 1) {
        setVariable(hcmdargvpÝ3¨, fssGetField(hcmdargvpÝ2¨));
    } else {
        iErr = -1;
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_REFRESH()
{
    return fssRefresh();
}

void
rxqueue(char *s)
{
    PLstr pstr;

    LPMALLOC(pstr)

    Lscpy(pstr, s);
    Queue2Stack(pstr);
}

long
rxqueued()
{
    return (StackQueued());
}

char *
rxpull()
{
    PLstr pstr;
    pstr = PullFromStack();
    return ((char *) LSTR(*pstr));
}

void
remlf(char *s)
{
    char *pos;
    if ((pos = strchr(s, '\n')) != NULL) {
        *pos = '\0';
    }
}

void
clearcmd()
{
    int i = 0;
    for (i = 0; i <= 128; i++) {
        hcmdargvpÝi¨ = NULL;
    }
}

int
parsecmd(char scmdÝ256¨)
{
    int lidx;
    lidx=0;
    clearcmd();
    hcmdargvpÝlidx¨=strtok(scmd," (),");
    printf(" ");  // without this f*** printf, the strtok will not work on MVS
    while(hcmdargvpÝlidx¨!=NULL) {
        lidx++;
        hcmdargvpÝlidx¨=strtok(NULL," (),");
    }
    if(lidx==0) { hcmdargvpÝlidx¨=(char *)&scmd; }
    return(lidx);
}

int
findcmd(char scmdÝ255¨)
{
    int lidx = 0;
    while (hcmdargvpÝlidx¨ != NULL) {
        if (strcasecmp(scmd, hcmdargvpÝlidx¨) == 0) {
            return (lidx);
        }
        lidx++;
    }
    return (-1);
}

int
RxForceRC(int rc)
{
    RxSetSpecialVar(RCVAR, rc);
    return (rc);
}
