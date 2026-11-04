/*
 * The attention exit (#610). An attention (PA1) ends the exec as HALT does
 * under TSO/E REXX, through BREXX's own end, so that ECTENVBK is given
 * back. The exit (asm/rxstax.asm) only sets a flag; RxAttnRaise() is what
 * the interpreter does with it at a clause boundary.
 */
#include <stdio.h>
#include "rexx.h"
#include "rxmvsext.h"

#ifdef __CROSS__

int RxAttnOn(void)  { return 0; }
int RxAttnOff(void) { return 0; }

#else

static int attn_on;     /* the exit of this copy is established */

/* The exec runs on without the exit when STAX refuses it, but says so. */

/* the exec is about to run */
int
RxAttnOn(void)
{
    int rc;

    if (attn_on) return 0;
    rc = RxStaxOn();
    if (rc == 0) {
        attn_on = 1;
    } else {
        fprintf(STDERR, "BRX0004W - ATTENTION EXIT NOT ESTABLISHED, STAX RC %d\n", rc);
    }
    return rc;
} /* RxAttnOn */

/* the exec is over, or aborted. Safe to call again. */
int
RxAttnOff(void)
{
    int rc;

    if (!attn_on) return 0;
    attn_on = 0;
    rc = RxStaxOff();
    RxAttn = 0;
    if (rc != 0) {
        fprintf(STDERR, "BRX0005W - ATTENTION EXIT NOT CANCELLED, STAX RC %d\n", rc);
    }
    return rc;
} /* RxAttnOff */

/* the flag is set: clear it and raise HALT like the signal did */
void
RxAttnRaise(void)
{
    RxAttn = 0;
    RxHaltTrap(0);
} /* RxAttnRaise */

#endif
