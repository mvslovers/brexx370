#ifndef __RAC_H
#define __RAC_H

#include "ldefs.h"

#if defined(__CROSS__)
# include <stdint.h>
#endif

typedef struct {
    uint8_t byte[3];
} uint24_t;

typedef struct {
    unsigned char   xbyte;
    uint24_t        uint24ptr;
} uint24xptr_t;

// see ACHKL mapping
/*
    4	(4)	BITSTRING	1	 ACHKFLG1	FIRST FLAGS BYTE
            1... ....	 ACHKRFI	RACFIND PARAMETER GIVEN
            .1.. ....	 ACHKRFIY	RACFIND=YES
            ..1. ....	 ACHKENX	ENTITYX IS SPECIFIED
            ...1 ....	 ACHKDSTV	DSTYPE=V
            .... 1...	 ACHK31IN	31-BIT ADDRESS LIST INDICATOR
            .... .1..	 ACHKLOGF	LOG=NOFAIL
           .... ..1.	 ACHKLOGN	LOG=NONE
           .... .11.	 ACHKLOGS	LOG=NOSTAT (BOTH ON)
            .... ...1	 ACHKCSA	ENTITY=(ADDR,CSA)
 */

/*
   8    (8)	    BITSTRING   1   ACHKFLG2	SECOND FLAGS BYTE
                 1... ....	    ACHKTALT	ATTR=ALTER
                  .111 ....	    *	        Reserved
                  .... 1...	    ACHKTCTL	ATTR=CONTROL
                  .... .1..	    ACHKTUPD	ATTR=UPDATE
                  .... ..1.	    ACHKTRD	    ATTR=READ
                  .... ...1	    *	        Reserved
 */
typedef struct {
    void *installation_params;
    void *entity_profile;
    void *class;
    void *volser;

    void *old_volser;
    void *appl;
    void *acee;
    void *owner;

    void *dummy[4];

    void *access_level;
    void *access_level_parms;

} RAC_AUTH_PARMS, *P_RAC_AUTH_PARMS;

typedef struct {
    unsigned char length;
    char  name[8];
} CLASS, *P_CLASS;

int rac_status();
int rac_check(const char *className, const char *profileName, const char *attributeName);
#endif //__RAC_H
