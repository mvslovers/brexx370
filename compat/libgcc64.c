/*
 * libgcc64.c - 64-bit integer support routines for the cc370 build
 *
 * GCC implements "long long" multiply/divide by calling __muldi3,
 * __divdi3, __udivdi3, __moddi3 and __umoddi3 (MVS names @@MULDI3, ...).
 * libc370 acts as cc370's libgcc but does not provide these (it has its own
 * __64 type instead), so BREXX carries them until libc370 does.
 * TODO(cc370): move to libc370 (mvslovers/libc370#187).
 *
 * The work is done on explicit 32-bit halves, so these routines never call
 * themselves recursively.
 */
#if !defined(JCC) && !defined(__CROSS__)

typedef union {
    unsigned long long u;
    long long          s;
    struct {
        unsigned hi;            /* S/370 is big-endian */
        unsigned lo;
    } w;
} dw_t;

/* 32 x 32 -> 64 bit unsigned multiply using 16-bit partial products */
static void
mul32(unsigned a, unsigned b, unsigned *hi, unsigned *lo)
{
    unsigned a0 = a & 0xFFFF, a1 = a >> 16;
    unsigned b0 = b & 0xFFFF, b1 = b >> 16;
    unsigned p00 = a0 * b0, p01 = a0 * b1, p10 = a1 * b0, p11 = a1 * b1;
    unsigned mid = (p00 >> 16) + (p01 & 0xFFFF) + (p10 & 0xFFFF);

    *lo = (p00 & 0xFFFF) | (mid << 16);
    *hi = p11 + (p01 >> 16) + (p10 >> 16) + (mid >> 16);
}

/* 64 / 64 bit unsigned restoring division */
static void
udivmod(unsigned nh, unsigned nl, unsigned dh, unsigned dl,
        unsigned *qh, unsigned *ql, unsigned *rh, unsigned *rl)
{
    unsigned h = 0, l = 0, xh = 0, xl = 0;
    int i;

    if (dh == 0 && dl == 0) {           /* undefined, do not loop */
        *qh = *ql = 0xFFFFFFFF;
        *rh = nh; *rl = nl;
        return;
    }

    for (i = 0; i < 64; i++) {
        h  = (h << 1) | (l >> 31);
        l  = (l << 1) | (nh >> 31);
        nh = (nh << 1) | (nl >> 31);
        nl <<= 1;
        xh = (xh << 1) | (xl >> 31);
        xl <<= 1;
        if (h > dh || (h == dh && l >= dl)) {
            unsigned borrow = l < dl;
            l -= dl;
            h -= dh + borrow;
            xl |= 1;
        }
    }
    *qh = xh; *ql = xl;
    *rh = h;  *rl = l;
}

static void
neg(dw_t *v)
{
    v->w.lo = ~v->w.lo + 1;
    v->w.hi = ~v->w.hi + (v->w.lo == 0);
}

long long __muldi3(long long a, long long b)                     asm("@@MULDI3");
unsigned long long __udivdi3(unsigned long long a,
                             unsigned long long b)               asm("@@UDIVDI");
unsigned long long __umoddi3(unsigned long long a,
                             unsigned long long b)               asm("@@UMODDI");
long long __divdi3(long long a, long long b)                     asm("@@DIVDI3");
long long __moddi3(long long a, long long b)                     asm("@@MODDI3");

long long
__muldi3(long long a, long long b)
{
    dw_t x, y, r;
    unsigned hi, lo, t1, t2, dummy;

    x.s = a;
    y.s = b;
    mul32(x.w.lo, y.w.lo, &hi, &lo);
    mul32(x.w.lo, y.w.hi, &dummy, &t1);
    mul32(x.w.hi, y.w.lo, &dummy, &t2);
    r.w.hi = hi + t1 + t2;
    r.w.lo = lo;
    return r.s;
}

unsigned long long
__udivdi3(unsigned long long a, unsigned long long b)
{
    dw_t n, d, q, r;

    n.u = a;
    d.u = b;
    udivmod(n.w.hi, n.w.lo, d.w.hi, d.w.lo, &q.w.hi, &q.w.lo, &r.w.hi, &r.w.lo);
    return q.u;
}

unsigned long long
__umoddi3(unsigned long long a, unsigned long long b)
{
    dw_t n, d, q, r;

    n.u = a;
    d.u = b;
    udivmod(n.w.hi, n.w.lo, d.w.hi, d.w.lo, &q.w.hi, &q.w.lo, &r.w.hi, &r.w.lo);
    return r.u;
}

long long
__divdi3(long long a, long long b)
{
    dw_t n, d, q, r;
    int negative = 0;

    n.s = a;
    d.s = b;
    if (n.w.hi & 0x80000000) { neg(&n); negative = !negative; }
    if (d.w.hi & 0x80000000) { neg(&d); negative = !negative; }
    udivmod(n.w.hi, n.w.lo, d.w.hi, d.w.lo, &q.w.hi, &q.w.lo, &r.w.hi, &r.w.lo);
    if (negative) neg(&q);
    return q.s;
}

long long
__moddi3(long long a, long long b)
{
    dw_t n, d, q, r;
    int negative = 0;

    n.s = a;
    d.s = b;
    if (n.w.hi & 0x80000000) { neg(&n); negative = 1; }  /* sign of dividend */
    if (d.w.hi & 0x80000000) { neg(&d); }
    udivmod(n.w.hi, n.w.lo, d.w.hi, d.w.lo, &q.w.hi, &q.w.lo, &r.w.hi, &r.w.lo);
    if (negative) neg(&r);
    return r.s;
}

#endif /* !JCC && !__CROSS__ */
