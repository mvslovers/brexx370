#pragma pack(packed)

#define __extension__
#ifndef __argtable_entry__
#define __argtable_entry__

struct argtable_entry {
    void          *argtable_argstring_ptr;    /* Address of the argument string */
    int            argtable_argstring_length; /* Length of the argument string  */
   // __extension__ double         argtable_next; /* Next ARGTABLE entry            */
};

#endif

#ifndef __argstring__
#define __argstring__

struct argstring {
    unsigned char  argtable_end[8]; /* End of ARGTABLE marker */
};

#endif

#ifndef __compgmtb_header__
#define __compgmtb_header__

struct compgmtb_header {
    void          *compgmtb_first;   /* Address of the first COMPGMTB    */
    int            compgmtb_total;   /* Total number of COMPGMTB entries */
    int            compgmtb_used;    /* Number of used COMPGMTB entries  */
    int            compgmtb_length;  /* Length of each COMPGMTB entry    */
    unsigned char  _filler1[8];      /* Reserved                         */
    unsigned char  compgmtb_ffff[8]; /* End marker - hex                 */
};

#endif

#ifndef __compgmtb_entry__
#define __compgmtb_entry__

struct compgmtb_entry {
    unsigned char  compgmtb_rtproc[8];   /* Name of the Run Time Processor  */
    unsigned char  compgmtb_compinit[8]; /* Name of the Initialization      */
    unsigned char  compgmtb_compterm[8]; /* Name of the Termination Routine */
    unsigned char  compgmtb_compload[8]; /* Name of the Load Routine        */
    unsigned char  compgmtb_compvar[8];  /* Name of the Variable Handling   */
    int            compgmtb_storage[4];  /* Storage for the Compiler        */
    __extension__ double         compgmtb_next; /* Next COMPGMTB entry             */
};

#endif

#ifndef __dsib_info__
#define __dsib_info__

struct dsib_info {
    unsigned char  dsib_id[8];     /* The 'IRXDSIB ' identifier          */
    short int      dsib_length;    /* Length of the DSIB_INFO control    */
    short int      _filler1;       /* Reserved                           */
    unsigned char  dsib_ddname[8]; /* Name of DD for which information   */
    union {
        unsigned char  _dsib_flags[4]; /* Flag word */
        struct {
            int            _dsib_lrecl_flag : 1, /* ON if LRECL field is set           */
                    _dsib_blksz_flag : 1, /* ON if BLKSZ field is set           */
                    _dsib_dsorg_flag : 1, /* ON if DSORG field is set           */
                    _dsib_recfm_flag : 1, /* ON if RECFM field is set           */
                    _dsib_get_flag   : 1, /* ON if GET_CNT field is valid       */
                    _dsib_put_flag   : 1, /* ON if PUT_CNT field is valid       */
                    _dsib_mode_flag  : 1, /* ON if MODE field is set            */
                    _dsib_cc_flag    : 1; /* ON if CC field is set              */
            int            _dsib_trc_flag   : 1, /* ON if TRC field is set             */
                    : 7;
            unsigned char  _filler2[2];          /* Reserved                  �DEI0051 */
        } _dsib_info_struct1;
    } _dsib_info_union1;
    union {
        unsigned char  _dsib_dcb_info[8]; /* DCB information - set at OPEN */
        struct {
            short int      _dsib_lrecl;    /* Data set LRECL                  */
            short int      _dsib_blksz;    /* Data set BLKSIZE                */
            unsigned char  _dsib_dsorg[2]; /* Data Set Organization (DSORG) - */
            unsigned char  _dsib_recfm[2]; /* Record Format Information ==>   */
        } _dsib_info_struct2;
    } _dsib_info_union2;
    union {
        unsigned char  _dsib_io_counts[8]; /* I/O count against this DCB */
        struct {
            int            _dsib_get_cnt; /* Total number of records read    */
            int            _dsib_put_cnt; /* Total number of records written */
        } _dsib_info_struct3;
    } _dsib_info_union3;
    unsigned char  dsib_io_mode;   /* Mode in which DCB was opened:      */
    unsigned char  dsib_cc;        /* Carriage control information:      */
    unsigned char  dsib_trc;       /* 3800 TRC information:              */
    unsigned char  _filler3;       /* Reserved                  �DEI0051 */
    int            _filler4[3];    /* Reserved words                     */
};

