#ifndef __SMF_H
#define __SMF_H

#include "lstring.h"

#define SMF_TYPE_242    242

typedef struct smf_record_header {                                // offset/len/  offset+1
    short int      reclen;        // Record Length                   0      2      1
    short int      segdesc;       // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;     // System indicator flags          4      1      5
    unsigned char  rectype;       // Record type: 42 (X'2A')         5      1      6
    unsigned char  time[4];       // Time in hundredths of a second  6      4      7
    unsigned char  dtepref;       // date prefix 1: date >=2000      10     1     11
    unsigned char  date[3];       // Date record written (by SMF)    11     3     12
    unsigned char  sysid[4];      // System identification (by SMF)  14     4     15
    unsigned char  data[128];     // User data                       18   128     19
} SMF_RECORD, *P_SMF_RECORD;

typedef struct smf242_record {
    short int      reclen;        // Record Length                   0      2      1
    short int      segdesc;       // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;     // System indicator flags          4      1      5
    unsigned char  rectype;       // Record type: 42 (X'2A')         5      1      6
    unsigned char  time[4];       // Time in hundredths of a second  6      4      7
    unsigned char  dtepref;       // date prefix 1: date >=2000      10     1     11
    unsigned char  date[3];       // Date record written (by SMF)    11     3     12
    unsigned char  sysid[4];      // System identification (by SMF)  14     4     15
    unsigned char  user[8] ;      // Current user identification
    unsigned char  runid[4];      // Kind of session identification
    unsigned char  type[7];       // <START> or <END>
    unsigned char  retcode[4];    // Return code on <END>
    unsigned char  exec[54] ;     // file name
} SMF_242_RECORD, *P_SMF_242_RECORD;

int  writeUserSmfRecord(P_SMF_RECORD smfRecord);
void write242Record(int runId, PLstr filename, const char type[7], int returnCode);
void setSmfSid(P_SMF_RECORD smfRecord);
void setSmfTime(P_SMF_RECORD smfRecord);
void setSmfDate(P_SMF_RECORD smfRecord);
void setSmfRunId(P_SMF_242_RECORD smf242Record, int runId);

#endif //__SMF_H
