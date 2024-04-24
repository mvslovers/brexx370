/*
 * $Id: os.h,v 1.10 2009/06/02 09:41:43 bnv Exp $
 * $Log: os.h,v $
 * Revision 1.10  2009/06/02 09:41:43  bnv
 * MVS/CMS corrections
 *
 * Revision 1.9  2008/07/14 13:09:21  bnv
 * MVS,CMS support
 *
 * Revision 1.8  2006/01/26 10:29:52  bnv
 * Corrected for Windows CE
 *
 * Revision 1.7  2003/11/04 09:48:17  bnv
 * REMOVED: the mkstemp
 * mkstemp was openning the file and returing the file handle
 *
 * Revision 1.6  2003/02/12 16:38:39  bnv
 * Added: pragma to disable the signed/unsigned comparison warning
 *
 * Revision 1.5  2002/08/22 12:30:34  bnv
 * Added: UNIX define
 *
 * Revision 1.4  2002/06/11 12:37:56  bnv
 * Added: CDECL
 *
 * Revision 1.3  2002/06/06 08:22:54  bnv
 * Added: MKTEMP
 *
 * Revision 1.2  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.1  1999/11/29 14:58:00  bnv
 * Initial revision
 *
 */

#ifndef __OS_H__
#define __OS_H__

/* ----------- Definitions depending on the OS system ---------- */

/*
 * The following definitions should be supplied from the
 * make.cnf file
 *
 * General
 *	ALIGN	- Align the code in 4-bytes (used for RISC machines)
 *	RMLAST	- If the last newline should be remove from the
 *		  Redirected commands
 *	INLINE	- Use inline in some routines to speed up the code.
 *	GREEK	- Support for the GREEK character set.
 *
 *	LUSEOPTION	Is not used!
 *
 *	__DEBUG__ Active the internal debugging
 *
 * Operating system
 *	MSDOS	- Compiled for a MSDOS operating system
 *	WIN32	- Compiled for a WIN32 system
 *	WCE	- For a PalmTop version Windows CE
 *
 * Compiler
 *	__BORLANDC__	For the Borland C++ compiler
 *	GCC	- GNU C compiler
 *	MSC_VER	- Microsoft C
 */

/* ======== Operating system specifics ========= */
#ifdef WCE

#	define	OS       "WINCE"
#	define	SHELL    "SHELL"
#	define	FILESEP  '\\'
#	define	PATHSEP  ';'
#	define	ALIGN	1
#	define	WIN	1

#	pragma warning(disable : 4018)	/* signed unsigned comparison warning */

#elif defined(MSDOS)

#	define	OS       "MSDOS"
#	define	SHELL    "COMSPEC"
#	define	FILESEP  '\\'
#	define	PATHSEP  ';'

#	define	HAS_TERMINALIO
#	define	HAS_STDIO
#	define	HAS_STRING	/* For BorlandC use special Strings */
#	define	HAS_CTYPE
#	define	HAS_XTOY
#	define	HAS_SIGNAL

#elif defined(WIN)

#	define	OS	"WIN"
#	define	SHELL	"COMSPEC"
#	define	FILESEP  '\\'
#	define	PATHSEP  ';'

#	define	HAS_STRING
#	define	HAS_CTYPE
#	define	HAS_XTOY

#elif __CMS__

#	define VMCMS 1
#	define SHELL "SHELL"
#	define OS "VM//CMS"
#	define FILESEP '.'
#	define PATHSEP ':'

#	define HAS_TERMINALIO
#	define HAS_STDIO
#	define HAS_STRING
#	define HAS_CTYPE
#	define HAS_XTOY
#	define HAS_SIGNAL

#elif __MVS__

#	define VMCMS 1
#	define SHELL "SHELL"
#	define OS "MVS"
#	define FILESEP '.'
#	define PATHSEP ':'

#	define HAS_TERMINALIO
#	define HAS_STDIO
#	define HAS_STRING
#	define HAS_CTYPE
#	define HAS_XTOY
#	define HAS_SIGNAL

#else

#	define	UNIX	1

#	define	OS       "UNIX"
#	define	SHELL    "SHELL"
#	define	FILESEP  '/'
#	define	PATHSEP  ':'

#	define	HAS_TERMINALIO
#	define	HAS_STDIO
#	define	HAS_STRING
#	define	HAS_CTYPE
#	define	HAS_XTOY
#	define	HAS_SIGNAL
#endif

#ifdef WCE
#	define	__CDECL	__cdecl
#else
#	define	__CDECL
#endif

#ifndef __BORLANDC__
#	define huge
#endif

/* --------------- NON UNICODE ----------------- */
#ifndef WIN
#	ifndef UNICODE
#		ifndef TCHAR
#			define	TCHAR		char
#			define	LPTSTR		char*
#		endif
#		ifndef TEXT
#			define	TEXT(x)		(x)
#		endif
#	endif
#endif

