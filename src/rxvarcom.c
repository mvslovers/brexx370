/*
 * Variable access for assembler programs: the IRXEXCOM calling convention
 * and semantics (SHVBLOCK chain, codes F S D f s d N P, SHVRET flags), on
 * the variables of the running exec (#602).
 *
 * The routine is reached only through the irxexcom entry of the IRXEXTE,
 * whose address a program finds from ECTENVBK -> ENVBLOCK -> IRXEXTE. It
 * has no name of its own that anyone can LOAD or LINK: the stub BRXEXCOM
 * (asm/rxexcom.asm) carries it into C through @@CCALL. The IRX* names are
 * REKX/370's.
 *
 * ECTENVBK points to the ENVBLOCK of this copy for the length of the exec
 * run (RxXcPub / RxXcRst). The ENVBLOCKs of the execs running under one ECT
 * form a chain through the word XC_PREVOFF: the block's predecessor is what
 * ECTENVBK held before the exec started. RxXcRst takes the block out of the
 * chain wherever it is, so execs may end in any order or abend. The same two
 * functions keep the word XC_STKOFF: the input stack element on top when the
 * exec started. The stub BRXEXCOM (asm/rxexcom.asm) uses both to find the
 * copy of BREXX whose exec the caller means, before this C code is entered.
 *
 * Limits:
 *  - the caller must run on the BREXX task: @@CCALL refuses a subtask of a
 *    C program (U3101);
 *  - an out-of-storage error inside the routine ends the exec, which
 *    unwinds across the caller's frames.
 */
#include "ldefs.h"
#include <ctype.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "lerror.h"
#include "lstring.h"
#include "rexx.h"
#include "bintree.h"
#include "interpre.h"
#include "variable.h"
#include "rxmvsext.h"

extern RX_ENVIRONMENT_BLK_PTR env_block;
extern Lstr stemvaluenotfound;          /* from variable.c */

/* libc370 try() (<clibtry.h>): calls func under ESTAE, 0 when it returned,
 * the abend code otherwise. Declared as in rxtcp.c. */
extern int ___try(void *func, ...);

#define XC_MAXNAME   250
#define XC_ADDR24    0x00FFFFFFU
#define XC_ERRFLAGS  (shvtrunc | shvbadn | shvbadv | shvbadf)
#define XC_RCNOENV   28
#define XC_RCNOEXEC  (-1)       /* no exec is running: the CLIST path */

/* ENVBLOCK + X'130': first of the four reserved words at the end of the
 * 320-byte ENVBLOCK. Holds the top input stack element (IOSTELM) while an
 * exec runs, 0 otherwise. The one place that knows the offset. */
#define XC_STKOFF    0x130
#define XC_STKWORD(e) (*(unsigned int *)((char *)(e) + XC_STKOFF))
typedef char xc_stkoff_in_envblock[(XC_STKOFF + 4 <= 320) ? 1 : -1];

/* ENVBLOCK + X'13C': the previous ECTENVBK, the next block down the chain.
 * X'134' and X'138' belong to the IKJCT441 with the REXX path (the current
 * PTF ZP60038): X'134' anchors
 * the chunks of its variable sequences, X'138' holds the TCB that owns
 * them (the task that got them, subpool 1). The owner word is in the block
 * and not in a chunk because the chunks go with their task and reading a
 * freed one abends. BREXX zeroes both words with the block
 * (RxMvsInitialize) and never touches them again. */
#define XC_PREVOFF   0x13C
#define XC_PREV(e)   (*(unsigned int *)((char *)(e) + XC_PREVOFF))
typedef char xc_prevoff_in_envblock[(XC_PREVOFF + 4 <= 320) ? 1 : -1];
#define XC_ENVLEN    320
#define XC_MAXHOPS   256        /* the same limit as BRXEXCOM */

static int          xc_active;      /* an exec is running                */
static int          xc_published;   /* the block is in the chain         */
static unsigned int *xc_ectenvbk;   /* where ECTENVBK is                 */

