#ifndef __NETDATA_H
#define __NETDATA_H

#include <stdio.h>

#ifndef BYTE
#   define BYTE unsigned char
#endif

#ifndef TRUE
#   define TRUE  1
#   define FALSE 0
#endif

typedef enum {
    VSAM,
    PO,
    PS,
    UNKNOWN_DOSORG
} ND_DSORG;

typedef enum {
    F,
    FB,
    V,
    VB,
    U,
    VS,
    VBS,
    VBSSHORT,
    UNKNOWN_RECFM
} ND_RECFM;

typedef enum {
    INMR01,
    INMR02,
    INMR03,
    INMR04,
    INMR06,
    INMR07,
    UNKNOWN_CTRL_REC_FORMAT
} ND_CTRL_RECORD_FORMAT;

typedef struct {
    char            year    [4];
    char            month   [2];
    char            day     [2];
    char            hour    [2];
    char            minute  [2];
    char            second  [2];
} ND_DATE_TIME, *P_ND_DATE_TIME;

/* INMR01 */
typedef struct {
    /* mandatory fields*/
    char            INMFNODE      [8];  /* Origin node name                             */
    ND_DATE_TIME    INMFTIME         ;  /* Origin timestamp                             */
    char            INMFUID       [8];  /* Origin user ID                               */
    unsigned int    INMLRECL         ;  /* Length of physical control record segments   */
    char            INMTNODE      [8];  /* Target node name                             */
    char            INMTUID       [8];  /* Target user ID                               */
    /* optional fields*/
    char            INMFACK      [64];  /* Receipt notification requested               */
    unsigned int    INMFVERS         ;  /* Origin version number                        */
    unsigned int    INMNUMF          ;  /* Number of files in this transmission         */
    char            INMUSERP    [251];  /* User parameter string                        */
} ND_HEADER_RECORD, *P_ND_HEADER_RECORD;

/* INMR02 */
typedef struct {
    /* mandatory fields */
    ND_DSORG        INMDSORG         ;  /* File organization                            */
    unsigned int    INMLRECL         ;  /* Logical record length                        */
    ND_RECFM        INMRECFM         ;  /* Record format                                */
    unsigned int    INMSIZE          ;  /* Approximate size of file in bytes            */
    char            INMUTILN      [8];  /* Utility program name                         */
    /* optional fields */
    int             INMBLKSZ         ;  /* File block size                              */
    ND_DATE_TIME    INMCREAT         ;  /* Creation date                                */
    unsigned int    INMDIR           ;  /* Number of directory blocks                   */
    char            INMDSNAM     [44];  /* File name                                    */
    ND_DATE_TIME    INMEXPDT         ;  /* Expiration date                              */
    int             INMFFM           ;  /* Filemode number                              */
    ND_DATE_TIME    INMLCHG          ;  /* Last change date                             */
    ND_DATE_TIME    INMLREF          ;  /* Last reference date                          */
    unsigned int    INMTERM          ;  /* Mail file                                    */
    char            INMUSERP    [251];  /* User parameter string                        */
    unsigned int    INMMEMBRN        ;  /* Member name number                           */
    char            INMMEMBR[1][8]   ;  /* Member name list                             */
} ND_FILE_UTIL_CTRL_RECORD, *P_ND_FILE_UTIL_CTRL_RECORD;

/* INMR03 */
typedef struct {
    /* mandatory fields */
    ND_DSORG        INMDSORG         ;  /* File organization                            */
    unsigned int    INMLRECL         ;  /* Logical record length                        */
    ND_RECFM        INMRECFM         ;  /* Record format                                */
    unsigned int    INMSIZE          ;  /* Approximate size of file in bytes            */
} ND_DATA_CTRL_RECORD, *P_ND_DATA_CTRL_RECORD;

typedef struct {
    unsigned int    length;
    short           first;
    short           last;
    BYTE            data[253];
} ND_DATA_RECORD, *P_ND_DATA_RECORD;

typedef struct {
    short           length;
    BYTE            data[1];
} ND_TEXT_UNIT_VALUE, *P_ND_TEXT_UNIT_VALUE;

typedef struct {
    unsigned short  key;
    unsigned short  number;
    ND_TEXT_UNIT_VALUE value;
} ND_TEXT_UNIT, *P_ND_TEXT_UNIT;

typedef struct {
    BYTE            identifier[6];
    BYTE            data[247];
} ND_CTRL_RECORD, *P_ND_CTRL_RECORD;

typedef struct {
    BYTE            length;
    BYTE            flags;
    BYTE            data[253];
} ND_SEGMENT, *P_ND_SEGMENT;

/* SEGMENT DESCRIPTOR FLAGS                                             */
#define ND_FIRST_SEGMENT    0x80u /* 1000                               */
#define ND_LAST_SEGMENT     0x40u /* 0100                               */
#define ND_CONTROL_RECORD   0x20u /* 0010                               */
#define ND_RECORD_NUMBER    0x10u /* 0001                               */

