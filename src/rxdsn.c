/* -------------------------------------------------------------------------------------
 * Data set functions: ALLOCATE, FREE, CREATE, EXISTS, REMOVE, RENAME,
 * LISTDSI, LISTDSIQ, SYSDSN, DIR, LOCATE, SUBMIT, BLDL, EXEC, and __SREAD/
 * __SWRITE (a data set into a string array and back). They open through
 * the data set layer dsio.c. Moved from rxmvs.c (#302).
 * -------------------------------------------------------------------------------------
 */
#include <stdlib.h>
#include <strings.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "util.h"
#include "stack.h"
#include "rxll.h"
#include "rxdsn.h"
#include "dynit.h"
#include "dsio.h"
#include "sarray.h"

extern Lstr LTMP[16];
extern RX_ENVIRONMENT_CTX_PTR environment;

#define iError(rc,label) {iErr=rc;goto label;}

/* DIR(): the directory entry layout and its ISPF statistics dates */
/* ------------------------------------------------------------------------------------------------------------------ */
#define maxdirent 3000
#define UDL_MASK   ((int) 0x1F)
#define NPTR_MASK  ((int) 0x60)
#define ALIAS_MASK ((int) 0x80)

void julian2gregorian(int year, int day, char **date)
{
    static const int month_len[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    int leap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
    int day_of_month = day;
    int month;

    for (month = 0; month < 12; month ++) {

        int mlen = month_len[month];

        if (leap && month == 1)
            mlen ++;

        if (mlen >= day_of_month)
            break;

        day_of_month -= mlen;

    }

    sprintf(*date, "%.2d-%.2d-%.2d", year, month+1, day_of_month);
}

int getYear(__unused byte flag, byte yy) {
    int year;

    // yy is packed decimal: two BCD digits
    year = ((yy >> 4) & 0x0F) * 10 + (yy & 0x0F);

    /*
    if (flag == 0x01) {
        year = year + 2000;
    } else {
        year = year + 1900;
    }
    */

    return year;
}

int getDay(byte byte1, byte byte2) {
    int day;

    // three BCD digits: both nibbles of byte1, the high nibble of byte2
    day = ((byte1 >> 4) & 0x0F) * 100 + (byte1 & 0x0F) * 10 + ((byte2 >> 4) & 0x0F);

    return day;
}

void R_bldl(__unused int func) {
    int found=0;
    if (ARGN != 1 || LLEN(*ARG1)==0) Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1) ;
    Lupper(ARG_OWN(1));

    if (findLoadModule((char *)LSTR(*ARG1))) found=1;
    Licpy(ARGR,found);
}

/* PDSdet() and LOCATE(): count the directory entries, or stop at one */
static int
dirCount(void *arg, const PDSLIST *entry)
{
    (void) arg;
    (void) entry;
    return 0;
}

void PDSdet (const char * filename, bool byDd)
{
    int  members;
    int  flen = 0;
    FILE *fh;

    /* the members through libc370's BPAM walk (#144). The number of
     * directory blocks is not available that way: SYSDIRBLK is n/a. */
    members = rxWalkDir(filename, byDd, dirCount, NULL);
    if (members < 0) return;

    fh = byDd ? rxOpenDd(filename, "rb") : rxOpenDsn(filename, "rb");
    if (fh == NULL) return;
    setVariable("SYSDIRBLK","n/a");
    setIntegerVariable("SYSMEMBERS",members);
    if (fseek(fh, 0, SEEK_END) == 0) flen = ftell(fh);
    setIntegerVariable("SYSSIZE2", flen);
    setIntegerVariable("SYSSIZE", flen);
    setVariable("SYSRECORDS","n/a");
    fclose(fh);
}

void R_listdsi(__unused int func)
{
    char *args[2];

    char sFileName[DSN_NAME_MAX + 1];
    char sFunctionCode[3];
    bool byDd = FALSE;
    char argCopy[DSN_NAME_MAX + 2 + 1 + 8 + 1];   /* 'dsn(member)' FILE */

    FILE *pFile;
    int flen=0,po=0,recfm=0,lrecl=0;
    int iErr;


    memset(sFileName,0,sizeof(sFileName));
    memset(sFunctionCode,0,3);

    iErr = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG_OWN(1));

    args[0]= NULL;
    args[1]= NULL;

    /* parseArgs() splits with strtok(), in place: on a copy, not on the
     * argument, which can be a literal BREXX shares with every equal one
     * (#299: the second LISTDSI('dd FILE') saw only 'dd'). Nothing that
     * fits a name and FILE is longer. */
    if (LLEN(*ARG1) >= sizeof(argCopy)) {
        Lscpy(ARGR, "16");
        return;
    }
    memcpy(argCopy, LSTR(*ARG1), LLEN(*ARG1));
    argCopy[LLEN(*ARG1)] = '\0';
    parseArgs(args, 2, argCopy);

    if (args[1] != NULL && strcmp(args[1], "FILE") != 0)
        Lerror(ERR_INCORRECT_CALL,0);

    if (args[0] == NULL) {                  /* no name at all */
        strcat(sFunctionCode, "16");
        iErr = 2;
    } else if (args[1] == NULL) {
        /* quoting, prefix and length as everywhere else (#170) */
        if (getDatasetName(environment, args[0], sFileName) != 0) {
            strcat(sFunctionCode, "16");
            iErr = 2;
        }
    } else {
        /* the DD name alone, not the whole "dd FILE" argument (#170) */
        if (strlen(args[0]) > 8) {
            printf("DD name exceeds 8 characters, requested length: %d\n",(int) strlen(args[0]));
            strcat(sFunctionCode, "16");
            iErr = 4;
        } else {
            strcpy(sFileName, args[0]);
            byDd = TRUE;
        }
    }

    if (iErr == 0) {
        char pbuff[4096];
        int records=0;
        pFile = byDd ? rxOpenDd(sFileName, "r") : rxOpenDsn(sFileName, "r");
           if (pFile != NULL) {
              strcat(sFunctionCode,"0");
              po=parseDCB(pFile);
              recfm=po/10;   // select recfm F or FB
              po=po%10;      // partititioned or SEQ
              if (po!=1) {  // po=0 PS, p0=1 PDS with assigned member, is treated as sequential
                  while (fgets(pbuff, 4096, pFile)) records++;  // just read 3 bytes to be safe including CRLF
                  setIntegerVariable("SYSRECORDS",records);
                  if (fseek(pFile, 0, SEEK_END) == 0) flen = ftell(pFile);
                  setIntegerVariable("SYSSIZE2",flen);
                  lrecl=getIntegerVariable("SYSLRECL");
                  if (recfm>0) setIntegerVariable("SYSSIZE",records*lrecl);
                      else setIntegerVariable("SYSSIZE",flen);
                  setVariable("SYSDIRBLK","n/a");
                  setVariable("SYSMEMBERS","n/a");
              }
              FCLOSE(pFile);
              if (po==1) {
                 PDSdet(sFileName, byDd);
              }
        } else {
            strcat(sFunctionCode,"16");
        }
    }

    Lscpy(ARGR,sFunctionCode);

}
/* ----------------------------------------------------------------------------
 * LISTDSIQ fast version with limited attributes
 *     fully qualified dsn expected (no FILE variant), no quotes are allowed
 * ----------------------------------------------------------------------------
 */
