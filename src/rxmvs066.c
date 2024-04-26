#include <stdlib.h>
#include <stdio.h>

#ifdef JCC
#include <io.h>
#include <time.h>
#include "sockets.h"
#include "mvsutils.h"
#include "rxmvsext.h"
#elif WIN32
#else
# include <sys/socket.h>
# include <sys/time.h>
# include <netinet/in.h>
# include <netinet/ip.h> /* superset of previous */
# include <netdb.h>
# include <arpa/inet.h>
# include <errno.h>
# define SOCKET      long
# define SOCKADDR_IN struct sockaddr_in
# define LPSOCKADDR  struct sockaddr *
# define SOCKET      long
# define INVALID_SOCKET (-1)
# define SOCKET_ERROR   (-1)
# define WSAGetLastError() errno
#endif

#include "irx.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "rxtso.h"
#include "util.h"
#include "rxnetdat.h"
#include "dynit.h"
#ifdef __DEBUG__
#include "bmem.h"
#endif

RX_ENVIRONMENT_CTX_PTR environment = NULL;

#ifdef JCC
extern FILE * stdin;
extern FILE * stdout;
extern FILE * stderr;
#endif

/* FLAG2 */
const unsigned char _TSOFG  = 0x1; // hex for 0000 0001
const unsigned char _TSOBG  = 0x2; // hex for 0000 0010
const unsigned char _EXEC   = 0x4; // hex for 0000 0100
const unsigned char _ISPF   = 0x8; // hex for 0000 1000
/* FLAG3 */
const unsigned char _STDIN  = 0x1; // hex for 0000 0001
const unsigned char _STDOUT = 0x2; // hex for 0000 0010
const unsigned char _STDERR = 0x4; // hex for 0000 0100

#ifdef JCC
extern char* _style;
extern void ** entry_R13;
#else
char* _style;
void ** entry_R13;
#endif

static int i;

/* internal function prototypes */
int GetClistVar(PLstr name, PLstr value);
int SetClistVar(PLstr name, PLstr value);

void parseArgs(char **array, char *str);
void parseDCB(FILE *pFile);
int checkNameLength(long lName);
int checkValueLength(long lValue);
int checkVariableBlacklist(PLstr name);
int reopen(int fp);

void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode);
int _EncryptString(const PLstr to, const PLstr from, const PLstr password);
void _rotate(PLstr to,PLstr from, int start,int slen);
void Lhash(const PLstr to, const PLstr from, long slots) ;


#ifdef __CROSS__
int __get_ddndsnmemb (int handle, char * ddn, char * dsn,
                      char * member, char * serial, unsigned char * flags);

#endif

#define BLACKLIST_SIZE 8
char *RX_VAR_BLACKLIST[BLACKLIST_SIZE] = {"RC", "LASTCC", "SIGL", "RESULT", "SYSPREF", "SYSUID", "SYSENV", "SYSISPF"};

#ifdef __CROSS__
/* ------------------------------------------------------------------------------------*/
char*
getNextVar(void** nextPtr)
{
    BinTree *currentTree = NULL;
    BinLeaf *leaf  = NULL;
    PLstr    value = NULL;

    currentTree = &(_proc[_rx_proc].scope[0]);

    if (*nextPtr == 0) {
        leaf = BinMin(currentTree->parent);
    }
    else {
        leaf = BinSuccessor(leaf);
    }

    return ((PLstr)leaf->value)->pstr;


    /*
    while (leaf == NULL && i < VARTREES) {
        if (nextPtr == NULL) {
            leaf = BinMin(_proc[_rx_proc].scope[i].parent);
        } else {
            leaf = BinSuccessor(nextPtr);
        }

        if (leaf != NULL) {
            value = (PLstr) leaf->value;
            leaf = BinSuccessor(leaf);
            if (leaf != NULL) {
                nextPtr = BinSuccessor(leaf);
            } else {
                nextPtr = 0;
            }
        } else {
            i++;
        }
    }

    return LSTR(*value);
    */
}
/* ------------------------------------------------------------------------------------*/
#endif

void R_dumpIt(int func)
{
    void *ptr  = 0;
    int   size = 0;
    long  adr  = 0;

    if (ARGN > 2 || ARGN < 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (ARGN == 1) {

    } else {
        Lx2d(ARGR,ARG1,0);    /* using ARGR as temp field for conversion */
        adr = Lrdint(ARGR);
        if (adr < 0) {
            Lerror(ERR_INCORRECT_CALL, 0);
        }

        ptr = (void *)adr;
        size = Lrdint(ARG2);
    }



    DumpHex((unsigned char *)ptr, size);
}

void R_wto(int func)
{
    RX_WTO_PARAMS_PTR params;

    char  *msgptr = NULL;
    size_t msglen = 0;
    int      cc     = 0;
    void     *wk;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);

    msglen = MIN(strlen((char *)LSTR(*ARG1)),80);

    if (msglen > 0) {
        msgptr = malloc(msglen);
        params = malloc(sizeof(RX_WTO_PARAMS));
        wk     = malloc(256);

        memset(msgptr,0,80);
        memcpy(msgptr,(char *)LSTR(*ARG1),msglen);

        params->msgadr       = msgptr;
        params->msgladr      = (unsigned int *)&msglen;
        params->ccadr        = (unsigned *)&cc;
        params->wkadr        = (unsigned *)wk;

        call_rxwto(params);

        free(wk);
        free(params);
        free(msgptr);
    }
}

void R_listIt(int func)
{
    BinTree tree;
    int	j;
    if (ARGN > 1 ) {
        Lstr lsFuncName,lsMaxArg;

        LINITSTR(lsFuncName)
        LINITSTR(lsMaxArg)

        Lfx(&lsFuncName,6);
        Lfx(&lsMaxArg, 4);

        Lscpy(&lsFuncName, "ListIT");
        Licpy(&lsMaxArg,1);

        Lerror(ERR_INCORRECT_CALL,4,&lsFuncName, &lsMaxArg);
    }

    if (ARG1 != NULL && ARG1->pstr == NULL) {
        printf("LISTIT: invalid parameters, maybe enclose in quotes\n");
        Lerror(ERR_INCORRECT_CALL,4,1);
    }

    tree = _proc[_rx_proc].scope[0];

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        printf("List all Variables\n");
        printf("------------------\n");
        BinPrint(tree.parent, NULL);
    } else {
        LASCIIZ(*ARG1) ;
        Lupper(ARG1);
        printf("List Variables with Prefix '%s'\n",ARG1->pstr);
        printf("%.*s\n", 29+ARG1->len,
            "-------------------------------------------------------");
        BinPrint(tree.parent, ARG1);
    }
}

