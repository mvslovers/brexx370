#include <string.h>
#include <strings.h>
#include "bmem.h"
#include "lstring.h"
#include "lerror.h"
#include "stack.h"
#include "rxmvsext.h"
#include "dsio.h"
#include "hostenv.h"
#include "util.h"

#ifdef __CROSS__
# include "jccdummy.h"
#else
extern Lstr	errmsg;
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

#define EXECIO_MAX_VNAME 250   // longest REXX symbol
#define EXECIO_STEMIDX   11    // room for a stem index and its sign

// copy a command token into a fixed buffer; one that does not fit is
// refused (a cut variable name or filter string means something else)
#define copyToken(target, token) \
  { if ((token) == NULL || strlen(token) >= sizeof(target)) goto toolong; \
    strcpy(target, token); }

void
setStem(char *sName, int stemint, char *sValue) {
    char vname[EXECIO_MAX_VNAME + EXECIO_STEMIDX + 1];
    memset(vname, 0, sizeof(vname));
    snprintf(vname, sizeof(vname), "%s%d", sName, stemint);  // edited stem name
    setVariable(vname, sValue);              // set rexx variable
}
void
setStem0(char *sName, int stemhi) {
    char vname[EXECIO_MAX_VNAME + EXECIO_STEMIDX + 1];
    char vint[32];
    memset(vname, 0, sizeof(vname));
    memset(vint,  0, sizeof(vint));
    snprintf(vint, sizeof(vint), "%d", stemhi);
    snprintf(vname, sizeof(vname), "%s0", sName);    // edited stem name
    setVariable(vname, vint);        // set hi value
}
void
getStem(PLstr plsPtr, char *sName,int stemindx) {
    char vname[EXECIO_MAX_VNAME + EXECIO_STEMIDX + 1];
    memset(vname, 0, sizeof(vname));
    snprintf(vname, sizeof(vname), "%s%d", sName, stemindx);
    getVariable(vname, plsPtr);
}

int
getStem0(char *sName)  {
    char vname[EXECIO_MAX_VNAME + EXECIO_STEMIDX + 1];
    memset(vname, 0, sizeof(vname));
    snprintf(vname, sizeof(vname), "%s0", sName);
    return getIntegerVariable(vname);
}

/* -------------------------* open_file *------------------------- */
/* An unquoted name is tried as a DD name first, then as a data set
 * name; a quoted one is a data set name. The data set name comes from
 * getDatasetName(), with the prefix if there is one (#299). */
FILE* __open_file( const PLstr fn, const char *mode)
{
    char  dsn[DSN_NAME_MAX + 1];
    FILE *fp = NULL;
    const char *name = (const char *) fn->pstr;

    switch (CheckQuotation(name)) {
        case UNQUOTED:
            if (LLEN(*fn) > 0 && LLEN(*fn) <= 8)
                fp = rxOpenDd(name, mode);
            if (fp == NULL && getDatasetName(environment, name, dsn) == 0)
                fp = rxOpenDsn(dsn, mode);
            break;
        case FULL_QUOTED:
            if (getDatasetName(environment, name, dsn) == 0)
                fp = rxOpenDsn(dsn, mode);
            break;
        default:                    /* partially quoted */
            Lerror(ERR_DATA_NOT_SPEC, 0);
    }
    return fp;
} /* open_file */


int RxEXECIO(char **tokens,PLstr incmd) {
    int ip1,ii;
    int filter=0, tokenhi = 0;
    int recs = 0, rrecs=0, wrecs=0, maxrecs=0;
    int skip=0, subfrom=0,sublen=0, startAT=0;
    int mode=FIFO;

    FILE *ftoken=NULL;
    int rc;
    bool writeFailed;
    PLstr plsValue,filename;

    char pbuff[4098];
    char *record;
    char vname1[EXECIO_MAX_VNAME + 1];
    char keep[EXECIO_MAX_VNAME + 1], drop[EXECIO_MAX_VNAME + 1];
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
        copyToken(drop, tokens[ip1+1]);
    }
    ip1=findToken("KEEP", tokens) ;           // keep only those records with a certain string
    if (ip1>0) {
        filter=2;
        if (ip1+1>tokenhi) goto incomplete;
        copyToken(keep, tokens[ip1+1]);
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
        copyToken(vname1, tokens[ip1 + 1]);      // name of stem variable
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
        record = pbuff;
        if (subfrom>0)  {
            // SUBSTR pads to its length, which can exceed pbuff
            Lscpy(plsValue,pbuff);
            substr(plsValue,plsValue,subfrom, sublen);
            record = (char *) LSTR(*plsValue);
        }

        switch (mode) {
            case STEM :
                setStem(vname1,rrecs+startAT,record) ;
                break;
            case LIFO :
                rxqueue(record, LIFO);
                break;
            case FIFO :
            default:
                rxqueue(record, FIFO);
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
    writeFailed = FALSE;
    ii = skip;
    /* ii is advanced first: filter() leaves a record out with continue */
    while (!writeFailed && ii < recs && (maxrecs <= 0 || wrecs < maxrecs)) {
        ii++;
        if (ip1 != -1) getStem(plsValue, tokens[ip1+1], ii);
        else {
            LPFREE(plsValue);
            plsValue=PullFromStack();
        }

        filter(LSTR(*plsValue));   // Filter via KEEP and DROP parms
        if (subfrom>0)  substr(plsValue,plsValue,subfrom,sublen);

        wrecs++;
        /* a failed write ends the action with RC 20 (#178) */
        if (fputs((char *) LSTR(*plsValue), ftoken) == EOF ||   // any length, no copy
            fputc('\n', ftoken) == EOF) {
            writeFailed = TRUE;
        }
    }
    /* fclose() writes the last block: its error is a write error too */
    rc = fclose(ftoken);
    ftoken = NULL;
    if (writeFailed || rc != 0) goto writeerror;
    goto exit0;
 /* --------------------------------------------------------------------------------------------
 * LIFOR  Read from Stack to STEM
 * --------------------------------------------------------------------------------------------
 */
  FIFOR:
    ip1 = findToken("STEM", tokens);
    if (ip1 <= 1) goto noStem;
    if (ip1+1>tokenhi) goto incomplete;
    copyToken(vname1, tokens[ip1 + 1]);  // name of stem variable
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
    copyToken(vname1, tokens[ip1 + 1]);  // it read an unset buffer (#386)

    recs = getStem0(vname1);

    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs >= maxrecs) break;
        /* the value goes into plsValue as in DISKW; it was freed first
         * and then written into, SA0A at the next FREEMAIN (#386) */
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
  toolong:
    printf("EXECIO parameter missing or too long\n");
    goto exit8;
  openerror:
    printf("EXECIO cannot open %s\n",LSTR(*filename));
    goto exit8;
  writeerror:
    printf("EXECIO write error on %s after %d record(s)\n",LSTR(*filename),wrecs);
    if (ftoken != NULL) fclose(ftoken);
    LPFREE(plsValue)
    LPFREE(filename)
    return 20;
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