void R_listdsiq(__unused int func)
{
    char sFileName[45];
    char sFunctionCode[3];
    char mode='N';
    char pbuff[4096];

    FILE *pFile;
    int iErr,records=0;



    memset(sFileName,0,45);
    memset(sFunctionCode,0,3);

    iErr = 0;

    if (ARGN >2) Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG_OWN(1));

    get_sv(2);
    if (ARGN==2) mode=LSTR(*ARG2)[0];

    if (LLEN(*ARG1)>44){
        printf("DSN exceeds 44 characters, requested length: %d\n",(int) LLEN(*ARG1)-2);
        iErr=3;
    } else strcpy(sFileName, (const char *) (LSTR(*ARG1)));

    if (iErr == 0) {
        pFile = rxOpenDsn(sFileName, "r");
        if (pFile != NULL) {
            parseDCB(pFile);
            if (mode=='R'){
               while (fgets(pbuff, 4096, pFile)) records++;
               setIntegerVariable("SYSRECORDS",records);
            }
            FCLOSE(pFile);
            iErr = 0;
        } else iErr=16;
    }
    Licpy(ARGR,iErr);
}

void R_sysdsn(__unused int func)
{
    char sDSName[DSN_NAME_MAX + 1];
    FILE *pFile;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG_OWN(1));

    if (LSTR(*ARG1)[0] == '\0') {
        Lscpy(ARGR, "MISSING DATASET NAME");
    } else if (getDatasetName(environment, (const char *) LSTR(*ARG1), sDSName) != 0) {
        /* partially quoted, or does not fit (#170); the message carries
         * the whole argument and grows with it */
        Lscpy(ARGR, "INVALID DATASET NAME, ");
        Lstrcat(ARGR, ARG1);
    } else {
        errno = 0;
        pFile = rxOpenDsn(sDSName, "r");
        if (pFile != NULL) {
            Lscpy(ARGR, "OK");
            FCLOSE(pFile);
        } else if (errno == EACCES) {
            Lscpy(ARGR, "PROTECTED DATASET");     /* #294, as TSO/E */
        } else {
            Lscpy(ARGR, "DATASET NOT FOUND");
        }
    }

}

/* ---------------------------------------------------------------
 *  DIR( file )
 *    Exploiting Partitioned Data Set Directory Fields
 *      Part   I: http://www.naspa.net/magazine/1991/t9109019.txt
 *      Part  II: http://www.naspa.net/magazine/1991/t9110014.txt
 *      Part III: http://www.naspa.net/magazine/1991/t9111015.txt
 *    Using the System Status Index
 *                http://www.naspa.net/magazine/1991/t9104004.txt
 * ---------------------------------------------------------------
 */
/* DIR(): one directory entry into DIRENTRY.n (#144). entry is libc370's
 * PDSLIST: name(8), TTR(3), the C byte, then the user data. */
typedef struct {
    char mode;          /* 'D' details, 'M' member names only, else a LINE */
    int  count;         /* entries set so far */
} DIR_CTX;