void R_wait(int func)
{
    RX_WAIT_PARAMS_PTR params;
    void     *wk;
    unsigned time   = 0;
    int      cc     = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_i (1,time);

    params = malloc(sizeof(RX_WAIT_PARAMS));
    wk     = malloc(256);

    params->timeadr      = &time;
    params->ccadr        = (unsigned *)&cc;
    params->wkadr        = (unsigned *)wk;

    call_rxwait(params);

    free(wk);
    free(params);
}

void R_abend(int func)
{
    RX_ABEND_PARAMS_PTR params;

    int ucc = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_i (1,ucc);

    params = malloc(sizeof(RX_ABEND_PARAMS));

    params->ucc          = ucc;

    call_rxabend(params);

    free(params);
}

void R_userid(int func)
{
    char *userid = "n.a.";

    if (ARGN>0) {
        Lerror(ERR_INCORRECT_CALL,0);
    }
#ifdef JCC
    userid = getlogin();
#endif
    Lscpy(ARGR,userid);
}

void R_listdsi(int func)
{
    char *args[2];

    char sFileName[45];
    char sFunctionCode[3];

    FILE *pFile;
    int iErr;

    QuotationType quotationType;

    char* _style_old = _style;

    memset(sFileName,0,45);
    memset(sFunctionCode,0,3);

    iErr = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    args[0]= NULL;
    args[1]= NULL;

    parseArgs(args, (char *)LSTR(*ARG1));

    if (args[1] != NULL && strcmp(args[1], "FILE") != 0)
        Lerror(ERR_INCORRECT_CALL,0);

    if (args[1] == NULL) {
        _style = "//DSN:";
        quotationType = CheckQuotation(args[0]);
        switch (quotationType) {
            case UNQUOTED:
                if (environment->SYSPREF[0] != '\0') {
                    strcat(sFileName, environment->SYSPREF);
                    strcat(sFileName, ".");
                    strcat(sFileName, (const char *) LSTR(*ARG1));
                }
                break;
            case PARTIALLY_QUOTED:
                strcat(sFunctionCode, "16");
                iErr = 2;
                break;
            case FULL_QUOTED:
                strncpy(sFileName, (const char *) (LSTR(*ARG1)) + 1, ARG1->len - 2);
                break;
            default:
                Lerror(ERR_DATA_NOT_SPEC, 0);


        }
    } else {
        strcpy(sFileName,args[0]);
        _style = "//DDN:";
    }

    if (iErr == 0) {
        pFile = FOPEN(sFileName,"R");
        if (pFile != NULL) {
            strcat(sFunctionCode,"0");
            parseDCB(pFile);
            FCLOSE(pFile);
        } else {
            strcat(sFunctionCode,"16");
        }
    }

    Lscpy(ARGR,sFunctionCode);

    _style = _style_old;
}

void R_sysdsn(int func)
{
    char sDSName[45];
    char sMessage[256];

    unsigned char *ptr;

    FILE *pFile;
    int iErr;

    QuotationType quotationType;

    char* _style_old = _style;

    const char* MSG_OK                  = "OK";
    const char* MSG_NOT_A_PO            = "MEMBER SPECIFIED, BUT DATASET IS NOT PARTITIONED";
    const char* MSG_MEMBER_NOT_FOUND    = "MEMBER NOT FOUND";
    const char* MSG_DATASET_NOT_FOUND   = "DATASET NOT FOUND";
    const char* MSG_ERROR_READING       = "ERROR PROCESSING REQUESTED DATASET";
    const char* MSG_DATSET_PROTECTED    = "PROTECTED DATASET";
    const char* MSG_VOLUME_NOT_FOUND    = "VOLUME NOT ON SYSTEM";
    const char* MSG_DATASET_UNAVAILABLE = "UNAVAILABLE DATASET";
    const char* MSG_INVALID_DSNAME      = "INVALID DATASET NAME, ";
    const char* MSG_MISSING_DSNAME      = "MISSING DATASET NAME";

    memset(sDSName,0,45);
    memset(sMessage,0,256);

    iErr = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    if (LSTR(*ARG1)[0] == '\0') {
        strcat(sMessage,MSG_MISSING_DSNAME);
        iErr = 1;
    }

    if (iErr == 0) {
        quotationType = CheckQuotation((char *)LSTR(*ARG1));
        switch(quotationType) {
            case UNQUOTED:
                if (environment->SYSPREF[0] != '\0') {
                    strcat(sDSName, environment->SYSPREF);
                    strcat(sDSName, ".");
                    strcat(sDSName, (const char*)LSTR(*ARG1));
                }
                break;
            case PARTIALLY_QUOTED:
                strcat(sMessage,MSG_INVALID_DSNAME);
                strcat(sMessage,(const char*)LSTR(*ARG1));
                iErr = 2;
                break;
            case FULL_QUOTED:
                strncpy(sDSName, (const char *)(LSTR(*ARG1))+1, ARG1->len-2);
                break;
            default:
                Lerror(ERR_DATA_NOT_SPEC,0);
        }
    }

    if (iErr == 0) {
        _style = "//DSN:";
        pFile = FOPEN(sDSName,"R");
        if (pFile != NULL) {
            strcat(sMessage, MSG_OK);
            FCLOSE(pFile);
        } else {
            strcat(sMessage,MSG_DATASET_NOT_FOUND);
        }
    }

    Lscpy(ARGR,sMessage);

    _style = _style_old;
}

void R_sysvar(int func)
{
    extern unsigned long long ullInstrCount;
    char *msg = "not yet implemented";

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    if (strcmp((const char*)ARG1->pstr, "SYSUID") == 0) {
        Lscpy(ARGR,environment->SYSUID);
    } else if (strcmp((const char*)ARG1->pstr, "SYSPREF") == 0) {
        Lscpy(ARGR, environment->SYSPREF);
    } else if (strcmp((const char*)ARG1->pstr, "SYSENV") == 0) {
        Lscpy(ARGR,environment->SYSENV);
    } else if (strcmp((const char*)ARG1->pstr, "SYSISPF") == 0) {
        Lscpy(ARGR, environment->SYSISPF);
    } else if (strcmp((const char*)ARG1->pstr, "RXINSTRC") == 0) {
        Licpy(ARGR, ullInstrCount);
    } else {
        Lscpy(ARGR,msg);
    }
}

