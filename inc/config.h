/* inc/config.h.  Generated from config.h.in by configure.  */
/* inc/config.h.in.  Generated from configure.in by autoheader.  */

/* Align bytecode to DWORD */
#define ALIGN 1

/* Support of GREEK character set */
/* #undef GREEK */

/* Define to 1 if you have the <dlfcn.h> header file. */
//#define HAVE_DLFCN_H 0

/* Define to 1 if you have the `dup2' function. */
//#define HAVE_DUP2 1

/* Define to 1 if you have the <fcntl.h> header file. */
//#define HAVE_FCNTL_H 0

/* Define to 1 if you have the `getcwd' function. */
//#define HAVE_GETCWD 0

/* Define to 1 if you have the `gettimeofday' function. */
//#define HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have the <history.h> header file. */
/* #undef HAVE_HISTORY_H */

/* Define to 1 if you have the <inttypes.h> header file. */
//#define HAVE_INTTYPES_H 0

/* Define to 1 if you have the `dl' library (-ldl). */
//#define HAVE_LIBDL 0

/* Define to 1 if you have the `m' library (-lm). */
//#define HAVE_LIBM 0

/* Define to 1 if you have the `nsl' library (-lnsl). */
//#define HAVE_LIBNSL 0

/* Define if you have a readline compatible library */
/* #undef HAVE_READLINE */

/* Define to 1 if you have the <limits.h> header file. */
#define HAVE_LIMITS_H 1

/* Define to 1 if your system has a GNU libc compatible `malloc' function, and
   to 0 otherwise. */
#define HAVE_MALLOC 1

/* Define to 1 if you have the <malloc.h> header file. */
//#define HAVE_MALLOC_H 0

/* Define to 1 if you have the <memory.h> header file. */
//#define HAVE_MEMORY_H 0

/* Define to 1 if you have the `pow' function. */
#define HAVE_POW 1

/* Define to 1 if you have the `putenv' function. */
//#define HAVE_PUTENV 0

/* Define to 1 if you have the <readline.h> header file. */
/* #undef HAVE_READLINE_H */

/* Define if your readline library has \`add_history' */
/* #undef HAVE_READLINE_HISTORY */

/* Define to 1 if you have the <readline/history.h> header file. */
/* #undef HAVE_READLINE_HISTORY_H */

/* Define to 1 if you have the <readline/readline.h> header file. */
/* #undef HAVE_READLINE_READLINE_H */

/* Define to 1 if you have the `setenv' function. */
//#define HAVE_SETENV 0

/* Define to 1 if you have the `sqrt' function. */
#define HAVE_SQRT 1

/* Define to 1 if you have the <stdint.h> header file. */
//#define HAVE_STDINT_H 0

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
//#define HAVE_STRINGS_H 0

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the `strstr' function. */
#define HAVE_STRSTR 1

/* Define to 1 if you have the <sys/stat.h> header file. */
//#define HAVE_SYS_STAT_H 0

/* Define to 1 if you have the <sys/timeb.h> header file. */
//#define HAVE_SYS_TIMEB_H 0

/* Define to 1 if you have the <sys/time.h> header file. */
//#define HAVE_SYS_TIME_H 0

/* Define to 1 if you have the <sys/types.h> header file. */
//#define HAVE_SYS_TYPES_H 0

/* Define to 1 if you have the <unistd.h> header file. */
//#define HAVE_UNISTD_H 0

/* Define to 1 if you have the <values.h> header file. */
//#define HAVE_VALUES_H 0

/* Old MySQL version */
/* #undef OLD_MYSQL */

/* Name of package */
#define PACKAGE "brexx"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "Vasilis.Vlachoudis@cern.ch"

/* Define to the full name of this package. */
#define PACKAGE_NAME "brexx"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "brexx 2.1.9"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "brexx"

/* Define to the version of this package. */
#define PACKAGE_VERSION "2.1.9"

/* Remove the trailing CR from system commands */
#define RMLAST 1

/* mySQL static support */
/* #undef RXMYSQLSTATIC */

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
//#define TIME_WITH_SYS_TIME 0

/* Define to 1 if your <sys/time.h> declares `struct tm'. */
/* #undef TM_IN_SYS_TIME */

/* Version number of package */
#define VERSION "2.1.9"

/* Enable debuging information */
/* #undef __DEBUG__ */

/* Enable profiling information */
/* #undef __PROFILE__ */

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif

/* Define to rpl_malloc if the replacement function should be used. */
/* #undef malloc */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */
/*
   Following sections contains name redefinitions for VM
*/
#include "lmvs.h"
#include "rxmvs.h"
