#ifndef __RXMVSEXT_H
#define __RXMVSEXT_H

#include "lstring.h"
#include "irx.h"

/* TODO: should be moved to rxmvs.h */
int  isTSO();
int  isTSOFG();
int  isTSOBG();
int  isEXEC();
int  isISPF();

/* real rexx control blocks */
typedef struct envblock         RX_ENVIRONMENT_BLK, *RX_ENVIRONMENT_BLK_PTR;
typedef struct parmblock        RX_PARM_BLK,        *RX_PARM_BLK_PTR;
typedef struct evalblock        RX_EVAL_BLK,        *RX_EVAL_BLK_PTR;
typedef struct execblk          RX_EXEC_BLK,        *RX_EXEC_BLK_PTR;
typedef struct instblk          RX_INST_BLK,        *RX_INST_BLK_PTR;
typedef struct workblok_ext     RX_WORK_BLK_EXT,    *RX_WORK_BLK_EXT_PTR;
typedef struct subcomtb_header  RX_SUBCMD_TABLE,    *RX_SUBCMD_TABLE_PTR;
typedef struct subcomtb_entry   RX_SUBCMD_ENTRY,    *RX_SUBCMD_ENTRY_PTR;
typedef struct irxexte          RX_IRXEXTE,         *RX_IRXEXTE_PTR;

/* internal brexx control blocks */
typedef  struct trx_env_ctx
{
    /* **************************/
    /* SYSVARS                  */
    /* **************************/

    /* User Information */
    char    SYSPREF[8];
        /* SYSPROC - */
            /* When the REXX exec is invoked in the foreground (SYSVAR('SYSENV') returns 'FORE'), SYSVAR('SYSPROC') will return the name of the current LOGON procedure.*/
            /* When the REXX exec is invoked in batch (for example, from a job submitted by using the SUBMIT command), SYSVAR('SYSPROC') will return the value 'INIT', which is the ID for the initiator. */
    char    SYSUID[8];
    /* Terminal Information */
        /* SYSLTERM - number of lines available on the terminal screen. In the background, SYSLTERM returns 0 */
        /* SYSWTERM - width of the terminal screen. In the background, SYSWTERM returns 132. */
    /* Exec Information */
    char    SYSENV[5];
    char    SYSISPF[11];
    /* System Information */
        /* SYSTERMID - the terminal ID of the terminal where the REXX exec was started. */
    /* Language Information */

    /* **************************/
    /* MVSVARS                  */
    /* **************************/

    /* **************************/
    /* FLAG FIELD               */
    /* **************************/

    unsigned char flags1;  /* allocations */
    unsigned char flags2;  /* environment */
    unsigned char flags3;  /* unused */
    unsigned char flags4;  /* unused */

    void         *literals;
    void         *variables;
    int           proc_id;
    void         *cppl;
    void         *lastLeaf;
    int           runId;      // TODO: add to asm csect
    unsigned      dummy[23];

    unsigned     *VSAMSUBT;
    unsigned      reserved[64];

} RX_ENVIRONMENT_CTX, *RX_ENVIRONMENT_CTX_PTR;

