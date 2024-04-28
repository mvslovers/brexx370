#ifndef __OS_H__
#define __OS_H__

/* ======== Operating system specifics ========= */
#ifdef __CMS__

#	define VMCMS 1
#	define SHELL "SHELL"
#	define OS "VM//CMS"
#	define FILESEP '.'
#	define PATHSEP ':'

#	define HAS_BLKIO

#elif __MVS__

#	define VMCMS 1
#	define SHELL "SHELL"
#	define OS "MVS"
#	define FILESEP '.'
#	define PATHSEP ':'

#	define HAS_BLKIO

#else

#	define	UNIX	1

#	define	OS       "UNIX"
#	define	SHELL    "SHELL"
#	define	FILESEP  '/'
#	define	PATHSEP  ':'

#endif

#define	__CDECL
#define huge

#ifndef TCHAR
#	define	TCHAR		char
#	define	LPTSTR		char*
#endif

#ifndef TEXT
#	define	TEXT(x)		(x)
#endif

/* -------------- Terminal I/O ----------------- */
#define	PUTS		puts
#define	PUTCHAR		putchar
//#	define	PUTINT(a,b,c)	;

/* -------------------- I/O -------------------- */
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

#	define	GETCWD		getcwd
#	define	CHDIR		chdir

#ifdef HAS_BLKIO_
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

/* ---------------- Memory Ops ------------------- */
#define	MEMMOVE		memmove
#define	MEMCPY		memcpy
#define	MEMCMP		memcmp
#define	MEMCHR		memchr
#define	MEMSET		memset

/* ----------------- Strings --------------------- */
#define	STRCPY		strcpy
#define	STRCMP		strcmp
#define	STRCAT		strcat
#define	STRCHR		strchr
#define	STRLEN		strlen
#define	STRSTR		strstr
#define	MKTEMP		mktemp

/* ----------------- Ctype ------------------------- */
#define	ISSPACE		isspace
#define	ISDIGIT		isdigit
#define	ISXDIGIT	isxdigit
#define	ISALPHA		isalpha

/* ----------------- Conversions ------------------- */
#define	LTOA		ltoa
#define	GCVT		gcvt
#define	FCVT		fcvt
#define	ECVT		ecvt

/* ------------------- Signal ---------------------- */
#define	SIGNAL		signal

#endif
