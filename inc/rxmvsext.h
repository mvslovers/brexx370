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

    unsigned      dummy[27];

    unsigned     *VSAMSUBT;
    unsigned      reserved[64];

} RX_ENVIRONMENT_CTX, *RX_ENVIRONMENT_CTX_PTR;

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
/* assembler module RXTSO                                  */
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

#ifdef __CROSS__
int  call_rxinit(RX_INIT_PARAMS_PTR params);
int  call_rxtso(RX_TSO_PARAMS_PTR params);
void call_rxsvc(RX_SVC_PARAMS_PTR params);
int  call_rxvsam(RX_VSAM_PARAMS_PTR params);
unsigned int call_rxikj441 (RX_IKJCT441_PARAMS_PTR params);
unsigned int call_rxabend (RX_ABEND_PARAMS_PTR params);
int systemCP(void *uptPtr, void *ectPtr, char *cmdStr, int cmdLen, char *retBuf, int retBufLen);

#else
extern int  call_rxinit(RX_INIT_PARAMS_PTR params);
extern int  call_rxtso(RX_TSO_PARAMS_PTR params);
extern void call_rxsvc(RX_SVC_PARAMS_PTR params);
extern int  call_rxvsam(RX_VSAM_PARAMS_PTR params);
extern unsigned int call_rxikj441 (RX_IKJCT441_PARAMS_PTR params);
extern unsigned int call_rxabend (RX_ABEND_PARAMS_PTR params);
extern int systemCP(void *uptPtr, void *ectPtr, char *cmdStr, int cmdLen, char *retBuf, int retBufLen);
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
    byte    skip[4];            /* tbd */
    byte    SDWACMPFM;          /* - FLAG BITS IN COMPLETION CODE. */
    byte    SDWACMPC[3];        /* - SYSTEM COMPLETION CODE (FIRST 12 BITS)
                                 *  AND USER COMPLETION CODE (SECOND 12 BITS). */
    byte    fill[96];
} SDWA;

#endif
