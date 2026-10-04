#ifndef BREXX_RXDSN_H
#define BREXX_RXDSN_H

#include <stdio.h>

/* the data set functions: ALLOCATE, FREE, CREATE, EXISTS, REMOVE, RENAME,
 * LISTDSI, LISTDSIQ, SYSDSN, DIR, LOCATE, SUBMIT, BLDL, EXEC, __SREAD and
 * __SWRITE (src/rxdsn.c, #302) */
void RxDsnRegFunctions();

/* __SREAD; ARRAYGEN (rxmvs.c) reads its output data set with it */
void R_sread(int func);
/* split str at blanks into at most max words */
void parseArgs(char **array, int max, char *str);
/* SYSDSNAME & co. of an open data set; 0 for non PDS, 1 for PDS, +10 F/FB */
int  parseDCB(FILE *pFile);

#endif /* BREXX_RXDSN_H */
