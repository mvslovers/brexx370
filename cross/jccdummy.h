#ifndef __JCCDUMMY_H
#define __JCCDUMMY_H

#if defined(__CROSS__)

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
int  __libc_tso_status;
long __libc_heap_used;
long __libc_heap_max;
long __libc_stack_used;
long __libc_stack_max;

int _open (char * filename, int open_flags);
int __bldl (int handle);
int _close (int handle);
int __get_ddndsnmemb (int handle, char * ddn, char * dsn,
                      char * member, char * serial, unsigned char * flags);

int _testauth (void);
int _modeset (int p);
int _setjmp_stae (jmp_buf jbs, char * sdwa104);
int _setjmp_estae (jmp_buf jbs, char * sdwa512);
int _setjmp_ecanc (void);
int _setjmp_canc (void);
int _write2op  (char * msg);
time_t time (time_t * timer);
char * strupr (char * string);
int _msize(void *ptr);


/* process.h */
#define CRITICAL_SECTION   long
#define LPCRITICAL_SECTION long *

#define WAIT   0
#define NOWAIT 1

void    InitialiseCriticalSection (LPCRITICAL_SECTION lock);
#define InitializeCriticalSection InitialiseCriticalSection

void    EnterCriticalSection (LPCRITICAL_SECTION lock);
void    LeaveCriticalSection (LPCRITICAL_SECTION lock);
long beginthread (int(*start_address)(void *), unsigned, void *);
int  threadstatus (long threadid, long mode); // mode 0=stop 1=start
int  threadpriority (long threadid, long value); // value +/- current
void endthread (int);
int  syncthread (long);

void Sleep (long value);

int  systemTSO (char *);
char *getlogin();
char * itoa (int v, char * buffer, int radix);

#define INFINITE -1
#define WAIT_OBJECT_0 0
#define WAIT_TIMEOUT -2
#define WAIT_FAILED -1

typedef struct event_tag * EVENT;

EVENT CreateEvent (int initial_state);

int   ResetEvent (EVENT e);
int   SetEvent (EVENT e);
int   EventStatus (EVENT e);
int   CloseEvent (EVENT e);

int   WaitForSingleEvent (EVENT e, int ms);
int   WaitForMultipleEvents (int Count, EVENT * arr, int WaitAll, int ms);

/* tcp */
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

// IO Stuff
#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#ifndef EOF
#define EOF (-1)
#endif

#define _O_RDONLY 0x0000
#define _O_WRONLY 0x0001
#define _O_RDWR   0x0002

#define _O_TEXT   0x0004
#define _O_BINARY 0x0008

#define _O_APPEND 0x0010
#define _O_TRUNC  0x0020

#define _O_CREAT  0x0040
#define _O_EXCL   0x0080

#define _O_ATTRS  0x0100 /* Special case for MVS-OS/390-zOS */

#define O_APPEND  _O_APPEND
#define O_BINARY  _O_BINARY
#define O_CREAT   _O_CREAT
#define O_EXCL    _O_EXCL
#define O_RDONLY  _O_RDONLY
#define O_RDWR    _O_RDWR
#define O_TEXT    _O_TEXT
#define O_TRUNC   _O_TRUNC
#define O_WRONLY  _O_WRONLY

#define SEEK_SET  0
#define SEEK_CUR  1
#define SEEK_END  2
#endif
#endif //__JCCDUMMY_H
