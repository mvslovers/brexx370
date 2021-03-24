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
    unsigned char vname1[19];
    unsigned char vname2[19];
    unsigned char vname3[19];
    unsigned char take[32];
    unsigned char obuff[4098];
    int filter=0;
    int ip1 = 0;
    int recs = 0;
    int rrecs=0;
    int maxrecs=0;
    int skip=0;
    int mode=FIFO;
    FILE *f;
    PLstr plsValue;

    LPMALLOC(plsValue)
    if (strcasecmp(tokens[1],"*") != 0) {
        maxrecs = atoi(&*tokens[1]);
    }
    ip1=findToken("DROP", tokens) ;
    if (ip1>0) {
        filter=1;
        ip1++;
        strcpy(take, tokens[ip1]);
    }
    ip1=findToken("KEEP", tokens) ;
    if (ip1>0) {
        filter=2;
        ip1++;
        strcpy(take, tokens[ip1]);
    }
    ip1=findToken("SKIP", tokens) ;
    if (ip1>0) {
        ip1++;
        skip = atoi(&*tokens[ip1]);
    }

 // DISKR
    if (strcasecmp(tokens[2], "DISKR") == 0) {
        ip1 = findToken("STEM", tokens);
        if (ip1 >= 0) {
            mode = STEM;
            ip1++;
            strcpy(vname1, tokens[ip1]);         // name of stem variable
        } else if (findToken("FIFO", tokens) >= 0) mode = FIFO;
          else if (findToken("LIFO", tokens) >= 0) mode = LIFO;
    // open file
        f = fopen(tokens[3], "r");
        if (f == NULL) {
            LPFREE(plsValue)
            return 8;
        }
        recs = 0;
        while (fgets(pbuff, 4096, f)) {
            rrecs++;
            if (rrecs<=skip) continue;
            if (maxrecs > 0 && recs >= maxrecs) break;
            if (filter > 0) {
               if (filter == 1 && strstr((const char *) pbuff, (const char *) take) != NULL) continue;
               else if (filter == 2 && strstr((const char *) pbuff, (const char *) take) == NULL) continue;
            }
            recs++;
            remlf(&pbuff[0]); // remove linefeed
            switch(mode) {
                case STEM :
                    sprintf(vname2, "%s%d", vname1, recs);  // edited stem name
                    setVariable(vname2, pbuff);             // set rexx variable
                    break;
               case LIFO :
                    rxqueue(pbuff,LIFO);
                    break;
                case FIFO :
                    rxqueue(pbuff,FIFO);
                    break;

            }   // end of switch
       }  // end of while
        if (mode==1) {
            sprintf(vname2, "%s0", vname1);
            sprintf(vname3, "%d", recs);
            setVariable(vname2, vname3);
        }
        fclose(f);
        LPFREE(plsValue)
        return 0;
    }

    // DISKW
    if (strcasecmp(tokens[2], "DISKW") == 0) {
        ip1 = findToken("STEM", tokens);
        if (ip1 != -1) {
            ip1++;
            strcpy(vname1, tokens[ip1]);  // name of stem variable
        }
        f = fopen(tokens[3], "w");
        if (f == NULL) {
            LPFREE(plsValue)
            return 8;
        }
        if (ip1 != -1) {
            sprintf(vname2, "%s0", vname1);
            recs = getIntegerVariable(vname2);
        }
        else if (ip1 == -1) {
            recs = rxqueued();
         }
        for (ii = skip+1; ii <= recs; ii++) {
            rrecs++;
            if (maxrecs > 0 && rrecs > maxrecs) break;
            if (ip1 != -1) {
                memset(vname2, 0, sizeof(vname2));
                sprintf(vname2, "%s%d", vname1, ii);
                getVariable(vname2, plsValue);
                sprintf(obuff, "%s\n", LSTR(*plsValue));
                fputs(obuff, f);
            }
            else if (ip1 == -1) {
               fputs(rxpull(), f);
            }
        }
        fclose(f);
        LPFREE(plsValue)
        return 0;
    }

    // DISKA
    if (strcasecmp(tokens[2], "DISKA") == 0) {
        ip1 = findToken("STEM", tokens);
        if (ip1 > 0) {
            ip1++;
            strcpy(vname1, tokens[ip1]);  // name of stem variable
        }
        f = fopen(tokens[3], "a");
        if (f == NULL) {
            LPFREE(plsValue)
            return 8;
        }
        sprintf(vname2, "%s0", vname1);
        recs = getIntegerVariable(vname2);

        for (ii = skip+1; ii <= recs; ii++) {
            rrecs++;
            if (maxrecs > 0 && rrecs > maxrecs) break;
            memset(vname2, 0, sizeof(vname2));
            sprintf(vname2, "%s%d", vname1, ii);
            getVariable(vname2, plsValue);
            sprintf(obuff, "%s\n", LSTR(*plsValue));
            fputs(obuff, f);
        }
        fclose(f);
        LPFREE(plsValue)
        return 0;
    }
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