/* KEYS FOR NETWORK USER IDENTIFICATION (INMR01 RECORD)                 */
#define ND_INMTNODE         0x1001 /* TARGET NODE NAME                  */
#define ND_INMTUID          0x1002 /* TARGET USERID                     */
#define ND_INMFNODE         0x1011 /* ORIGIN NODE NAME                  */
#define ND_INMFUID          0x1012 /* ORIGIN NODE NAME                  */
#define ND_INMFVERS         0x1023 /* ORIGIN VERSION NUMBER             */
#define ND_INMFTIME         0x1024 /* ORIGIN TIME STAMP                 */
#define ND_INMTTIME         0x1025 /* DESTINATION TIME STAMP            */
#define ND_INMNUMF          0x102F /* # OF FILES IN TRANSMISSION        */

/* KEYS FOR GENERAL CONTROL                                             */
#define ND_INMFACK          0x1026 /* ACKNOWLEDGEMENT REQUEST           */
#define ND_INMERRCD         0x1027 /* RECEIVE ERROR CODE                */
#define ND_INMUTILN         0x1028 /* NAME OF UTILITY PROGRAM           */
#define ND_INMUSERP         0x1029 /* USER PARAMETER STRING             */
#define ND_INMRECCT         0x102A /* TRANSMITTED RECORD COUNT          */

/* KEYS FOR DATASET IDENTIFICATION (INMR02,INMR03 RECORDS)              */
#define ND_INMDDNAM         0x0001 /* DDNAME FOR FILE                   */
#define ND_INMDSNAM         0x0002 /* DATASET NAME FOR FILE             */
#define ND_INMMEMBR         0x0003 /* TRANSMITTED MEMBER LIST           */
#define ND_INMSECND         0x000B /* SECONDARY SPACE QUANTITY          */
#define ND_INMDIR           0x000C /* DIRECTORY SPACE QUANTITY          */
#define ND_INMEXPDT         0x0022 /* EXPIRATION DATE                   */
#define ND_INMTERM          0x0028 /* TERMINAL ALLOCATION               */
#define ND_INMBLKSZ         0x0030 /* BLOCKSIZE                         */
#define ND_INMDSORG         0x003C /* DATA SET ORGANIZATION             */
#define ND_INMLRECL         0x0042 /* LOGICAL RECORD  LENGTH            */
#define ND_INMRECFM         0x0049 /* RECORD FORMAT                     */
#define ND_INMLREF          0x1020 /* LAST REFERENCE DATE               */
#define ND_INMLCHG          0x1021 /* LAST CHANGE DATE                  */
#define ND_INMCREAT         0x1022 /* CREATION DATE                     */
#define ND_INMSIZE          0x102C /* FILE SIZE IN BYTES                */
#define ND_INMFFM           0x102D /* FILE MODE NUMBER                  */
#define ND_INMTYPE          0x8012 /* DATA SET TYPE                     */

#define ND_DSORG_VSAM       0x0008u /* VSAM                              */
#define ND_DSORG_PO         0x0200u /* partitioned organisation          */
#define ND_DSORG_PS         0x4000u /* physical sequential               */

#define ND_RECFM_VBSSHORT   0x0001u /* Shortened VBS format used for transmission records    */
#define ND_RECFM_VAR_LEN    0x0002u /* Varying length records without the 4-byte header      */
#define ND_RECFM_PACKED     0x0004u /* Packed file (multiple blanks removed)                 */
#define ND_RECFM_COMP       0x0008u /* Compressed File (Huffman encoded                      */
#define ND_RECFM_MP         0x0200u /* Data includes machine code printer control characters */
#define ND_RECFM_AP         0x0400u /* Data contains ASA printer control characters          */
#define ND_RECFM_FS         0x0800u /* Standard fixed records or spanned variable records    */
#define ND_RECFM_B          0x1000u /* Blocked records                                       */
#define ND_RECFM_TO_VA      0x2000u /* Track overflow or variable ASCII records              */
#define ND_RECFM_V          0x4000u /* Variable length records                               */
#define ND_RECFM_F          0x8000u /* Fixed length records                                  */
#define ND_RECFM_U          0xC000u /* Undefined records.                                    */

int readSegment(FILE *pFile, P_ND_SEGMENT pSegment);
int isControlRecord(P_ND_SEGMENT pSegment);
int isDataRecord(P_ND_SEGMENT pSegment);
ND_CTRL_RECORD_FORMAT getControlRecordFormat(P_ND_SEGMENT pSegment);
int getHeaderRecord(P_ND_SEGMENT pSegment, P_ND_HEADER_RECORD pHeaderRecord);
int getFileUtilCtrlRecord(P_ND_SEGMENT pSegment, P_ND_FILE_UTIL_CTRL_RECORD pFileUtilCtrlRecord);
int getDataCtrlRecord(P_ND_SEGMENT pSegment, P_ND_DATA_CTRL_RECORD pDataCtrlRecord);
void getDataRecord(P_ND_SEGMENT pSegment, P_ND_DATA_RECORD pDataRecord);

#endif //__NETDATA_H
