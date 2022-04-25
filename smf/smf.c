#include <stdlib.h>
#include "smf.h"
#include "rxmvsext.h"

#ifdef JCC
# include "time.h"
#endif

#ifdef __CROSS__
# include "jccdummy.h"
#endif

//
// INTERNAL FUNCTION PROTOTYPES
//

void setDSN(P_SMF_242_LOAD_RECORD smfRecord, char *fileName);
void setDDN(P_SMF_242_LOAD_RECORD smfRecord, char *fileName);
void setMember(P_SMF_242_LOAD_RECORD smfRecord, char *fileName);
int dayOfYear(int year, int month, int day);

//
// EXPORTED FUNCTIONS
//

int writeUserSmfRecord(P_SMF_RECORD smfRecord)
{
    int rc;

    RX_SVC_PARAMS svcParams;

    // switch on authorisation
    rc = privilege(1);     // requires authorisation

    if (rc == 0) {
        svcParams.SVC = 83;
        svcParams.R0  = 0;
        svcParams.R1  = (uintptr_t) smfRecord;

        call_rxsvc(&svcParams);

        rc = (int) svcParams.R15;

        // switch off authorisation
        privilege(0);    // switch authorisation off
    }

    return rc;
}

void writeStartRecord(char *fileName, char *args)
{
    int rc;

    RX_SVC_PARAMS svcParams;
    SMF_242_START_RECORD smfRecord;

    char sRundId[4 + 1];

    sprintf(sRundId, "%04d", getRunId());

    bzero(&smfRecord, sizeof(SMF_242_START_RECORD));

    // setting SMF base header fields
    smfRecord.reclen     = sizeof(SMF_242_START_RECORD);
    smfRecord.segdesc    = 0;
    smfRecord.sysiflags  = 2;
    smfRecord.rectype    = SMF_TYPE_242;
    smfRecord.subrectype = SMF_TYPE_242_START;

    // setting time and date
    setSmfTime((P_SMF_RECORD_BASE_HEADER) &smfRecord);
    setSmfDate((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting system id
    setSmfSid((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting SMF extended header fields
    memset(&smfRecord.ssi, ' ', sizeof (smfRecord.ssi));
    memcpy(&smfRecord.ssi, "BRX", 3);

    // setting SMF brexx header fields
    memset(&smfRecord.user, ' ', sizeof(smfRecord.user));
    memcpy(&smfRecord.user,  getlogin(), strlen(getlogin()));
    memcpy(&smfRecord.runid, sRundId, 4);

    // setting subrecord 1 data fields fileName / args
    memset(&smfRecord.dsname, ' ', sizeof(smfRecord.dsname));
    if (fileName != NULL) {
        memcpy(&smfRecord.dsname, fileName, strlen((const char *) fileName));
    }

    memset(&smfRecord.args, ' ', sizeof(smfRecord.args));
    if (args != NULL) {
        memcpy(&smfRecord.args, args, strlen((const char *) args));
    }

    // switch on authorisation
    rc = privilege(1);     // requires authorisation

    if (rc == 0) {
        svcParams.SVC = 83;
        svcParams.R0  = 0;
        svcParams.R1  = (uintptr_t) &smfRecord;

        call_rxsvc(&svcParams);

        // switch off authorisation
        privilege(0);    // switch authorisation off
    }
}

void writeTermRecord(int returnCode, const char *abendCode)
{
    int rc;

    RX_SVC_PARAMS svcParams;
    SMF_242_TERM_RECORD smfRecord;

    char sRundId[4 + 1];

    sprintf(sRundId, "%04d", getRunId());

    bzero(&smfRecord, sizeof(SMF_242_TERM_RECORD));

    // setting SMF base header fields
    smfRecord.reclen     = sizeof(SMF_242_TERM_RECORD);
    smfRecord.segdesc    = 0;
    smfRecord.sysiflags  = 2;
    smfRecord.rectype    = SMF_TYPE_242;
    smfRecord.subrectype = SMF_TYPE_242_TERM;

    // setting time and date
    setSmfTime((P_SMF_RECORD_BASE_HEADER) &smfRecord);
    setSmfDate((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting system id
    setSmfSid((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting SMF extended header fields
    memset(&smfRecord.ssi, ' ', sizeof (smfRecord.ssi));
    memcpy(&smfRecord.ssi, "BRX", 3);

    // setting SMF brexx header fields
    memset(&smfRecord.user, ' ', sizeof(smfRecord.user));
    memcpy(&smfRecord.user,  getlogin(), strlen(getlogin()));
    memcpy(&smfRecord.runid, sRundId, 4);

    // setting subrecord 10 data fields retcode / abendcode
    smfRecord.retcode = (short) returnCode;

    memset(&smfRecord.abendcode, ' ', sizeof(smfRecord.abendcode));
    if (abendCode != NULL) {
        memcpy(&smfRecord.abendcode, abendCode, strlen(abendCode));
    }

    // switch on authorisation
    rc = privilege(1);     // requires authorisation

    if (rc == 0) {
        svcParams.SVC = 83;
        svcParams.R0  = 0;
        svcParams.R1  = (uintptr_t) &smfRecord;

        call_rxsvc(&svcParams);

        // switch off authorisation
        privilege(0);    // switch authorisation off
    }
}

void writeLoadRecord(char *fileName, bool isDsn, bool isLoaded)
{
    int rc;

    RX_SVC_PARAMS svcParams;
    SMF_242_LOAD_RECORD smfRecord;

    char sRundId[4 + 1];

    sprintf(sRundId, "%04d", getRunId());

    bzero(&smfRecord, sizeof(SMF_242_LOAD_RECORD));

    // setting SMF base header fields
    smfRecord.reclen     = sizeof(SMF_242_LOAD_RECORD);
    smfRecord.segdesc    = 0;
    smfRecord.sysiflags  = 2;
    smfRecord.rectype    = SMF_TYPE_242;
    smfRecord.subrectype = SMF_TYPE_242_LOAD;

    // setting time and date
    setSmfTime((P_SMF_RECORD_BASE_HEADER) &smfRecord);
    setSmfDate((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting system id
    setSmfSid((P_SMF_RECORD_BASE_HEADER) &smfRecord);

    // setting SMF extended header fields
    memset(&smfRecord.ssi, ' ', sizeof(smfRecord.ssi));
    memcpy(&smfRecord.ssi, "BRX", 3);

    // setting SMF brexx header fields
    memset(&smfRecord.user, ' ', sizeof(smfRecord.user));
    memcpy(&smfRecord.user,  getlogin(), strlen(getlogin()));
    memcpy(&smfRecord.runid, sRundId, 4);

    // setting subrecord 2 data fields dsn / ddn / member / found
    memset(&smfRecord.dsname, ' ', sizeof(smfRecord.dsname));
    memset(&smfRecord.ddname, ' ', sizeof(smfRecord.ddname));
    memset(&smfRecord.member, ' ', sizeof(smfRecord.member));
    memset(&smfRecord.found,  ' ', sizeof(smfRecord.found));

    if (isDsn) {
        setDSN(&smfRecord, fileName);
    } else {
        setDDN(&smfRecord, fileName);
    }

    setMember(&smfRecord, fileName);

    if (isLoaded) {
        memcpy(&smfRecord.found, "FOUND", 5);
    } else {
        memcpy(&smfRecord.found, "NOT FOUND", 9);
    }

    // switch on authorisation
    rc = privilege(1);     // requires authorisation

    if (rc == 0) {
        svcParams.SVC = 83;
        svcParams.R0  = 0;
        svcParams.R1  = (uintptr_t) &smfRecord;

        call_rxsvc(&svcParams);

        // switch off authorisation
        privilege(0);    // switch authorisation off
    }
}

void setSmfSid(P_SMF_RECORD_BASE_HEADER smfHeader)
{

#ifndef __CROSS__
    void ** psa;           // PSA     =>   0 / 0x00
    void ** cvt;           // FLCCVT  =>  16 / 0x10
    void ** smca;          // CVTSMCA => 196 / 0xC4
    void ** smcasid;       // SMCASID =>  16 / 0x10

    // pulling smf sysid
    psa     = 0;
    cvt     = psa[4];      //  16
    smca    = cvt[49];     // 196
    smcasid =  smca + 4;   //  16

    memcpy(smfHeader->sysid, smcasid, 4);
#else
    memcpy(smfHeader->sysid, "CRSS", 4);
#endif
}

void setSmfTime(P_SMF_RECORD_BASE_HEADER smfHeader)
{
    Lstr temp;

    // setup temporary field
    LINITSTR(temp)
    Lfx(&temp, 32);

    Ltime(&temp, '4');
    L2int(&temp);

    memcpy(smfHeader->time, &LINT(temp), 4);

    // free temporary field
    LFREESTR(temp)
}

void setSmfDate(P_SMF_RECORD_BASE_HEADER smfHeader)
{
    time_t now;
    struct tm *tmdata;

    Lstr target,source;
    int year, day;

    // setup temporary fields
    LINITSTR(source)
    Lfx(&source,32);

    LINITSTR(target)
    Lfx(&target,32);

    // calculate SMF date
    now    = time(NULL);
    tmdata = localtime(&now);
    day    = dayOfYear((int) tmdata->tm_year + 1900, (int) tmdata->tm_mon, (int) tmdata->tm_mday);
    year   = (tmdata->tm_year + 1900 - 2000) * 1000 + day;

    // converting to packed decimal
    Licpy(&source, year);
    Ld2p(&target, &source, 3 ,0) ;

    // prefix date is 1 as year>= 2000
    smfHeader->dtepref = 1;

    memcpy(smfHeader->date, LSTR(target), 3);

    // free temporary fields
    LFREESTR(source)
    LFREESTR(target)
}

void setDSN(P_SMF_242_LOAD_RECORD smfRecord, char *fileName)
{
    char *temp;
    char *dsn;

    temp = malloc(strlen(fileName) + 1);
    strcpy(temp, fileName);

    dsn = strtok(temp, "()");
    while(dsn)
    {
        if (dsn <= temp || fileName[dsn - temp - 1] != '(') {
            memcpy(&smfRecord->dsname, dsn, strlen(dsn));
            dsn = NULL;
        }
    }

    free(temp);
}

void setDDN(P_SMF_242_LOAD_RECORD smfRecord, char *fileName)
{
    char *temp;
    char *dsn;

    temp = malloc(strlen(fileName) + 1);
    strcpy(temp, fileName);

    dsn = strtok(temp, "()");
    while(dsn)
    {
        if (dsn <= temp || fileName[dsn - temp - 1] != '(') {
            memcpy(&smfRecord->ddname, dsn, strlen(dsn));
            dsn = NULL;
        }
    }

    free(temp);
}

void setMember(P_SMF_242_LOAD_RECORD smfRecord, char *fileName)
{
    char *temp;
    char *member;

    temp = malloc(strlen(fileName) + 1);
    strcpy(temp, fileName);

    member = strtok(temp, "()");
    while(member)
    {
        if (member <= temp || fileName[member - temp - 1] != '(') {
            member = strtok(NULL, "()");
        } else {
            memcpy(&smfRecord->member, member, strlen(member));
            member = NULL;
        }
    }

    free(temp);
}

//
// INTERNAL FUNCTIONS
//

int dayOfYear(int year, int month, int day)
{
    int mo[12] = {31, 28 , 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    int ii , dayyear = 0;
    if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) mo[1]=29;

    for (ii = 0; ii < month; ii++) dayyear += mo[ii];

    dayyear += day;
    return dayyear;
}