static int          xc_have;        /* N: a variable was returned        */
static int          xc_intail;      /* N: ...a compound of xc_head       */
static Lstr         xc_head;        /* N: key of its head in the scope   */
static Lstr         xc_tail;        /* N: key of the compound            */

/* ------------------------------------------------------------------ */
/* ECTENVBK                                                           */
/* ------------------------------------------------------------------ */

/* PSAAOLD -> ASCBASXB -> ASXBLWA -> LWAPECT -> ECT. Without an LWA
 * (batch) there is no ECT, and nothing to publish. */
static unsigned int
XcEct(void)
{
    unsigned int ascb, asxb, lwa;

    ascb = *(volatile unsigned int *)(uintptr_t)548 & XC_ADDR24;
    if (!ascb) return 0;
    asxb = *(volatile unsigned int *)(uintptr_t)(ascb + 108) & XC_ADDR24;
    if (!asxb) return 0;
    lwa = *(volatile unsigned int *)(uintptr_t)(asxb + 20) & XC_ADDR24;
    if (!lwa) return 0;
    return *(volatile unsigned int *)(uintptr_t)(lwa + 32) & XC_ADDR24;
} /* XcEct */

/* ECT -> ECTIOWA (+4) -> IOSRL, IOSTELM at +0: the top input stack
 * element, 0 if there is none */
static unsigned int
XcTopStack(unsigned int ect)
{
    unsigned int iosrl;

    iosrl = *(volatile unsigned int *)(uintptr_t)(ect + 4) & XC_ADDR24;
    if (!iosrl) return 0;
    return *(volatile unsigned int *)(uintptr_t)iosrl;
} /* XcTopStack */

/* the exec is about to run: put the block on top of the chain (ECTENVBK),
 * and record the input stack element on top and the previous ECTENVBK in
 * the block first, so that a block in the chain is always complete */
void
RxXcPub(void)
{
    unsigned int ect;

    if (xc_active || !env_block) return;

    LINITSTR(xc_head);
    LINITSTR(xc_tail);
    xc_have = 0;
    xc_intail = 0;
    xc_active = 1;

    ect = XcEct();
    if (ect) {
        xc_ectenvbk = (unsigned int *)(uintptr_t)(ect + 48);
        XC_STKWORD(env_block) = XcTopStack(ect);
        XC_PREV(env_block) = *xc_ectenvbk;
        *xc_ectenvbk = (unsigned int)(uintptr_t)env_block;
        xc_published = 1;
    }
} /* RxXcPub */

/* an ENVBLOCK: eyecatcher and length */
static int
XcIsEnv(unsigned int e)
{
    return MEMCMP((void *)(uintptr_t)e, "ENVBLOCK", 8) == 0 &&
           *(int *)(uintptr_t)(e + 12) == XC_ENVLEN;
} /* XcIsEnv */

/* take our block out of the chain. ECTENVBK points to it: pop. Otherwise
 * blocks of execs that started later are above it: walk down from
 * ECTENVBK, at most XC_MAXHOPS blocks, to the one whose predecessor is
 * ours and give it ours. A value that is not a chain with our block in it
 * (someone else's ECTENVBK) is left alone. Under try(): the value may be
 * a stale pointer. */
static int
XcUnlink(__unused void *unused)
{
    unsigned int me = (unsigned int)(uintptr_t)env_block;
    unsigned int cur = *xc_ectenvbk;
    int          n;

    if (cur == me) {
        *xc_ectenvbk = XC_PREV(env_block);
        return 0;
    }
    for (n = 0; n < XC_MAXHOPS && cur && XcIsEnv(cur); n++) {
        if (XC_PREV(cur) == me) {
            XC_PREV(cur) = XC_PREV(env_block);
            break;
        }
        cur = XC_PREV(cur);
    }
    return 0;
} /* XcUnlink */