#define dsib_flags      _dsib_info_union1._dsib_flags
#define dsib_lrecl_flag _dsib_info_union1._dsib_info_struct1._dsib_lrecl_flag
#define dsib_blksz_flag _dsib_info_union1._dsib_info_struct1._dsib_blksz_flag
#define dsib_dsorg_flag _dsib_info_union1._dsib_info_struct1._dsib_dsorg_flag
#define dsib_recfm_flag _dsib_info_union1._dsib_info_struct1._dsib_recfm_flag
#define dsib_get_flag   _dsib_info_union1._dsib_info_struct1._dsib_get_flag
#define dsib_put_flag   _dsib_info_union1._dsib_info_struct1._dsib_put_flag
#define dsib_mode_flag  _dsib_info_union1._dsib_info_struct1._dsib_mode_flag
#define dsib_cc_flag    _dsib_info_union1._dsib_info_struct1._dsib_cc_flag
#define dsib_trc_flag   _dsib_info_union1._dsib_info_struct1._dsib_trc_flag
#define dsib_dcb_info   _dsib_info_union2._dsib_dcb_info
#define dsib_lrecl      _dsib_info_union2._dsib_info_struct2._dsib_lrecl
#define dsib_blksz      _dsib_info_union2._dsib_info_struct2._dsib_blksz
#define dsib_dsorg      _dsib_info_union2._dsib_info_struct2._dsib_dsorg
#define dsib_recfm      _dsib_info_union2._dsib_info_struct2._dsib_recfm
#define dsib_io_counts  _dsib_info_union3._dsib_io_counts
#define dsib_get_cnt    _dsib_info_union3._dsib_info_struct3._dsib_get_cnt
#define dsib_put_cnt    _dsib_info_union3._dsib_info_struct3._dsib_put_cnt

/* Values for field "_filler4" */
#define dsiblen 0x38 /* Length of DSIB control block */

#endif

#ifndef __efpl__
#define __efpl__

struct efpl {
    void          *efplcom;  /* * RESERVED                        */
    void          *efplbarg; /* * RESERVED                        */
    void          *efplearg; /* * RESERVED                        */
    void          *efplfb;   /* * RESERVED                        */
    void          *efplarg;  /* * POINTER TO ARGUMENTS TABLE      */
    void          *efpleval; /* * POINTER TO ADDRESS OF EVALBLOCK */
};

#endif

#ifndef __envblock__
#define __envblock__

struct envblock {
    unsigned char  envblock_id[8];            /* ENVBLOCK identifier 'ENVBLOCK'   */
    unsigned char  envblock_version[4];       /* Version number        �DEI0040   */
    int            envblock_length;           /* Length of ENVBLOCK    �DEI0040   */
    void          *envblock_parmblock;        /* Address of the PARMBLOCK         */
    void          *envblock_userfield;        /* Address of the user field        */
    void          *envblock_workblok_ext;     /* Address of the current           */
    void          *envblock_irxexte;          /* Address of IRXEXTE               */
    union {
        unsigned char  _envblock_error[256]; /* Error information */
        struct {
            void          *_error_call_;               /* Address of the routine in error  */
            int            _filler1;                   /* Reserved                         */
            unsigned char  _error_msgid[8];            /* Message identifier of first call */
            unsigned char  _primary_error_message[80]; /* Error message                    */
            unsigned char  _alternate_error_msg[160];  /* Extended error message           */
        } _envblock_struct1;
    } _envblock_union1;
    void          *envblock_compgmtb;         /* Address of the Compiler          */
    void          *envblock_attnrout_parmptr; /* Address of a parameter           */
    void          *envblock_ectptr;           /* Address of the ECT under which   */
    union {
        unsigned char  _envblock_info_flags[4]; /* Information flags       �YA57272 */
        struct {
            int            _envblock_terma_cleanup : 1, /* Flag to indicate that            */
                    : 7;
            unsigned char  _filler2[3];                 /* Reserved                �YA57272 */
        } _envblock_struct2;
    } _envblock_union2;
    int            envblock_uss_rexx;         /* Word reserved for USS REXX  �P1C */
    int            _filler3[3];               /* Reserved                    �P1C */
};

#define envblock_error         _envblock_union1._envblock_error
#define error_call_            _envblock_union1._envblock_struct1._error_call_
#define error_msgid            _envblock_union1._envblock_struct1._error_msgid
#define primary_error_message  _envblock_union1._envblock_struct1._primary_error_message
#define alternate_error_msg    _envblock_union1._envblock_struct1._alternate_error_msg
#define envblock_info_flags    _envblock_union2._envblock_info_flags
#define envblock_terma_cleanup _envblock_union2._envblock_struct2._envblock_terma_cleanup

