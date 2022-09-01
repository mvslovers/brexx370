#include <string.h>
#include "bmem.h"
#include "lstring.h"
#include "lerror.h"
#include "stack.h"
#include "rxmvsext.h"
#include "hostenv.h"
#include "util.h"

#ifdef __CROSS__
# include "jccdummy.h"
#else
extern Lstr	errmsg;
extern char* _style;
#endif

#define STEM 1
#define FIFO 2
#define LIFO 3

extern RX_ENVIRONMENT_CTX_PTR environment;

void rxqueue(char *s, int mode);
void remlf(char *s);

#define substr(tostr,fromstr,from,len) \
  { Lsubstr(tostr,fromstr,from,len,' '); \
    LSTR(*tostr)[LLEN(*tostr)]=0x0;  }

#define filter(record) \
{if (filter > 0) { \
   if (filter == 1 && strstr((char *) record,drop) != NULL) continue;  \
   if (filter == 2 && strstr((char *) record,keep) == NULL) continue;}  \
}
#define dsopen(filename,mode) \
  {Lword(filename,incmd,4);   \
   ftoken=__open_file( filename,mode); \
   if (ftoken == NULL) goto openerror; \
}

void
setStem(char *sName, int stemint, char *sValue) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemint);  // edited stem name
    setVariable(vname, sValue);              // set rexx variable
}
void
setStem0(char *sName, int stemhi) {
    char vname[128];
    char vint[32];
    memset(vname, 0, sizeof(vname));
    memset(vint,  0, sizeof(vint));
    sprintf(vint,   "%d", stemhi);
    sprintf(vname, "%s0", sName);    // edited stem name
    setVariable(vname, vint);        // set hi value
}
void
getStem(PLstr plsPtr, char *sName,int stemindx) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemindx);
    getVariable(vname, plsPtr);
}

int
getStem0(char *sName)  {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s0", sName);
    return getIntegerVariable(vname);
}

/* -------------------------* open_file *------------------------- */
FILE* __open_file( const PLstr fn, const char *mode)
{
    int	i,pdsmode;
    Lstr	str;
    FILE   *fp=NULL;
    QuotationType quotationType;

    char* _style_old = _style;

    quotationType = CheckQuotation((char *)fn->pstr);
    switch (quotationType) {
        // supplied ddname or dsn is unquoted, could be both ddn or dsn
        case UNQUOTED:
            _style = "//DDN:";    // 1. try to open as DDN
            if (LLEN(*fn)<=8) if ((fp=FOPEN((char*)LSTR(*fn),mode))!=NULL) goto isopen;

            if (environment->SYSPREF[0] != '\0') {
                LINITSTR(str)
                Lcat(&str, environment->SYSPREF);
                Lcat(&str, ".");
                Lcat(&str, (char *)fn->pstr);
                LASCIIZ(str)
                _style = "//DSN:";    // 2. try to open as userid.DSN
                if ((fp=FOPEN((char*)LSTR(str),mode))==NULL) {
                    LFREESTR(str)
                    pdsmode=1;
                    goto tryOpenDDN;  // if open fails, no more options, go to open failed
                }
            } else {    // userid prefix (TSO) is no active, must be a DDname as 1. option already failed
                _style = "//DSN:";    // 3. try to open as DSN
                if ((fp=FOPEN((char*)LSTR(*fn),mode))!=NULL) goto isopen;
                pdsmode=2;            // else 4. try to open as DDN
                goto tryOpenDDN;
            }
            break;
        // supplied name is quoted, must be a dsn
        case FULL_QUOTED:
            LINITSTR(str)
            Lfx(&str,LLEN(*fn)-2);
            memcpy(str.pstr, (fn->pstr) + 1, fn->len - 2);
            str.len = fn->len - 2;
            LASCIIZ(str)
            _style = "//DSN:";
            if ((fp=FOPEN((char*)LSTR(str),mode))==NULL) goto notopen;
            break;
        // unknown or incomplete name
        default:
            Lerror(ERR_DATA_NOT_SPEC, 0);
    }
// file is open or not open, cleanup and return file handle or NULL
 isopen:
 notopen:
   LFREESTR(str);
   _style = _style_old;
return fp;

// Try to open with ddname, the supplied name is a dd (dd must not contain pds member notation!)
 tryOpenDDN:
    LINITSTR(str)
    Lfx(&str,LLEN(*fn));
    Lcat(&str, (char *)fn->pstr);
    if (LLEN(str)<1 || LLEN(str)>8) goto notopen;
    LASCIIZ(str)
    if ((strchr((const char *)LSTR(str), '.') == 0) &&
        (strchr((const char *)LSTR(str), '(') == 0) &&
        (strchr((const char *)LSTR(str), ')') == 0)) {
        _style = "//DDN:";
        if ((fp=FOPEN((char*)LSTR(str),mode))!=NULL) goto isopen;
        goto notopen;
    } else {
      if (pdsmode==1) goto notopen;
      else Lerror(ERR_ILLEGAL_DDN, 0, fn);
    }
} /* open_file */


