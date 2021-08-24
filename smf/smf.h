#ifndef __SMF_H
#define __SMF_H

#include "lstring.h"

#define SMF_TYPE_242        242
#define SMF_TYPE_242_START  1
#define SMF_TYPE_242_LOAD   2
#define SMF_TYPE_242_TERM   10

typedef struct smf_record_base_header {    //                                 offset/len/   offset+1
    // base header
    short int      reclen;                 // Record Length                   0      2      1
    short int      segdesc;                // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;              // System indicator flags          4      1      5
    unsigned char  rectype;                // Record type: 242 (X'2A')        5      1      6
    unsigned char  time[4];                // Time in hundredths of a second  6      4      7
    unsigned char  dtepref;                // date prefix 1: date >=2000      10     1     11
    unsigned char  date[3];                // Date record written (by SMF)    11     3     12
    unsigned char  sysid[4];               // System identification (by SMF)  14     4     15
} SMF_RECORD_BASE_HEADER, *P_SMF_RECORD_BASE_HEADER;

typedef struct smf_user_record {           //                                 offset/len/   offset+1
    // base header
    short int      reclen;                 // Record Length                   0      2      1
    short int      segdesc;                // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;              // System indicator flags          4      1      5
    unsigned char  rectype;                // Record type: 242 (X'2A')        5      1      6
    unsigned char  time[4];                // Time in hundredths of a second  6      4      7
    unsigned char  dtepref;                // date prefix 1: date >=2000      10     1     11
    unsigned char  date[3];                // Date record written (by SMF)    11     3     12
    unsigned char  sysid[4];               // System identification (by SMF)  14     4     15
    // data
    unsigned char  data[128];              // User data                       18   128     19
} SMF_RECORD, *P_SMF_RECORD;

typedef struct smf242_start_record {       //                                 offset/len/   o+1/   o-4
    // base header
    short int      reclen;                 // Record Length                   0      2      1
    short int      segdesc;                // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;              // System indicator flags          4      1      5      1
    unsigned char  rectype;                // Record type: 242 (X'2A')        5      1      6      2
    unsigned char  time[4];                // Time in hundredths of a second  6      4      7      3
    unsigned char  dtepref;                // date prefix 1: date >=2000      10     1     11      7
    unsigned char  date[3];                // Date record written (by SMF)    11     3     12      8
    unsigned char  sysid[4];               // System identification (by SMF)  14     4     15     11
    // header with record subtype
    unsigned char  ssi[4];                 // Subsystem identification        18     4     19     15
    short int      subrectype;             // Record subtype                  22     2     23     19
    // brexx header
    unsigned char  user[8] ;               // Current user identification     24     8     25     21
    unsigned char  runid[4];               // Kind of session identification  32     4     33     29
    // data
    unsigned char  dsname[54];             // dataset name                    36    54     37     33
    unsigned char  args[80];               // dataset name                    90    80     91     87

} SMF_242_START_RECORD, *P_SMF_242_START_RECORD;

typedef struct smf242_load_record {        //                                 offset/len/   o+1/   o-4
    // base header
    short int      reclen;                 // Record Length                   0      2      1
    short int      segdesc;                // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;              // System indicator flags          4      1      5      1
    unsigned char  rectype;                // Record type: 242 (X'2A')        5      1      6      2
    unsigned char  time[4];                // Time in hundredths of a second  6      4      7      3
    unsigned char  dtepref;                // date prefix 1: date >=2000      10     1     11      7
    unsigned char  date[3];                // Date record written (by SMF)    11     3     12      8
    unsigned char  sysid[4];               // System identification (by SMF)  14     4     15     11
    // header with record subtype
    unsigned char  ssi[4];                 // Subsystem identification        18     4     19     15
    short int      subrectype;             // Record subtype                  22     2     23     19
    // brexx header
    unsigned char  user[8] ;               // Current user identification     24     8     25     21
    unsigned char  runid[4];               // Kind of session identification  32     4     33     29
    // data
    unsigned char  exec[54] ;              // file name                       36    54     37     33
} SMF_242_LOAD_RECORD, *P_SMF_242_LOAD_RECORD;

typedef struct smf242_term_record {        //                                 offset/len/   o+1/   o-4
    // base header
    short int      reclen;                 // Record Length                   0      2      1
    short int      segdesc;                // Segment Descriptor (RDW) -- 0   2      2      3
    unsigned char  sysiflags;              // System indicator flags          4      1      5      1
    unsigned char  rectype;                // Record type: 242 (X'2A')        5      1      6      2
    unsigned char  time[4];                // Time in hundredths of a second  6      4      7      3
    unsigned char  dtepref;                // date prefix 1: date >=2000      10     1     11      7
    unsigned char  date[3];                // Date record written (by SMF)    11     3     12      8
    unsigned char  sysid[4];               // System identification (by SMF)  14     4     15     11
    // header with record subtype
    unsigned char  ssi[4];                 // Subsystem identification        18     4     19     15
    short int      subrectype;             // Record subtype                  22     2     23     19
    // brexx header
    unsigned char  user[8] ;               // Current user identification     24     8     25     21
    unsigned char  runid[4];               // Kind of session identification  32     4     33     29
    // data
    short int      retcode;                // Return code on termination      36     2     37     33
    unsigned char  abendcode[5];           // Return code on termination      38     5     39     35
} SMF_242_TERM_RECORD, *P_SMF_242_TERM_RECORD;

int  writeUserSmfRecord(P_SMF_RECORD smfRecord);
void writeStartRecord(unsigned int runId, unsigned char *fileName, unsigned char *args);
void writeLoadRecord(unsigned int runId, PLstr filename, const char type[7], unsigned int retcode, const char *abendcode);
void writeTermRecord(unsigned int runId, int retcode, const char *abendcode);
void setSmfSid(P_SMF_RECORD_BASE_HEADER smfHeader);
void setSmfTime(P_SMF_RECORD_BASE_HEADER smfHeader);
void setSmfDate(P_SMF_RECORD_BASE_HEADER smfHeader);

#endif //__SMF_H