#endif

#ifndef __evalblock__
#define __evalblock__

struct evalblock {
    int            evalblock_evpad1; /* Reserved - set to binary zero */
    int            evalblock_evsize; /* Size of EVALBLOCK in double   */
    int            evalblock_evlen;  /* Length of data                */
    int            evalblock_evpad2; /* Reserved - set to binary zero */
    unsigned char  evalblock_evdata[1]; /* Result                        */
};

#endif

#ifndef __execblk__
#define __execblk__

struct execblk {
    unsigned char  exec_blk_acryn[8]; /* Acronym identifier, must be set     */
    int            exec_blk_length;   /* Length of EXECBLK in bytes �PEI0455 */
    int            _filler1;          /* Reserved                   �PEI0455 */
    unsigned char  exec_member[8];    /* The member name of the Exec, if     */
    unsigned char  exec_ddname[8];    /* The DD from which the Exec is       */
    unsigned char  exec_subcom[8];    /* Name of the initial subcommand      */
    void          *exec_dsnptr;       /* Pointer to a data set name (DSN)    */
    int            exec_dsnlen;       /* Length of DSN pointed to by         */
    union {
        unsigned char  _exec_v1_end;      /* End of EXECBLK             �PEI0455 */
        void          *_exec_extname_ptr; /* Pointer to the extended execname.   */
    } _execblk_union1;
    int            exec_extname_len;  /* Length of the extended name         */
    int            _filler2[2];       /* RSVD                       �WA28404 */
    __extension__ unsigned char  exec_v2_end; /* End of Ver 2 EXECBLK       �WA28404 */
};

#define exec_v1_end      _execblk_union1._exec_v1_end
#define exec_extname_ptr _execblk_union1._exec_extname_ptr

/* Values for field "exec_v1_end" */
#define execblen       0x30 /* Length of the EXECBLK Ver1 �WA28404 */
#define execblk_v1_len 0x30 /* Length of the EXECBLK Ver1          */

/* Values for field "exec_v2_end" */
#define execblk_v2_len 0x40 /* Length of the EXECBLK Ver2 �WA28404 */

#endif

#ifndef __irxexte__
#define __irxexte__

struct irxexte {
    int            irxexte_entry_count; /* Number of entry points in the    */
    void          *irxinit;             /* IRXINIT - REXX Initialization    */
    void          *load_routine;        /* LOAD_ROUTINE - REXX Load Exec    */
    void          *irxload;             /* IRXLOAD - Default REXX Load Exec */
    void          *irxexcom;            /* IRXEXCOM - REXX Variable Access  */
    void          *irxexec;             /* IRXEXEC - REXX Run Exec Routine  */
    void          *io_routine;          /* IO_ROUTINE - REXX Input/Output   */
    void          *irxinout;            /* IRXINOUT - Default REXX          */
    void          *irxjcl;              /* IRXJCL - REXX JCL Routine        */
    void          *irxrlt;              /* IRXRLT - REXX Get Result Routine */
    void          *stack_routine;       /* STACK_ROUTINE - REXX Data Stack  */
    void          *irxstk;              /* IRXSTK - Default REXX Data Stack */
    void          *irxsubcm;            /* IRXSUBCM - REXX Subcommand       */
    void          *irxterm;             /* IRXTERM - REXX Termination       */
    void          *irxic;               /* IRXIC - REXX Immediate Commands  */
    void          *msgid_routine;       /* MSGID_ROUTINE - REXX Message ID  */
    void          *irxmsgid;            /* IRXMSGID - Default REXX Message  */
    void          *userid_routine;      /* USERID_ROUTINE - REXX User ID    */
    void          *irxuid;              /* IRXUID - Default REXX User ID    */
    void          *irxterma;            /* IRXTERMA - REXX Abnormal         */
    void          *irxsay;              /* IRXSAY - REXX SAY      �E23X2BJ  */
    void          *irxers;              /* IRXERS - REXX External �E23X2BJ  */
    void          *irxhst;              /* IRXHST - REXX Host     �E23X2BJ  */
    void          *irxhlt;              /* IRXHLT - REXX Halt     �E23X2BJ  */
    void          *irxtxt;              /* IRXTXT - REXX Text     �E23X2BJ  */
    void          *irxlin;              /* IRXLIN - REXX LINESIZE �E23X2BJ  */
    void          *irxrte;              /* IRXRTE - REXX Exit     �E23X2BJ  */
};

