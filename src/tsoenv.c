/* -------------------------------------------------------------------------------------
 * The TSO environment BREXX reports through SYSVAR and isTSO(), isTSOFG(),
 * isISPF(): foreground or background, the data set prefix, the user id
 * and ISPF. Until #353 this was the
 * assembler module RXINIT (asm/rxinit.asm). libc370's startup has already
 * issued the EXTRACT it used (TSO flag and PSCB, in the PPA), so what is
 * left is reading control blocks. BREXX allocates no terminal DDs any more
 * and publishes nothing in ECTENVBK.
 * -------------------------------------------------------------------------------------
 */
#include <string.h>
#include "rexx.h"
#include "rxmvsext.h"
#include "rac.h"
#ifdef __MVS__
#include <mvs/crt.h>
#include <ibm/mvs/ikjpscb.h>
#endif

extern const unsigned char _TSOFG;
extern const unsigned char _TSOBG;
extern const unsigned char _ISPF;

#ifdef __MVS__
/* ISPQRY answers 0 under ISPF; it is looked for first, as LINK to a
 * missing module abends S806 */
static int ispfActive(void)
{
    return findLoadModule("ISPQRY") &&
           linkLoadModule("ISPQRY  ", NULL, NULL) == 0;
}

/* Copy a blank padded field, at most len characters, without the blanks */
static void copyField(char *to, size_t size, const char *from, size_t len)
{
    if (len >= size)
        len = size - 1;
    while (len > 0 && from[len - 1] == ' ')
        len--;
    memcpy(to, from, len);
    to[len] = '\0';
}
#endif

void tsoEnvInit(RX_ENVIRONMENT_CTX_PTR env)
{
#ifdef __MVS__
    CLIBPPA *ppa = __ppaget();
    PSCB    *pscb;

    if (ppa == NULL)
        return;
    if (ppa->ppaflag & PPAFLAG_TSOFG)
        env->flags2 |= _TSOFG;
    if (ppa->ppaflag & PPAFLAG_TSOBG)   /* a PSCB, also in the foreground */
        env->flags2 |= _TSOBG;
    if ((env->flags2 & (_TSOFG | _TSOBG)) == 0)
        return;                         /* not TSO: no SYSVAR values */

    if (ispfActive())
        env->flags2 |= _ISPF;

    pscb = ppa->ppapscb;
    if (pscb != NULL) {
        copyField(env->SYSUID, sizeof(env->SYSUID),
                  pscb->pscbuser, sizeof(pscb->pscbuser));
        if (pscb->pscbupt != NULL)
            copyField(env->SYSPREF, sizeof(env->SYSPREF),
                      pscb->pscbupt->uptprefx,
                      (size_t) (unsigned char) pscb->pscbupt->uptprefl);
    }

    /* RXINIT read the user id from the PSCB in the foreground only; in the
     * background it read a TCB field as ACEE, and SYSUID was empty. A
     * batch TMP's PSCB has no user id either (mvsdev JOB01444), so the
     * background takes it where USERID() does (#353). */
    if (env->SYSUID[0] == '\0' || env->SYSUID[0] == ' ')
        copyField(env->SYSUID, sizeof(env->SYSUID),
                  rac_user(), strlen(rac_user()));

    strcpy(env->SYSENV, (env->flags2 & _TSOFG) ? "FORE" : "BACK");
    strcpy(env->SYSISPF, (env->flags2 & _ISPF) ? "ACTIVE" : "NOT ACTIVE");
#else
    (void) env;
#endif
}