void R_vxget(int func)
{
    PLstr plsValue;

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if ((environment->flags2 & _EXEC) == _EXEC &&
        (environment->flags2 & _ISPF) == _ISPF) {

        LPMALLOC(plsValue)
        LASCIIZ(*ARG1);

        get_s(1);
        Lupper(ARG1);

        GetClistVar(ARG1, plsValue);
        setVariable(LSTR(*ARG1), LSTR(*plsValue));

        LPFREE(plsValue);
    } else {
        Lerror(ERR_ROUTINE_NOT_FOUND,0);
    }
}

void R_vxput(int func)
{
    PLstr plsValue;

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if ((environment->flags2 & _EXEC) == _EXEC &&
        (environment->flags2 & _ISPF) == _ISPF) {

        LPMALLOC(plsValue)
        LASCIIZ(*ARG1);

        get_s(1);
        Lupper(ARG1);

        getVariable(LSTR(*ARG1), plsValue);
        SetClistVar(ARG1, plsValue);

        LPFREE(plsValue);
    } else {
        Lerror(ERR_ROUTINE_NOT_FOUND,0);
    }
}

void R_stemcopy(int func)
{
    BinTree *tree;
    PBinLeaf from, to, ptr ;
    Lstr tempKey, tempValue;
    Variable *varFrom, *varTo, *varTemp;

    if (ARGN!=2){
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    // FROM
    Lupper(ARG1);
    LASCIIZ(*ARG1);

    // TO
    Lupper(ARG2);
    LASCIIZ(*ARG2);

    tree = _proc[_rx_proc].scope;

    // look up Source stem
    from = BinFind(tree, ARG2);
    if (!from) {
       printf("Invalid Stem %s\n", LSTR(*ARG2));
       Lerror(ERR_INCORRECT_CALL,0);
    }

    //  look up Target stem, must be available, later set it up
    to = BinFind(tree, ARG1);
    if (!to) {
        printf("Target Stem missing %s\n", LSTR(*ARG1));
        Lerror(ERR_INCORRECT_CALL,0);
    }

    varFrom = (Variable *) from->value;
    varTo   = (Variable *) to->value;

    ptr = BinMin(varFrom->stem->parent);
    while (ptr != NULL) {

        LINITSTR(tempKey)
        LINITSTR(tempValue)

        Lstrcpy(&tempKey, &ptr->key);
        Lstrcpy(&tempValue, LEAFVAL(ptr));

        varTemp = (Variable *)MALLOC(sizeof(Variable),"Var");
        varTemp->value = tempValue;
        varTemp->exposed=((Variable *) ptr->value)->exposed;

        BinAdd((BinTree *)varTo->stem, &tempKey, varTemp);

        ptr = BinSuccessor(ptr);
    }

    LFREESTR(tempKey)
}
#ifndef WIN32   // don't compile in Windows
void R_tcpopen(int func) {

    int                 sock;
    unsigned long       inAddress;
    struct sockaddr_in  sockAddrIn;
    struct hostent     *host;
    struct timeval      timeout;

#ifdef JCC
    int                 lastError = 0;
#endif

    printf("DBG> connecting to %s:%d\n", LSTR(*ARG1), (int)LINT(*ARG2));

    inAddress = inet_addr((const char *) LSTR(*ARG1));

    if ((inAddress) == INADDR_NONE) {
        host = gethostbyname(LSTR(*ARG1));
        if (host == NULL || host->h_addr_list[0] == NULL) {
            printf("Unknown host %s\n", (const char *)LSTR(*ARG1));
            Lerror(ERR_INCORRECT_CALL,0);
        } else {
            inAddress = ((long *)(host->h_addr_list [0])) [0];
        }
    }

    sockAddrIn.sin_family       = AF_INET;
    sockAddrIn.sin_addr.s_addr  = inAddress;
    sockAddrIn.sin_port         = ntohs (LINT(*ARG2));

    // create socket
    sock = socket (PF_INET, SOCK_STREAM, 0);
    if (sock == INVALID_SOCKET) {
#ifdef JCC
        lastError = WSAGetLastError ();
        printf("Invalid socket. (errno=%d)\n", lastError);
        closesocket (sock);
#else
        printf("Invalid socket\n");
#endif
        Lerror(ERR_INCORRECT_CALL,0);
    }

    // set receive timeout
    timeout.tv_sec = 10;        // 10 Secs Timeout
    timeout.tv_usec = 0;        // Not init'ing this can cause strange errors

#ifdef JCC
    setsockopt(sock, SO_RCVTIMEO,(int *) &timeout, sizeof(struct timeval));
#else
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(struct timeval));
#endif

    // connect
    if (connect(sock, (LPSOCKADDR)&sockAddrIn, sizeof (sockAddrIn))) {
#ifdef JCC
        lastError = WSAGetLastError ();
        printf("Unable to connect. (errno=%d)\n", lastError);
        closesocket (sock);
#else
        printf("Unable to connect.\n");
#endif
        Lerror(ERR_INCORRECT_CALL,0);
    }

    // return socket fd
    LINT(*ARGR)  = sock;
    LTYPE(*ARGR) = LINTEGER_TY;
    LLEN(*ARGR)  = sizeof(long);

}

void R_tcprecv(int func) {

    int                 sock;

    long                j;
    char                buffer [1024];
    // char             ip_adx [260];
    // SOCKADDR_IN      Clocal_adx;
    // struct hostent * result;
    // char newline [2] = {0x15, 0x00};

#ifdef JCC
    int                 lastError = 0;
#endif

    L2INT(ARG1);
    sock = LINT(*ARG1);

    // receive data
    if ((j = recv (sock, buffer, 1024, 0)) == SOCKET_ERROR) {
        //printf("ERR> %s\n", strerror(errno));
        printf("ERR> receiving failed.\n");
        Lerror(ERR_INCORRECT_CALL,0);
        /*
        if (WSAGetLastError() != ENOTSOCK)
            _putline ("recv failed, terminating.");
        running = 0;
        break;*/
    };
#ifdef JCC
    ascii2ebcdic (buffer, j);
#endif

    if (buffer [0] == 55) {
        printf ("DBG> terminating at EOT.\n");
    }

    // print to terminal
    buffer [j] = 0;

    printf("DBG> received [%s] from server\n", buffer);

}