#endif

#ifndef __fpckdir_header__
#define __fpckdir_header__

struct fpckdir_header {
    unsigned char  fpckdir_id[8];         /* FPCKDIR character id    */
    int            fpckdir_header_length; /* Length of header        */
    int            fpckdir_functions;     /* Number of functions     */
    int            _filler1;              /* Reserved                */
    int            fpckdir_entry_length;  /* Length of FPCKDIR entry */
};

#endif

#ifndef __fpckdir_entry__
#define __fpckdir_entry__

struct fpckdir_entry {
    unsigned char  fpckdir_funcname[8]; /* Name of Function or Subroutine */
    void          *fpckdir_funcaddr;    /* Address of the entry point of  */
    int            _filler1;            /* Reserved                       */
    unsigned char  fpckdir_sysname[8];  /* Name of the entry point        */
    unsigned char  fpckdir_sysdd[8];    /* DD name from which the package */
    __extension__ double         fpckdir_next; /* Next FPCKDIR entry             */
};

#endif

#ifndef __instblk__
#define __instblk__

struct instblk {
    union {
        unsigned char  _instblk_header[128]; /* In-Storage Block Header */
        struct {
            unsigned char  _instblk_acronym[8];  /* The INSTBLK Identifier              */
            int            _instblk_hdrlen;      /* Length of INSTBLK header            */
            int            _filler1;             /* Reserved                            */
            void          *_instblk_address;     /* Address of first INSTBLK_ENTRY      */
            int            _instblk_usedlen;     /* Total length of all used            */
            unsigned char  _instblk_member[8];   /* Name of member from which exec      */
            unsigned char  _instblk_ddname[8];   /* Name of DD representing data set    */
            unsigned char  _instblk_subcom[8];   /* Name of initial subcommand environ- */
            int            _filler2;             /* Reserved                            */
            int            _instblk_dsnlen;      /* Length of data set name             */
            unsigned char  _instblk_dsname[54];  /* Data set name from which exec was   */
            short int      _filler3;             /* Reserved                            */
            void          *_instblk_extname_ptr; /* Ptr to the extended execname.       */
            int            _instblk_extname_len; /* Length of the extended name         */
            int            _filler4[2];          /* Reserved - 2 words         �WA28404 */
        } _instblk_struct1;
    } _instblk_union1;
    __extension__ union {
        unsigned char  _instblk_entries[8]; /* The INSTBLK_ENTRY array of entries */
    } _instblk_union2;
};

#define instblk_header      _instblk_union1._instblk_header
#define instblk_acronym     _instblk_union1._instblk_struct1._instblk_acronym
#define instblk_hdrlen      _instblk_union1._instblk_struct1._instblk_hdrlen
#define instblk_address     _instblk_union1._instblk_struct1._instblk_address
#define instblk_usedlen     _instblk_union1._instblk_struct1._instblk_usedlen
#define instblk_member      _instblk_union1._instblk_struct1._instblk_member
#define instblk_ddname      _instblk_union1._instblk_struct1._instblk_ddname
#define instblk_subcom      _instblk_union1._instblk_struct1._instblk_subcom
#define instblk_dsnlen      _instblk_union1._instblk_struct1._instblk_dsnlen
#define instblk_dsname      _instblk_union1._instblk_struct1._instblk_dsname
#define instblk_extname_ptr _instblk_union1._instblk_struct1._instblk_extname_ptr
#define instblk_extname_len _instblk_union1._instblk_struct1._instblk_extname_len
#define instblk_entries     _instblk_union2._instblk_entries

#endif

#ifndef __instblk_entry__
#define __instblk_entry__

struct instblk_entry {
    void          *instblk_stmt_;   /* Address of REXX statement    */
    int            instblk_stmtlen; /* Length of the REXX statement */
    __extension__ union {
        unsigned char  _instblk_next[8]; /* Next INSTBLK_ENTRY */
    } _instblk_entry_union1;
};

#define instblk_next _instblk_entry_union1._instblk_next

#endif

#ifndef __statement__
#define __statement__

struct statement {
    unsigned char  instblk_acryn[8]; /* In-storage control      �E23X2BJ */
};

#endif

#ifndef __modnamet__
#define __modnamet__

