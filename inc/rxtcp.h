#ifndef __RXTCP_H
#define __RXTCP_H

#ifdef JCC
#include <io.h>
#include <time.h>
#include "sockets.h"
#include "mvsutils.h"
#include "rxmvsext.h"

#define __unused
typedef long    socklen_t;
#endif

#ifdef __CROSS__
#    define ENABLE_NBIO(FD) {                            \
                              int flag = 1;              \
                              ioctl (FD, FIONBIO, &flag);\
                            }
#    define DISBLE_NBIO(FD) {                            \
                              int flag = 0;              \
                              ioctl (FD, FIONBIO, &flag);\
                            }
#else
#    define ENABLE_NBIO(FD)                              \
                            while(0);
#    define DISBLE_NBIO(FD)                              \
                            while(0);
#endif

/* events */
#define CONNECT_EVENT     1
#define RECEIVE_EVENT     2
#define TIMEOUT_EVENT     3
#define CLOSE_EVENT       4
#define ERROR_EVENT       5
#define STOP_EVENT        6

/* return values */
#define EOT             -55

/* functions */
void RxTcpRegFunctions();
void ResetTcpIp();

#endif //__RXTCP_H
