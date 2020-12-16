#include "lstring.h"
#include "fss.h"
#include "rxmvsext.h"
#include "hostenv.h"

int
RxFSS_INIT(char **tokens)
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
RxFSS_TERM(char **tokens)
{
    return fssTerm();
}

int
RxFSS_RESET(char **tokens)
{
    return fssReset();
}

int
RxFSS_FIELD(char **tokens)
{
    int iErr = 0;

    PLstr plsValue;
    int row  = 0;
    int col  = 0;
    int attr = 0;
    int len  = 0;

    LPMALLOC(plsValue)

    // check row is numeric
    if (fssIsNumeric(tokens[1])) {
        row = atoi(tokens[1]);
    } else {
        iErr = -1;
    }

    // check col is numeric
    if (fssIsNumeric(tokens[2])) {
        col = atoi(tokens[2]);
    } else {
        iErr = -2;
    }

    // check attr is numeric
    if (fssIsNumeric(tokens[3])) {
        attr = atoi(tokens[3]);
    }

    // check len is numeric
    if (fssIsNumeric(tokens[5])) {
        len = atoi(tokens[5]);
    } else {
        iErr = -5;
    }

    if (iErr == 0) {
        getVariable(tokens[6], plsValue);

        iErr = fssFld(row, col, attr, tokens[4], len, (char *)LSTR(*plsValue));
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_TEXT(char **tokens)
{
    int iErr = 0;

    PLstr plsValue;
    int row  = 0;
    int col  = 0;
    int attr = 0;

    LPMALLOC(plsValue)

    // check row is numeric
    if (fssIsNumeric(tokens[1])) {
        row = atoi(tokens[1]);
    } else {
        iErr = -1;
    }

    // check col is numeric
    if (fssIsNumeric(tokens[2])) {
        col = atoi(tokens[2]);
    } else {
        iErr = -2;
    }

    // check attr is numeric
    if (fssIsNumeric(tokens[3])) {
        attr = atoi(tokens[3]);
    } else {
        if (strstr(tokens[3], "#ATTR") != NULL) {
            attr = getIntegerVariable("#ATTR");
        } else {
            if(strstr(tokens[3], "#PROT") != NULL){
                attr = attr + fssPROT;
            }
            if(strstr(tokens[3], "#NUM") != NULL){
                attr = attr + fssNUM;
            }
            if(strstr(tokens[3], "#HI") != NULL){
                attr = attr + fssHI;
            }
            if(strstr(tokens[3], "#NON") != NULL){
                attr = attr + fssNON;
            }
            if(strstr(tokens[3], "#BLUE") != NULL){
                attr = attr + fssBLUE;
            }
            if(strstr(tokens[3], "#RED") != NULL){
                attr = attr + fssRED;
            }
            if(strstr(tokens[3], "#PINK") != NULL){
                attr = attr + fssPINK;
            }
            if(strstr(tokens[3], "#GREEN") != NULL){
                attr = attr + fssGREEN;
            }
            if(strstr(tokens[3], "#TURQ") != NULL){
                attr = attr + fssTURQ;
            }
            if(strstr(tokens[3], "#YELLOW") != NULL){
                attr = attr + fssYELLOW;
            }
            if(strstr(tokens[3], "#WHITE") != NULL){
                attr = attr + fssWHITE;
            }
            if(strstr(tokens[3], "#BLINK") != NULL){
                attr = attr + fssBLINK;
            }
            if(strstr(tokens[3], "#REVERSE") != NULL){
                attr = attr + fssREVERSE;
            }
            if(strstr(tokens[3], "#USCORE") != NULL){
                attr = attr + fssUSCORE;
            }
        }

    }

    if (iErr == 0) {
        getVariable(tokens[4], plsValue);

        iErr = fssTxt(row, col, attr, (char *)LSTR(*plsValue));
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_SET(char **tokens)
{
    int iErr = 0;

    PLstr plsValue;

    LPMALLOC(plsValue)

    if (findToken("CURSOR", tokens) == 1)
    {
        iErr = fssSetCursor(tokens[2]);
    } else if ( findToken("FIELD", tokens) == 1)
    {
        getVariable(tokens[3], plsValue);
        iErr = fssSetField(tokens[2], (char *)LSTR(*plsValue));
    } else if ( findToken("COLOR", tokens) == 1)
    {
        int color = 0;

        // check color is numeric
        if (fssIsNumeric(tokens[3]))
        {
            color = atoi(tokens[3]);
        }
        else
        {
            if(strstr(tokens[3], "#BLUE") != NULL)
            {
                color = fssBLUE;
            }
            if(strstr(tokens[3], "#RED") != NULL)
            {
                color = fssRED;
            }
            if(strstr(tokens[3], "#PINK") != NULL)
            {
                color = fssPINK;
            }
            if(strstr(tokens[3], "#GREEN") != NULL)
            {
                color = fssGREEN;
            }
            if(strstr(tokens[3], "#TURQ") != NULL)
            {
                color = fssTURQ;
            }
            if(strstr(tokens[3], "#YELLOW") != NULL)
            {
                color = fssYELLOW;
            }
            if(strstr(tokens[3], "#WHITE") != NULL)
            {
                color = fssWHITE;
            }
        }

        getVariable(tokens[3], plsValue);
        iErr = fssSetColor(tokens[2], color);
    } else
    {
        iErr = -1;
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_GET(char **tokens)
{
    int iErr = 0;

    PLstr plsValue;
    char *  tmp = NULL;

    LPMALLOC(plsValue)

    if (findToken("AID", tokens) == 1) {
        setIntegerVariable(tokens[2], fssGetAID());
    } else if (findToken("WIDTH", tokens) == 1) {
        setIntegerVariable(tokens[2], fssGetAlternateScreenWidth());
    } else if (findToken("HEIGHT", tokens) == 1) {
        setIntegerVariable(tokens[2], fssGetAlternateScreenHeight());
    } else if (findToken("FIELD", tokens) == 1) {
        setVariable(tokens[3], fssGetField(tokens[2]));
    } else {
        iErr = -1;
    }

    LPFREE(plsValue)

    return iErr;
}

int
RxFSS_REFRESH(char **tokens)
{
    return fssRefresh();
}

int
RxFSS_CHECK(char **tokens)
{
    int iErr;

    int i;
    char *s = tokens[2];

    if (strcasecmp(tokens[1], "FIELD") == 0) {

        // TODO: extract this ta a strupr() function
        for (i = 0; s[i]!='\0'; i++) {
            s[i] = (char) toupper(s[i]);
        }

        if (fssFieldExists(tokens[2])) {
            iErr = 0;
        } else {
            iErr = 4;
        }
    } else {
        iErr = -3;
    }

    return iErr;
}