void R_tcpsend(int func) {

    SOCKET Ccom_han;

    long             j;
    int              sockerr=0;
    char             ip_adx [260];
    SOCKADDR_IN      Clocal_adx;
    struct hostent * result;
    char             buffer [1024];
    char newline [2] = {0x15, 0x00};

    L2INT(ARG1);
    Ccom_han = LINT(*ARG1);

    strcpy (buffer, LSTR(*ARG2));
    printf("DBG> sending [%s] to server\n", buffer);

    j = strlen (buffer);
#ifdef JCC
    ebcdic2ascii (buffer, j);
#endif

    if (send (Ccom_han, buffer, j, 0) == SOCKET_ERROR) {
        printf("ERR> send failed, terminating.\n");
#ifdef JCC
        closesocket (Ccom_han);
#endif
        Lerror(ERR_INCORRECT_CALL,0);
    }

}
#endif    // not in Windows

// -------------------------------------------------------------------------------------
// Encrypt/Decrypt  String Sub procedure
// -------------------------------------------------------------------------------------
int _EncryptString(const PLstr to, const PLstr from, const PLstr password) {
    int slen,plen, ki, kj;
    L2STR(from);
    L2STR(password);
    slen=LLEN(*from);
    plen=LLEN(*password);
    for (ki = 0, kj=0; ki < slen; ki++,kj++) {
        if (kj >= plen) kj = 0;
        LSTR(*to)[ki] = LSTR(*from)[ki] ¬ LSTR(*password)[kj];
    }
    LLEN(*to) = (size_t) slen;
    LTYPE(*to) = LSTRING_TY;
    return slen;
}
// -------------------------------------------------------------------------------------
// Encrypt String
// -------------------------------------------------------------------------------------
void R_crypt(int func) {
    int rounds=7;
 // string to encrypt and password must exist
    must_exist(1);
    must_exist(2);
    get_oi0(3,rounds);       /* drop rounds parameter, it might decrease security */
    if (rounds==0) rounds=7;  /* maximum slots */
    Lcryptall(ARGR, ARG1, ARG2,rounds,0);  // mode =0  encode
}
// -------------------------------------------------------------------------------------
// Decrypt String
// -------------------------------------------------------------------------------------
void R_decrypt(int func) {
    int rounds=7;
    // string to encrypt and password must exist
    must_exist(1);
    must_exist(2);
    get_oi0(3,rounds);       /* drop rounds parameter, it might decrease security */
    if (rounds==0) rounds=7;  /* maximum slots */
    Lcryptall(ARGR, ARG1, ARG2,rounds,1); // mode =1  decode
}
// -------------------------------------------------------------------------------------
// Encrypt/Decrypt common Procedure
// -------------------------------------------------------------------------------------
void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode) {
    int plen, slen, ki,kj, hashv;
    Lstr pwt;
    L2STR(from);                 // make sure FROM is string
    L2STR(pw);                   // same for password
    slen = LLEN(*from);       // don't use STRLEN, as string may contain '0'x
    if (slen < 1) {              // is string empty? then return null string
        LZEROSTR(*to);
        return;
    }
    // set up temporary result
    Lfx(to, slen);
    Lstrcpy(to, from);
    // init Password definition
    plen = LLEN(*pw);
    if (plen == 0) return;   // no password given, string remains unchanged

    LINITSTR(pwt);
    Lfx(&pwt, plen);

    Lhash(&pwt, pw, 127);
    hashv = LINT(pwt);

    if (mode == 0) {  // encode
     // run through encryption in several rounds
        for (ki = 1; ki <= rounds; ki++) {    // Step 1: XOR String with Password
            for (kj = 0; kj < slen; kj++) {
                LSTR(*to)[kj] = LSTR(*to)[kj] + hashv;
            }
            hashv=(hashv+3)%127;
            _rotate(&pwt, pw, ki, 0);
            slen = _EncryptString(to, to, &pwt);
        }
    } else {    // decode
        hashv=(hashv+3*rounds-3)%127;
        for (ki = rounds; ki >= 1; ki--) {    // Step 1: XOR String with Password
            _rotate(&pwt, pw, ki,0);
            slen = _EncryptString(to, to, &pwt);
            for (kj = 0; kj < slen; kj++) {
                LSTR(*to)[kj]=LSTR(*to)[kj]-hashv;
            }
            hashv=(hashv-3)%127;
        }
    }
    // final settings and cleanup
    LLEN(*to) = (size_t) slen;
    LTYPE(*to) = LSTRING_TY;
    LFREESTR(pwt)
}

