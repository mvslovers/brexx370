#include <string.h>
#include "bmem.h"
#include "lstring.h"
#include "stack.h"
#include "rxmvsext.h"
#include "hostenv.h"

#define STEM 1
#define FIFO 2
#define LIFO 3

#define NOLINEFEED 0
#define LINEFEED 1

char *rxpull();
void rxqueue(char *s, int mode);
long rxqueued();
void remlf(char *s);

int RxEXECIO(char **tokens) {
    int ii;
    int filter=0;
    int ip1 = 0;
    int recs = 0;
    int rrecs=0, wrecs=0;
    int maxrecs=0;
    int skip=0;
    int subfrom=0,sublen=0;
    int mode=FIFO;
    int tokenhi = 0;
    FILE *ftoken;
    PLstr plsValue;

    char pbuff[4098];
    char vname1[32];
    char vname2[32];
    char vname3[32];
    char keep[32];
    char drop[32];
    char obuff[4098];
/* --------------------------------------------------------------------------------------------
 * INIT EXECIO
 * --------------------------------------------------------------------------------------------
 */
    LPMALLOC(plsValue)
    while (tokens[tokenhi] != NULL) tokenhi++;   // number of tokens
    tokenhi--;
    if (strcasecmp(tokens[1],"*") != 0) {
        maxrecs = atoi(&*tokens[1]);
    }
    ip1=findToken("DROP", tokens) ;
    if (ip1>0) {
        filter=1;
        if (ip1+1>tokenhi) goto incomplete;
        strcpy(drop, tokens[ip1+1]);
    }
    ip1=findToken("KEEP", tokens) ;
    if (ip1>0) {
        filter=2;
        if (ip1+1>tokenhi) goto incomplete;
        strcpy(keep, tokens[ip1+1]);
    }
    ip1=findToken("SKIP", tokens) ;
    if (ip1>0) {
        if (ip1+1>tokenhi) goto incomplete;
        skip = atoi(&*tokens[ip1+1]);
    }
    ip1=findToken("SUBSTR", tokens) ;
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
    printf("EXECIO invalid action parameter %s \n",tokens[2]);
    goto exit8;
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
    ftoken = fopen(tokens[3], "r");
    if (ftoken == NULL) goto openerror;
    recs = 0;
    while (fgets(pbuff, 4096, ftoken)) {
        recs++;
        if (recs <= skip) continue;
        if (maxrecs > 0 && rrecs >= maxrecs) break;
        if (filter > 0) {
            if (filter == 1 && strstr(pbuff, drop) != NULL) continue;  // allow KEEP and DROP
            if (filter == 2 && strstr(pbuff, keep) == NULL) continue;
        }
        rrecs++;
        remlf(&pbuff[0]); // remove linefeed
        if (subfrom>0)  {
            Lscpy(plsValue,pbuff);
            Lsubstr(plsValue,plsValue,subfrom, sublen,' ');
            LSTR(*plsValue)[LLEN(*plsValue)]=NULL;
            strcpy(pbuff,LSTR(*plsValue));
        }

        switch (mode) {
            case STEM :
                sprintf(vname2, "%s%d", vname1, rrecs);  // edited stem name
                setVariable(vname2, pbuff);             // set rexx variable
                break;
            case LIFO :
                rxqueue(pbuff, LIFO);
                break;
            default:
            case FIFO :
                rxqueue(pbuff, FIFO);
                break;
        }   // end of switch
    }  // end of while
    if (mode == STEM) {
        sprintf(vname2, "%s0", vname1);
        sprintf(vname3, "%d", rrecs);
        setVariable(vname2, vname3);
    }
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * DISKW
 * --------------------------------------------------------------------------------------------
 */
 DISKW:
    if (tokenhi<3) goto incomplete;
    ftoken = fopen(tokens[3], "w");
    goto WriteAll;
 /* --------------------------------------------------------------------------------------------
 * DISKA
 * --------------------------------------------------------------------------------------------
 */
 DISKA:
    if (tokenhi<3) goto incomplete;
    ftoken = fopen(tokens[3], "a");
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
        strcpy(vname1, tokens[ip1 + 1]);  // name of stem variable
        sprintf(vname2, "%s0", vname1);
        recs = getIntegerVariable(vname2);
    } else if (ip1 == -1) {              // get queue entries
        recs = StackQueued();
        if (recs==0) goto emptyStack;
    }
    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs >= maxrecs) break;
        if (ip1 == -1) {
            LPFREE(plsValue);
            plsValue=PullFromStack();
        }
        else {
            memset(vname2, 0, sizeof(vname2));
            sprintf(vname2, "%s%d", vname1, ii);
            getVariable(vname2, plsValue);
        }
        if (filter > 0) {
            if (filter == 1 && strstr(LSTR(*plsValue), drop) != NULL) continue;  // allow KEEP and DROP
            if (filter == 2 && strstr(LSTR(*plsValue), keep) == NULL) continue;
        }
        if (subfrom>0)  {
           Lsubstr(plsValue,plsValue,subfrom, sublen,' ');
           LSTR(*plsValue)[LLEN(*plsValue)]=NULL;
        }

        wrecs++;
        sprintf(obuff, "%s\n", LSTR(*plsValue));
        fputs(obuff, ftoken);
    }
    goto exit0;
 /* --------------------------------------------------------------------------------------------
 * LIFOR
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
        memset(vname2, 0, sizeof(vname2));
        sprintf(vname2, "%s%d", vname1, ii);
        LPFREE(plsValue);
        plsValue=PullFromStack();
        if (filter > 0) {
            if (filter == 1 && strstr(LSTR(*plsValue), drop) != NULL) continue;  // allow KEEP and DROP
            if (filter == 2 && strstr(LSTR(*plsValue) ,keep) == NULL) continue;
        }
        if (subfrom>0) {
            Lsubstr(plsValue,plsValue,subfrom, sublen,' ');
            LSTR(*plsValue)[LLEN(*plsValue)]=NULL;
        }
        wrecs++;
        setVariable(vname2, LSTR(*plsValue));
    }

    sprintf(vname2, "%s0", vname1);
    sprintf(vname3, "%d", wrecs);
    setVariable(vname2, vname3);
    goto exit0Stack;
 /* --------------------------------------------------------------------------------------------
 * LIFOW
 * --------------------------------------------------------------------------------------------
 */
    FIFOW:
    ip1 = findToken("STEM", tokens);
    if (ip1 <= 1) goto noStem;
    if (strcasecmp(tokens[2], "LIFOW")==0) mode=LIFO;
       else mode=FIFO;
    if (ip1+1>tokenhi) goto incomplete;
    strcpy(vname1, tokens[ip1 + 1]);  // name of stem variable
    sprintf(vname2, "%s0", vname1);
    recs = getIntegerVariable(vname2);
    LPMALLOC(plsValue)
    for (ii = skip + 1; ii <= recs; ii++) {
        if (maxrecs > 0 && wrecs >= maxrecs) break;
        memset(vname2, 0, sizeof(vname2));
        sprintf(vname2, "%s%d", vname1, ii);
        getVariable(vname2, plsValue);
        if (filter > 0) {
            if (filter == 1 && strstr(LSTR(*plsValue), drop) != NULL) continue;  // allow KEEP and DROP
            if (filter == 2 && strstr(LSTR(*plsValue) ,keep) == NULL) continue;
        }
        if (subfrom>0)  {
            Lsubstr(plsValue,plsValue,subfrom, sublen,' ');
            LSTR(*plsValue)[LLEN(*plsValue)]=NULL;
        }
        wrecs++;
        rxqueue(LSTR(*plsValue), mode);
    }
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * Return Handling
 * --------------------------------------------------------------------------------------------
 */
  exit0:
    fclose(ftoken);
  exit0Stack:
    LPFREE(plsValue)
    return 0;
  noStem:
    printf("EXECIO STEM parameter missing\n");
  goto exit8;
  suberror:
    printf("EXECIO SUBSTR parameter invalid or missing\n");
    goto exit8;
  incomplete:
    printf("EXECIO incomplete parameter list\n");
    goto exit8;
  openerror:
    printf("EXECIO cannot open %s\n",tokens[3]);
    goto exit8;
  emptyStack:
    printf("EXECIO DISKW stack is empty, nothing to store \n");
    goto exit8;

exit8:
    LPFREE(plsValue)
    return 8;
}

void
rxqueue(char *s,int mode)
{
    PLstr pstr;
    LPMALLOC(pstr)

    Lscpy(pstr, s);

    if (mode==FIFO) Queue2Stack(pstr);
    else Push2Stack(pstr);
}

char *
rxpull(int mode)
{
    PLstr pstr;
    pstr = PullFromStack();

    if (mode==LINEFEED) Lcat(pstr,"\n");

    LASCIIZ(*pstr);

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