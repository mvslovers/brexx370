#include <string.h>
#include "bmem.h"
#include "lstring.h"
#include "stack.h"
#include "rxmvsext.h"
#include "hostenv.h"

char *rxpull();
void rxqueue(char *s);
long rxqueued();
void remlf(char *s);

int RxEXECIO(char **tokens) {
    int ii;

    unsigned char pbuff[1025];
    unsigned char vname1[19];
    unsigned char vname2[19];
    unsigned char vname3[19];
    unsigned char obuff[4097];
    int ip1 = 0;
    int recs = 0;
    FILE *f;
    PLstr plsValue;

    LPMALLOC(plsValue)

    // DISKR
    if (strcasecmp(tokens[2], "DISKR") == 0) {
        ip1 = findToken("STEM", tokens);
        if (ip1 != -1) {
            ip1++;
            strcpy(vname1, tokens[ip1]);         // name of stem variable
        }
        f = fopen(tokens[3], "r");
        if (f == NULL) {
            LPFREE(plsValue)
            return 8;
        }
        recs = 0;
        while (fgets(pbuff, 1024, f)) {
            recs++;
            remlf(&pbuff[0]);                     // remove linefeed
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
        for (ii = 1; ii <= recs; ii++) {
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
