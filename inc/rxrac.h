#ifndef __RXRAC_H
#define __RXRAC_H

#ifdef JCC
#define __unused
#endif

#define FACILITY    (unsigned char *) "FACILITY"

#define AUTH_ALL    (unsigned char *) "BRXALLAUTH"
#define PRIVILAGE   (unsigned char *) "BRXPRIVAUTH"
#define CONSOLE     (unsigned char *) "BRXCONSAUTH"
#define MTT         (unsigned char *) "BRXMTTAUTH"
#define SMF         (unsigned char *) "BRXSMFAUTH"
#define CP          (unsigned char *) "BRXCPAUTH"

#define READ        (unsigned char *) "READ"
#define ALTER       (unsigned char *) "ALTER"

void RxRacRegFunctions();

#endif //__RXRAC_H