struct modnamet {
    union {
        unsigned char  _modnamet_dds[24]; /* DDs */
        struct {
            unsigned char  _modnamet_indd[8];   /* Name of the input DD and is only */
            unsigned char  _modnamet_outdd[8];  /* Name of the output DD and is     */
            unsigned char  _modnamet_loaddd[8]; /* Name of the load exec DD         */
        } _modnamet_struct1;
    } _modnamet_union1;
    union {
        unsigned char  _modnamet_routines[80]; /* Routines                �YA17590 */
        struct {
            unsigned char  _modnamet_iorout[8];   /* Name of the input and output     */
            unsigned char  _modnamet_exrout[8];   /* Name of the exec load routine    */
            unsigned char  _modnamet_getfreer[8]; /* Name of the getmain and freemain */
            unsigned char  _modnamet_execinit[8]; /* Name of the Exec Initialization  */
            unsigned char  _modnamet_attnrout[8]; /* Name of the attention routine    */
            unsigned char  _modnamet_stackrt[8];  /* Name of the stack routine        */
            unsigned char  _modnamet_irxexecx[8]; /* Name of the IRXEXEC exit routine */
            unsigned char  _modnamet_idrout[8];   /* Name of the userid routine       */
            unsigned char  _modnamet_msgidrt[8];  /* Name of the message id routine   */
            unsigned char  _modnamet_execterm[8]; /* Name of the Exec Termination     */
        } _modnamet_struct2;
    } _modnamet_union2;
    unsigned char  modnamet_ffff[8]; /* End marker - hex */
};

#define modnamet_dds      _modnamet_union1._modnamet_dds
#define modnamet_indd     _modnamet_union1._modnamet_struct1._modnamet_indd
#define modnamet_outdd    _modnamet_union1._modnamet_struct1._modnamet_outdd
#define modnamet_loaddd   _modnamet_union1._modnamet_struct1._modnamet_loaddd
#define modnamet_routines _modnamet_union2._modnamet_routines
#define modnamet_iorout   _modnamet_union2._modnamet_struct2._modnamet_iorout
#define modnamet_exrout   _modnamet_union2._modnamet_struct2._modnamet_exrout
#define modnamet_getfreer _modnamet_union2._modnamet_struct2._modnamet_getfreer
#define modnamet_execinit _modnamet_union2._modnamet_struct2._modnamet_execinit
#define modnamet_attnrout _modnamet_union2._modnamet_struct2._modnamet_attnrout
#define modnamet_stackrt  _modnamet_union2._modnamet_struct2._modnamet_stackrt
#define modnamet_irxexecx _modnamet_union2._modnamet_struct2._modnamet_irxexecx
#define modnamet_idrout   _modnamet_union2._modnamet_struct2._modnamet_idrout
#define modnamet_msgidrt  _modnamet_union2._modnamet_struct2._modnamet_msgidrt
#define modnamet_execterm _modnamet_union2._modnamet_struct2._modnamet_execterm

#endif

#ifndef __packtb_header__
#define __packtb_header__

struct packtb_header {
    void          *packtb_user_first;   /* Address of the first user PACKTB */
    int            packtb_user_total;   /* Total number of user PACKTB      */
    int            packtb_user_used;    /* Number of used user PACKTB       */
    void          *packtb_local_first;  /* Address of the first local       */
    int            packtb_local_total;  /* Total number of local PACKTB     */
    int            packtb_local_used;   /* Number of used local PACKTB      */
    void          *packtb_system_first; /* Address of the first system      */
    int            packtb_system_total; /* Total number of system PACKTB    */
    int            packtb_system_used;  /* Number of used system PACKTB     */
    int            packtb_length;       /* Length of each PACKTB entry      */
    unsigned char  packtb_ffff[8];      /* End marker - hex                 */
};

#endif

#ifndef __packtb_entry__
#define __packtb_entry__

struct packtb_entry {
    unsigned char  packtb_name[8];             /* Name of the function package   */
    union {
        double         _packtb_next;           /* Next PACKTB entry               */
        unsigned char  _valid_parmblock_id[8]; /* Valid  PARMBLOCK       �E23X2BJ */
    } _packtb_entry_union1;
    unsigned char  valid_parmblock_version[4]; /* Current PARMBLOCK     �E23X2BJ */
};

#define packtb_next        _packtb_entry_union1._packtb_next
#define valid_parmblock_id _packtb_entry_union1._valid_parmblock_id

#endif

#ifndef __parmblock__
#define __parmblock__

