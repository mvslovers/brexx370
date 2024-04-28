#include "rexx.h"
#include "rxdefs.h"
#include "rxtcp.h"
#include "rxmvsext.h" // TODO: set*VAR* functions should get it's own source file
#include "lstring.h"
#include <errno.h>

#ifdef __CROSS__
# include "jccdummy.h"
#else
  char *inet_ntoa(struct in_addr in);
#endif

#define SELECT_TIMEOUT 2
#define MAX_CLIENTS 256
#define BUFFER_SIZE 4096

SOCKET server_socket;
SOCKET client_sockets[MAX_CLIENTS];

bool tcpInit = FALSE;
size_t num_clients;
size_t wakeup_counter;

int  checkSocket(SOCKET socket);
int  closeSocket(int client_socket);
void closeAllSockets();

bool testX75() {

    SDWA sdwa;
    jmp_buf b;

    int staeret = _setjmp_stae(b, (char *) &sdwa);

    if (staeret == 0) {
        closesocket(0);
        _setjmp_canc();
        return TRUE;
    } else {
        _setjmp_canc();
        return FALSE;
    }
}

void R_tcpinit(__unused int func) {

    wakeup_counter = 0;

    // event constants
    setIntegerVariable("#CONNECT", CONNECT_EVENT);
    setIntegerVariable("#RECEIVE", RECEIVE_EVENT);
    setIntegerVariable("#TIMEOUT", TIMEOUT_EVENT);
    setIntegerVariable("#CLOSE", CLOSE_EVENT);
    setIntegerVariable("#ERROR", ERROR_EVENT);
    setIntegerVariable("#STOP", STOP_EVENT);

    // error constants
    setIntegerVariable("#EOT", EOT);

    // check availability of hercules tcp facility
    tcpInit = testX75();
    if (!tcpInit) Lerror(ERR_HERC_MISSING_X75, 0);
}

void R_tcpserve(__unused int func) {
    int rc = 0;

    unsigned int port;

    struct sockaddr_in sockAddrIn;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);
    get_i(1, port)

    if (server_socket > 0) Lerror(ERR_INCORRECT_CALL, 0);

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket == -1) {
        rc = -1;
    }

    if (rc == 0) {
        sockAddrIn.sin_family = AF_INET;
        sockAddrIn.sin_addr.s_addr = htonl (INADDR_ANY);
        sockAddrIn.sin_port = htons(port);

        rc = bind(server_socket, (struct sockaddr *) &sockAddrIn, sizeof(struct sockaddr));
    }

    if (rc == 0) {
        rc = listen(server_socket, MAX_CLIENTS);
    }

    Licpy(ARGR, rc);
}