static int
dirEntry(void *arg, const PDSLIST *entry)
{
    DIR_CTX *ctx = (DIR_CTX *) arg;
    const unsigned char *currentPosition;

    char   memberName[8 + 1];
    char   aliasName[8 + 1];
    char   ttr[6 + 1];
    char   version[5 + 1];
    char   creationDate[8 + 1];
    char   changeDate[8 + 1];
    char   changeTime[8 + 1];
    char   init[5 + 1];
    char   curr[5 + 1];
    char   mod[5 + 1];
    char   uid[8 + 1];
    char   line[255];
    char   *sLine;
    char   stemName[13];        /* DIRENTRY (8) + . (1) + up to 3000 (4) */
    char   varName[32];

    int    info_byte;
    short  numPointers;
    short  userDataLength;
    int    loadModuleSize;
    long   jj;
    const USER_DATA *pUserData;

    if (ctx->count == maxdirent) return 1;      /* stop: no more stems */

    memset(line, 0, sizeof(line));
    sLine = line;

    memset(memberName, 0, 9);
    memcpy(memberName, entry->name, 8);
    jj = 7;                                     /* remove trailing blanks */
    while (jj >= 0 && memberName[jj] == ' ') jj--;
    memberName[++jj] = 0;
    sLine += sprintf(sLine, "%-8s", memberName);

    memset(ttr, 0, 7);
    sprintf(ttr, "%.2X%.2X%.2X", entry->ttr[0], entry->ttr[1], entry->ttr[2]);
    sLine += sprintf(sLine, "   %-6s", ttr);

    info_byte      = (int) entry->idc;
    numPointers    = (info_byte & NPTR_MASK);
    userDataLength = (info_byte & UDL_MASK) * 2;
    currentPosition = (const unsigned char *) entry + 12;  /* the user data */

    if (numPointers == 0 && userDataLength > 0) {      /* no load module */
        if (ctx->mode != 'M') {
            int year;
            int day;
            char *datePtr;

            pUserData = (const USER_DATA *) currentPosition;
            memset(version, 0, 6);
            sprintf(version, "%.2d.%.2d", pUserData->vlvl, pUserData->mlvl);
            sLine += sprintf(sLine, " %-5s", version);
            memset(creationDate, 0, 9);
            datePtr = (char *) &creationDate;
            year = getYear(pUserData->credt[0], pUserData->credt[1]);
            day = getDay(pUserData->credt[2], pUserData->credt[3]);
            julian2gregorian(year, day, &datePtr);
            sLine += sprintf(sLine, " %-8s", creationDate);

            memset(changeDate, 0, 9);
            datePtr = (char *) &changeDate;
            year = getYear(pUserData->chgdt[0], pUserData->chgdt[1]);
            day = getDay(pUserData->chgdt[2], pUserData->chgdt[3]);
            julian2gregorian(year, day, &datePtr);
            sLine += sprintf(sLine, " %-8s", changeDate);

            memset(changeTime, 0, 9);
            sprintf(changeTime, "%.2x:%.2x:%.2x", (int) pUserData->chgtm[0], (int) pUserData->chgtm[1],
                    (int) pUserData->chgss);
            sLine += sprintf(sLine, " %-8s", changeTime);

            memset(init, 0, 6);
            sprintf(init, "%5d", pUserData->init);
            sLine += sprintf(sLine, " %-5s", init);

            memset(curr, 0, 6);
            sprintf(curr, "%5d", pUserData->curr);
            sLine += sprintf(sLine, " %-5s", curr);

            memset(mod, 0, 6);
            sprintf(mod, "%5d", pUserData->mod);
            sLine += sprintf(sLine, " %-5s", mod);

            memset(uid, 0, 9);
            sprintf(uid, "%-.8s", pUserData->uid);
            sLine += sprintf(sLine, " %-8s", uid);
        }
    } else {
        loadModuleSize = ((byte) *(currentPosition + 0xA)) << 16 |
                         ((byte) *(currentPosition + 0xB)) << 8 |
                         ((byte) *(currentPosition + 0xC));

        sLine += sprintf(sLine, " %.6x", loadModuleSize);

        if (info_byte & ALIAS_MASK) {
            memset(aliasName, 0, 9);
            memcpy(aliasName, currentPosition + 0x18, 8);
            jj = 7;                             /* remove trailing blanks */
            while (jj >= 0 && aliasName[jj] == ' ') jj--;
            aliasName[++jj] = 0;
            snprintf(sLine, sizeof(line) - (size_t) (sLine - line), " %.8s", aliasName);
        }
    }

    memset(stemName, 0, sizeof(stemName));
    memset(varName, 0, sizeof(varName));
    snprintf(stemName, sizeof(stemName), "DIRENTRY.%d", ++ctx->count);

    snprintf(varName, sizeof(varName), "%s.NAME", stemName);
    setVariable(varName, memberName);
    if (ctx->mode == 'D') {
        snprintf(varName, sizeof(varName), "%s.TTR", stemName);
        setVariable(varName, ttr);

        if ((((info_byte & 0x60) >> 5) == 0) && userDataLength > 0) {
            snprintf(varName, sizeof(varName), "%s.CDATE", stemName);
            setVariable(varName, creationDate);

            snprintf(varName, sizeof(varName), "%s.UDATE", stemName);
            setVariable(varName, changeDate);

            snprintf(varName, sizeof(varName), "%s.UTIME", stemName);
            setVariable(varName, changeTime);

            snprintf(varName, sizeof(varName), "%s.INIT", stemName);
            setVariable(varName, init);

            snprintf(varName, sizeof(varName), "%s.SIZE", stemName);
            setVariable(varName, curr);

            snprintf(varName, sizeof(varName), "%s.MOD", stemName);
            setVariable(varName, mod);

            snprintf(varName, sizeof(varName), "%s.UID", stemName);
            setVariable(varName, uid);
        }
    }
    if (ctx->mode != 'M') {
        snprintf(varName, sizeof(varName), "%s.LINE", stemName);
        setVariable(varName, line);
    }
    return 0;
}