struct parmblock {
    unsigned char  parmblock_id[8];       /* PARMBLOCK character id          */
    unsigned char  parmblock_version[4];  /* Version number in EBCDIC        */
    unsigned char  parmblock_language[3]; /* Language identifier    �DG10017 */
    unsigned char  _filler1;
    void          *parmblock_modnamet;    /* Address of the MODNAMET         */
    void          *parmblock_subcomtb;    /* Address of the SUBCOMTB header  */
    void          *parmblock_packtb;      /* Address of the PACKTB header    */
    unsigned char  parmblock_parsetok[8]; /* Parse source token              */
    union {
        unsigned char  _parmblock_flags[4]; /* Flags */
        struct {
            int            _tsofl    : 1, /* Integrate with TSO flag          */
                    : 1,
                    _cmdsofl  : 1, /* Command search order flag        */
                    _funcsofl : 1, /* Function/subroutine search order */
                    _nostkfl  : 1, /* No data stack flag               */
                    _noreadfl : 1, /* No read flag                     */
                    _nowrtfl  : 1, /* No write flag                    */
                    _newstkfl : 1; /* New data stack flag              */
            int            _userpkfl : 1, /* User external function package   */
                    _locpkfl  : 1, /* Local external function package  */
                    _syspkfl  : 1, /* System external function package */
                    _newscfl  : 1, /* New subcommand table flag        */
                    _closexfl : 1, /* Close exec data set flag         */
                    _noestae  : 1, /* No recovery ESTAE flag           */
                    _rentrant : 1, /* Reentrant REXX environment flag  */
                    _nopmsgs  : 1; /* No primary messages flag         */
            int            _altmsgs  : 1, /* Issue alternate messages flag    */
                    _spshare  : 1, /* Subpool storage is shared flag   */
                    _storfl   : 1, /* STORAGE function flag   �PEI0279 */
                    _noloaddd : 1, /* Do not load from        �DEI0043 */
                    _nomsgwto : 1, /* MVS, do not issue error messages */
                    _nomsgio  : 1, /* MVS, do not issue error messages */
                    _rostorfl : 1, /* Read only STORAGE function. The  */
                    : 1;
            unsigned char  _filler2;      /* Reserved                         */
        } _parmblock_struct1;
    } _parmblock_union1;
    union {
        unsigned char  _parmblock_masks[4]; /* Masks for flags */
        struct {
            int            _tsofl_mask    : 1, /* Integrate with TSO flag mask     */
                    : 1,
                    _cmdsofl_mask  : 1, /* Command search order flag mask   */
                    _funcsofl_mask : 1, /* Function/subroutine search order */
                    _nostkfl_mask  : 1, /* No data stack flag mask          */
                    _noreadfl_mask : 1, /* No read flag mask                */
                    _nowrtfl_mask  : 1, /* No write flag mask               */
                    _newstkfl_mask : 1; /* New data stack flag mask         */
            int            _userpkfl_mask : 1, /* User external function package   */
                    _locpkfl_mask  : 1, /* Local external function package  */
                    _syspkfl_mask  : 1, /* System external function package */
                    _newscfl_mask  : 1, /* New subcommand table flag mask   */
                    _closexfl_mask : 1, /* Close exec data set flag mask    */
                    _noestae_mask  : 1, /* No recovery ESTAE flag mask      */
                    _rentrant_mask : 1, /* Reentrant REXX environment flag  */
                    _nopmsgs_mask  : 1; /* No primary messages flag mask    */
            int            _altmsgs_mask  : 1, /* Issue alternate messages flag    */
                    _spshare_mask  : 1, /* Subpool storage is shared flag   */
                    _storfl_mask   : 1, /* STORAGE function flag   �PEI0279 */
                    _noloaddd_mask : 1, /* Mask for                �DEI0043 */
                    _nomsgwto_mask : 1, /* MVS, do not issue error messages */
                    _nomsgio_mask  : 1, /* MVS, do not issue error messages */
                    _rostorfl_mask : 1, /* Read only STORAGE mask      �L1A */
                    : 1;
            unsigned char  _filler3;           /* Reserved                         */
        } _parmblock_struct2;
    } _parmblock_union2;
    int            parmblock_subpool;     /* Subpool number                  */
    unsigned char  parmblock_addrspn[8];  /* Name of the address space       */
    unsigned char  parmblock_ffff[8];     /* End marker - hex                */
};

