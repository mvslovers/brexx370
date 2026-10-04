/* -------------------------------------------------------------------------------------
 * REXX variables for BREXX's C code: get and set a variable or a stem
 * element by name, in the current scope. Moved from rxmvs.c (#302); the
 * prototypes are in rxmvsext.h.
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include <string.h>
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "variable.h"

void getStemV(PLstr plsPtr, char *sName,int stemindx) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemindx);
    getVariable(vname, plsPtr);
}
int getIntegerV(char *sName,int stemindx) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemindx);
    return getIntegerVariable(vname);
}

int getStemV0(char *sName)  {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s0", sName);
    return getIntegerVariable(vname);
}

void getVariable(char *sName, PLstr plsValue)
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

int getIntegerVariable(char *sName) {
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

    LPFREE(plsValue);

    return (atoi(sValue));
}

void setVariable(char *sName, char *sValue)
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

    LASCIIZ(lsName);
    LASCIIZ(lsValue);

    RxPoolSet(&lsScope, &lsName, &lsValue);

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)
}

void setVariable2(char *sName, char *sValue, int lValue)
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

void setIntegerVariable(char *sName, int iValue)
{
    char sValue[19];

    sprintf(sValue,"%d",iValue);
    setVariable(sName,sValue);
}