void R_dir( __unused const int func )
{
    char    sDSN[DSN_NAME_MAX + 1];   /* getDatasetName() fills 55 bytes (#283) */
    DIR_CTX ctx;

    if (ARGN < 1 || ARGN >2) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    must_exist(1);
    get_s(1)
    get_modev(2,ctx.mode,'D');
    ctx.count = 0;

    LASCIIZ(*ARG1)

#ifndef __CROSS__
    Lupper(ARG_OWN(1));
#endif

    /* the directory through libc370's BPAM walk; JCC's fopen options for
     * reading it as RECFM=U blocks never reached libc370 (#144) */
    if (getDatasetName(environment, (const char*)LSTR(*ARG1), sDSN) != 0 ||
        rxWalkDir(sDSN, FALSE, dirEntry, &ctx) < 0) {
        Licpy(ARGR,8);
        return;
    }
    setIntegerVariable("DIRENTRY.0", ctx.count);
    Licpy(ARGR,0);
}

/* LOCATE(): stop at the member asked for; an exact compare, not a pattern */
typedef struct {
    const char *member;
    int         found;
} LOCATE_CTX;

static int
locateEntry(void *arg, const PDSLIST *entry)
{
    LOCATE_CTX *ctx = (LOCATE_CTX *) arg;
    char memberName[8 + 1];
    int  jj = 7;

    memcpy(memberName, entry->name, 8);
    while (jj >= 0 && memberName[jj] == ' ') jj--;
    memberName[jj + 1] = 0;
    ctx->found = (strcmp(ctx->member, memberName) == 0);
    return ctx->found;
}

void R_locate (__unused const int func )
{
    int        byDd = FALSE;
    LOCATE_CTX ctx;
    const char *name;
    char       dsn[DSN_NAME_MAX + 1];

    if (ARGN < 2 || ARGN > 3) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }
    get_s(1)
    get_s(2)
    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    Lupper(ARG_OWN(1));
    Lupper(ARG_OWN(2));
    if (ARGN==3) {
        get_s(3)
        Lupper(ARG_OWN(3));
        if (strcmp(LSTR(*ARG3), "FILE") == 0) byDd = TRUE;
    }
    /* for performance reasons we expect always fully qualified DSNs; the
     * directory through libc370's BPAM walk (#144): 0 found, 8 not found,
     * 12 the directory cannot be read */
    ctx.member = (const char *) LSTR(*ARG2);
    ctx.found  = 0;
    name = (const char *) LSTR(*ARG1);
    if (!byDd && CheckQuotation(name) == FULL_QUOTED) {
        /* 'dsn' and dsn both name the data set itself, as jcc_fopen() took them */
        if (strlen(name) < 3 || strlen(name) - 2 > DSN_NAME_MAX) {
            Licpy(ARGR, 12);
            return;
        }
        snprintf(dsn, sizeof(dsn), "%.*s", (int) strlen(name) - 2, name + 1);
        name = dsn;
    }
    if (rxWalkDir(name, byDd, locateEntry, &ctx) < 0)
        Licpy(ARGR, 12);
    else
        Licpy(ARGR, ctx.found ? 0 : 8);
}

/* -------------------------------------------------------------------------------------
 * Remove DSN
 * -------------------------------------------------------------------------------------
 */
void R_removedsn(__unused int func)
{
    char sFileName[55];
    int remrc=-2, iErr=0,dbg=0;

    memset(sFileName,0,55);
    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1)
#ifndef __CROSS__
    Lupper(ARG_OWN(1));
#endif
    get_s(1)
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    // no errors occurred so far, perform the remove
    if (iErr == 0) remrc = remove(sFileName);
    else remrc=iErr;

    if (dbg==1) {
        printf("Remove %s\n",sFileName);
        printf("   RC  %i\n",remrc);
    }

    Licpy(ARGR,remrc);
}

/* -------------------------------------------------------------------------------------
 * Rename DSN-old,DSN-new
 * -------------------------------------------------------------------------------------
 */
void R_renamedsn(__unused int func)
{
    char sFileNameOld[55];
    Lstr oldDSN, oldMember;
    char sFileNameNew[55];
    Lstr newDSN, newMember;
    int renrc=-9, iErr=0, dbg=0;

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL,0);

    memset(sFileNameOld,0,55);
    memset(sFileNameNew,0,55);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)

#ifndef __CROSS__
    Lupper(ARG_OWN(1));
    Lupper(ARG_OWN(2));
#endif
// * ---------------------------------------------------------------------------------------
// * Split DSN and Member
// * ---------------------------------------------------------------------------------------
    splitDSN(&oldDSN, &oldMember, ARG1);
    splitDSN(&newDSN, &newMember, ARG2);
// * ---------------------------------------------------------------------------------------
// * Auto complete DSNs
// * ---------------------------------------------------------------------------------------
    iErr = getDatasetName(environment, (const char *) LSTR(oldDSN), sFileNameOld);
    if (iErr == 0) {
        iErr = getDatasetName(environment, (const char *) LSTR(newDSN), sFileNameNew);
        if (iErr != 0) renrc=-2;
    } else renrc=-2;
    if (iErr != 0) goto leave;
//* Add Member Names if there are any
    if (LLEN(oldMember)>0) {
        strcat(sFileNameOld, "(");
        strcat(sFileNameOld, (const char *) LSTR(oldMember));
        strcat(sFileNameOld, ")");
    }
    if (LLEN(newMember)>0) {
        strcat(sFileNameNew, "(");
        strcat(sFileNameNew, (const char *) LSTR(newMember));
        strcat(sFileNameNew, ")");
    }