typedef struct trx_outtrap_ctx {
    Lstr varName;
    Lstr ddName;
    unsigned int maxLines;
    bool concat;
    unsigned int skipAmt;
} RX_OUTTRAP_CTX, *RX_OUTTRAP_CTX_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXINIT                                  */
/* ---------------------------------------------------------- */
typedef struct trx_init_params
{
    unsigned   *rxctxadr;
    unsigned   *wkadr;
} RX_INIT_PARAMS, *RX_INIT_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXIKJ441                                  */
/* ---------------------------------------------------------- */
typedef struct trx_ikjct441_params
{
    unsigned    ecode;
    size_t      namelen;
    char       *nameadr;
    size_t      valuelen;
    char       *valueadr;
    unsigned   *wkadr;
} RX_IKJCT441_PARAMS, *RX_IKJCT441_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXTSO                                     */
/* ---------------------------------------------------------- */
typedef struct trx_tso_params
{
    unsigned   *cppladdr;
    char       ddin[8];
    char       ddout[8];
} RX_TSO_PARAMS, *RX_TSO_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXSVC                                     */
/* ---------------------------------------------------------- */
typedef struct trx_svc_params
{
    int SVC;
    unsigned int R0;
    unsigned int R1;
    unsigned int R15;
} RX_SVC_PARAMS, *RX_SVC_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXVSAM                                    */
/* ---------------------------------------------------------- */
typedef  struct trx_vsam_params
{
    char            VSAMFUNC[8];
    unsigned char   VSAMTYPE;
    char            VSAMDDN[8];
    char            VSAMKEY[255];
    unsigned char   VSAMKEYL;
    char            VSAMMOD;
    unsigned char   ALLIGN1[2];
    unsigned       *VSAMREC;
    unsigned short  VSAMRECL;
    unsigned char   ALLIGN2[2];
    unsigned       *VSAMSUBTA;
    unsigned        VSAMRCODE;
    char            VSAMEXTRC[10];
    char            VSAMMSG[81];
    char            VSAMTRC[81];
} RX_VSAM_PARAMS, *RX_VSAM_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* assembler module RXABEND                                   */
/* ---------------------------------------------------------- */
typedef struct trx_abend_params
{
    int         ucc;
} RX_ABEND_PARAMS, *RX_ABEND_PARAMS_PTR;

/* ---------------------------------------------------------- */
/* parameters for BLDL macro                                  */
/* ---------------------------------------------------------- */
typedef struct trx_bldl_params
{
    unsigned short BLDLF;
    unsigned short BLDLL;
    char           BLDLN[8];
    unsigned char  BLDLD[68];
} RX_BLDL_PARAMS, *RX_BLDL_PARAMS_PTR;

typedef struct trx_enq_parms {
    byte flags;
    byte rname_length;
    byte params;
    byte ret;
    char *qname;
    char *rname;
} RX_ENQ_PARAMS, *RX_ENQ_PARAMS_PTR;

typedef struct trx_hostenv_params {
    char *envName;     // A(ENVIRONMENT NAME - 'ISPEXECW')
    char **cmdString;  // A(A(COMMAND STRING))
    int  *cmdLength;   // A(L(COMMAND LENGTH))
    char **userToken;  // A(A(USER TOKEN))
    int  *returnCode;  // A(RETURN CODE)
} RX_HOSTENV_PARAMS, *RX_HOSTENV_PARAMS_PTR;

typedef struct trx_dataset_user_data {
    byte vlvl;     // version level
    byte mlvl;     // modification level
    byte res1;     // reserver
    byte chgss;    // X   { SS }
    byte credt[4]; // PL4 { signed packed
    byte chgdt[4]; // PL4   julian date   }
    byte chgtm[2]; // XL2 { HHMM }
    short curr;    // number of current  records
    short init;    // number of initial  records
    short mod ;    // number of modified records
    char uid[10];
} USER_DATA, *P_USER_DATA;

void *getEnvBlock();
void setEnvBlock(void *envblk);
void getVariable(char *sName, PLstr plsValue);
int  getIntegerVariable(char *sName);
void setVariable(char *sName, char *sValue);
void setVariable2(char *sName, char *sValue, int lValue);
void setIntegerVariable(char *sName, int iValue);
int  findLoadModule(char moduleName[8]);
int  loadLoadModule(char moduleName[8], void **pAddress);
int  linkLoadModule(const char8 moduleName, void *pParmList, void *GPR0);
int  privilege(int state);
int  getRunId();

