#ifndef __RXRAC_H
#define __RXRAC_H

#ifdef JCC
#define __unused
#endif

#define FACILITY    (const char *) "FACILITY"

#define SVC244      (const char *) "SVC244"
#define DIAG8       (const char *) "DIAG8CMD"

#define READ        (const char *) "READ"
#define ALTER       (const char *) "ALTER"

void RxRacRegFunctions();

#endif //__RXRAC_H