// * ---------------------------------------------------------------------------------------
// * Test certain RENAME some scenarios
// * ---------------------------------------------------------------------------------------
    if ((LLEN(oldMember)==0 && LLEN(newMember)!=0) || (LLEN(oldMember)!=0 && LLEN(newMember)==0)) goto incomplete;
    if (Lstrcmp(&oldDSN,&newDSN)==0 ){
        if (LLEN(oldMember)==0 && LLEN(newMember)==0) goto STequal;
        if (LLEN(oldMember)>0 && LLEN(newMember)>0) {
            if (strcmp((const char *) LSTR(oldMember),(const char *) LSTR(newMember))==0) goto STequal;
            goto doRename;  // perform Member Rename
        }
    }
    if (Lstrcmp(&oldDSN,&newDSN)!=0 ) {
        if (LLEN(oldMember) > 0 && LLEN(newMember) > 0) goto invalren;
        else if (LLEN(oldMember) == 0 && LLEN(newMember) == 0) goto doRename;
    }
    goto doRename;  // no match with special secenarious, just try the rename/*
// * ---------------------------------------------------------------------------------------
// * Incomplete Member definition in either from or to DSN
// * ---------------------------------------------------------------------------------------
    incomplete:
    if (dbg==1) printf("incomplete Member definition in Rename\n");
    renrc=-3;
    goto leave;
// * ---------------------------------------------------------------------------------------
// * From / To DSNs are equal, no Rename necessary
// * ---------------------------------------------------------------------------------------
    STequal:
    if (dbg==1) printf("Source and Target DSN are equal\n");
    renrc=-4;
    goto leave;
//  * ---------------------------------------------------------------------------------------
//  * DSN Rename and Member Rename at the same time are not allowed
//  * ---------------------------------------------------------------------------------------
    invalren:
    if (dbg==1) printf("Invalid Rename of DSN and Member at the same time\n");
    renrc = -5;
    goto leave;
// * ---------------------------------------------------------------------------------------
// * Perform the Rename
// * ---------------------------------------------------------------------------------------
    doRename:
#ifndef __CROSS__
    renrc = rename(sFileNameOld,sFileNameNew);
#else
    renrc=0;
#endif
// * ---------------------------------------------------------------------------------------
// * Clean up and exit
// * ---------------------------------------------------------------------------------------
    leave:
    if (dbg==1) {
        printf("Rename from %s\n",sFileNameOld);
        printf("         To %s\n",sFileNameNew);
        printf("         RC %i\n",renrc);
    }
    LFREESTR(oldDSN);
    LFREESTR(oldMember);
    LFREESTR(newDSN);
    LFREESTR(newMember);
    Licpy(ARGR,renrc);
}

/* -------------------------------------------------------------------------------------
 * DYNFREE  ddname
 * -------------------------------------------------------------------------------------
 */
void R_free(__unused int func)
{
    int iErr=0,dbg=0;
    __dyn_t dyn_parms;

    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    get_s(1)

#ifndef __CROSS__
    Lupper(ARG_OWN(1));
#endif

    dyninit(&dyn_parms);
    dyn_parms.__ddname = (char *) LSTR(*ARG1);

    iErr = dynfree(&dyn_parms);
    if (dbg==1) {
        printf("FREE DD %s\n",LSTR(*ARG1));
        printf("     RC %i\n",iErr);
    }

    Licpy(ARGR, iErr);
}

/* -------------------------------------------------------------------------------------
 * DYNALLOC ddname DSN SHR
 * -------------------------------------------------------------------------------------
 */
void R_allocate(__unused int func) {
    int iErr = 0, dbg = 0;
    char sFileName[55];
    Lstr DSN, Member;
    __dyn_t dyn_parms;
    if (ARGN < 2 || ARGN > 3) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)
    if (ARGN == 3) {
        LASCIIZ(*ARG3)
        Lupper(ARG_OWN(3));
    }
#ifndef __CROSS__
    Lupper(ARG_OWN(1));
    Lupper(ARG_OWN(2));
#endif
    dyninit(&dyn_parms);
    dyn_parms.__ddname = (char *) LSTR(*ARG1);
    // free DDNAME, just in case it's allocated
    iErr = dynfree(&dyn_parms);

    if (strcmp((const char *) ARG2->pstr, "DUMMY") == 0) {
        dyn_parms.__misc_flags = __DUMMY_DSN;
        iErr = dynalloc(&dyn_parms);
    } else if (strcmp((const char *) ARG2->pstr, "INTRDR") == 0) {
        dyn_parms.__sysout = 'A';
        dyn_parms.__sysoutname = (char *) LSTR(*ARG2);
        dyn_parms.__lrecl = 80;
        dyn_parms.__blksize = 80;
        dyn_parms.__recfm = _F_;
        dyn_parms.__misc_flags = __PERM;
        iErr = dynalloc(&dyn_parms);
    } else if(strncmp((const char *) ARG2->pstr, "##", strlen("##")) == 0) {

        char * varName = (char *) LSTR(*ARG2) + 2;

        dyn_parms.__recfm = _FB_;
        dyn_parms.__lrecl = 255;
        dyn_parms.__blksize = 255;
        dyn_parms.__alcunit = __TRK;
        dyn_parms.__primary = 5;
        dyn_parms.__secondary = 6;
        dyn_parms.__unit = "VIO";
        dyn_parms.__status = __DISP_NEW & __DISP_DELETE;

        iErr = dynalloc(&dyn_parms);

        setVariable(varName, dyn_parms.__retdsn);
    } else if(strncmp((const char *) ARG2->pstr, "&&", strlen("&&")) == 0) {

        char * varName = (char *) LSTR(*ARG2) + 2;

        dyn_parms.__recfm = _FB_;
        dyn_parms.__lrecl = 80;
        dyn_parms.__blksize = 80;
        dyn_parms.__alcunit = __TRK;
        dyn_parms.__primary = 5;
        dyn_parms.__secondary = 6;
        dyn_parms.__unit = "VIO";
        dyn_parms.__status = __DISP_NEW & __DISP_DELETE;

        iErr = dynalloc(&dyn_parms);

        setVariable(varName, dyn_parms.__retdsn);
    } else {
        splitDSN(&DSN, &Member, ARG2);
        iErr = getDatasetName(environment, (const char *) LSTR(DSN), sFileName);
        if (iErr == 0) {
            dyn_parms.__dsname = (char *) sFileName;
            if (LLEN(Member)>0) dyn_parms.__member = (char *) LSTR(Member);
            if (ARGN==3 && strcasecmp(LSTR(*ARG3),"MOD") == 0) dyn_parms.__status = __DISP_MOD;
            else dyn_parms.__status = __DISP_SHR;
            iErr = dynalloc(&dyn_parms);
            if (dbg==1) {
                printf("ALLOC DD %s\n",LSTR(*ARG1));
                printf("     DSN %s\n",sFileName);
                if (LLEN(Member)>0)  printf("  Member %s\n",LSTR(Member));
                printf("      RC %i\n",iErr);
            }
        }
        LFREESTR(DSN);
        LFREESTR(Member);
    }
    Licpy(ARGR,iErr);

}