void R_tcpwait(__unused int func) {
    int rc = 0;

    int j;
    unsigned int highest;
    unsigned int timeout;
    unsigned int max_wakeup_counter;
    struct timeval timeoutValue;

    fd_set read_set;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN > 1) Lerror(ERR_INCORRECT_CALL, 0);

    if (ARGN == 1) {
        get_i(1, timeout)
    } else {
        timeout = 0;
    }

    if (timeout >= SELECT_TIMEOUT) {
        max_wakeup_counter = timeout / SELECT_TIMEOUT;
    } else {
        max_wakeup_counter = 0;
    }

    // set select timeout
    timeoutValue.tv_sec = SELECT_TIMEOUT;
    timeoutValue.tv_usec = 0;

    Licpy(ARGR, 0);

    while (LINT(*ARGR) == 0) {
        FD_ZERO(&read_set);

        if (server_socket >= 0) {
            highest = (int) server_socket;

            FD_SET(server_socket, &read_set);
            if (num_clients > 0) {
                int ii;

                for (ii = 0; ii < num_clients; ii++) {
                    if (highest < client_sockets[ii]) {
                        highest = (int) client_sockets[ii];
                    }

                    FD_SET(client_sockets[ii], &read_set);
                }
            }

            // TODO: not sure what to do with this magic stuff
            /* copied by Jason Winters FTPD */
            {
                j = ((highest + 31) / 32) - 1; /* Get word ptr to last 'long' */
                while ((j > 0) && ((long *) &read_set)[j] == 0) j--;

                j = ((j + 1) * 32) - 1; /* Highest Socket to check */
                if (j > highest) j = highest; /* may be greater than the known value */

                while ((j >= 0) && (FD_ISSET (j, &read_set) == 0)) j--;

                if (j < 0) j = 0; // Algorithm fix for IBM sockets (descr 0 allowed)
            }

        } else {
            rc = -1; // NO SERVER SOCKET
            Licpy(ARGR, rc);
        }

        if (rc == 0) {
            bool stop = 0;

            // check if the socket is ready to receive
            rc = select(j + 1, &read_set, NULL, NULL, &timeoutValue);
            if (rc == 0) {
#ifndef __CROSS__
                long *s;

                s = (*((long **)548));       // 548->ASCB
                s = ((long **)s) [14];       //  56->CSCB
                if (s) {
                    s = ((long **)s) [11];   //  44->CIB

                    while (s)
                    {
                        if (((unsigned char *)s) [4] == 0x40)
                        {
                            stop = 1;
                            break;
                        }
                        s = ((long **)s) [0];//   0->NEXT-CIB
                    }
                }
#endif
                if (stop) {
                    Licpy(ARGR, STOP_EVENT);
                } else {
                    if (max_wakeup_counter > 0) {
                        wakeup_counter++;
                        if (wakeup_counter >= max_wakeup_counter) {
                            wakeup_counter = 0;
                            Licpy(ARGR, TIMEOUT_EVENT);
                        }
                    }
                }
            } else if (rc < 0) {
                Licpy(ARGR, ERROR_EVENT);
            } else {
                int current_socket;

                rc = 0;  // SET NO ERROR
                for (current_socket = 0; current_socket < FD_SETSIZE; ++current_socket) {
                    if (FD_ISSET (current_socket, &read_set)) {
                        if (current_socket == server_socket) {
                            struct sockaddr_in clientname;
                            socklen_t size;

                            size = sizeof(clientname);

                            num_clients++;
                            client_sockets[num_clients - 1] = accept(server_socket,
                                                                     (struct sockaddr *) &clientname,
                                                                     &size);

                            if (client_sockets[num_clients - 1] < 0) {
                                num_clients--;
                                rc = -2; // ACCEPT FAILED
                            }

                            if (rc == 0) {
                                setVariable("_IP", inet_ntoa(clientname.sin_addr));
                                setIntegerVariable("_PORT", ntohs (clientname.sin_port));
                                setIntegerVariable("_FD", client_sockets[num_clients - 1]);

                                Licpy(ARGR, CONNECT_EVENT);
                            }
                        } else {
                            long available = 0;

                            setIntegerVariable("_FD", current_socket);
                            ioctlsocket(current_socket, FIONREAD, &available);
                            if (available > 0) {
                                setIntegerVariable("_AVAILABLE", (int) available);
                                Licpy(ARGR, RECEIVE_EVENT);
                            } else {
                                closeSocket(current_socket);
                                Licpy(ARGR, CLOSE_EVENT);
                            }
                        }
                    }
                }
            }
        }
    }

}