#ifdef __CROSS__
int  call_rxinit(RX_INIT_PARAMS_PTR params);
int  call_rxtso(RX_TSO_PARAMS_PTR params);
void call_rxsvc(RX_SVC_PARAMS_PTR params);
int  call_rxvsam(RX_VSAM_PARAMS_PTR params);
unsigned int call_rxikj441 (RX_IKJCT441_PARAMS_PTR params);
unsigned int call_rxabend (RX_ABEND_PARAMS_PTR params);
int systemCP(void *uptPtr, void *ectPtr, char *cmdStr, int cmdLen, char *retBuf, int retBufLen);
int cputime(void *workarea);

#else
extern int  call_rxinit(RX_INIT_PARAMS_PTR params);
extern int  call_rxtso(RX_TSO_PARAMS_PTR params);
extern void call_rxsvc(RX_SVC_PARAMS_PTR params);
extern int  call_rxvsam(RX_VSAM_PARAMS_PTR params);
extern unsigned int call_rxikj441 (RX_IKJCT441_PARAMS_PTR params);
extern unsigned int call_rxabend (RX_ABEND_PARAMS_PTR params);
extern int systemCP(void *uptPtr, void *ectPtr, char *cmdStr, int cmdLen, char *retBuf, int retBufLen);
extern int cputime(void *workarea);
#endif

/* ---------------------------------------------------------- */
/* MVS control blocks                                         */
/* ---------------------------------------------------------- */

struct psa {
    char    psastuff[548];      /* 548 bytes before ASCB ptr */
    struct  ascb *psaaold;
};

struct ascb {
    char    ascbascb[4];        /* acronym in ebcdic -ASCB- */
    char    ascbstuff[104];     /* 104 byte to the ASXB ptr */
    struct  asxb *ascbasxb;
};

struct asxb {
    char    asxbasxb[4];        /* acronym in ebcdic -ASXB- */
    char    asxbstuff[16];         /* 16 bytes to the lwa ptr */
    struct lwa *asxblwa;
};

struct lwa {
    int     lwapptr;          /* address of the logon work area */
    char    lwalwa[8];        /* ebcdic ' LWA ' */
    char    lwastuff[12];     /* 12 byte to the PSCB ptr */
    struct  pscb *lwapscb;
};

struct pscb {
    char    pscbstuff[52];        /* 52 byte before UPT ptr */
    struct  upt *pscbupt;
};

struct upt {
    char    uptstuff[16];         /* 16 byte before UPTPREFX */
    char    uptprefx[7];        /* dsname prefix */
    char    uptprefl;        /* length of dsname prefix */
};

typedef struct t_iopl {
    void *IOPLUPT;
    void *IOPLECT;
    void *IOPLECB;
    void *IOPLIOPB;
} IOPL;

