#ifndef BREXX_RXDSIO_H
#define BREXX_RXDSIO_H

#include <stdio.h>

/*
 * BREXX's own data set I/O on libc370 (#299): a data set is named either
 * by its data set name or by a DD name, and opened directly through
 * libc370's fopen(), without the JCC layer's global _style.
 *
 * rxOpenDsn() takes a fully qualified name without quotes, with or without
 * "(member)", as getDatasetName() returns it (DSN_NAME_MAX characters at
 * most). rxOpenDd() takes a DD name, with or without "(member)".
 * The mode is libc370's: "r", "w", "a", "b", "+" and its options.
 * Both return NULL with errno EINVAL for a name that does not fit.
 */
FILE *rxOpenDsn(const char *dsn, const char *mode);
FILE *rxOpenDd(const char *ddn, const char *mode);

#endif /* BREXX_RXDSIO_H */