/* the exec is over, or aborted: take the block out of the chain, and clear
 * its two words. Safe to call again. */
void
RxXcRst(void)
{
    if (xc_published) {
        ___try((void *)XcUnlink, 0);
        XC_STKWORD(env_block) = 0;
        XC_PREV(env_block) = 0;
        xc_published = 0;
    }
    if (xc_active) {
        LFREESTR(xc_head);
        LFREESTR(xc_tail);
        LINITSTR(xc_head);
        LINITSTR(xc_tail);
        xc_have = 0;
        xc_active = 0;
    }
} /* RxXcRst */

/* ------------------------------------------------------------------ */
/* names and values                                                   */
/* ------------------------------------------------------------------ */

static void *
XcAddr(void *p)
{
    return (void *)((uintptr_t)p & XC_ADDR24);
} /* XcAddr */

static int
XcSymChar(int c)
{
    return isalnum(c) || c == '@' || c == '#' || c == '$' || c == '!' ||
           c == '?' || c == '_' || c == '.';
} /* XcSymChar */

/* a symbol: no digit or dot first; direct: the tail after the first dot
 * is free */
static int
XcNameOk(const unsigned char *s, int len, int direct)
{
    int i;

    if (!s || len < 1 || len > XC_MAXNAME) return 0;
    if (isdigit(s[0]) || s[0] == '.') return 0;
    for (i = 0; i < len; i++) {
        if (s[i] == '.' && direct) return 1;
        if (!XcSymChar(s[i])) return 0;
    }
    return 1;
} /* XcNameOk */

/* the name of a block into name (initialised by the caller), 0 = bad */
static int
XcName(struct shvblock *b, int direct, PLstr name)
{
    const unsigned char *s = (const unsigned char *)XcAddr(b->shvnama);

    if (!XcNameOk(s, b->shvnaml, direct)) return 0;
    Lscpy2(name, (const char *)s, b->shvnaml);
    if (!direct) Lupper(name);
    return 1;
} /* XcName */

/* a compound name: a dot except in the last character */
static int
XcIsCompound(PLstr name)
{
    return MEMCHR(LSTR(*name), '.', LLEN(*name) - 1) != NULL;
} /* XcIsCompound */

/* length of the stem head including its dot */
static size_t
XcHeadLen(PLstr name)
{
    unsigned char *p = MEMCHR(LSTR(*name), '.', LLEN(*name) - 1);

    return (size_t)(p - LSTR(*name)) + 1;
} /* XcHeadLen */

/* DROP of a compound leaves it with its own name as the value */
static int
XcIsDropped(PBinLeaf leaf, const unsigned char *head, size_t headlen)
{
    PLstr v = LEAFVAL(leaf);
    PLstr t = &(leaf->key);

    if (LISNULL(*v)) return 0;
    L2STR(v);
    return LLEN(*v) == headlen + LLEN(*t) &&
           MEMCMP(LSTR(*v), head, headlen) == 0 &&
           MEMCMP(LSTR(*v) + headlen, LSTR(*t), LLEN(*t)) == 0;
} /* XcIsDropped */

/* value into the buffer of a block; returns the SHVRET bits */
static int
XcPut(struct shvblock *b, PLstr val)
{
    char  *buf = (char *)XcAddr(b->shvvala);
    int    n = b->shvbufl;
    size_t len, cp;
    int    ret = 0;

    if (LISNULL(*val)) {
        len = 0;
    } else {
        L2STR(val);
        len = LLEN(*val);
    }
    if (n < 0 || !buf) n = 0;
    cp = len < (size_t)n ? len : (size_t)n;
    if (cp) MEMCPY(buf, LSTR(*val), cp);
    if (len > (size_t)n) ret |= shvtrunc;
    b->shvvall = (int)len;
    return ret;
} /* XcPut */