void R_tcpopen(__unused int func) {
    int rc = 0;

    SOCKET client_socket;

    unsigned long inAddress;
    unsigned int port;
    unsigned int timeout;

    struct sockaddr_in sockAddrIn;
    struct hostent *host;
    struct timeval timeoutValue;

    fd_set write_set;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN < 2) Lerror(ERR_INCORRECT_CALL, 0);
    if (ARGN > 3) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    get_s(1)
    get_i(2, port)
    if (ARGN == 3) {
        get_i(3, timeout)
    } else {
        timeout = 5;
    }

    // set connect timeout
    timeoutValue.tv_sec = timeout;
    timeoutValue.tv_usec = 0;

    // get internet address
    inAddress = inet_addr((const char *) LSTR(*ARG1));
    if ((inAddress) == INADDR_NONE) {
        host = gethostbyname(LSTR(*ARG1));
        if (host == NULL || host->h_addr_list[0] == NULL) {
            rc = -5;
        } else {
            inAddress = ((long *) (host->h_addr_list[0]))[0];
        }
    }

    // create socket
    if (rc == 0) {
        sockAddrIn.sin_family = AF_INET;
        sockAddrIn.sin_addr.s_addr = inAddress;
        sockAddrIn.sin_port = ntohs (port);

        client_socket = socket(PF_INET, SOCK_STREAM, 0);
        if (client_socket == INVALID_SOCKET) {
            rc = -4;
        }
    }

    if (rc == 0) {
        ENABLE_NBIO(client_socket)   // in __CROSS__ only

        rc = connect(client_socket, (LPSOCKADDR) &sockAddrIn, sizeof(sockAddrIn));
        if (errno == WSAEINPROGRESS) rc = 0;
    }

    if (rc == 0) {
        FD_ZERO(&write_set);
        FD_SET(client_socket, &write_set);

        // check if the socket is ready
        select(client_socket + 1, NULL, &write_set, NULL, &timeoutValue);
        if (!FD_ISSET(client_socket, &write_set)) {
            rc = -3;
        }

        DISBLE_NBIO(client_socket)   // in __CROSS__ only
    }

    if (rc == 0) {
        setIntegerVariable("_FD", client_socket);
    }

    Licpy(ARGR, rc);
}

void R_tcpclose(__unused int func) {
    int rc = 0;

    SOCKET client_socket;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);

    get_i(1, client_socket)

    if (checkSocket(client_socket == FALSE)) Lerror(ERR_INCORRECT_CALL, 0);

    rc = closeSocket(client_socket);

    Licpy(ARGR, rc);
}

void R_tcpsend(__unused int func) {
    int rc = 0;

    SOCKET client_socket;

    unsigned int timeout;

    int result;
    size_t remaining;

    char buffer[BUFFER_SIZE];
    struct timeval timeoutValue;

    fd_set write_set;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN < 2) Lerror(ERR_INCORRECT_CALL, 0);
    if (ARGN > 3) Lerror(ERR_INCORRECT_CALL, 0);
    if (LLEN(*ARG2) > BUFFER_SIZE) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG2)

    get_i(1, client_socket)
    get_s(2);
    if (ARGN == 3) {
        get_i(3, timeout)
    } else {
        timeout = 5;
    }

    if (checkSocket(client_socket == FALSE)) Lerror(ERR_INCORRECT_CALL, 0);

    // set send timeout
    timeoutValue.tv_sec = timeout;
    timeoutValue.tv_usec = 0;

    bzero(buffer, BUFFER_SIZE);
    strncpy (buffer, (char *) LSTR(*ARG2), MIN(BUFFER_SIZE, LLEN(*ARG2)));

    remaining = strlen(buffer);

    ENABLE_NBIO(client_socket)   // in __CROSS__ only

    while (rc == 0 && remaining > 0) {
        FD_ZERO(&write_set);
        FD_SET(client_socket, &write_set);

        // check if the socket is ready to send
        select(client_socket + 1, NULL, &write_set, NULL, &timeoutValue);
        if (!FD_ISSET(client_socket, &write_set)) {
            rc = -2;
        }

        if (rc == 0) {
            result = send(client_socket, buffer, remaining, 0);
            if (result == SOCKET_ERROR) {
                result = WSAGetLastError();
                if (result != WSAEWOULDBLOCK) {
                    rc = -1;
                    break;
                }
            }
            remaining -= result;
        }
    }

    // return count of bytes send
    LINT(*ARGR) = rc;
    LTYPE(*ARGR) = LINTEGER_TY;
    LLEN(*ARGR) = sizeof(long);
}