// -------------------------------------------------------------------------------------
// Rotate String
// -------------------------------------------------------------------------------------
// Return string at a certain position til it's end and continued substring before starting position
void _rotate(PLstr to, PLstr from, int start, int frlen) {
    int slen,rlen, istart=start,flen=frlen;

    slen=LLEN(*from);
    if (slen<1) {                  // is string empty? then return null string
        LZEROSTR(*to);
        return;
    }
    istart=istart%slen;             // if start > string length (re-calculate offset)
    istart--;                       // make start to a offset
    istart=istart%slen;             // if start > string length (re-calculate offset)
    rlen = slen- istart;            // lenght of remaining string
    if (flen==0) flen=slen;
    if (LISNULL(*to)) LINITSTR(*to);
    Lfx(to,slen);
// 1. copy remaining string part
    MEMMOVE( LSTR(*to), LSTR(*from)+istart, (size_t)rlen);
// 2. attach remaining length with string starting from position 1
    if (flen>rlen) MEMMOVE( LSTR(*to)+rlen, LSTR(*from), (size_t)slen-rlen);
    LLEN(*to) = (size_t) flen;
    LTYPE(*to) = LSTRING_TY;
}
// -------------------------------------------------------------------------------------
// Rotate String (registered stub)
// -------------------------------------------------------------------------------------
void R_rotate(int func) {
    int start, slen;
    must_exist(1);
    must_exist(2);
    get_oi(2,start);
    get_oi0(3,slen);
    _rotate(ARGR,ARG1,start,slen);
}
// -------------------------------------------------------------------------------------
// RHASH function
// -------------------------------------------------------------------------------------
void Lhash(const PLstr to, const PLstr from, long slots) {
    int ki,value=0, pcn,pwr,islots=INT32_MAX;
    size_t	lhlen=0;

    if (slots==0) slots=islots; /* maximum slots */

    pcn   = 71;                    /* potentially different Chars   */
    pwr = 1;                       /* Power of ... */

    if (!LISNULL(*from)) {
        switch (LTYPE(*from)) {
            case LINTEGER_TY:
               lhlen = sizeof(long);
               break;
            case LREAL_TY:
               lhlen = sizeof(double);
               break;
            case LSTRING_TY:
               lhlen = LLEN(*from);
               break;
        }

        for (ki = 0; ki < lhlen; ki++) {
            value = (value + (LSTR(*from)[ki]) * pwr)%islots;
            pwr = ((pwr * pcn) % islots);
        }
    }
    value=labs(value%slots);
    Licpy(to,labs(value));
}
// -------------------------------------------------------------------------------------
// RHASH (registered stub)
// -------------------------------------------------------------------------------------
void R_rhash(int func) {
    int     slots=0;

    must_exist(1);
    get_oi0(2,slots);       /* is there a max slot given? */

    Lhash(ARGR,ARG1,slots);
}
// -------------------------------------------------------------------------------------
// Remove DSN
// -------------------------------------------------------------------------------------
void R_removedsn(int func)
{
    char sFileName[45];
    int remrc=-2, iErr=0;
    char* _style_old = _style;

    memset(sFileName,0,45);
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    get_s(1)
#ifndef __CROSS__
    Lupper(ARG1);
#endif
    get_s(1)
    _style = "//DSN:";
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
 // if no errors occurred so far, perform the remove
    if (iErr == 0) {
       remrc = remove(sFileName);
    }
    Licpy(ARGR,remrc);
    _style = _style_old;
}
// -------------------------------------------------------------------------------------
// Rename DSN-old,DSN-new
// -------------------------------------------------------------------------------------
void R_renamedsn(int func)
{
    char sFileNameOld[45];
    char sFileNameNew[45];
    char sFunctionCode[3];
    int remrc=-2, iErr=0;
    char* _style_old = _style;

    if (ARGN != 2) Lerror(ERR_INCORRECT_CALL,0);

    memset(sFileNameOld,0,45);
    memset(sFileNameNew,0,45);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)
#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif
    _style = "//DSN:";
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileNameOld);
    if (iErr == 0) {
        iErr = getDatasetName(environment, (const char *) LSTR(*ARG2), sFileNameNew);
        if (iErr != 0) remrc=-3;
    } else remrc=-2;
    if (iErr == 0) {   // if no errors occurred so far, perform the rename
        remrc = rename(sFileNameOld,sFileNameNew);
     } else Lerror(ERR_DATA_NOT_SPEC, 0);
    Licpy(ARGR,remrc);
    _style = _style_old;
}
// -------------------------------------------------------------------------------------
// DYNFREE  ddname
// -------------------------------------------------------------------------------------
void R_free(int func)
{
    int iErr=0;

    __dyn_t dyn_parms;

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    get_s(1)

    dyninit(&dyn_parms);
    dyn_parms.__ddname = (char *) LSTR(*ARG1);

    iErr = dynfree(&dyn_parms);

    Licpy(ARGR, iErr);
}
// -------------------------------------------------------------------------------------
// DYNALLOC ddname DSN SHR
// -------------------------------------------------------------------------------------
void R_allocate(int func) {
    int iErr = 0;
    char sFileName[45];
    char *_style_old = _style;

    __dyn_t dyn_parms;
    if (ARGN < 2 || ARGN > 3) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    if (ARGN = 3) LASCIIZ(*ARG3)
    get_s(1)
    get_s(2)

#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
    if (ARGN=3) Lupper(ARG3);
#endif
    _style = "//DSN:";    // Complete DSN if necessary
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG2), sFileName);
    if (iErr == 0) {
        dyninit(&dyn_parms);
        dyn_parms.__ddname = (char *) LSTR(*ARG1);
     // free DDNAME, just in case it's allocated
        iErr = dynfree(&dyn_parms);

        dyn_parms.__dsname = (char *) sFileName;
        if (ARGN = 3) dyn_parms.__member = (char *) LSTR(*ARG3);
        dyn_parms.__status = __DISP_SHR;

        iErr = dynalloc(&dyn_parms);
    }
    Licpy(ARGR,iErr);
    _style = _style_old;
}
#ifdef __DEBUG__
void R_magic(int func)
{
    void *pointer;
    long decAddr;
    int  count;
    char magicstr[64];

    char option='F';

    if (ARGN>1)
        Lerror(ERR_INCORRECT_CALL,0);
    if (exist(1)) {
        L2STR(ARG1);
        option = l2u[(byte)LSTR(*ARG1)[0]];
    }

    option = l2u[(byte)option];

    switch (option) {
        case 'F':
            pointer = mem_first();
            decAddr = (long) pointer;
            sprintf(magicstr,"%ld", decAddr);
            break;
        case 'L':
            pointer = mem_last();
            decAddr = (long) pointer;
            sprintf(magicstr,"%ld", decAddr);
            break;
        case 'C':
            count = mem_count();
            sprintf(magicstr,"%d", count);
            break;
        default:
            sprintf(magicstr,"%s", "ERROR");
    }

    Lscpy(ARGR,magicstr);
}

void R_dummy(int func)
{
    void *nextPtr = 0x00;

#ifdef __CROSS__

    BinTree tree = _proc[_rx_proc].scope[0];
    BinPrint(tree.parent, NULL);
    /*
    do {
        printf("FOO> %s\n", getNextVar(&nextPtr));
    }
    while (nextPtr != NULL);
     */
#endif

}
#endif