static PBinLeaf
XcFind(Scope sc, PLstr name, int direct, bool *found)
{
    return direct ? RxVarFindNameDir(sc, name, found)
                  : RxVarFindName(sc, name, found);
} /* XcFind */

/* ------------------------------------------------------------------ */
/* F S D                                                              */
/* ------------------------------------------------------------------ */

static void
XcFetch(Scope sc, struct shvblock *b, int direct)
{
    Lstr     name;
    PBinLeaf leaf;
    bool     found;
    int      ret, comp;

    LINITSTR(name);
    if (!XcName(b, direct, &name)) {
        b->shvret = shvbadn;
        LFREESTR(name);
        return;
    }
    comp = XcIsCompound(&name);
    leaf = XcFind(sc, &name, direct, &found);

    if (found && comp && XcIsDropped(leaf, LSTR(name), XcHeadLen(&name))) {
        ret = shvnewv | XcPut(b, LEAFVAL(leaf));
    } else if (found) {
        ret = XcPut(b, LEAFVAL(leaf));
    } else {
        /* an unset variable has its own name as the value; a compound
         * the default of its stem */
        Lstr dflt;

        LINITSTR(dflt);
        Lstrcpy(&dflt, comp ? &stemvaluenotfound : &name);
        ret = shvnewv | XcPut(b, &dflt);
        LFREESTR(dflt);
    }
    b->shvret = (unsigned char)ret;
    LFREESTR(name);
} /* XcFetch */

static void
XcStore(Scope sc, struct shvblock *b, int direct)
{
    Lstr     name, val;
    PBinLeaf leaf;
    bool     found;
    int      ret = 0, comp;
    int      len = b->shvvall;
    char    *src = (char *)XcAddr(b->shvvala);

    LINITSTR(name);
    if (!XcName(b, direct, &name)) {
        b->shvret = shvbadn;
        LFREESTR(name);
        return;
    }
    if (len < 0 || (len > 0 && !src)) {
        b->shvret = shvbadv;
        LFREESTR(name);
        return;
    }
    LINITSTR(val);
    Lscpy2(&val, len ? src : "", len);

    comp = XcIsCompound(&name);
    leaf = XcFind(sc, &name, direct, &found);
    if (found) {
        if (comp && XcIsDropped(leaf, LSTR(name), XcHeadLen(&name)))
            ret |= shvnewv;
    } else {
        leaf = RxVarAdd(sc, &name, comp, leaf);
        ret |= shvnewv;
    }
    Lstrcpy(LEAFVAL(leaf), &val);
    if (!comp && LSTR(name)[LLEN(name) - 1] == '.')
        RxScopeAssign(leaf);            /* a stem head sets all its tails */

    b->shvret = (unsigned char)ret;
    LFREESTR(val);
    LFREESTR(name);
} /* XcStore */

static void
XcDrop(Scope sc, struct shvblock *b, int direct)
{
    Lstr     name;
    PBinLeaf leaf;
    bool     found;
    int      comp;

    LINITSTR(name);
    if (!XcName(b, direct, &name)) {
        b->shvret = shvbadn;
        LFREESTR(name);
        return;
    }
    comp = XcIsCompound(&name);
    leaf = XcFind(sc, &name, direct, &found);
    if (found && !(comp && XcIsDropped(leaf, LSTR(name), XcHeadLen(&name))))
        RxVarDelName(sc, &name, leaf);
    b->shvret = 0;
    LFREESTR(name);
} /* XcDrop */

/* ------------------------------------------------------------------ */
/* N                                                                  */
/* ------------------------------------------------------------------ */

/* the leaf with the smallest key greater than key (the first if NULL) */
static PBinLeaf
XcAfter(BinTree *tree, PLstr key)
{
    PBinLeaf leaf, best = NULL;

    if (!tree || !tree->parent) return NULL;
    if (!key) return BinMin(tree->parent);
    leaf = tree->parent;
    while (leaf) {
        if (_Lstrcmp(key, &(leaf->key)) < 0) {
            best = leaf;
            leaf = leaf->left;
        } else {
            if (leaf->isThreaded) break;
            leaf = leaf->right;
        }
    }
    return best;
} /* XcAfter */