/* -------------------------------------------------------------------------------------
 * CREATE new Dataset
 * -------------------------------------------------------------------------------------
 */
void R_create(__unused int func) {
    int  iErr;
    char sFileName[DSN_NAME_MAX + 1];

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)

#ifndef __CROSS__
    Lupper(ARG_OWN(1));
#endif
    /* the allocation information in ARG2 is applied again, as JCC's fopen
     * did: dynamic allocation with DCB and space (#299). 0 created, -1 it
     * cannot be (also a bad ARG2), -2 cataloged already. */
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    if (iErr == 0)
        iErr = rxCreateDsn(sFileName, (const char *) LSTR(*ARG2));
    else
        iErr = -1;

    Licpy(ARGR,iErr);
}

/* -------------------------------------------------------------------------------------
 * EXISTS does Dataset exist
 * -------------------------------------------------------------------------------------
 */
void R_exists(__unused int func) {
    int iErr = 0;
    char sFileName[55];
    FILE *fk; // file handle

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    get_s(1)
#ifndef __CROSS__
    Lupper(ARG_OWN(1));
#endif
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    if (iErr == 0) {
        fk = rxOpenDsn(sFileName, "rb");
        if (fk != NULL) { // File already defined, error
            FCLOSE(fk);
            iErr = 1;
        } else iErr=0;
    }
    Licpy(ARGR,iErr);
}

/* -------------------------------------------------------------------------------------
 * Load and execute external REXX qualified with dsname
 * -------------------------------------------------------------------------------------
 */
void R_exec(__unused int func) {

}

/* -------------------------------------------------------------------------------------
 * __SREAD and __SWRITE: a data set into a string array and back (the string
 * array functions themselves are in rxsarray.c, #302)
 * -------------------------------------------------------------------------------------
 */
void R_sread(__unused int func) {
    int sname,recs=0,ssize,ii,skip;
    long smax,off1,off2;
    FILE *fk; // file handle
    char record[16385];

    get_s(1);
    LASCIIZ(*ARG1);
    Lupper(ARG_OWN(1));
    get_oiv(2,ssize,3000);
    if (ssize<1000) ssize=1000;
    get_oiv(3,skip,0);

    R_screate(ssize);
    sname=LINT(*ARGR);
    sindex= (char **) sarray[sname];

    fk = rxOpenDd((const char *) LSTR(*ARG1), "r");
    if (fk == NULL) {
        Licpy(ARGR, -1);
        return;
    }
    off1=ftell(fk);        // begin offset
    for (;;) {
        memset(record, 0, sizeof(record));
        fgets(record, sizeof(record)-1, fk);
        if(feof(fk)) break;
        off2=ftell(fk);    // new current offset
        smax=off2-off1-1;  // this is the reclen
        off1=off2;

        for (ii = smax+1; ii>=0; ii--) {   // start behind reclen, to see if there is /n
            if (record[ii]=='\n') {
                record[ii] = '\0';
                break;
            }
        }
     // clear unwanted x'00' in string
        for (ii = 0; ii < smax; ii++) {
            if (record[ii]=='\n') record[ii]=' ';
            else if(record[ii]=='\0') record[ii]=' ';
        }
     // skip trailing blanks
        for (ii = smax; ii >= 0; ii--) {
            if (record[ii] == ' ') record[ii] = '\0';
            else if (record[ii] == '\0') ;
            else break;
        }
        if(skip==1) if (ii <= 0 || record[0] == '\0' || record[1] == '\0') continue;
        if (recs>sindxhi[sname]) {
            if (ssize<8192) ssize=ssize*2;
            else ssize=ssize+2000;
            sarray[sname] = REALLOC((void *) sarray[sname], ssize * sizeof(char *));
            sindex= (char **) sarray[sname];
            sindxhi[sname]=ssize;
        } // else printf("fits in %d %s\n",recs,record);
        snew(recs, record, 0);
        recs++;    // record count starts with position 0
    }
    fclose(fk);
    sindxhi[sname]=recs+50;
    sarrayhi[sname]=recs;
   // sarray[sname] = REALLOC((void *) sarray[sname], sindxhi[sname] * sizeof(char *));
    setIntegerVariable("sarrayhi", sarrayhi[sname]);
    setIntegerVariable("sarraymax",sindxhi[sname]);

    Licpy(ARGR,sname);
}