int RxMvsInitialize()
{
    RX_INIT_PARAMS_PTR init_parameter;
    RX_TSO_PARAMS_PTR  tso_parameter;
    RX_ENVIRONMENT_BLK_PTR env_block;

    void ** pEnvBlock;


    int      rc     = 0;

#ifdef __DEBUG__
    if (entry_R13 != 0) {
        printf("DBG> SA at %08X\n", (unsigned) entry_R13);
    }
#endif

#ifdef ___NEW___
        tso_parameter   = malloc(sizeof(RX_TSO_PARAMS));
        memset(tso_parameter,00, sizeof(RX_TSO_PARAMS));

        tso_parameter->cppladdr = (unsigned int*)cppl;
        strcpy(tso_parameter->ddin,  "STDIN   ");
        strcpy(tso_parameter->ddout, "STDOUT  ");

        rc = call_rxtso(tso_parameter);

#ifdef __DEBUG1__
        printf("DBG> RC(RXTSO)=%d\n",rc);
#endif
#endif

    init_parameter   = malloc(sizeof(RX_INIT_PARAMS));
    memset(init_parameter, 0, sizeof(RX_INIT_PARAMS));

    environment      = malloc(sizeof(RX_ENVIRONMENT_CTX));
    memset(environment, 0, sizeof(RX_ENVIRONMENT_CTX));

    init_parameter->rxctxadr = (unsigned *)environment;

    rc = call_rxinit(init_parameter);

    if ((environment->flags3 & _STDIN) == _STDIN) {
        reopen(_STDIN);
    }
    if ((environment->flags3 & _STDOUT) == _STDOUT) {
        reopen(_STDOUT);
    }
    if ((environment->flags3 & _STDERR) == _STDERR) {
        reopen(_STDERR);
    }

    free(init_parameter);

#ifdef __DEBUG__
    printf("DBG> ENVIRONMENT CONTEXT AT %08X\n", (unsigned)environment);
    DumpHex((unsigned char*)environment, sizeof(RX_ENVIRONMENT_CTX) - (64*4));
    printf("\n");
#endif

    env_block = malloc(sizeof(RX_ENVIRONMENT_BLK));
    memset((env_block), 0, sizeof(RX_ENVIRONMENT_BLK));
    memcpy(env_block->envblock_id, "ENVBLOCK", 8);
    memcpy(env_block->envblock_version, "0100", 4);
    env_block->envblock_length = 320;

    if (isTSO()) {
        setEnvBlock(env_block);
    }

    return rc;
}

int reopen(int fp) {

    int new_fp, rc = 0;
    char* _style_old = _style;

#ifdef JCC
    _style = "//DDN:";
    switch(fp) {
        case 0x01:
            if (stdin != NULL) {
              fclose(stdin);
            }

            new_fp = _open("STDIN", O_TEXT | O_RDONLY);
            rc = _dup2(new_fp, 0);
            _close(new_fp);

            stdin = fdopen(0,"rt");

            break;
        case 0X02:
            if (stdout != NULL) {
              fclose(stdout);
            }

            new_fp = _open("STDOUT", O_TEXT | O_WRONLY);
            rc = _dup2(new_fp, 1);
            _close(new_fp);

            stdout = fdopen(1,"at");

            break;
        case 0x04:
            if (stderr != NULL) {
              fclose(stderr);
            }

            new_fp = _open("STDERR", O_TEXT | O_WRONLY);
            rc = _dup2(new_fp, 2);
            _close(new_fp);

            stderr = fdopen(2, "at");

            break;
        default:
            rc = ERR_INITIALIZATION;
            break;
    }
#endif
    _style = _style_old;

    return 0;
}

void RxMvsRegFunctions()
{
    RxNetDataRegFunctions();

    /* MVS specific functions */
    RxRegFunction("ENCRYPT",    R_crypt,0);
    RxRegFunction("DECRYPT",    R_decrypt,0);
    RxRegFunction("FREE",       R_free, 0);
    RxRegFunction("ALLOCATE",   R_allocate,0);
    RxRegFunction("DUMPIT",     R_dumpIt,  0);
    RxRegFunction("LISTIT",     R_listIt,  0);
    RxRegFunction("WAIT",       R_wait,    0);
    RxRegFunction("WTO",        R_wto ,    0);
    RxRegFunction("ABEND",      R_abend ,  0);
    RxRegFunction("USERID",     R_userid,  0);
    RxRegFunction("LISTDSI",    R_listdsi, 0);
    RxRegFunction("ROTATE",     R_rotate,0);
    RxRegFunction("SYSDSN",     R_sysdsn,  0);
    RxRegFunction("SYSVAR",     R_sysvar,  0);
    RxRegFunction("VXGET",      R_vxget,   0);
    RxRegFunction("VXPUT",      R_vxput,   0);
    RxRegFunction("STEMCOPY",   R_stemcopy,0);
    RxRegFunction("REMOVE",     R_removedsn,0);
    RxRegFunction("RENAME",     R_renamedsn,0);
#ifndef WIN32
    RxRegFunction("TCPOPEN",    R_tcpopen, 0);
    RxRegFunction("TCPRECEIVE", R_tcprecv,0);
    RxRegFunction("TCPSEND",    R_tcpsend,0);
#endif
    RxRegFunction("RHASH",      R_rhash,0);
#ifdef __DEBUG__
    RxRegFunction("MAGIC",  R_magic, 0);
    RxRegFunction("DUMMY",  R_dummy, 0);
#endif
}

int isTSO() {
    int ret = 0;

    if ((environment->flags2 & _TSOFG) == _TSOFG ||
        (environment->flags2 & _TSOBG) == _TSOBG) {
        ret = 1;
    }

    return ret;
}

int isISPF() {
    int ret = 0;

    if ((environment->flags2 & _ISPF) == _ISPF) {
        ret = 1;
    }

    return ret;
}

void parseArgs(char **array, char *str)
{
    int i = 0;
    char *p = strtok (str, " ");
    while (p != NULL)
    {
        array[i++] = p;
        p = strtok (NULL, " ");
    }
}

void parseDCB(FILE *pFile)
{
    unsigned char *flags;
    unsigned char  sDsn[45];
    unsigned char  sDdn[9];
    unsigned char  sMember[9];
    unsigned char  sSerial[7];
    unsigned char  sLrecl[6];
    unsigned char  sBlkSize[6];

    flags = malloc(11);
    __get_ddndsnmemb(fileno(pFile), (char *)sDdn, (char *)sDsn, (char *)sMember, (char *)sSerial, flags);

    /* DSN */
    if (sDsn[0] != '\0')
        setVariable("SYSDSNAME", (char *)sDsn);

    /* DDN */
    if (sDdn[0] != '\0')
        setVariable("SYSDDNAME", (char *)sDdn);

    /* MEMBER */
    if (sMember[0] != '\0')
        setVariable("SYSMEMBER", (char *)sMember);

    /* VOLSER */
    if (sSerial[0] != '\0')
        setVariable("SYSVOLUME", (char *)sSerial);

    /* DSORG */
    if(flags[4] == 0x40)
        setVariable("SYSDSORG", "PS");
    else if (flags[4] == 0x02)
        setVariable("SYSDSORG", "PO");
    else
        setVariable("SYSDSORG", "???");

    /* RECFM */
    if(flags[6] == 0x40)
        setVariable("SYSRECFM", "V");
    else if(flags[6] == 0x50)
        setVariable("SYSRECFM", "VB");
    else if(flags[6] == 0x54)
        setVariable("SYSRECFM", "VBA");
    else if(flags[6] == 0x80)
        setVariable("SYSRECFM", "F");
    else if(flags[6] == 0x90)
        setVariable("SYSRECFM", "FB");
    else if(flags[6] == 0xC0)
        setVariable("SYSRECFM", "U");
    else
        setVariable("SYSRECFM", "??????");

    /* BLKSIZE */
    sprintf((char *)sBlkSize, "%d", flags[8] | flags[7] << 8);
    setVariable("SYSBLKSIZE", (char *)sBlkSize);

    /* LRECL */
    sprintf((char *)sLrecl, "%d", flags[10] | flags[9] << 8);
    setVariable("SYSLRECL", (char *)sLrecl);

    free(flags);
}

