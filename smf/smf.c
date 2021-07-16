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

int dayOfYear(int year, int month, int day);

//
// EXPORTED FUNCTIONS
//

int writeUserSmfRecord(P_SMF_RECORD smfRecord)
{
    int rc;

    RX_SVC_PARAMS svcParams;

    // switch off authorisation
    privilege(1);     // requires authorisation

    svcParams.SVC = 83;
    svcParams.R0  = 0;
    svcParams.R1  = (uintptr_t) smfRecord;

    call_rxsvc(&svcParams);

    rc = (int) svcParams.R15;

    // switch off authorisation
    privilege(0);    // switch authorisation off

    return rc;
}

void write242Record(unsigned int runId, PLstr filename, const char type[7], unsigned int retcode, const char *abendcode)
{
    RX_SVC_PARAMS svcParams;
    SMF_242_RECORD smfRecord;

    char sRundId[4 + 1];
    char sRetCode[5 + 1];

    sprintf(sRundId, "%04d", runId);
    sprintf(sRetCode, "%05d", retcode);

    // setting SMF record header
    bzero(&smfRecord, sizeof(SMF_242_RECORD));
    memset(&smfRecord.retcode, 0x43, 2);
    memset(&smfRecord.runid, 0x42, 4);

    smfRecord.reclen    = sizeof(SMF_242_RECORD);
    smfRecord.segdesc   = 0;
    smfRecord.sysiflags = 2;
    smfRecord.rectype   = SMF_TYPE_242;

    // setting time and date
    setSmfTime((P_SMF_RECORD) &smfRecord);
    setSmfDate((P_SMF_RECORD) &smfRecord);

    // setting system id
    setSmfSid((P_SMF_RECORD) &smfRecord);

    // setting remaining header fields

    memset(&smfRecord.user, ' ', sizeof(smfRecord.user));
    memcpy(&smfRecord.user,  getlogin(), strlen(getlogin()));
    memcpy(&smfRecord.runid, sRundId, 4);
    memset(&smfRecord.type, ' ', sizeof(smfRecord.type));
    memcpy(&smfRecord.type, type, strlen(type));
    memset(&smfRecord.retcode, ' ', sizeof(smfRecord.retcode));
    if (strcasecmp(SMF_START, type) != 0) {
        if (abendcode == NULL) {
            memcpy(&smfRecord.retcode, sRetCode, 5);
        } else {
            memset(&smfRecord.retcode, ' ', sizeof(smfRecord.retcode));
            memcpy(&smfRecord.retcode, abendcode, strlen(abendcode));
        }
    }
    memset(&smfRecord.exec, ' ', sizeof(smfRecord.exec));
    memcpy(&smfRecord.exec, LSTR(*filename), LLEN(*filename));

    // switch on authorisation
    privilege(1);     // requires authorisation

    svcParams.SVC = 83;
    svcParams.R0  = 0;
    svcParams.R1  = (uintptr_t) &smfRecord;

    call_rxsvc(&svcParams);

    // switch off authorisation
    privilege(0);    // switch authorisation off
}

void setSmfSid(P_SMF_RECORD smfRecord)
{
    void ** psa;           // PSA     =>   0 / 0x00
    void ** cvt;           // FLCCVT  =>  16 / 0x10
    void ** smca;          // CVTSMCA => 196 / 0xC4
    void ** smcasid;       // SMCASID =>  16 / 0x10

    // pulling smf sysid
#ifndef __CROSS__
    psa     = 0;
    cvt     = psa[4];      //  16
    smca    = cvt[49];     // 196
    smcasid =  smca + 4;   //  16

    memcpy(smfRecord->sysid, smcasid, 4);
#else
    memcpy(smfRecord->sysid, "CRSS", 4);
#endif
}

void setSmfTime(P_SMF_RECORD smfRecord)
{
    Lstr temp;

    // setup temporary field
    LINITSTR(temp)
    Lfx(&temp, 32);

    Ltime(&temp, '4');
    L2int(&temp);

    memcpy(smfRecord->time, &LINT(temp), 4);

    // free temporary field
    LFREESTR(temp)
}

void setSmfDate(P_SMF_RECORD smfRecord)
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
    smfRecord->dtepref = 1;

    memcpy(smfRecord->date, LSTR(target), 3);

    // free temporary fields
    LFREESTR(source)
    LFREESTR(target)
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
