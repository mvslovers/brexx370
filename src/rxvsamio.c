#include <string.h>
#include "rexx.h"
#include "bmem.h"
#include "lstring.h"
#include "stack.h"
#include "rxmvsext.h"
#include "hostenv.h"

extern RX_ENVIRONMENT_CTX_PTR environment;
bool vsamsubtSet = FALSE;

int
RxVSAMIO(char **tokens)
{
    RX_VSAM_PARAMS_PTR params;

    int rc = 0;

    params =  MALLOC(sizeof(RX_VSAM_PARAMS),"RXVSAM");
    memset(params,0,sizeof(RX_VSAM_PARAMS));
    strcpy(params->VSAMDDN,"        ");

    // OPEN
    if (strcasecmp(tokens[1], "OPEN") == 0) {

        // set function code
        if (findToken("READ", tokens) != -1) {
            strcpy(params->VSAMFUNC,"OPENR");
        } else if (findToken("UPDATE", tokens) != -1) {
            strcpy(params->VSAMFUNC,"OPENU");
        } else if (findToken("LOAD", tokens) != -1) {
            strcpy(params->VSAMFUNC,"OPENL");
        } else if (findToken("RESET", tokens) != -1) {
            strcpy(params->VSAMFUNC,"OPENX");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

#ifdef __DEBUG__
        // enable tracing via WTOs
        params->VSAMMOD = 'T';
#else
        // disable tracing
        params->VSAMMOD = 'N';
#endif

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // READ
    } else if (strcasecmp(tokens[1], "READ") == 0) {

        unsigned char vname[19];
        int pos;
        bool useVar = FALSE;

        // set function code
        pos = findToken("KEY", tokens);
        if (pos != -1) {
            if (findToken("UPDATE",tokens) == -1) {
                strcpy(params->VSAMFUNC, "READK");
            } else {
                strcpy(params->VSAMFUNC, "READKU");
            }
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findToken("NEXT", tokens) != -1) {
            if (findToken("UPDATE", tokens) == -1) {
                strcpy(params->VSAMFUNC, "READN");
            } else {
                strcpy(params->VSAMFUNC, "READNU");
            }
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findToken("VAR", tokens);
        if (pos != -1) {
            useVar = TRUE;
            strcpy((char *) vname, tokens[++pos]);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        if (rc == 0 && params->VSAMRECL > 0) {

            char *record;

            record = MALLOC(params->VSAMRECL + 1, "VSAM RECORD");
            memset(record, 0,  params->VSAMRECL + 1);
            memcpy(record,(char *)params->VSAMREC, params->VSAMRECL);

            if (useVar){
                setVariable2((char *) vname, record, params->VSAMRECL);
            } else {
                // put record on queue
                PLstr pstr;
                LPMALLOC(pstr)
                Lscpy(pstr, record);
                Queue2Stack(pstr);
            }

            FREE(record);
        }

    // LOCATE
    } else if (strcasecmp(tokens[1], "LOCATE") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "LOCATE");

        pos = findToken("KEY", tokens);
        if (pos != -1) {
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // POINT
    } else if (strcasecmp(tokens[1], "POINT") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "POINT");

        pos = findToken("KEY", tokens);
        if (pos != -1) {
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    // WRITE
    } else if (strcasecmp(tokens[1], "WRITE") == 0) {

        unsigned char vname[19];
        int pos;

        PLstr plsValue;
        bool useVar = FALSE;

        LPMALLOC(plsValue)

        pos = findToken("KEY", tokens);
        if (pos != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "WRITEK");
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findToken("NEXT", tokens) != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "WRITEN");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findToken("VAR", tokens);
        if (pos != -1) {
            useVar = TRUE;
            strcpy((char *) vname, tokens[++pos]);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // set record
        if (useVar) {
            getVariable((char *) vname,plsValue);
            params->VSAMREC = (unsigned *) plsValue->pstr;
        } else {
            // pull record from queue
            PLstr pstr = PullFromStack();
            params->VSAMREC = (unsigned int *) LSTR(*pstr);
        }

        params->VSAMRECL = strlen((char *)params->VSAMREC);

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        LPFREE(plsValue)

    // INSERT
    } else if (strcasecmp(tokens[1], "INSERT") == 0) {

        unsigned char vname[19];
        int pos;

        PLstr plsValue;
        bool useVar = FALSE;

        LPMALLOC(plsValue)

        // set function code
        strcpy(params->VSAMFUNC, "INSERT");

        pos = findToken("KEY", tokens);
        if (pos != -1) {
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // use var or queue
        pos = findToken("VAR", tokens);
        if (pos != -1) {
            useVar = TRUE;
            strcpy((char *) vname, tokens[++pos]);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // set record
        if (useVar) {
            getVariable((char *) vname,plsValue);
            params->VSAMREC = (unsigned *) plsValue->pstr;
        } else {
            // pull record from stack
            PLstr pstr;
            pstr = PullFromStack();
            params->VSAMREC = (unsigned int *) LSTR(*pstr);
        }

        params->VSAMRECL = strlen((char *)params->VSAMREC);

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        LPFREE(plsValue)

    // DELETE
    } else if (strcasecmp(tokens[1], "DELETE") == 0) {

        int pos;

        // set function code
        strcpy(params->VSAMFUNC, "DELETEK");

        pos = findToken("KEY", tokens);
        if (pos != -1) {
            strcpy(params->VSAMKEY, tokens[++pos]);
            params->VSAMKEYL = strlen(params->VSAMKEY);
        } else if (findToken("NEXT", tokens) != -1) {
            // set function code
            strcpy(params->VSAMFUNC, "DELETEN");
        } else {
            FREE(params);
            Lerror(ERR_INCORRECT_CALL,0);
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // set DDN
        if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
            strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
        } else {
            rc = -1;
        }

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

        // CLOSE
    } else if (strcasecmp(tokens[1], "CLOSE") == 0) {

        // set function code
        if (strcasecmp(tokens[2], "ALL") == 0) {
            strcpy(params->VSAMFUNC,"CLOSEA");
        } else {
            strcpy(params->VSAMFUNC,"CLOSE");

            // set DDN
            if (strlen(tokens[2]) >= 1 && strlen(tokens[2]) <= 8) {
                strncpy(params->VSAMDDN, tokens[2], strlen(tokens[2]));
            } else {
                rc = -1;
            }
        }

        // set vsam type to KSDS
        params->VSAMTYPE = 'K';

        // call rxvsam
        if (rc == 0) {
            if (vsamsubtSet) {
                params->VSAMSUBTA = environment->VSAMSUBT;
            }

            rc = call_rxvsam(params);
            setVariable("RCX", params->VSAMEXTRC);

            if (!vsamsubtSet) {
                environment->VSAMSUBT = params->VSAMSUBTA;
                vsamsubtSet = TRUE;
            }
        }

    } else {
        FREE(params);
        Lerror(ERR_INCORRECT_CALL,0);
    }

    FREE(params);

    return rc;
}
