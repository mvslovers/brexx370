#ifndef __JCCDUMMY_H
#define __JCCDUMMY_H

#if __CROSS__

#include <unistd.h>
#include <errno.h>
#include <sys/time.h>

/* SOCKET STUFF */
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <setjmp.h>

char* _style;
void ** entry_R13;
int __libc_tso_status;

int __get_ddndsnmemb (int handle, char * ddn, char * dsn,
                      char * member, char * serial, unsigned char * flags);

int _setjmp_stae (jmp_buf jbs, char * sdwa104);
int _setjmp_canc (void);
int _write2op  (char * msg);

#define SOCKET      int
#define SOCKADDR_IN struct sockaddr_in
#define LPSOCKADDR  struct sockaddr *
#define INVALID_SOCKET (-1)
#define SOCKET_ERROR   (-1)
#define WSAGetLastError() errno
#define ioctlsocket ioctl
#define closesocket close

#define WSAEINVAL          EINVAL
#define WSAEWOULDBLOCK     EWOULDBLOCK
#define WSAEINPROGRESS     EINPROGRESS
#define WSAEALREADY        EALREADY
#define WSAENOTSOCK        ENOTSOCK
#define WSAEDESTADDRREQ    EDESTADDRREQ
#define WSAEMSGSIZE        EMSGSIZE
#define WSAEPROTOTYPE      EPROTOTYPE
#define WSAENOPROTOOPT     ENOPROTOOPT
#define WSAEPROTONOSUPPORT EPROTONOSUPPORT
#define WSAESOCKTNOSUPPORT ESOCKTNOSUPPORT
#define WSAEOPNOTSUPP      EOPNOTSUPP
#define WSAEPFNOSUPPORT    EPFNOSUPPORT
#define WSAEAFNOSUPPORT    EAFNOSUPPORT
#define WSAEADDRINUSE      EADDRINUSE
#define WSAEADDRNOTAVAIL   EADDRNOTAVAIL
#define WSAENETDOWN        ENETDOWN
#define WSAENETUNREACH     ENETUNREACH
#define WSAENETRESET       ENETRESET
#define WSAECONNABORTED    ECONNABORTED
#define WSAECONNRESET      ECONNRESET
#define WSAENOBUFS         ENOBUFS
#define WSAEISCONN         EISCONN
#define WSAENOTCONN        ENOTCONN
#define WSAESHUTDOWN       ESHUTDOWN
#define WSAETOOMANYREFS    ETOOMANYREFS
#define WSAETIMEDOUT       ETIMEDOUT
#define WSAECONNREFUSED    ECONNREFUSED
#define WSAELOOP           ELOOP
#define WSAENAMETOOLONG    ENAMETOOLONG
#define WSAEHOSTDOWN       EHOSTDOWN
#define WSAEHOSTUNREACH    EHOSTUNREACH
#define WSAENOTEMPTY       ENOTEMPTY
#define WSAEPROCLIM        EPROCLIM
#define WSAEUSERS          EUSERS
#define WSAEDQUOT          EDQUOT
#define WSAESTALE          ESTALE
#define WSAEREMOTE         EREMOTE

#endif
#endif //__JCCDUMMY_H