#define parmblock_flags _parmblock_union1._parmblock_flags
#define tsofl           _parmblock_union1._parmblock_struct1._tsofl
#define cmdsofl         _parmblock_union1._parmblock_struct1._cmdsofl
#define funcsofl        _parmblock_union1._parmblock_struct1._funcsofl
#define nostkfl         _parmblock_union1._parmblock_struct1._nostkfl
#define noreadfl        _parmblock_union1._parmblock_struct1._noreadfl
#define nowrtfl         _parmblock_union1._parmblock_struct1._nowrtfl
#define newstkfl        _parmblock_union1._parmblock_struct1._newstkfl
#define userpkfl        _parmblock_union1._parmblock_struct1._userpkfl
#define locpkfl         _parmblock_union1._parmblock_struct1._locpkfl
#define syspkfl         _parmblock_union1._parmblock_struct1._syspkfl
#define newscfl         _parmblock_union1._parmblock_struct1._newscfl
#define closexfl        _parmblock_union1._parmblock_struct1._closexfl
#define noestae         _parmblock_union1._parmblock_struct1._noestae
#define rentrant        _parmblock_union1._parmblock_struct1._rentrant
#define nopmsgs         _parmblock_union1._parmblock_struct1._nopmsgs
#define altmsgs         _parmblock_union1._parmblock_struct1._altmsgs
#define spshare         _parmblock_union1._parmblock_struct1._spshare
#define storfl          _parmblock_union1._parmblock_struct1._storfl
#define noloaddd        _parmblock_union1._parmblock_struct1._noloaddd
#define nomsgwto        _parmblock_union1._parmblock_struct1._nomsgwto
#define nomsgio         _parmblock_union1._parmblock_struct1._nomsgio
#define rostorfl        _parmblock_union1._parmblock_struct1._rostorfl
#define parmblock_masks _parmblock_union2._parmblock_masks
#define tsofl_mask      _parmblock_union2._parmblock_struct2._tsofl_mask
#define cmdsofl_mask    _parmblock_union2._parmblock_struct2._cmdsofl_mask
#define funcsofl_mask   _parmblock_union2._parmblock_struct2._funcsofl_mask
#define nostkfl_mask    _parmblock_union2._parmblock_struct2._nostkfl_mask
#define noreadfl_mask   _parmblock_union2._parmblock_struct2._noreadfl_mask
#define nowrtfl_mask    _parmblock_union2._parmblock_struct2._nowrtfl_mask
#define newstkfl_mask   _parmblock_union2._parmblock_struct2._newstkfl_mask
#define userpkfl_mask   _parmblock_union2._parmblock_struct2._userpkfl_mask
#define locpkfl_mask    _parmblock_union2._parmblock_struct2._locpkfl_mask
#define syspkfl_mask    _parmblock_union2._parmblock_struct2._syspkfl_mask
#define newscfl_mask    _parmblock_union2._parmblock_struct2._newscfl_mask
#define closexfl_mask   _parmblock_union2._parmblock_struct2._closexfl_mask
#define noestae_mask    _parmblock_union2._parmblock_struct2._noestae_mask
#define rentrant_mask   _parmblock_union2._parmblock_struct2._rentrant_mask
#define nopmsgs_mask    _parmblock_union2._parmblock_struct2._nopmsgs_mask
#define altmsgs_mask    _parmblock_union2._parmblock_struct2._altmsgs_mask
#define spshare_mask    _parmblock_union2._parmblock_struct2._spshare_mask
#define storfl_mask     _parmblock_union2._parmblock_struct2._storfl_mask
#define noloaddd_mask   _parmblock_union2._parmblock_struct2._noloaddd_mask
#define nomsgwto_mask   _parmblock_union2._parmblock_struct2._nomsgwto_mask
#define nomsgio_mask    _parmblock_union2._parmblock_struct2._nomsgio_mask
#define rostorfl_mask   _parmblock_union2._parmblock_struct2._rostorfl_mask

#endif

#ifndef __shvblock__
#define __shvblock__

struct shvblock {
    void          *shvnext; /* Chain pointer to next SHVBLOCK */
    int            shvuser; /* Used during "FETCH NEXT"       */
    union {
        int            _shvcodes;
        struct {
            unsigned char  _shvcode;  /* Function code - indicates type */
            unsigned char  _shvret;   /* Return codes                   */
            short int      _filler1;  /* Reserved (should be 0)         */
        } _shvblock_struct1;
    } _shvblock_union1;
    int            shvbufl; /* Length of fetch value buffer   */
    void          *shvnama; /* Address of variable name       */
    int            shvnaml; /* Length of variable name        */
    void          *shvvala; /* Address of value buffer        */
    int            shvvall; /* Length of value buffer         */
};

