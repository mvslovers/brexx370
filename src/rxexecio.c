#include <string.h>
#include "bmem.h"
#include "lstring.h"
#include "stack.h"
#include "rxmvsext.h"
#include "hostenv.h"

#define STEM 1
#define FIFO 2
#define LIFO 3

char *rxpull();
void rxqueue(char *s, int mode);
long rxqueued();
void remlf(char *s);

int RxEXECIO(char **tokens) {
    int ii;

    unsigned char pbuff[4098];
    unsigned char vname1[32];
    unsigned char vname2[32];
    unsigned char vname3[32];
    unsigned char take[32];
    unsigned char obuff[4098];
    int filter=0;
    int ip1 = 0;
    int recs = 0;
    int rrecs=0;
    int maxrecs=0;
    int skip=0;
    int mode=FIFO;
    FILE *ftoken;
    PLstr plsValue;

/* --------------------------------------------------------------------------------------------
 * INIT EXECIO
 * --------------------------------------------------------------------------------------------
 */
    LPMALLOC(plsValue)
    if (strcasecmp(tokens[1],"*") != 0) {
        maxrecs = atoi(&*tokens[1]);
    }
    ip1=findToken("DROP", tokens) ;
    if (ip1>0) {
        filter=1;
        strcpy(take, tokens[ip1+1]);
    }
    ip1=findToken("KEEP", tokens) ;
    if (ip1>0) {
        filter=2;
        strcpy(take, tokens[ip1+1]);
    }
    ip1=findToken("SKIP", tokens) ;
    if (ip1>0) {
        skip = atoi(&*tokens[ip1+1]);
    }
/* --------------------------------------------------------------------------------------------
 * Now Choose what to do
 *   Long live modular programming!
 * --------------------------------------------------------------------------------------------
 */
    if (strcasecmp(tokens[2], "DISKR")      == 0) goto DISKR;
    else if (strcasecmp(tokens[2], "DISKW") == 0) goto DISKW;
    else if (strcasecmp(tokens[2], "DISKA") == 0) goto DISKA;
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
    ftoken = fopen(tokens[3], "r");
    if (ftoken == NULL) goto exit8;

    recs = 0;
    while (fgets(pbuff, 4096, ftoken)) {
        rrecs++;
        if (rrecs <= skip) continue;
        if (maxrecs > 0 && recs >= maxrecs) break;
        if (filter > 0) {
            if (filter == 1 && strstr((const char *) pbuff, (const char *) take) != NULL) continue;
            else if (filter == 2 && strstr((const char *) pbuff, (const char *) take) == NULL) continue;
        }
        recs++;
        remlf(&pbuff[0]); // remove linefeed
        switch (mode) {
            case STEM :
                sprintf(vname2, "%s%d", vname1, recs);  // edited stem name
                setVariable(vname2, pbuff);             // set rexx variable
                break;
            case LIFO :
                rxqueue(pbuff, LIFO);
                break;
            case FIFO :
                rxqueue(pbuff, FIFO);
                break;
        }   // end of switch
    }  // end of while
    if (mode == STEM) {
        sprintf(vname2, "%s0", vname1);
        sprintf(vname3, "%d", recs);
        setVariable(vname2, vname3);
    }
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * DISKW
 * --------------------------------------------------------------------------------------------
 */
 DISKW:
    ftoken = fopen(tokens[3], "w");
    goto WriteAll;
 /* --------------------------------------------------------------------------------------------
 * DISKA
 * --------------------------------------------------------------------------------------------
 */
 DISKA:
    ftoken = fopen(tokens[3], "a");
    goto WriteAll  ;
/* --------------------------------------------------------------------------------------------
 * Write Records for DISKW and DISKA
 * --------------------------------------------------------------------------------------------
 */
 WriteAll:
    if (ftoken == NULL) goto exit8;
    ip1 = findToken("STEM", tokens);
    if (ip1 >= 1) {
        strcpy(vname1, tokens[ip1 + 1]);  // name of stem variable
        sprintf(vname2, "%s0", vname1);
        recs = getIntegerVariable(vname2);
    } else if (ip1 == -1) {              // get queue entries
        recs = StackQueued();
    }
    for (ii = skip + 1; ii <= recs; ii++) {
        rrecs++;
        if (maxrecs > 0 && rrecs > maxrecs) break;
        if (ip1 != -1) {
            memset(vname2, 0, sizeof(vname2));
            sprintf(vname2, "%s%d", vname1, ii);
            getVariable(vname2, plsValue);
            sprintf(obuff, "%s\n", LSTR(*plsValue));
            fputs(obuff, ftoken);
        } else if (ip1 == -1) {
            fputs(rxpull(), ftoken);
        }
    }
    goto exit0;
/* --------------------------------------------------------------------------------------------
 * Return Handling
 * --------------------------------------------------------------------------------------------
 */
  exit0:
    fclose(ftoken);
    LPFREE(plsValue)
    return 0;
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
rxpull()
{
    PLstr pstr;
    pstr = PullFromStack();
    Lcat(pstr,"\n");
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