void *
_getEctEnvBk()
{
    void ** psa;           // PAS      =>   0 / 0x00
    void ** ascb;          // PSAAOLD  => 548 / 0x224
    void ** asxb;          // ASCBASXB => 108 / 0x6C
    void ** lwa;           // ASXBLWA  =>  20 / 0x14
    void ** ect;           // LWAPECT  =>  32 / 0x20
    void ** ectenvbk;      // ECTENVBK =>  48 / 0x30

    if (isTSO()) {
        psa  = 0;
        ascb = psa[137];
        asxb = ascb[27];
        lwa  = asxb[5];
        ect  = lwa[8];

        ectenvbk = ect + 48;

    } else {
        ectenvbk = NULL;
    }

    return ectenvbk;
}

void *
getEnvBlock()
{
    void **ectenvbk;
    void  *envblock;

    ectenvbk = _getEctEnvBk();

    if (ectenvbk != NULL) {
        envblock = *ectenvbk;
    } else {
        envblock = NULL;
    }

    return envblock;
}

void
setEnvBlock(void *envblk)
{
    void ** ectenvbk;

    ectenvbk  = _getEctEnvBk();

    if (ectenvbk != NULL) {
        *ectenvbk = envblk;
    }
}

void
getVariable(char *sName, PLstr plsValue)
{
    Lstr lsScope,lsName;

    LINITSTR(lsScope)
    LINITSTR(lsName)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);

    RxPoolGet(&lsScope, &lsName, plsValue);

    LASCIIZ(*plsValue)

    LFREESTR(lsScope)
    LFREESTR(lsName)
}

char *
getStemVariable(char *sName)
{
    char  sValue[4097];
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);

    RxPoolGet(&lsScope, &lsName, &lsValue);

    LASCIIZ(lsValue)

    if(LTYPE(lsValue)==1) {
        sprintf(sValue,"%d",LINT(lsValue));
    }
    if(LTYPE(lsValue)==2) {
        sprintf(sValue,"%f",LREAL(lsValue));
    }
    if(LTYPE(lsValue)==0) {
        memset(sValue,0,sizeof(sValue));
        strncpy(sValue,LSTR(lsValue),LLEN(lsValue));
    }

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)

    return (char *)sValue[0];
}

int
getIntegerVariable(char *sName) {
    char sValue[19];
    PLstr plsValue;
    LPMALLOC(plsValue)
    getVariable(sName, plsValue);

    if(LTYPE(*plsValue)==1) {
        sprintf(sValue,"%d",(int)LINT(*plsValue));
    } else if (LTYPE(*plsValue)==0) {
        memset(sValue,0,sizeof(sValue));
        strncpy(sValue,(const char*)LSTR(*plsValue),LLEN(*plsValue));
    } else {
        sprintf(sValue,"%d",0);
    }

    return (atoi(sValue));
}

void
setVariable(char *sName, char *sValue)
{
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));
    Lfx(&lsValue, strlen(sValue));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);
    Lscpy(&lsValue, sValue);

    RxPoolSet(&lsScope, &lsName, &lsValue);

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)
}

void
setVariable2(char *sName, char *sValue, int lValue)
{
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));
    Lfx(&lsValue, lValue);

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);
    Lscpy2(&lsValue, sValue, lValue);

    RxPoolSet(&lsScope, &lsName, &lsValue);

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)
}

void
setIntegerVariable(char *sName, int iValue)
{
    char sValue[19];

    sprintf(sValue,"%d",iValue);
    setVariable(sName,sValue);
}

int
GetClistVar(PLstr name, PLstr value)
{
    int rc = 0;
    void *wk;

    RX_IKJCT441_PARAMS_PTR params;

    /* do not handle special vars here */
    if (checkVariableBlacklist(name) != 0)
        return -1;

    /* NAME LENGTH < 1 OR > 252 */
    if (checkNameLength(name->len) != 0)
        return -2;

    params = malloc(sizeof(RX_IKJCT441_PARAMS));
    wk     = malloc(256);

    memset(wk,     0, sizeof(wk));
    memset(params, 0, sizeof(RX_IKJCT441_PARAMS));

    params->ecode    = 18;
    params->nameadr  = (char *)name->pstr;
    params->namelen  = name->len;
    params->valueadr = 0;
    params->valuelen = 0;
    params->wkadr    = wk;

    rc = call_rxikj441 (params);

    if (value->maxlen < params->valuelen) {
        Lfx(value,params->valuelen);
    }
    if (value->pstr != params->valueadr) {
        strncpy((char *)value->pstr,params->valueadr,params->valuelen);
    }

    value->len    = params->valuelen;
    value->maxlen = params->valuelen;
    value->type   = LSTRING_TY;

    free(wk);
    free(params);

    return rc;
}

int
SetClistVar(PLstr name, PLstr value)
{
    int rc = 0;
    void *wk;

    RX_IKJCT441_PARAMS_PTR params;

    /* convert numeric values to a string */
    if (value->type != LSTRING_TY) {
        L2str(value);
    }

    /* terminate all strings with a binary zero */
    LASCIIZ(*name);
    LASCIIZ(*value);

    /* do not handle special vars here */
    if (checkVariableBlacklist(name) != 0)
        return -1;

    /* NAME LENGTH < 1 OR > 252 */
    if (checkNameLength(name->len) != 0)
        return -2;

    /* VALUE LENGTH < 0 OR > 32767 */
    if (checkValueLength(value->len) != 0)
        return -3;

    params = malloc(sizeof(RX_IKJCT441_PARAMS));
    wk     = malloc(256);

    memset(wk,     0, sizeof(wk));
    memset(params, 0, sizeof(RX_IKJCT441_PARAMS)),

            params->ecode    = 2;
    params->nameadr  = (char *)name->pstr;
    params->namelen  = name->len;
    params->valueadr = (char *)value->pstr;
    params->valuelen = value->len;
    params->wkadr    = wk;

    rc = call_rxikj441(params);

    free(wk);
    free(params);

    return rc;
}