typedef struct t_sdwa {
    void            *SDWAPARM;
    struct {
        struct {
            byte  _sdwacmpf;    /* -     FLAG BITS IN COMPLETION CODE.            */
            byte  _sdwacmpc[3]; /* -   SYSTEM COMPLETION CODE (FIRST 12 BITS) AND */
        } sdwaabcc;
    } sdwafiob;
    struct {
        byte  _sdwacmka;      /* -     CHANNEL INTERRUPT MASKS.                  */
        byte  _sdwamwpa;      /* -     PSW KEY AND 'M-W-P'.                      */
        byte  _sdwainta[2];   /* -   INTERRUPT CODE (LAST 2 BYTES OF INTERRUPT   */
        byte  _sdwapmka;      /* -     INSTRUCTION LENGTH CODE, CONDITION CODE,  */
        //int _sdwanxta : 24;
        byte  _sdwanxta[3];   /* -   ADDRESS OF NEXT INSTRUCTION TO BE EXECUTED. */
    } sdwactl1;
    struct {
        byte  _sdwacmkp;      /* -     CHANNEL INTERRUPT MASKS.                  */
        byte  _sdwamwpp;      /* -     PSW KEY AND 'M-W-P'.                      */
        byte  _sdwaintp[2];   /* -   INTERRUPT CODE (LAST 2 BYTES OF INTERRUPT   */
        byte  _sdwapmkp;      /* -     INSTRUCTION LENGTH CODE, CONDITION CODE,  */
        //int _sdwanxtp : 24;
        byte  _sdwanxtp[3];   /* -   ADDRESS OF NEXT INSTRUCTION TO BE EXECUTED. */
    } sdwactl2;
    struct {
        int   _sdwagr00;    /* -     GPR 0.  */
        int   _sdwagr01;    /* -     GPR 1.  */
        int   _sdwagr02;    /* -     GPR 2.  */
        int   _sdwagr03;    /* -     GPR 3.  */
        int   _sdwagr04;    /* -     GPR 4.  */
        int   _sdwagr05;    /* -     GPR 5.  */
        int   _sdwagr06;    /* -     GPR 6.  */
        int   _sdwagr07;    /* -     GPR 7.  */
        int   _sdwagr08;    /* -     GPR 8.  */
        int   _sdwagr09;    /* -     GPR 9.  */
        int   _sdwagr10;    /* -     GPR 10. */
        int   _sdwagr11;    /* -     GPR 11. */
        int   _sdwagr12;    /* -     GPR 12. */
        int   _sdwagr13;    /* -     GPR 13. */
        int   _sdwagr14;    /* -     GPR 14. */
        int   _sdwagr15;    /* -     GPR 15. */
    } sdwagrsv;
    struct {
        void *_sdwarbad;    /* -     RB ADDRESS OF ABENDING PROGRAM (IF SUPERVISOR */
        byte  _filler1[4];  /* -     CONTAINS ZEROS IF SUPERVISOR MODE PROGRAM     */
    } sdwaname;
    void      *sdwaepa;     /* -     ENTRY POINT ADDRESS OF ABENDING PROGRAM.   */
    void      *sdwaiobr;    /* -     POINTER TO SDWAFIOB FIELD,                 */
    struct {
        int _sdwapsw1;
        int _sdwanxt1;
    } sdwaec1;

    union {
        struct {
            unsigned char  _filler3;  /* RESERVED                                */
            unsigned char  _sdwailc1; /* INSTRUCTION LENGTH CODE FOR PSW DEFINED */
            unsigned char  _filler4;  /* RESERVED FOR IMPRECISE INTERRUPTS */
            unsigned char  _sdwaicd1; /* 8 BIT INTERRUPT CODE              */
            void          *_sdwatran; /* VIRTUAL ADDRESS CAUSING TRANSLATION     */
        } sdwaaec1;
        struct {
            unsigned char  _filler5[7];
            unsigned char  _sdwadxc;     /* Data exception code when program interrupt */
        } _sdwa_struct1;
    } _sdwa_union1;

    byte _rest[392];
} SDWA;

#define sdwacmpf  sdwafiob.sdwaabcc._sdwacmpf
#define sdwacmpc  sdwafiob.sdwaabcc._sdwacmpc
#define sdwacmka  sdwactl1._sdwacmka
#define sdwamwpa  sdwactl1._sdwamwpa
#define sdwainta  sdwactl1._sdwainta
#define sdwapmka  sdwactl1._sdwapmka
#define sdwanxta  sdwactl1._sdwanxta
#define sdwacmkp  sdwactl2._sdwacmkp
#define sdwamwpp  sdwactl2._sdwamwpp
#define sdwaintp  sdwactl2._sdwaintp
#define sdwapmkp  sdwactl2._sdwapmkp
#define sdwanxtp  sdwactl2._sdwanxtp
#define sdwagr00  sdwagrsv._sdwagr00
#define sdwagr01  sdwagrsv._sdwagr01
#define sdwagr02  sdwagrsv._sdwagr02
#define sdwagr03  sdwagrsv._sdwagr03
#define sdwagr04  sdwagrsv._sdwagr04
#define sdwagr05  sdwagrsv._sdwagr05
#define sdwagr06  sdwagrsv._sdwagr06
#define sdwagr07  sdwagrsv._sdwagr07
#define sdwagr08  sdwagrsv._sdwagr08
#define sdwagr09  sdwagrsv._sdwagr09
#define sdwagr10  sdwagrsv._sdwagr10
#define sdwagr11  sdwagrsv._sdwagr11
#define sdwagr12  sdwagrsv._sdwagr12
#define sdwagr13  sdwagrsv._sdwagr13
#define sdwagr14  sdwagrsv._sdwagr14
#define sdwagr15  sdwagrsv._sdwagr15
#define sdwarbad  sdwaname._sdwarbad
#define sdwapsw1  sdwaec1._sdwapsw1
#define sdwanxt1  sdwaec1._sdwanxt1
#define sdwailc1  _sdwa_union1.sdwaaec1._sdwailc1
#define sdwaicd1  _sdwa_union1.sdwaaec1._sdwaicd1
#define sdwatran  _sdwa_union1.sdwaaec1._sdwatran
#define sdwadxc   _sdwa_union1._sdwa_struct1._sdwadxc

