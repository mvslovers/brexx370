/* -------------------------------------------------------------------------------------
 * The standard streams of a BREXX run (#251, internals/dd-io.md).
 *
 * libc370 opens stdout as *SYSPRINT, stderr as *SYSTERM and stdin as
 * DD:SYSIN; a missing SYSPRINT or SYSTERM becomes a SYSOUT of its own. So
 * the STDOUT/STDERR DDs of a BREXX job were never written, and SAY landed
 * in an unnamed data set. __premain() runs before libc370 opens the three
 * and sets them, in this order:
 *
 *   PUTLINE                   stdout and stderr under a TMP, in batch
 *                             and in the foreground: the TMP's SYSTSPRT
 *                             or the terminal, as TSO/E REXX writes SAY
 *   STDOUT / STDERR / STDIN   otherwise BREXX's own DDs (2.5.3 JCL);
 *                             STDIN also under a TMP
 *   SYSTSPRT / SYSTSIN        only outside TSO, as IRXJCL reads them;
 *                             stderr shares stdout's SYSTSPRT stream
 *   the terminal              TSO foreground stdin, as before (*STDIN)
 *   libc370's default         everything else, as before
 *
 * Under a TMP the TMP holds SYSTSPRT open; a second DCB on it would write
 * without order against the TMP's messages, so BREXX writes through the
 * TMP's PUTLINE (libc370 "*PUTLINE", which finds the TMP without a CPPL
 * and answers NULL without one) and leaves SYSTSIN alone.
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include "rexx.h"

#ifdef __MVS__
#include <mvs/crt.h>
#include <mvs/dd.h>

/* Open DD ddn when the step has it. Looked up first: an OPEN of a
 * missing DD puts IEC130I on the console. */
static FILE *openDd(const char *ddn, const char *mode)
{
    char name[3 + 8 + 1];

    if (get_dsab(NULL, ddn) == NULL)
        return NULL;
    snprintf(name, sizeof(name), "DD:%s", ddn);
    return fopen(name, mode);
}

int __premain(__unused char *parm, __unused char *pgmname,
              __unused void **pgmr1)
{
    CLIBPPA *ppa = __ppaget();
    int      fg  = ppa != NULL && (ppa->ppaflag & PPAFLAG_TSOFG);
    int      tso = ppa != NULL &&
                   (ppa->ppaflag & (PPAFLAG_TSOFG | PPAFLAG_TSOBG));

    stdout = fopen("*PUTLINE", "w");    /* NULL, ENODEV: no TMP */
    if (stdout != NULL) {
        stderr = stdout;
    } else {
        stdout = openDd("STDOUT", "w");
        stderr = openDd("STDERR", "w");
    }
    stdin = openDd("STDIN", "r");

    if (!tso) {
        if (stdout == NULL) {
            stdout = openDd("SYSTSPRT", "w");
            if (stdout != NULL && stderr == NULL)
                stderr = stdout;
        }
        if (stdin == NULL)
            stdin = openDd("SYSTSIN", "r");
    }
    /* libc370 allocates the terminal and frees it at fclose() */
    if (fg && stdin == NULL)
        stdin = fopen("*STDIN", "r");
    return 0;
}
#endif