void R_swrite(__unused int func) {
    int sname, ii;
    char sNumber[6];
    FILE *fk; // file handle

    get_i0(1, sname);
    sindex = (char **) sarray[sname];

    get_s(2);
    LASCIIZ(*ARG2);
    Lupper(ARG_OWN(2));
    /* SWRITE passes a DD name; it used to inherit whatever _style DIR()
     * or LOCATE() had left behind (#299) */
    fk = rxOpenDd((const char *) LSTR(*ARG2), "w");
    if (fk == NULL) Licpy(ARGR, -1);
    else {
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            fputs(sstring(ii), fk);
            if (fputs("\n", fk)<0) {
                sprintf(sNumber,"%06d", ii+1);
                Lfailure ("Write Error at Record:", sNumber, "check Dataset size", "", "");
            }
        }
        fclose(fk);
        Licpy(ARGR, (long) sarrayhi[sname]);
    }
}

#define subline(string) {sprintf(pbuff, "%s\n", string);   \
                         fputs(pbuff, ftout);              \
                         if (debug>0){                     \
                            printf("SUBMIT %s\n",string);  \
                            printf("HEX    ");             \
                            for (j=0;j<80;j++)   {         \
                                if (pbuff[j]==0) break;    \
                                if (j>0 && j%30==0) printf("\n       "); \
                                printf("%x ",pbuff[j]);     \
                            } \
                            printf("\n");} \
                         }

/* -----------------------------------------------------------------------------------
 * SUBMIT(DSN) SUBMIT(")STEM stemname.")
 *   rc :  -1  INTRDR can't be allocated
 *   rc :  -2  INTRDR can't be opened
 *   rc :  -3  JCL DSN can't be allocated or opened
 *   rc :  -4  STEM.0 is not set or not numeric
 * -----------------------------------------------------------------------------------
 */
void R_submit(__unused int func) {
    int iErr = 0, ii, j,recs,sname,llname,mode=-1,debug=0;
    char sFileName[55];
    char pbuff[81];

    __dyn_t dyn_parms;
    PLstr plsValue;
    FILE *ftin = NULL, *ftout = NULL;

    LASCIIZ(*ARG1)
    get_s(1)
    Lupper(ARG_OWN(1));
    if (LSTR(*ARG1)[LLEN(*ARG1) - 1] == '.') mode = 1;
    else if (LSTR(*ARG1)[0] == '*')          mode = 3;
    else if (strstr(LSTR(*ARG1), "SARRAY") != 0) mode = 4;
    else if (strstr(LSTR(*ARG1), "LLIST") != 0)  mode = 5;
    else mode = 0;
    get_oiv(3,debug,0);
/*--------------------------------------------------------
 * 1. Allocate internal Reader and open it
 * -----------------------------------------------------------------------------------
 */
    dyninit(&dyn_parms);   // init DYNALLOC

    //   dyn_parms.__ddname = (char *) "SUBINT";
    //   free DDNAME, just in case it's allocated
    iErr = dynfree(&dyn_parms);
    // Allocate INTRDR
    dyn_parms.__sysout = 'A';
    dyn_parms.__sysoutname = (char *) "INTRDR";
    dyn_parms.__lrecl = 80;
    dyn_parms.__blksize = 80;
    dyn_parms.__recfm = _F_;
    dyn_parms.__misc_flags = __CLOSE;
    iErr = dynalloc(&dyn_parms);
    if (iErr != 0) iError(-1,cleanup)
    else {
        //     printf("PEJ> %s\n", dyn_parms.__retddn);
        ftout = rxOpenDd(dyn_parms.__retddn, "w");
        if (ftout == NULL) iError(-2,cleanup)
    }
/* -----------------------------------------------------------------------------------
 * 2. OPEN JCL DSN
 * -----------------------------------------------------------------------------------
 */
    if (mode == 1)      goto writeStem;    // mode 1: is stem
    else if (mode == 3) goto writeQueue;   // mode 3: is queue
    else if (mode == 4) goto writeSarray;  // mode 4: is SARRAY
    else if (mode == 5) goto writeLList;   // mode 5: is Linked List
    else if (mode == 0) {                  // mode 0: is DSN
        getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
        ftin = rxOpenDsn(sFileName, "r");
        if (ftin != NULL) goto writeDSN;
        iError(-3,cleanup)
    }
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.1 WRITE STEM to INTRDR
 * -----------------------------------------------------------------------------------
 */
    writeStem:
    LPMALLOC(plsValue)

    recs = getStemV0(LSTR(*ARG1));
    if (recs==0) iErr=-4;
    else {
        for (ii = 1; ii <= recs; ii++) {
            getStemV(plsValue, LSTR(*ARG1), ii);
            subline(LSTR(*plsValue))
        }
    }
    LPFREE(plsValue);
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.2 WRITE JCL to INTRDR
 * -----------------------------------------------------------------------------------
 */
    writeDSN:
    while (fgets(pbuff, 80, ftin)) {
        fputs(pbuff, ftout);
    }
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.3 WRITE JCL from Queue
 * -----------------------------------------------------------------------------------
 */
    writeQueue:
    recs =  StackQueued();
    //  printf("QUEUE recs %d \n",recs);
    for (ii = 1; ii <= recs; ii++) {
        plsValue=PullFromStack();
        subline(LSTR(*plsValue))
        LPFREE(plsValue);
    }
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.4 WRITE SARRAY to INTRDR
 * -----------------------------------------------------------------------------------
 */
   writeSarray:
    get_i0(2,sname);
    recs = sarrayhi[sname];

    sindex= (char **) sarray[sname];

    if (recs<=0) iErr=-4;
    else {
        for (ii = 0; ii < recs; ii++) {
            subline(sstring(ii));
        }
    }
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.5 WRITE Linked List to INTRDR
 * -----------------------------------------------------------------------------------
 */
   writeLList:
    {   struct node *current;
        get_i0(2, llname);
        current = (struct node *) llist[llname]->next;
        while (current != NULL) {
            subline(current->data);
            current = (struct node *) current->next;
        }
        goto cleanup;
    }
    /* -----------------------------------------------------------------------------------
    * 4 CLEANUP end end
    * -----------------------------------------------------------------------------------
    */
    cleanup:
    if (ftin  !=0 ) fclose(ftin);
    if (ftout !=0 ) fclose(ftout);
    //  dynfree(&dyn_parms);
    Licpy(ARGR,iErr);
    return;
/* end of SUBMIT Procedure */
}