/* the first compound of a stem after tail (the first if NULL) that was
 * not dropped */
static PBinLeaf
XcCompound(PBinLeaf head, PLstr tail)
{
    Scope    st = ((Variable *)(head->value))->stem;
    PBinLeaf t = XcAfter(st, tail);

    while (t && XcIsDropped(t, LSTR(head->key), LLEN(head->key)))
        t = XcAfter(st, &(t->key));
    return t;
} /* XcCompound */

/* a stem head made by creating a compound has no value of its own */
static int
XcHasValue(PBinLeaf head)
{
    return !LISNULL(*LEAFVAL(head));
} /* XcHasValue */

/* the variable after the cursor: top-level keys in order, a stem head
 * with a value of its own, then its compounds */
static int
XcSucc(Scope sc, PBinLeaf *hl, PBinLeaf *tl)
{
    PBinLeaf h, t;

    *tl = NULL;
    if (!xc_have) {
        h = XcAfter(sc, NULL);
    } else {
        h = BinFind(sc, &xc_head);
        if (h) {
            t = XcCompound(h, xc_intail ? &xc_tail : NULL);
            if (t) { *hl = h; *tl = t; return 1; }
        }
        h = XcAfter(sc, &xc_head);
    }
    while (h) {
        if (XcHasValue(h)) { *hl = h; return 1; }
        t = XcCompound(h, NULL);
        if (t) { *hl = h; *tl = t; return 1; }
        h = XcAfter(sc, &(h->key));
    }
    return 0;
} /* XcSucc */

static void
XcNext(Scope sc, struct shvblock *b)
{
    PBinLeaf h, t;
    char    *buf = (char *)XcAddr(b->shvnama);
    int      n = b->shvuser;
    size_t   len, cp, hl;
    int      ret = 0;

    if (!XcSucc(sc, &h, &t)) {
        xc_have = 0;
        b->shvret = shvlvar;
        return;
    }

    len = LLEN(h->key) + (t ? LLEN(t->key) : 0);
    if (n < 0 || !buf) n = 0;
    cp = len < (size_t)n ? len : (size_t)n;
    if (cp) {
        hl = LLEN(h->key) < cp ? LLEN(h->key) : cp;
        MEMCPY(buf, LSTR(h->key), hl);
        if (t && cp > hl) MEMCPY(buf + hl, LSTR(t->key), cp - hl);
    }
    if (len > (size_t)n) ret |= shvtrunc;
    b->shvnaml = (int)len;
    ret |= XcPut(b, LEAFVAL(t ? t : h));

    Lstrcpy(&xc_head, &(h->key));
    if (t) Lstrcpy(&xc_tail, &(t->key));
    xc_intail = t != NULL;
    xc_have = 1;
    b->shvret = (unsigned char)ret;
} /* XcNext */

/* ------------------------------------------------------------------ */
/* P                                                                  */
/* ------------------------------------------------------------------ */