/* Values for field "sdwacmpf" */
#define sdwareq  0x80 /* - ON, SYSABEND/SYSMDUMP/SYSUDUMP DUMP TO BE        */
#define sdwastep 0x40 /* - ON, JOBSTEP TO BE TERMINATED.                    */
#define sdwastcc 0x10 /* - ON, DON'T STORE COMPLETION CODE.                 */
#define sdwarcf  0x04 /* - ON, REASON CODE IN SDWACRC IS VALID         @PBC */

/* Values for field "sdwacmka" */
#define sdwaioa  0xFE /* - I/O INTERRUPTS (ALL ZEROS OR ALL ONES).          */
#define sdwaexta 0x01 /* - EXTERNAL INTERRUPT.                              */

/* Values for field "sdwamwpa" */
#define sdwakeya 0xF0 /* - PSW KEY.                                         */
#define sdwamcka 0x04 /* - MACHINE CHECK INTERRUPT.                         */
#define sdwawata 0x02 /* - WAIT STATE.                                      */
#define sdwaspva 0x01 /* - SUPERVISOR/PROBLEM-PROGRAM MODE.                 */

/* Values for field "sdwapmka" */
#define sdwaila  0xC0 /* - INSTRUCTION LENGTH CODE.                         */
#define sdwacca  0x30 /* - LAST CONDITION CODE.                             */
#define sdwafpa  0x08 /* - FIXED-POINT OVERFLOW.                            */
#define sdwadoa  0x04 /* - DECIMAL OVERFLOW.                                */
#define sdwaeua  0x02 /* - EXPONENT UNDERFLOW.                              */
#define sdwasga  0x01 /* - SIGNIFICANCE.                                    */

/* Values for field "sdwacmkp" */
#define sdwaiop  0xFE /* - I/O INTERRUPTS (ALL ZEROS OR ALL ONES).          */
#define sdwaextp 0x01 /* - EXTERNAL INTERRUPT.                              */

/* Values for field "sdwamwpp" */
#define sdwakeyp 0xF0 /* - PSW KEY.                                         */
#define sdwamckp 0x04 /* - MACHINE CHECK INTERRUPT.                         */
#define sdwawatp 0x02 /* - WAIT STATE.                                      */
#define sdwaspvp 0x01 /* - SUPERVISOR/PROBLEM-PROGRAM MODE.                 */

/* Values for field "sdwapmkp" */
#define sdwailp  0xC0 /* - INSTRUCTION LENGTH CODE.                         */
#define sdwaccp  0x30 /* - LAST CONDITION CODE.                             */
#define sdwafpp  0x08 /* - FIXED-POINT OVERFLOW.                            */
#define sdwadop  0x04 /* - DECIMAL OVERFLOW.                                */
#define sdwaeup  0x02 /* - EXPONENT UNDERFLOW.                              */
#define sdwasgp  0x01 /* - SIGNIFICANCE.                                    */

#endif