int RxEXECIO(char **tokens,PLstr incmd) {
    int ip1,ii;
    int filter=0, tokenhi = 0;
    int recs = 0, rrecs=0, wrecs=0, maxrecs=0;
    int skip=0, subfrom=0,sublen=0, startAT=0;
    int mode=FIFO;
    int findx=0;

    FILE *ftoken=NULL;
    PLstr plsValue,filename;

    char pbuff[4098], obuff[4098];
    char vname1[32];
    char keep[32], drop[32];
/* --------------------------------------------------------------------------------------------
 * INIT EXECIO
 * --------------------------------------------------------------------------------------------
 */
    LPMALLOC(plsValue)
    LPMALLOC(filename)
    while (tokens[tokenhi] != NULL) tokenhi++;     // find number of tokens
    tokenhi--;

    if (strcasecmp(tokens[1],"*") != 0) {          // process a certain number of records
        maxrecs = atoi(&*tokens[1]);
        if (maxrecs==0) goto notnumeric;
    }
    ip1=findToken("DROP", tokens) ;           // drop those records with a certain string
    if (ip1>0) {
        filter=1;
        if (ip1+1>tokenhi) goto incomplete;
        strcpy(drop, tokens[ip1+1]);
    }
    ip1=findToken("KEEP", tokens) ;           // keep only those records with a certain string
    if (ip1>0) {
        filter=2;
        if (ip1+1>tokenhi) goto incomplete;
        strcpy(keep, tokens[ip1+1]);
    }
    ip1=findToken("SKIP", tokens) ;           // skip n records before processing
    if (ip1>0) {
        if (ip1+1>tokenhi) goto incomplete;
        skip = atoi(&*tokens[ip1+1]);
        if (skip==0) goto notnumeric;
    }
    ip1=findToken("START", tokens) ;          // start at a certain stem entry
    if (ip1>0) {
        if (ip1+1>tokenhi) goto incomplete;
        startAT = atoi(&*tokens[ip1 + 1]);
        if (startAT <= 0) goto notnumeric;
        startAT--;
    }
    ip1=findToken("SUBSTR", tokens) ;         // create substring of record
    if (ip1>0) {
        if (ip1+2>tokenhi) goto incomplete;
        subfrom = atoi(&*tokens[ip1+1]);
        sublen = atoi(&*tokens[ip1+2]);
        if (subfrom==0 || sublen==0 ) goto suberror;
    }
/* --------------------------------------------------------------------------------------------
 * Now Choose what to do
 *   Long live modular programming!
 * --------------------------------------------------------------------------------------------
 */
    if (tokenhi<2) goto incomplete;
    if (strcasecmp(tokens[2], "DISKR")      == 0)  goto DISKR;
    else if (strcasecmp(tokens[2], "DISKW") == 0)  goto DISKW;
    else if (strcasecmp(tokens[2], "DISKA") == 0)  goto DISKA;
    else if (strcasecmp(tokens[2], "FIFOR") == 0)  goto FIFOR;
    else if (strcasecmp(tokens[2], "LIFOR") == 0)  goto FIFOR;
    else if (strcasecmp(tokens[2], "LIFOR") == 0)  goto FIFOR;
    else if (strcasecmp(tokens[2], "FIFOW") == 0)  goto FIFOW;
    else if (strcasecmp(tokens[2], "LIFOW") == 0)  goto FIFOW;
    else goto invalidact;
/* --------------------------------------------------------------------------------------------
 * DISKR
 * --------------------------------------------------------------------------------------------
 */
DISKR:
    ip1 = findToken("STEM", tokens);
    if (ip1 >= 1) {
        mode = STEM;
        strcpy(vname1, tokens[ip1 + 1]);         // name of stem variable
    } else if (findToken("FIFO", tokens) >= 0) mode = FIFO;
      else if (findToken("LIFO", tokens) >= 0) mode = LIFO;
// open file
    if (tokenhi<3) goto incomplete;
    dsopen(filename,"r");     // returns file handle in ftoken
    recs = 0;
    while (fgets(pbuff, 4096, ftoken)) {
        recs++;
        if (recs <= skip) continue;
        if (maxrecs > 0 && rrecs >= maxrecs) break;

        filter(pbuff);   // Filter via KEEP and DROP parms

        rrecs++;
        remlf(&pbuff[0]); // remove linefeed
        if (subfrom>0)  {
            Lscpy(plsValue,pbuff);
            substr(plsValue,plsValue,subfrom, sublen);
            strcpy(pbuff,(char *) LSTR(*plsValue));
        }

        switch (mode) {
            case STEM :
                setStem(vname1,rrecs+startAT,pbuff) ;
                break;
            case LIFO :
                rxqueue(pbuff, LIFO);
                break;
            case FIFO :
            default:
                rxqueue(pbuff, FIFO);
                break;
        }   // end of switch
    }  // end of while
    if (mode == STEM) setStem0(vname1,rrecs+startAT);
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * DISKW
 * --------------------------------------------------------------------------------------------
 */
 DISKW:
    if (tokenhi<3) goto incomplete;
//    ftoken = fopen(tokens[3], "w");
    dsopen(filename,"w");     // returns file handle in ftoken
    goto WriteAll;
 /* --------------------------------------------------------------------------------------------
 * DISKA
 * --------------------------------------------------------------------------------------------
 */
 DISKA:
    if (tokenhi<3) goto incomplete;
//    ftoken = fopen(tokens[3], "a");
    dsopen(filename,"a");     // returns file handle in ftoken
    goto WriteAll  ;
/* --------------------------------------------------------------------------------------------
 * Write Records for DISKW and DISKA
 * --------------------------------------------------------------------------------------------
 */
 WriteAll:
    if (ftoken == NULL) goto openerror;
    ip1 = findToken("STEM", tokens);
    if (ip1 >= 1) {
        if (ip1+1>tokenhi) goto incomplete;
        recs = getStem0(tokens[ip1+1]);
    } else if (ip1 == -1) {              // get queue entries
        recs = StackQueued();
        if (recs==0) goto emptyStack;
    }
    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs >= maxrecs) break;

        if (ip1 != -1) getStem(plsValue, tokens[ip1+1], ii);
        else {
            LPFREE(plsValue);
            plsValue=PullFromStack();
        }

        filter(LSTR(*plsValue));   // Filter via KEEP and DROP parms
        if (subfrom>0)  substr(plsValue,plsValue,subfrom,sublen);

        wrecs++;
        sprintf(obuff, "%s\n", LSTR(*plsValue));
        fputs(obuff, ftoken);
    }
    goto exit0;
 /* --------------------------------------------------------------------------------------------
 * LIFOR  Read from Stack to STEM
 * --------------------------------------------------------------------------------------------
 */
  FIFOR:
    ip1 = findToken("STEM", tokens);
    if (ip1 <= 1) goto noStem;
    if (ip1+1>tokenhi) goto incomplete;
    strcpy(vname1, tokens[ip1 + 1]);  // name of stem variable
    recs =  StackQueued();

    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs > maxrecs) break;
        LPFREE(plsValue);
        plsValue=PullFromStack();

        filter(LSTR(*plsValue));   // Filter via KEEP and DROP parms       filter()   // Filter via KEEP and DROP parms
        if (subfrom>0) substr(plsValue,plsValue,subfrom, sublen);

        wrecs++;
        setStem(vname1,wrecs,(char *) LSTR(*plsValue)) ;
    }
    setStem0(vname1, wrecs);
    goto exit0;
 /* --------------------------------------------------------------------------------------------
 * FIFOW Push STEM to FIFO/LIFO stack
 * --------------------------------------------------------------------------------------------
 */
  FIFOW:
    ip1 = findToken("STEM", tokens);
    if (ip1 <= 1) goto noStem;
    if (strcasecmp(tokens[2], "LIFOW")==0) mode=LIFO;
       else mode=FIFO;
    if (ip1+1>tokenhi) goto incomplete;

    recs = getStem0(vname1);

    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs >= maxrecs) break;
        LPFREE(plsValue);
        getStem(plsValue,vname1,ii);

        filter(LSTR(*plsValue));   // Filter via KEEP and DROP parms
        if (subfrom>0) substr(plsValue,plsValue,subfrom, sublen);

        wrecs++;
        rxqueue((char *) LSTR(*plsValue), mode);
    }
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * Return Handling
 * --------------------------------------------------------------------------------------------
 */
  exit0:
    if (ftoken!=NULL) fclose(ftoken);
    LPFREE(plsValue)
    return 0;

  invalidact:
    printf("EXECIO invalid action parameter %s \n",tokens[2]);
    goto exit8;
  noStem:
    printf("EXECIO STEM parameter missing\n");
    goto exit8;
  suberror:
    printf("EXECIO SUBSTR parameter invalid or missing\n");
    goto exit8;
  notnumeric:
    printf("EXECIO SKIP or number record parameter not numeric\n");
    goto exit8;
  incomplete:
    printf("EXECIO incomplete parameter list\n");
    goto exit8;
  openerror:
    printf("EXECIO cannot open %s\n",LSTR(*filename));
    goto exit8;
  emptyStack:
    printf("EXECIO DISKW stack is empty, nothing to store \n");
    goto exit8;

exit8:
    LPFREE(plsValue)
    LPFREE(filename)
    return 8;
}

void
rxqueue(char *s,int mode) {
    PLstr pstr;
    LPMALLOC(pstr)

    Lscpy(pstr, s);

    if (mode==FIFO) Queue2Stack(pstr);
    else Push2Stack(pstr);
}

void
remlf(char *s) {
    char *pos;
    if ((pos = strchr(s, '\n')) != NULL) *pos = '\0';
}