/* -------------- Terminal I/O ----------------- */
#ifdef HAS_TERMINALIO
#	define	PUTS		puts
#	define	PUTCHAR		putchar
//#	define	PUTINT(a,b,c)	;
#else
#	define	PUTS		Bputs
#	define	PUTINT		Bputint
#	define	PUTCHAR		Bputch
#	define	GETCHAR		WReadKey
#endif

/* -------------------- I/O -------------------- */
#ifdef HAS_STDIO
	/* --- Use the standard I/O --- */
#	define	STDIN		stdin
#	define	STDOUT		stdout
#	define	STDERR		stderr

#	define	FILEP		FILE*
#	define	FOPEN		fopen
#	define	FEOF		feof
#	define	FTELL		ftell
#	define	FSEEK		fseek
#	define	FFLUSH		fflush
#	define	FCLOSE		fclose
#	define	FPUTC		fputc
#	define	FPUTS		fputs
#	define	FGETC		fgetc
#	define	PRINTF		printf

#	ifdef WIN
#		define	GETCWD		_getcwd
#		define	CHDIR		_chdir
#	else
#		define	GETCWD		getcwd
#		define	CHDIR		chdir
#	endif
#else
	/* --- Use the home made I/O --- */
#	define	STDIN		NULL
#	define	STDOUT		NULL
#	define	STDERR		NULL

#	define	FILEP		BFILE*
#	define	FOPEN		Bfopen
#	define	FCLOSE		Bfclose
#	define	FEOF		Bfeof
#	define	FTELL		Bftell
#	define	FSEEK		Bfseek
#	define	FFLUSH		Bfflush
#	define	FPUTC		Bfputc
#	define	FPUTS		Bfputs
#	define	FGETC		Bfgetc
#	define	PRINTF		Bprintf

#	define	GETCWD		Bgetcwd
#	define	CHDIR		Bchdir
#endif

/* ---------------- Unicode Ops ------------------ */
#ifdef UNICODE
#	define	SPRINTF		swprintf
#else
#	define	SPRINTF		sprintf
#endif

/* ---------------- Memory Ops ------------------- */
#ifdef __BORLANDC__	/* For the HUGE/LARGE memory model */
#	define	MEMMOVE		memmove
#	define	MEMCPY		_fmemcpy
#	define	MEMCMP		_fmemcmp
#	define	MEMCHR		_fmemchr
#	define	MEMSET		_fmemset
#else
#	define	MEMMOVE		memmove
#	define	MEMCPY		memcpy
#	define	MEMCMP		memcmp
#	define	MEMCHR		memchr
#	define	MEMSET		memset
#endif

/* ----------------- Strings --------------------- */
#ifdef __BORLANDC__	/* For the HUGE/LARGE memory model */
#	define	STRCPY		_fstrcpy
#	define	STRCMP		_fstrcmp
#	define	STRCAT		_fstrcat
#	define	STRCHR		_fstrchr
#	define	STRLEN		_fstrlen
#	define	STRSTR		_fstrstr
#	define	MKTEMP		mktemp
#elif defined(HAS_STRING)
#	define	STRCPY		strcpy
#	define	STRCMP		strcmp
#	define	STRCAT		strcat
#	define	STRCHR		strchr
#	define	STRLEN		strlen
#	define	STRSTR		strstr
#	define	MKTEMP		mktemp
#else
#	define	STRCPY		Bstrcpy
#	define	STRCMP		Bstrcmp
#	define	STRCAT		Bstrcat
#	define	STRCHR		Bstrchr
#	define	STRLEN		Bstrlen
#	define	STRSTR		Bstrstr
#endif

/* ----------------- Ctype ------------------------- */
#ifdef HAS_CTYPE
#	define	ISSPACE		isspace
#	define	ISDIGIT		isdigit
#	define	ISXDIGIT	isxdigit
#	define	ISALPHA		isalpha
#else
#	define	ISSPACE		Bisspace
#	define	ISDIGIT		Bisdigit
#	define	ISXDIGIT	Bisxdigit
#	define	ISALPHA		Bisalpha
#endif

/* ----------------- Conversions ------------------- */
#ifdef HAS_XTOY
#	define	LTOA		ltoa
#	define	GCVT		gcvt
#	define	FCVT		fcvt
#	define	ECVT		ecvt
#elif defined(WCE)
#	define	LTOA		_ltoa
#	define	GCVT		_gcvt
#	define	FCVT		_fcvt
#	define	ECVT		_ecvt
#else
#	error	"No home made conversions!"
#endif

/* ------------------- Signal ---------------------- */
#ifdef HAS_SIGNAL
#	define	SIGNAL		signal
#else
#	define	SIGNAL		WSignal
#endif

#endif