void R_tcprecv(__unused int func) {
    int rc = 0;

    SOCKET client_socket;

    unsigned int timeout;

    int result = 0;

    char buffer[BUFFER_SIZE];
    struct timeval timeoutValue;

    fd_set read_set;

    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    if (ARGN < 1) Lerror(ERR_INCORRECT_CALL, 0);
    if (ARGN > 2) Lerror(ERR_INCORRECT_CALL, 0);

    get_i(1, client_socket)
    if (ARGN == 2) {
        get_i(2, timeout)
    } else {
        timeout = 30;
    }

    if (checkSocket(client_socket == FALSE)) Lerror(ERR_INCORRECT_CALL, 0);

    // set receive timeout
    timeoutValue.tv_sec = timeout;
    timeoutValue.tv_usec = 0;

    bzero(buffer, BUFFER_SIZE);
    setVariable("_DATA", buffer);

    ENABLE_NBIO(client_socket)   // in __CROSS__ only

    FD_ZERO(&read_set);
    FD_SET(client_socket, &read_set);

    // check if the socket is ready to receive
    select(client_socket + 1, &read_set, NULL, NULL, &timeoutValue);
    if (!FD_ISSET(client_socket, &read_set)) {
        rc = -1;
    }

    if (rc == 0) {
        long available = 0;
        long read = 0;
        ioctlsocket(client_socket, FIONREAD, &available);
        read = MIN(BUFFER_SIZE, available);
        if (read < available) rc = 42;

        result = recv(client_socket, buffer, read, 0);

        // receive data
        if (result == SOCKET_ERROR) {
            result = WSAGetLastError();
            if (result != WSAEWOULDBLOCK) {
                result = 0;
                rc = -2;
            } else {
                result = 0;
            }
        }

        setVariable("_DATA", buffer);

        DISBLE_NBIO(client_socket)
    }

    /*
    // detect EOT
    if (buffer[0] == 0x37 || buffer[0] == 0x04)
    {
        rc = EOT;
    }
    */

    if (rc == 0 && result > 0) {
        Licpy(ARGR, result);
    } else {
        Licpy(ARGR, rc);
    }
}

void R_tcpterm(__unused int func) {
    if (!tcpInit) Lerror(ERR_TCPIP_NOT_INIT, 0);

    closeAllSockets();
}

/* register rexx functions to brexx/370 */
void RxTcpRegFunctions() {
#ifndef WIN32   // don't compile in Windows
    RxRegFunction("TCPINIT", R_tcpinit, 0);
    RxRegFunction("TCPSERVE", R_tcpserve, 0);
    RxRegFunction("TCPWAIT", R_tcpwait, 0);
    RxRegFunction("TCPOPEN", R_tcpopen, 0);
    RxRegFunction("TCPCLOSE", R_tcpclose, 0);
    RxRegFunction("TCPRECEIVE", R_tcprecv, 0);
    RxRegFunction("TCPSEND", R_tcpsend, 0);
    RxRegFunction("TCPTERM", R_tcpterm, 0);
#endif
} /* RxTcpRegFunctions() */

void RxResetTcpIp() {
    if (tcpInit) {
        closeAllSockets();
    }
}

/* internal functions */
int checkSocket(SOCKET socket) {
    bool found = FALSE;

    if (num_clients > 0) {
        int ii;

        for (ii = 0; ii <= num_clients - 1; ii++) {
            if (client_sockets[ii] == socket) {
                found = TRUE;
            }
        }
    }

    return found;
}

int closeSocket(int client_socket) {
    int rc = 0;

    if (num_clients > 0) {
        int ii;
        int pos = 0;

        for (ii = 0; ii <= num_clients - 1; ii++) {
            if (client_sockets[ii] == client_socket) {
                rc  = closesocket(client_socket);
                pos = ii;
            }
        }

        if (rc == 0) {
            for (ii = pos; ii <= num_clients - 1; ii++) {
                client_sockets[ii] = client_sockets[ii + 1];
            }
        }

        num_clients--;
    }

    return rc;
}

void closeAllSockets() {
    int ii;

    closesocket(server_socket);

    for (ii = 0; ii < num_clients; ++ii) {
        closesocket(client_sockets[ii]);
    }
}

// TODO: copyright notiz hinzufügen
#ifndef __CROSS__
char *inet_ntoa(struct in_addr in) {
    static char b[18];
    register char *p;

    p = (char *) &in;
#define    UC(b)    (((int)b)&0xff)
    (void) snprintf(b, sizeof(b),
                    "%d.%d.%d.%d", UC(p[0]), UC(p[1]), UC(p[2]), UC(p[3]));
    return (b);
}
#endif
