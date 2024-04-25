#ifndef __SVC99_H
#define __SVC99_H

#define MASK 0x80000000

typedef struct __S99struc
{
    unsigned char   __S99RBLN;   /* length of rb         */
    unsigned char   __S99VERB;   /* verb code            */
    unsigned short  __S99FLAG1;  /* FLAGS1 of rb         */
    unsigned short  __S99ERROR;  /* error code           */
    unsigned short  __S99INFO;   /* info  code           */
    void *          __S99TXTPP;  /* ptr to tu ptr list   */
    void *          __S99S99X;   /* ptr to rbx           */
    unsigned int    __S99FLAG2;  /* FLAGS2 of rb         */
} __S99struc, __S99parms;

typedef struct __S99rbx
{
    char            __S99EIDÝ6¨; /* rbx identifier           */
    unsigned char   __S99EVER;   /* rbx version              */
    unsigned char   __S99EOPTS;  /* rbx message process. opts*/
    unsigned char   __S99ESUBP;  /* rbx storage subpool      */
    unsigned char   __S99EKEY;   /* rbx storage key          */
    unsigned char   __S99EMGSV;  /* rbx min. severity of mess.*/
    unsigned char   __S99ENMSG;  /* rbx no. of msg. blks ret. */
    void *          __S99ECPPL;  /* Â§ of comd. proc. para. list*/
    char            __reserved;  /* rbx reserved - zero init..*/
    char            __S99ERES;   /* rbx reserved - zero init..*/
    unsigned char   __S99ERCO;   /* rbx rea. code for failure.*/
    unsigned char   __S99ERCF;   /* rbx rea. code of why      */
    int             __S99EWRC;   /* rbx ret code from WTO/PUTL*/
    void *          __S99EMSGP;  /* rbx Â§ of a chain of msg blk*/
    unsigned short  __S99EERR;   /* rbx err code              */
    unsigned short  __S99EINFO;  /* rbx info code             */
    int             __reserv2;   /* rbx reserved - zero init  */
} __S99rbx, __S99rbx_t;

typedef struct __S99emparms {    /* Error Messages Parms     */
    unsigned char   __EMFUNCT;   /* functions to be performed*/
    unsigned char   __EMIDNUM;   /* identifies caller        */
    unsigned char   __EMNMSGBK;  /* num. of messages         */
    unsigned char   __filler1;   /* reserved                 */
    void *          __EMS99RBP;  /* Â§ of failing SVC99/DAIR par */
    int             __EMRETCOD;  /* svc99 or dair ret. code   */
    void *          __EMCPPLP;   /* Â§ of comm. proc. par. list */
    void *          __EMBUFP;    /* Â§ of message buffer        */
    int             __reserv1;   /* rbx reserved - zero init..*/
    int             __reserv2;   /* rbx reserved - zero init..*/
} __S99emparms, __S99emparms_t;

int svc99(__S99parms *parms);

#endif //__SVC99_H