#define shvcodes _shvblock_union1._shvcodes
#define shvcode  _shvblock_union1._shvblock_struct1._shvcode
#define shvret   _shvblock_union1._shvblock_struct1._shvret

/* Values for field "shvvall" */
#define shvblen  0x20 /* Length of SHVBLOCK              */
#define shvfetch 'F'  /* Copy value of shared variable   */
#define shvstore 'S'  /* Set variable from given value   */
#define shvdropv 'D'  /* Drop variable                   */
#define shvsyfet 'f'  /* Symbolic name retrieve          */
#define shvsyset 's'  /* Symbolic name set               */
#define shvsydro 'd'  /* Symbolic name drop              */
#define shvnextv 'N'  /* Fetch "next" variable           */
#define shvpriv  'P'  /* Fetch private information       */
#define shvclean 0x00 /* Execution was OK                */
#define shvnewv  0x01 /* Variable did not exist          */
#define shvlvar  0x02 /* Last variable transferred ("N") */
#define shvtrunc 0x04 /* Truncation occurred for "Fetch" */
#define shvbadn  0x08 /* Invalid variable name           */
#define shvbadv  0x10 /* Invalid value specified         */
#define shvbadf  0x80 /* Invalid function code (SHVCODE) */
#define shvrcok  0    /* Entire Plist chain processed    */
#define shvrcinv -1   /* Invalid entry conditions        */
#define shvrcist -2   /* Insufficient storage available  */

#endif

#ifndef __subcomtb_header__
#define __subcomtb_header__

struct subcomtb_header {
    void          *subcomtb_first;      /* Address of the first SUBCOMTB    */
    int            subcomtb_total;      /* Total number of SUBCOMTB entries */
    int            subcomtb_used;       /* Number of used SUBCOMTB entries  */
    int            subcomtb_length;     /* Length of each SUBCOMTB entry    */
    unsigned char  subcomtb_initial[8]; /* Name of the initial subcommand   */
    unsigned char  _filler1[8];         /* Reserved                         */
    unsigned char  subcomtb_ffff[8];    /* End marker - hex                 */
};

#endif

#ifndef __subcomtb_entry__
#define __subcomtb_entry__

struct subcomtb_entry {
    unsigned char  subcomtb_name[8];    /* Name of the subcommand         */
    unsigned char  subcomtb_routine[8]; /* Name of the subcommand routine */
    unsigned char  subcomtb_token[16];  /* Subcommand token               */
    //__extension__ double         subcomtb_next; /* Next SUBCOMTB entry            */
};

#endif

#ifndef __workblok_ext__
#define __workblok_ext__

struct workblok_ext {
    void          *workext_execblk;        /* Address of the EXECBLK           */
    void          *workext_argtable;       /* Address of the first ARGTABLE    */
    union {
        unsigned char  _workext_flags[4]; /* Flags describing the REXX exec */
        struct {
            int            _workext_command    : 1, /* Exec is a command    */
                    _workext_function   : 1, /* Exec is a function   */
                    _workext_subroutine : 1, /* Exec is a subroutine */
                    : 5;
            unsigned char  _filler1[3];             /* Reserved             */
        } _workblok_ext_struct1;
    } _workblok_ext_union1;
    void          *workext_instblk;        /* Address of the INSTBLK header    */
    void          *workext_cpplptr;        /* Address of the CPPL     �PEI0853 */
    void          *workext_evalblock;      /* Address of the REXX user         */
    void          *workext_workarea;       /* Address of the workarea header   */
    void          *workext_userfield;      /* Address of a user field �PEI0853 */
    int            workext_rtproc;         /* A fullword for use by  �E23X2BJ  */
    void          *workext_source_address; /* The address of the     �E23X2BJ  */
    int            workext_source_length;  /* The length of the      �E23X2BJ  */
    int            _filler2;               /* Reserved               �E23X2BJ  */
};

#define workext_flags      _workblok_ext_union1._workext_flags
#define workext_command    _workblok_ext_union1._workblok_ext_struct1._workext_command
#define workext_function   _workblok_ext_union1._workblok_ext_struct1._workext_function
#define workext_subroutine _workblok_ext_union1._workblok_ext_struct1._workext_subroutine

#endif

#pragma pack(reset)
