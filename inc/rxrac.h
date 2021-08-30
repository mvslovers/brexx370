#ifndef __RXRAC_H
#define __RXRAC_H

#ifdef JCC
#define __unused
#endif

#define FACILITY    (const char *) "FACILITY"

#define AUTH_ALL    (const char *) "BRXALLAUTH"
#define PRIVILAGE   (const char *) "BRXPRIVAUTH"
#define CONSOLE     (const char *) "BRXCONSAUTH"
#define MTT         (const char *) "BRXMTTAUTH"
#define SMF         (const char *) "BRXSMFAUTH"
#define CP          (const char *) "BRXCPAUTH"

#define READ        (const char *) "READ"
#define ALTER       (const char *) "ALTER"

void RxRacRegFunctions();

#endif //__RXRAC_H
