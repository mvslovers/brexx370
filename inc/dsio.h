#ifndef BREXX_DSIO_H
#define BREXX_DSIO_H

#include <stdio.h>
#include <mvs/dslist.h>

/* a data set name with member: 44 + "(" + 8 + ")" (also in util.h) */
#ifndef DSN_NAME_MAX
#define DSN_NAME_MAX 54
#endif

/*
 * BREXX's own data set I/O on libc370 (#299): a data set is named either
 * by its data set name or by a DD name, and opened directly through
 * libc370's fopen(), without the JCC layer's global _style.
 *
 * rxOpenDsn() takes a fully qualified name, with or without "(member)", as
 * getDatasetName() returns it (DSN_NAME_MAX characters at most). A name
 * already in quotes, or a temporary one starting with '&', is used as it
 * stands, as jcc_fopen() did. rxOpenDd() takes a DD name, with or without "(member)".
 * The mode is libc370's: "r", "w", "a", "b", "+" and its options.
 * Both return NULL with errno EINVAL for a name that does not fit.
 */
FILE *rxOpenDsn(const char *dsn, const char *mode);
FILE *rxOpenDd(const char *ddn, const char *mode);


/*
 * rxWalkDir() hands every entry of a PDS directory to fn, in directory
 * order: libc370's __walkpd() (BPAM), for a data set name as rxOpenDsn()
 * takes it or, with byDd, a DD name. fn returns 0 to go on. Returns the
 * number of entries handed over, or -1 when the directory could not be
 * read (#144).
 */
int rxWalkDir(const char *name, int byDd, PDS_WALK fn, void *arg);

/*
 * rxDsAttr() looks a cataloged data set up (catalog, then its format-1
 * DSCB): its first volume and its DSORG as "PS", "PO", "DA", "IS" or
 * "??". dsn is fully qualified, without quotes or member. Returns 0, or
 * -1 when it is not cataloged or the DSCB cannot be read.
 */
int rxDsAttr(const char *dsn, char volser[6 + 1], char dsorg[2 + 1]);

/*
 * rxCreateDsn() creates and catalogs a data set (dynamic allocation,
 * DISP=(NEW,CATLG,DELETE), then freed again) from an allocation string:
 * comma separated KEY=value, case does not matter --
 *   DSORG=PS|PO  RECFM=F|FB|V|VB|U|... (+A, M, S)  LRECL=n  BLKSIZE=n
 *   PRI=n  SEC=n (tracks)  DIRBLKS=n  UNIT=name
 * DSORG is PO when DIRBLKS is given, else PS; a PO without DIRBLKS gets
 * 5; space is 1 primary and 1 secondary track unless given; UNIT is
 * SYSDA. dsn is fully qualified, without quotes or member.
 * Returns 0, -1 when it cannot be created (also for an unknown key or a
 * bad value), -2 when it is cataloged already (#299).
 */
int rxCreateDsn(const char *dsn, const char *attrs);

#endif /* BREXX_DSIO_H */
