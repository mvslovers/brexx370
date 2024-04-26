#ifndef __DYNIT_H
#define __DYNIT_H

#define MAX_NUM_TU 25

struct   __S99rbx ;
struct   __S99emparms;

typedef struct   __DYNstruct {
    char           *__ddname;     /* DDNAME */
    char           *__dsname;     /* DSNAME, dataset name  */
    char            __sysout;     /* system output dataset */
    char            __01__[7];
    char           *__sysoutname; /* program name for sysout */
    char           *__member;     /* member of a PDS */
    char            __status;     /* dataset status  */
    char            __normdisp;   /* dataset's normal disp */
    char            __conddisp;   /* dataset's cond disp */
    char            __02__[5];
    char           *__unit;       /* unit name of dataset */
    char           *__volser;     /* volume serial number */
    short           __dsorg;      /* dataset organization */
    char            __alcunit;    /* unit of space allocation */
    char            __03__[1];
    int             __primary;    /* primary space allocation */
    int             __secondary;  /* secondary space alloc'n  */
    short           __recfm;      /* the record format */
    short           __blksize;    /* the block size */
    unsigned short  __lrecl;      /* record length  */
    char            __04__[6];
    char           *__volrefds;   /* volume serial reference */
    char           *__dcbrefds;   /* dsname for DCB reference */
    char           *__dcbrefdd;   /* ddname for DCB reference */
    unsigned char   __misc_flags; /* attribute flags */
    char            __05__[7];
    char           *__password;   /* password */
    char          **__miscitems;  /* all remaining text units */
    short           __infocode;   /* SVC 99 info code  */
    short           __errcode;    /* specifies SVC 99 error code */
    int             __dirblk;     /* number of directory blks */
    int             __avgblk;     /* the average block length */
    char           *__storclass;  /* SMS storage class  */
    char           *__mgntclass;  /* SMS management class  */
    char           *__dataclass;  /* SMS data class  */
    unsigned char   __recorg;     /* Vsam dataset organization */
    char            __06__[1];
    short           __keylength;  /* Vsam key length  */
    short           __keyoffset;  /* Vsam key offset  */
    char            __07__[2];
    char           *__refdd;      /* copy attributes of ref. dd*/
    char           *__like;       /* copy attributes of like dsn */
    unsigned char   __dsntype;    /* type att. of pds or pdse */
    char            __08__[7];
    char            __09__[4];
    struct __S99rbx *  __rbx;      /* to the req. block extension */
    char            __10__[4];
    struct __S99emparms * __emsgparmlist; /* @ of error msg parms*/
} __DYNstruct, __dyn_t;

int   dyninit  (__dyn_t * dyn_parms);

#define dyninit(__dynp) \
       (\
        memset((char *)__dynp,'\0',sizeof(__dyn_t)),   \
        *((char *)__dynp+1+(2*sizeof(void *))) = 0x01, 0 \
       )

int   dynalloc (__dyn_t * dyn_parms);
int   dynfree  (__dyn_t * dyn_parms);

/* for sysout */

#define __DEF_CLASS '-'

/* ALCUNIT */
#define __CYL               '\x01'
#define __TRK               '\x02'

/* STATUS */
#define __DISP_OLD          0x01
#define __DISP_MOD          0x02
#define __DISP_NEW          0x04
#define __DISP_SHR          0x08

/* NORMDISP, CONDDISP */
#define __DISP_UNCATLG      0x01
#define __DISP_CATLG        0x02
#define __DISP_DELETE       0x04
#define __DISP_KEEP         0x08

/* DSORG */
#define __DSORG_unknown     0x0000
#define __DSORG_VSAM        0x0008
#define __DSORG_GS          0x0080
#define __DSORG_PO          0x0200
#define __DSORG_POU         0x0300
#define __DSORG_DA          0x2000
#define __DSORG_DAU         0x2100
#define __DSORG_PS          0x4000
#define __DSORG_PSU         0x4100
#define __DSORG_IS          0x8000
#define __DSORG_ISU         0x8100

/* RECFM */
#define _M_                 0x02
#define _A_                 0x04
#define _S_                 0x08
#define _B_                 0x10
#define _D_                 0x20
#define _V_                 0x40
#define _F_                 0x80
#define _U_                 0xc0
#define _FB_                0x90
#define _VB_                0x50
#define _FBS_               0x98
#define _VBS_               0x58
#define _VS_                0x48

/* MISCFLAGS */
#define __CLOSE             0x01
#define __RELEASE           0x02
#define __PERM              0x04
#define __CONTIG            0x08
#define __ROUND             0x10
#define __TERM              0x20
#define __DUMMY_DSN         0x40
#define __HOLDQ             0x80

/* VSAM TYPE */
#define __KS                0x80
#define __ES                0x40
#define __RR                0x20
#define __LS                0x10

/* PDS TYPE */
#define __DSNT_PDS          0x40

#endif //__DYNIT_H