/* split str at blanks into at most max words; a word past max is
 * dropped instead of written behind the array (#170) */
void parseArgs(char **array, int max, char *str)
{
    int i = 0;
    char *p = strtok (str, " ");
    while (p != NULL && i < max)
    {
        array[i++] = p;
        p = strtok (NULL, " ");
    }
}

int parseDCB(FILE *pFile)
{
    char           sLrecl[6];
    char           sBlkSize[6];
    RX_FILEINFO    info;
    RX_DSATTR      dsattr;
    unsigned char  dsorg;
    unsigned char  recfm;
    unsigned short lrecl;
    unsigned short blksize;
    int po=0;

    if (rxFileInfo(pFile, &info) != 0)
        return 0;

    /* DSN */
    if (info.dsn[0] != '\0')
        setVariable("SYSDSNAME", info.dsn);

    /* DDN */
    if (info.ddn[0] != '\0')
        setVariable("SYSDDNAME", info.ddn);

    /* MEMBER */
    if (info.member[0] != '\0') {
        setVariable("SYSMEMBER", info.member);
        po=1;
    }

    /* the DCB as opened; DSORG guessed from the member name */
    dsorg   = info.member[0] != '\0' ? 0x02 : 0x40;    /* PO / PS */
    recfm   = info.recfm;
    lrecl   = info.lrecl;
    blksize = info.blksize;

    /* VOLSER, DSORG, RECFM, BLKSIZE and LRECL from the data set itself
     * (#299): an open of a PDS without a member shows its directory
     * (F, 256, 256), and a PDS named without a member is no PS. The
     * guess stays for what is not cataloged (a temporary data set). */
    if (info.dsn[0] != '\0' && rxDsAttr(info.dsn, &dsattr) == 0) {
        setVariable("SYSVOLUME", dsattr.volser);
        if (strcmp(dsattr.dsorg, "PO") == 0)
            dsorg = 0x02;
        else if (strcmp(dsattr.dsorg, "PS") == 0)
            dsorg = 0x40;
        else
            dsorg = 0;                  /* reported as ??? below */
        recfm   = dsattr.recfm;
        lrecl   = dsattr.lrecl;
        blksize = dsattr.blksize;
    }

    /* DSORG */
    if(dsorg == 0x40)
        setVariable("SYSDSORG", "PS");
    else if (dsorg == 0x02) {
        setVariable("SYSDSORG", "PO");
        po++;    // set po=2 to distinguish a DSN addressed with member name
    }
    else
        setVariable("SYSDSORG", "???");

    /* RECFM */
    if(recfm == 0x40)
        setVariable("SYSRECFM", "V");
    else if(recfm == 0x50)
        setVariable("SYSRECFM", "VB");
    else if(recfm == 0x54)
        setVariable("SYSRECFM", "VBA");
    else if(recfm == 0x52)
        setVariable("SYSRECFM", "VBM");
    else if(recfm == 0x80)
        setVariable("SYSRECFM", "F");
    else if(recfm == 0x90)
        setVariable("SYSRECFM", "FB");
    else if(recfm == 0x92)
        setVariable("SYSRECFM", "FBM");
    else if(recfm == 0xC0)
        setVariable("SYSRECFM", "U");
    else
        setVariable("SYSRECFM", "??????");
    /* BLKSIZE */
    snprintf(sBlkSize, sizeof(sBlkSize), "%u", (unsigned) blksize);
    setVariable("SYSBLKSIZE", sBlkSize);

    /* LRECL */
    snprintf(sLrecl, sizeof(sLrecl), "%u", (unsigned) lrecl);
    setVariable("SYSLRECL", sLrecl);

    if(recfm == 0x80 || recfm == 0x90) po=po+10;  // RECFM=F or FB

    return po;
}

void RxDsnRegFunctions()
{
    RxRegFunction("FREE",       R_free,         0);
    RxRegFunction("ALLOCATE",   R_allocate,     0);
    RxRegFunction("CREATE",     R_create,       0);
    RxRegFunction("EXISTS",     R_exists,       0);
    RxRegFunction("RENAME",     R_renamedsn,    0);
    RxRegFunction("REMOVE",     R_removedsn,    0);
    RxRegFunction("LISTDSI",    R_listdsi,      0);
    RxRegFunction("LISTDSIQ",   R_listdsiq,     0);
    RxRegFunction("SYSDSN",     R_sysdsn,       0);
    RxRegFunction("BLDL",       R_bldl,         0);
    RxRegFunction("EXEC",       R_exec,         0);
    RxRegFunction("__SREAD",    R_sread,        0);
    RxRegFunction("__SWRITE",   R_swrite,       0);
    RxRegFunction("DIR",        R_dir,          0);
    RxRegFunction("LOCATE",     R_locate,       0);
    RxRegFunction("SUBMIT",     R_submit,       0);
} /* RxDsnRegFunctions() */