//----------------------------------------
// BLDL/FIND
//----------------------------------------
int findLoadModule(char *moduleName)
{
    int iRet = 0;
    char sTemp[8];
    char *sToken;

    RX_BLDL_PARAMS bldlParams;
    RX_SVC_PARAMS svcParams;

    memset(&bldlParams, 0, sizeof(RX_BLDL_PARAMS));
    memset(&bldlParams.BLDLN, ' ', 8);

    strncpy(sTemp, moduleName, 8);

    sToken = strtok(sTemp, " ");
    strncpy(bldlParams.BLDLN, sToken, strlen(sToken));

    bldlParams.BLDLF = 1;
    bldlParams.BLDLL = 50;

    svcParams.SVC = 18;
    svcParams.R0  = (unsigned)&bldlParams;
    svcParams.R1  = 0;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        iRet = 1;
    }

    return iRet;
}

/* internal functions */
int checkNameLength(long lName)
{
    int rc = 0;
    if (lName < 1)
        rc = -1;
    if (lName > 252)
        rc =  1;

    return rc;
}

int checkValueLength(long lValue)
{
    int rc = 0;

    if (lValue == 0)
        rc = -1;
    if (lValue > 32767)
        rc =  1;

    return rc;
}

int checkVariableBlacklist(PLstr name)
{
    int rc = 0;
    int i  = 0;

    Lupper(name);

    for (i = 0; i < BLACKLIST_SIZE; ++i) {
        if (strcmp((char *)name->pstr,RX_VAR_BLACKLIST[i]) == 0)
            return -1;
    }

    return rc;
}

/* dummy implementations for cross development */
#ifdef __CROSS__
int call_rxinit(RX_INIT_PARAMS_PTR params)
{
    int rc = 0;

    RX_ENVIRONMENT_CTX_PTR env;

#ifdef __DEBUG__
    printf("DBG> DUMMY RXINIT ...\n");
#endif

    if (params != NULL) {
        if (params->rxctxadr != NULL) {
            env = (RX_ENVIRONMENT_CTX_PTR)params->rxctxadr;
            env->flags1 = 0x0F;
            env->flags2 = 0x00;
            env->flags3 = 0x00;

            strncpy(env->SYSENV,  "DEVEL",   5);
            strncpy(env->SYSPREF, "MIG",     3);
            strncpy(env->SYSUID,  "FIX0MIG", 7);

        } else {
            rc = -42;
        }
    } else {
        rc = -43;
    }
    return rc;
}

unsigned int call_rxikj441 (RX_IKJCT441_PARAMS_PTR params)
{
    printf("DBG> DUMMY RXIKJ441 ...\n");

    return 0;
}

int call_rxtso(RX_TSO_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXTSO ...\n");

#endif
    return 0;
}

void call_rxsvc (RX_SVC_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL) {
        printf("DBG> DUMMY RXSVC for svc %d .\n", params->SVC);
        if(params->SVC == 93) {
            if((params->R1 & 0x81000000) == 0x81000000) {
                printf("DBG> TGET ASIS\n");
                printf("DBG> PRESS ENTER KEY\n");
                getchar();

                params->R1 = 42;
            } else if ((params->R1 & 0x03000000) == 0x03000000) {
                printf("DBG> TPUT FSS\n");
            }
        } else if (params->SVC == 94) {
            RX_GTTERM_PARAMS_PTR paramsPtr = params->R1;
            memcpy((void *)*paramsPtr->primadr,0x1850,2);
        } else if (params->SVC == 18) {
            RX_GTTERM_PARAMS_PTR paramsPtr = params->R1;
            params->R15 = 4;
        }
    }
        printf("DBG> DUMMY RXSVC for svc %d .\n", params->SVC);
#endif
}

int call_rxvsam (RX_VSAM_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL) {
        printf("\n");
        printf("DBG> DUMMY RXVSAM ...\n");
        printf("DBG>  VSAMFUNC : %s\n",params->VSAMFUNC);
        printf("DBG>  VSAMTYPE : %c\n",params->VSAMTYPE);
        printf("DBG>  VSAMDDN  : %s\n",params->VSAMDDN);
        printf("DBG>  VSAMKEY  : %s\n",params->VSAMKEY);
        printf("DBG>  VSAMKEYL : %d\n",params->VSAMKEYL);

        if (strcasecmp(params->VSAMFUNC, "READK") == 0) {
            char * record = MALLOC(13, "CROSS VSAM READK");
            memset(record,0,13);
            strcpy(record,"123456789ABC");
            params->VSAMREC = (void *)record;
            params->VSAMRECL=12;
        }

        if (strcasecmp(params->VSAMFUNC, "READN") == 0) {
            char * record = MALLOC(13,"CROSS VSAM READN");

            strcpy(record,"ABC123456789");
            params->VSAMREC = (void *)record;
            params->VSAMRECL=12;
        }

        if (strcasecmp(params->VSAMFUNC, "WRITE") == 0) {
            printf("DBG>  VSAMREC  : %s\n",params->VSAMREC);
        }
    }

#endif
    return 0;
}

int call_rxptime (RX_PTIME_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXPTIME ...\n");

#endif
    return 0;
}

int call_rxstime (RX_STIME_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXSTIME ...\n");
#endif
    return 0;
}

int call_rxwto (RX_WTO_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXWTO tell %s\n", params->msgadr);
#endif
    return 0;
}

int call_rxwait (RX_WAIT_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXWAIT for %d seconds.\n", (*params->timeadr)/100);
#endif
    return 0;
}

unsigned int call_rxabend (RX_ABEND_PARAMS_PTR params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXABEND with ucc %d\n", params->ucc);
#endif
    return 0;
}

int call_rxdynalc (RX_DYNALC_PARAMS_PTR  params)
{
#ifdef __DEBUG__
    if (params != NULL)
        printf("DBG> DUMMY RXDYNALC ...\n");
#endif
    return 0;
}

#endif