/* PARM, PARM.n, VERSION */
static void
XcPriv(struct shvblock *b)
{
    Lstr   name, val;
    int    ok = 1;
    const unsigned char *s = (const unsigned char *)XcAddr(b->shvnama);
    RxProc *pr = _proc + _rx_proc;

    if (!XcNameOk(s, b->shvnaml, 1)) {
        b->shvret = shvbadn;
        return;
    }
    LINITSTR(name);
    LINITSTR(val);
    Lscpy2(&name, (const char *)s, b->shvnaml);
    Lupper(&name);

    if (LLEN(name) == 7 && MEMCMP(LSTR(name), "VERSION", 7) == 0) {
        Lscpy(&val, VERSIONSTR);
    } else if (LLEN(name) == 4 && MEMCMP(LSTR(name), "PARM", 4) == 0) {
        Lfx(&val, sizeof(long));
        Licpy(&val, pr->arg.n);
    } else if (LLEN(name) > 5 && LLEN(name) < 15 &&
               MEMCMP(LSTR(name), "PARM.", 5) == 0) {
        long   i = 0;
        size_t k;

        for (k = 5; k < LLEN(name); k++) {
            if (!isdigit(LSTR(name)[k])) { ok = 0; break; }
            i = i * 10 + (LSTR(name)[k] - '0');
        }
        if (ok && i < 1) ok = 0;
        if (ok) {
            if (i <= pr->arg.n && i <= MAXARGS && pr->arg.a[i - 1])
                Lstrcpy(&val, pr->arg.a[i - 1]);
            else
                Lscpy2(&val, "", 0);
        }
    } else {
        ok = 0;
    }

    if (ok)
        b->shvret = (unsigned char)XcPut(b, &val);
    else
        b->shvret = shvbadn;
    LFREESTR(val);
    LFREESTR(name);
} /* XcPriv */

/* ------------------------------------------------------------------ */
/* the entry                                                          */
/* ------------------------------------------------------------------ */

/*
 * list is the caller's parameter list (the stub passes it on), whose
 * entries are: 'IRXEXCOM', two reserved, the first SHVBLOCK, optionally
 * an ENVBLOCK and the address of a fullword for the return code. X'80'
 * marks the last entry. envp is the caller's R0: the ENVBLOCK the stub
 * was entered with, which is ours (BRXEXCOM does not enter C otherwise).
 *
 * R15: 0, or the OR of the error flags (TRUNC, BADN, BADV, BADF) of all
 * blocks; shvrcinv (-1 as well, a bad parameter list); XC_RCNOEXEC (-1)
 * when no exec is running; 28 when the ENVBLOCK in the list is not the one
 * in R0. A non-zero code is also stored in the sixth parameter when there
 * is one.
 */
int
RxXcom(void *list, void *envp)
{
    const unsigned int *pl = (const unsigned int *)XcAddr(list);
    void  *arg[6];
    int    n = 0, rc = 0;
    Scope  sc = NULL;
    struct shvblock *b;

    if (pl) {
        while (n < 6) {
            unsigned int w = pl[n];

            arg[n++] = XcAddr((void *)(uintptr_t)w);
            if (w & 0x80000000U) break;
        }
    }

    if (n < 4 || !arg[0] || MEMCMP(arg[0], "IRXEXCOM", 8) != 0 || !arg[3]) {
        rc = shvrcinv;
    } else if (!xc_active || !_proc || _rx_proc < 0 ||
               !(sc = _proc[_rx_proc].scope)) {
        rc = XC_RCNOEXEC;
    } else if (n > 4 && arg[4] && arg[4] != XcAddr(envp)) {
        rc = XC_RCNOENV;
    } else {
        for (b = (struct shvblock *)arg[3]; b;
             b = (struct shvblock *)XcAddr(b->shvnext)) {
            b->shvret = 0;
            if (b->shvcode != shvnextv) xc_have = 0;
            switch (b->shvcode) {
                case shvfetch: XcFetch(sc, b, 1); break;
                case shvsyfet: XcFetch(sc, b, 0); break;
                case shvstore: XcStore(sc, b, 1); break;
                case shvsyset: XcStore(sc, b, 0); break;
                case shvdropv: XcDrop(sc, b, 1);  break;
                case shvsydro: XcDrop(sc, b, 0);  break;
                case shvnextv: XcNext(sc, b);     break;
                case shvpriv:  XcPriv(b);         break;
                default:       b->shvret = shvbadf; break;
            }
            rc |= b->shvret & XC_ERRFLAGS;
        }
    }

    if (rc && n > 5 && arg[5])
        *(int *)arg[5] = rc;
    return rc;
} /* RxXcom */
