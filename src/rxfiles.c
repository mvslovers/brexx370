#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <ctype.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"
#include "util.h"
#include "rxmvsext.h"
#include "dsio.h"

#ifdef __CROSS__
# include "jccdummy.h"
#else
extern Lstr	errmsg;
#endif

#define	FSTDIN	0
#define	FSTDOUT	1
#define	FSTDERR	2
#define	FSTDAUX	3
#define	FSTDPRN	4

#define FILE_INC	10
int	file_size;	/* file size in filelist structure	*/

/* there are two types of files, std unix files and rexx files	*/
/* std unix files like old BRexx have one position pointer	*/
/* rexx files have 4 position pointers				*/
/*
 * The REXX stream functions (CHARIN, CHAROUT, LINEIN, LINEOUT, CHARS,
 * LINES) keep a read and a write position of their own, as the standard
 * requires: the read position starts at 1, the write position of a
 * persistent stream at its end. Positions are byte offsets from ftell()
 * (libc370 counts an FB record as its LRECL + 1 for the '\n'). The C
 * position is set with fseek() before every operation, which also makes
 * every switch between reading and writing legal C. READ, WRITE, SEEK
 * and EOF are the one-pointer family and work on the C position as is.
 */
#define F_SEEK	0x01	/* positions are kept (not a terminal/SYSOUT)	*/
#define F_WRITE	0x02	/* opened in a mode that allows writing		*/
#define F_NOTREADY 0x04	/* the last operation raised NOTREADY		*/

static
struct files_st {
	PLstr	name;	/* IN STRUCTURE */
	FILEP	f;
	long	rpos;	/* read position, byte offset			*/
	long	wpos;	/* write position, -1 = end, not yet computed	*/
	long	rline;	/* line number at rpos				*/
	long	wline;	/* line number at wpos, -1 = unknown		*/
	int	flags;
} *file;

extern RX_ENVIRONMENT_CTX_PTR environment;

/* ----------------------* set_positions *------------------------ */
static void
set_positions( const int i, const int flags )
{
	file[i].rpos  = 0;
	file[i].rline = 1;
	file[i].wpos  = -1;
	file[i].wline = -1;
	file[i].flags = flags;
}

/* ------------------------* RxInitFiles *------------------------ */
void __CDECL
RxInitFiles(void)
{
	int	i;

	file = (struct files_st *)
		MALLOC( FILE_INC * sizeof(struct files_st), "FILE");
	file_size = FILE_INC;
	for (i=0; i<file_size; i++) {
		file[i].name = NULL;
		file[i].f    = NULL;
		set_positions(i, 0);
	}

	i = 0;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDIN>");    file[i].f = STDIN;
	set_positions(i, 0);

	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDOUT>");   file[i].f = STDOUT;
	set_positions(i, F_WRITE);

	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDERR>");   file[i].f = STDERR;
	set_positions(i, F_WRITE);

} /* RxInitFiles*/

/* ------------------------* RxDoneFiles *------------------------ */
void __CDECL
RxDoneFiles(void)
{
	int i;
	for (i=0;i<file_size;i++) {
		/* is it system file? */
		if (file[i].name != NULL) {
			if (LSTR(*(file[i].name))[0]!='<')	/* system file */
				FCLOSE(file[i].f);
			LPFREE(file[i].name)
		}
	}
	FREE(file);
} /* RxDoneFiles */

/* -------------------------* find_file *------------------------- */
static int
find_file( const PLstr fn )
{
	int	i, j=-1;
	int	isnum=0;

	/* search to see if it is a number */
	if ((LTYPE(*fn)==LSTRING_TY) && (_Lisnum(fn) == LINTEGER_TY)) {
		j = (int)Lrdint(fn);
		isnum = 1;
	} else
	if (LTYPE(*fn) == LINTEGER_TY) {
		j = (int)LINT(*fn);
		isnum = 1;
	} else
	if (LTYPE(*fn) == LREAL_TY) {
		j = Lrdint(fn);
		isnum = 1;
	}

	if (IN_RANGE(0,j,file_size-1))
		if (file[j].name != NULL) return j;

	if (isnum)
		Lerror(ERR_FILE_NOT_OPENED,0 );

	L2STR(fn);

	for (i=0; i<file_size; i++)
		if (file[i].name != NULL && !Lstrcmp(fn, file[i].name))
			return i;
	return -1;
} /* find_file */

/* ------------------------* find_empty *------------------------- */
static int
find_empty( void )
{
	int	i,j;
	for (i=0; i<file_size; i++)
		if (file[i].name==NULL)
			return i;

	i = file_size;
	file_size += FILE_INC;
/* then allocate some more space */
	file = (struct files_st *)
		REALLOC( file, file_size * sizeof(struct files_st));
	for (j=i; j<file_size; j++) {
		file[j].name = NULL;
		file[j].f = NULL;
	}
	return i;
} /* find_empty */

static int close_file( const int f );

/* -------------------------* open_mode *------------------------- */
/* "w" and "a" are opened for update ("w+", "a+"): a REXX stream that
 * was written can be read back (OPEN(name,'W') followed by LINEIN).
 * Anything after a ',' (JCC options) is kept as it is. */
static const char *
open_mode( const char *mode, char *buf, size_t buflen )
{
	size_t	len = strlen(mode);

	if ((mode[0] != 'w' && mode[0] != 'a') || len + 2 > buflen)
		return mode;
	if (strchr(mode, '+') != NULL &&
	    (strchr(mode, ',') == NULL || strchr(mode, '+') < strchr(mode, ',')))
		return mode;
	buf[0] = mode[0];
	buf[1] = '+';
	memcpy(buf + 2, mode + 1, len);	/* includes the NUL */
	return buf;
}

/* -------------------------* mode_flags *------------------------ */
static int
mode_flags( const char *mode )
{
	const char *comma = strchr(mode, ',');
	const char *plus  = strchr(mode, '+');

	if (mode[0] == 'w' || mode[0] == 'a' ||
	    (plus != NULL && (comma == NULL || plus < comma)))
		return F_WRITE;
	return 0;
}

/* -----------------------* open_unquoted *---------------------- */
/* a name without '.', '(' and ')' can be a DD name */
static int
ddn_like( const char *name )
{
	return strchr(name, '.') == NULL && strchr(name, '(') == NULL &&
	       strchr(name, ')') == NULL;
} /* ddn_like */

/* An unquoted name: with a prefix, prefix.name as a data set, then the
 * name as a DD if it can be one; without a prefix, a DD name only. The
 * data set name comes from getDatasetName(), as everywhere (#299). */
static FILE *
open_unquoted( const PLstr fn, const char *mode )
{
	char	dsn[DSN_NAME_MAX + 1];
	FILE	*fp = NULL;
	const char *name = (const char *) fn->pstr;

	if (environment->SYSPREF[0] == '\0') {
		if (!ddn_like(name))
			Lerror(ERR_ILLEGAL_DDN, 0, fn);
		return rxOpenDd(name, mode);
	}

	if (getDatasetName(environment, name, dsn) == 0)
		fp = rxOpenDsn(dsn, mode);
	if (fp == NULL && ddn_like(name))
		fp = rxOpenDd(name, mode);
	return fp;
} /* open_unquoted */

/* -----------------------* open_file_as *----------------------- */
static int
open_file_as( const PLstr fn, const char *mode)
{
	int	i;
	FILE	*fp = NULL;

	i = find_empty();

	switch (CheckQuotation((char *)fn->pstr)) {
		case UNQUOTED:
			fp = open_unquoted(fn, mode);
			break;
		case FULL_QUOTED: {	/* a data set name, it stands as it is */
			char	dsn[DSN_NAME_MAX + 1];

			if (getDatasetName(environment, (const char *) fn->pstr, dsn) == 0)
				fp = rxOpenDsn(dsn, mode);
			break;
		}
		default:
			Lerror(ERR_DATA_NOT_SPEC, 0);
	}
	if (fp == NULL)
		return -1;
	file[i].f = fp;

	LPMALLOC(file[i].name);
	Lstrcpy(file[i].name, fn);
	set_positions(i, F_SEEK | mode_flags(mode));
	if (mode[0] == 'w') {		/* truncated: write from the start */
		file[i].wpos  = 0;
		file[i].wline = 1;
	}

	return i;
} /* open_file_as */

/* -------------------------* open_file *------------------------- */
static int
open_file( const PLstr fn, const char *mode)
{
	char	modebuf[16];
	const char *umode = open_mode(mode, modebuf, sizeof(modebuf));
	int	i = open_file_as(fn, umode);

	/* SYSOUT and terminals cannot be opened for update: open them as
	 * asked, with one position (no fseek) */
	if (i == -1 && umode != mode) {
		i = open_file_as(fn, mode);
		if (i != -1) file[i].flags &= ~F_SEEK;
	}
	return i;
} /* open_file */

/* -----------------------* open_for_write *---------------------- */
/* implicit open by CHAROUT/LINEOUT: never truncate. An existing
 * stream is opened "r+" (the write position is its end); "w+" only
 * creates one. A failed "r+" is never retried as "w+": libc370 cannot
 * tell "does not exist" from "in use", so "r" is the existence probe. */
static int
open_for_write( const PLstr fn )
{
	int	i = open_file(fn, "r");

	if (i != -1) {
		close_file(i);
		return open_file(fn, "r+");
	}
	return open_file(fn, "w");	/* "w+", or "w" for SYSOUT */
} /* open_for_write */

/* -------------------------* close_file *------------------------ */
static int
close_file( const int f )
{
	int	r = 0;
	/* stderr may share stdout's stream: SYSTSPRT or PUTLINE (#251) */
	if (f != FSTDERR || file[f].f != file[FSTDOUT].f)
		r = FCLOSE(file[f].f);
	file[f].f = NULL;
	LPFREE(file[f].name);
	file[f].name = NULL;
	return r;
} /* close_file */

/* ------------------------* reopen_update *--------------------- */
/* A stream that was opened for reading only is written: reopen it
 * "r+" in the same slot, so a numeric handle stays valid. "r+" never
 * truncates. The positions are kept. */
static int
reopen_update( const int i )
{
	int	j;

	FCLOSE(file[i].f);
	file[i].f = NULL;
	j = open_file(file[i].name, "r+");
	if (j == -1) {			/* at least keep it readable */
		j = open_file(file[i].name, "r");
		if (j == -1) return -1;
	}
	file[i].f = file[j].f;
	file[i].flags |= file[j].flags & F_WRITE;
	file[j].f = NULL;
	LPFREE(file[j].name);
	file[j].name = NULL;
	return (file[i].flags & F_WRITE) ? 0 : -1;
} /* reopen_update */

/* -------------------------* end_pos *--------------------------- */
static long
end_pos( const int i )
{
	if (FSEEK(file[i].f, 0L, SEEK_END) != 0) return -1;
	return FTELL(file[i].f);
} /* end_pos */

/* ------------------------* line_offset *------------------------ */
/* byte offset of the start of line n (1-based); the line just after
 * the last one is valid (it is where the next line would go), -1
 * beyond that */
static long
line_offset( const int i, const long n )
{
	FILEP	f = file[i].f;
	long	line = 1;
	int	any;

	if (n < 1 || FSEEK(f, 0L, SEEK_SET) != 0) return -1;
	while (line < n) {		/* one lock per line, not per byte */
		if (!Lskipline(f, &any)) return -1;
		line++;
	}
	return FTELL(f);
} /* line_offset */

/* -------------------------* prep_read *------------------------- */
static void
prep_read( const int i )
{
	file[i].flags &= ~F_NOTREADY;
	if (file[i].flags & F_SEEK)
		FSEEK(file[i].f, file[i].rpos, SEEK_SET);
	clearerr(file[i].f);
} /* prep_read */

/* -------------------------* done_read *------------------------- */
static void
done_read( const int i )
{
	if (file[i].flags & F_SEEK)
		file[i].rpos = FTELL(file[i].f);
} /* done_read */

/* -------------------------* prep_write *------------------------ */
/* 0 = ready to write at the write position */
static int
prep_write( const int i )
{
	file[i].flags &= ~F_NOTREADY;
	if (!(file[i].flags & F_WRITE) && reopen_update(i) != 0)
		return -1;
	if (!(file[i].flags & F_SEEK))
		return 0;
	if (file[i].wpos < 0) {		/* the end of a persistent stream */
		file[i].wpos  = end_pos(i);
		file[i].wline = -1;
		if (file[i].wpos < 0) return -1;
	}
	return FSEEK(file[i].f, file[i].wpos, SEEK_SET);
} /* prep_write */

/* -------------------------* done_write *------------------------ */
static void
done_write( const int i )
{
	if (file[i].flags & F_SEEK)
		file[i].wpos = FTELL(file[i].f);
} /* done_write */

/* -------------------------* put_str *--------------------------- */
/* write str (and a '\n'), return the number of characters written;
 * libc370 refuses a write it cannot do (EOPNOTSUPP in the middle of a
 * record) by the return value, not by ferror() */
static long
put_str( FILEP f, const PLstr str, const bool newline )
{
	long	n;
	unsigned char *c;

	L2STR(str);
	c = LSTR(*str);
#ifdef __MVS__
	/* one fwrite(), not one FPUTC per byte: libc370's fputc() takes an
	 * ENQ and a DEQ for every byte; fwrite() locks once and reports the
	 * bytes it wrote through the same __fputc() */
	n = (long) fwrite(c, 1, LLEN(*str), f);
	if (n < (long) LLEN(*str)) return n;
#else
	for (n = 0; n < (long) LLEN(*str); n++)
		if (FPUTC(c[n], f) == EOF) return n;
#endif
	if (newline && FPUTC('\n', f) == EOF)
		return n;
	return n + (newline ? 1 : 0);
} /* put_str */

/* -------------------------* notready *-------------------------- */
/* raised only when NOTREADY is trapped. For SIGNAL ON RxSignalCondition
 * jumps and reports a missing label; for CALL ON it returns and the
 * routine is called at the end of the clause (#239), so every caller
 * returns right after it */
static void
notready( const int i )
{
	/* STREAM() reported READY after it, FEOF() was all it knew (#386) */
	file[i].flags |= F_NOTREADY;
	if (!(_proc[_rx_proc].condition & SC_NOTREADY))
		return;
	LASCIIZ(*(file[i].name));
	RxSignalCondition(SC_NOTREADY, (char *) LSTR(*(file[i].name)));
} /* notready */

/* --------------------------------------------------------------- */
/*  OPEN( file, mode, dmode                                        */
/* ----------------------* create_for_open *--------------------- */
/* OPEN(name, mode, allocation-information): a data set that does not
 * exist is created with the allocation information before a write open;
 * one that exists keeps its own definition (#299). The name is resolved
 * as open_file_as() does: quoted, or unquoted with the prefix; a DD name
 * (no prefix) has nothing to create. A member is split off: its data set
 * is created partitioned. Returns 0 to go on with the open, -1 when the
 * allocation information is bad or the data set cannot be created. */
static int
create_for_open( const Lstr *fn, const char *mode, const char *attrs )
{
	char	dsn[DSN_NAME_MAX + 1];
	char	upper[256];
	char	alloc[sizeof(upper) + 9];	/* "DSORG=PO," + upper */
	const char *name = (const char *) fn->pstr;
	char	*lp;
	size_t	i;
	int	rc;

	if (mode[0] != 'w' && mode[0] != 'a')
		return 0;			/* a read needs the data set */

	switch (CheckQuotation(name)) {
		case UNQUOTED:
			if (environment->SYSPREF[0] == '\0') return 0;	/* a DD */
			break;
		case FULL_QUOTED:
			break;
		default:
			return 0;		/* the open reports it */
	}
	if (getDatasetName(environment, name, dsn) != 0) return -1;
	for (char *p = dsn; *p; p++) *p = (char) toupper((unsigned char) *p);

	if (strlen(attrs) >= sizeof(upper)) return -1;
	for (i = 0; attrs[i]; i++) upper[i] = (char) toupper((unsigned char) attrs[i]);
	upper[i] = '\0';
	snprintf(alloc, sizeof(alloc), "%s", upper);
	lp = strchr(dsn, '(');
	if (lp != NULL) {
		*lp = '\0';			/* the data set of the member */
		if (strstr(upper, "DSORG") == NULL && strstr(upper, "DIRBLKS") == NULL)
			snprintf(alloc, sizeof(alloc), "DSORG=PO,%s", upper);
	}
	rc = rxCreateDsn(dsn, alloc);
	return (rc == -1) ? -1 : 0;	/* -2: it exists, keep it */
} /* create_for_open */

/* --------------------------------------------------------------- */
void __CDECL
R_open( )
{
	if ((ARGN < 2) || (ARGN > 3)) Lerror(ERR_INCORRECT_CALL, 0 );
	must_exist(1); L2STR(ARG1);
	must_exist(2); L2STR(ARG2);
	Llower(ARG_OWN(1)); LASCIIZ(*ARG1);
	Llower(ARG_OWN(2)); LASCIIZ(*ARG2);

	/* A third argument VIO opened a JCC memory file, which libc370 does
	 * not have: it never worked in the cc370 build and is gone (#299).
	 * Anything else is the allocation information: a data set that does
	 * not exist is created with it before a write open (#299). */
	if (exist(3)) {
		L2STR(ARG3);
		LASCIIZ(*ARG3);
		if (strcasecmp((const char *)LSTR(*ARG3),"VIO") == 0)
			Lerror(ERR_INCORRECT_CALL, 0);
		if (create_for_open(ARG1, (const char *)LSTR(*ARG2),
		                    (const char *)LSTR(*ARG3)) != 0) {
			Licpy(ARGR, -1);
			return;
		}
	}
	Licpy(ARGR, open_file(ARG1,(char *)LSTR(*ARG2)));
} /* R_open */

/* --------------------------------------------------------------- */
/*  CLOSE( file )                                                  */
/* --------------------------------------------------------------- */
void __CDECL
R_close( )
{
	int	i;

	if (ARGN != 1)
		Lerror(ERR_INCORRECT_CALL, 0);
	i=find_file(ARG1);
	if (i==-1) Lerror(ERR_FILE_NOT_OPENED,0 );

	Licpy(ARGR,close_file(i));
} /* R_close */

/* --------------------------------------------------------------- */
/*  EOF( file )                                                    */
/* --------------------------------------------------------------- */
void __CDECL
R_eof( )
{
	int	i;
	if (ARGN!=1)
		Lerror(ERR_INCORRECT_CALL, 0);
	i = find_file(ARG1);
	if (i==-1)
		Licpy(ARGR,-1);
	else
		Licpy(ARGR,((FEOF(file[i].f))?1:0));
} /* R_eof */

/* --------------------------------------------------------------- */
/*  FLUSH( file )                                                  */
/* --------------------------------------------------------------- */
void __CDECL
R_flush( )
{
	int	i;
	if (ARGN!=1)
		Lerror(ERR_INCORRECT_CALL, 0);
	i = find_file(ARG1);
	if (i==-1)
		Licpy(ARGR,-1);
	else
		Licpy(ARGR,(FFLUSH(file[i].f)));
} /* R_flush */

/* --------------------------------------------------------------- */
/*  STREAM(file[,[option][,command]])                              */
/* --------------------------------------------------------------- */
void __CDECL
R_stream( )
{
	char	option;
	Lstr	cmd;
	int	i;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);

	must_exist(1);
	i = find_file(ARG1);
	if (exist(2)) {
		L2STR(ARG2);
		option = l2u[(byte)LSTR(*ARG2)[0]];
	} else
		option = 'S';	/* Status */

	/* only with option='C' we must have a third argument */
	if (option != 'C' && exist(3))
		Lerror(ERR_INCORRECT_CALL, 0);

	switch (option) {
		case 'C':		/* command */
			if (!exist(3))
				Lerror(ERR_INCORRECT_CALL, 0);
			LINITSTR(cmd); Lfx(&cmd,LLEN(*ARG3));
			Lstrip(&cmd,ARG3,LBOTH,' ');
			Lupper(&cmd);

			if (Lcmp(&cmd,"READ") == 0 || Lcmp(&cmd, "OPEN") == 0 || Lcmp(&cmd, "OPEN READ") == 0) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"r");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"READBINARY") == 0 || Lcmp(&cmd, "OPEN BINARY") == 0 || Lcmp(&cmd, "OPEN READ BINARY") == 0) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"rb");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"WRITE") == 0 || Lcmp(&cmd, "OPEN WRITE") == 0) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"w");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"WRITEBINARY") == 0 || Lcmp(&cmd, "OPEN WRITE BINARY") == 0) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"wb");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"APPEND") == 0 || Lcmp(&cmd, "OPEN WRITE APPEND") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"a+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"APPENDBINARY") == 0 || Lcmp(&cmd, "OPEN WRITE APPEND BINARY") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"ab+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"UPDATE") == 0 || Lcmp(&cmd, "OPEN BOTH") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"r+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"UPDATEBINARY") == 0 || Lcmp(&cmd, "OPEN BOTH BINARY") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"rb+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"CREATE") == 0 || Lcmp(&cmd, "OPEN WRITE REPLACE") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"w+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
            if (Lcmp(&cmd,"CREATEBINARY") == 0 || Lcmp(&cmd, "OPEN WRITE REPLACE BINARY") == 0 ) {
				if (i>=0) close_file(i);
				i = open_file(ARG1,"wb+");
				if (i==-1) Lerror(ERR_CANT_OPEN_FILE,0);
			} else
			if (!Lcmp(&cmd,"CLOSE")) {
				if (i>=0) close_file(i);
			} else
			if (!Lcmp(&cmd,"FLUSH")) {
				if (i>=0) FFLUSH(file[i].f);
			} else
			if (!Lcmp(&cmd,"RESET")) {
				if (i>=0) {
					FSEEK( file[i].f, 0L, SEEK_SET );
					file[i].rpos = 0;  file[i].rline = 1;
					file[i].wpos = 0;  file[i].wline = 1;
					file[i].flags &= ~F_NOTREADY;
				}
			} else
				Lerror(ERR_INCORRECT_CALL, 0);

			Lscpy(ARGR,"READY");
			LFREESTR(cmd);
			break;
		case 'D':		/* get a description */
		case 'S':		/* status */
			if (i==-1)
				Lscpy(ARGR,"UNKNOWN");
			else {
				if (FEOF(file[i].f) || (file[i].flags & F_NOTREADY))
					Lscpy(ARGR,"NOTREADY");
				else
					Lscpy(ARGR,"READY");
			}
			/* ERROR??? where */
			break;
		default:
			Lerror(ERR_INCORRECT_CALL, 0);
	}

} /* R_stream */

/* --------------------------------------------------------------- */
/*  CHARS((file))                                                  */
/* --------------------------------------------------------------- */
/*  LINES((file))                                                  */
/* --------------------------------------------------------------- */
void __CDECL
R_charslines( const int func )
{
	int	i, any = 0;
	long	n = 0, end;

	if (ARGN > 1)
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDIN;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"r");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);

	if (!(file[i].flags & F_SEEK)) {	/* terminal: 1 while not at end */
		Licpy(ARGR, FEOF(file[i].f) ? 0 : 1);
		return;
	}
	/* counted from the read position; the C position is left where it
	   ends up, the next operation seeks anyway */
	if (func == f_chars) {
		end = end_pos(i);
		n = (end > file[i].rpos) ? end - file[i].rpos : 0;
	} else {
		prep_read(i);
		while (Lskipline(file[i].f, &any))	/* one lock per line */
			n++;
		if (any) n++;			/* last line without '\n' */
	}
	Licpy(ARGR, n);
} /* R_charslines */

/* --------------------------------------------------------------- */
/*  CHARIN((file)(,(start)(,length)))                              */
/* --------------------------------------------------------------- */
/*  LINEIN((file)(,(line)(,count)))                                */
/* --------------------------------------------------------------- */
void __CDECL
R_charlinein( const int func )
{
	int	i;
	long	start,length,off;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDIN;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"r");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);
	get_oiv(2,start,LSTARTPOS);
	get_oiv(3,length,1);
	if (length < 0 || (start != LSTARTPOS && start < 1))
		Lerror(ERR_INCORRECT_CALL, 0);

	if (start != LSTARTPOS && (file[i].flags & F_SEEK)) {
		if (func == f_charin) {
			file[i].rpos = start - 1;
		} else {
			off = line_offset(i, start);
			if (off < 0) {		/* beyond the last line */
				LZEROSTR(*ARGR);
				notready(i);
				return;
			}
			file[i].rpos  = off;
			file[i].rline = start;
		}
	}

	prep_read(i);
	if (length == 0) {
		LZEROSTR(*ARGR);
	} else if (func == f_charin) {
		Lread(file[i].f, ARGR, length);
	} else {
		Llinein(file[i].f, ARGR, &(file[i].rline), LSTARTPOS, length);
	}
	done_read(i);

	if (length > 0 &&
	    ((func == f_charin && (long) LLEN(*ARGR) < length) ||
	     (func == f_linein && LLEN(*ARGR) == 0 && FEOF(file[i].f))))
		notready(i);
} /* R_charlinein */

/* -------------------------* set_wpos *-------------------------- */
/* CHAROUT start is a character position, LINEOUT start a line */
static int
set_wpos( const int i, const int func, const long start )
{
	long	off;

	if (start < 1)
		Lerror(ERR_INCORRECT_CALL, 0);
	if (!(file[i].flags & F_SEEK))
		return 0;
	if (func == f_charout) {
		file[i].wpos  = start - 1;
		file[i].wline = -1;
		return 0;
	}
	off = line_offset(i, start);
	if (off < 0) return -1;		/* beyond the line after the last */
	file[i].wpos  = off;
	file[i].wline = start;
	return 0;
} /* set_wpos */

/* --------------------------------------------------------------- */
/*  CHAROUT((file)(,(string)(,start)))                             */
/* --------------------------------------------------------------- */
/*  LINEOUT((file)(,(string)(,start)))                             */
/* --------------------------------------------------------------- */
/* Returns what the standard says: the number of characters (CHAROUT)
 * or lines (LINEOUT) NOT written, so 0 on success. */
void __CDECL
R_charlineout( const int func )
{
	int	i;
	long	start, want, written;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDOUT;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_for_write(ARG1);
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);

	get_oiv(3,start,LSTARTPOS);

	if (!exist(2)) {			/* no string: nothing is written */
		Licpy(ARGR, 0);
		if (start != LSTARTPOS) {
			if (set_wpos(i, func, start) != 0) notready(i);
		} else {		/* flush, write position to the end */
			FFLUSH(file[i].f);
			if (file[i].flags & F_SEEK) {
				file[i].wpos  = -1;
				file[i].wline = -1;
			}
		}
		return;
	}

	L2STR(ARG2);
	want = (func == f_lineout) ? 1 : (long) LLEN(*ARG2);
	Licpy(ARGR, want);			/* until it is written */

	if (start != LSTARTPOS && set_wpos(i, func, start) != 0) {
		notready(i);
		return;
	}
	if (prep_write(i) != 0) {
		notready(i);
		return;
	}
	written = put_str(file[i].f, ARG2, func == f_lineout);
	done_write(i);
	if (!(file[i].flags & F_SEEK))		/* terminal, SYSOUT */
		FFLUSH(file[i].f);

	if (func == f_lineout) {
		if (written == (long) LLEN(*ARG2) + 1) {
			Licpy(ARGR, 0);
			if (file[i].wline > 0) file[i].wline++;
		}
	} else
		Licpy(ARGR, want - written);
	if (LINT(*ARGR) != 0)
		notready(i);
} /* R_charlineout */

/* --------------------------------------------------------------- */
/*  WRITE( (file)(, string(,)))                                    */
/* --------------------------------------------------------------- */
void __CDECL
R_write( )
{
	int	i;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDOUT;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"w");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);
	if (exist(2)) {
		Lwrite(file[i].f,ARG2,FALSE);
		Licpy(ARGR, LLEN(*ARG2));
	} else {
		FPUTC('\n',file[i].f);
		Licpy(ARGR,1);
	}
	if (ARGN==3) {
		FPUTC('\n',file[i].f);
		LINT(*ARGR)++;
	}
}  /* R_write */

/* --------------------------------------------------------------- */
/*  READ( (file)(,length) )                                        */
/*  length can be a number declaring number of bytes to read       */
/*  or an option 'file', 'line' or 'char'                          */
/* --------------------------------------------------------------- */
void __CDECL
R_read( )
{
	int	i;
	long	l = LREADLINE;

	if (!IN_RANGE(0,ARGN,2))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDIN;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"r");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);

	if (exist(2)) {
		/* search to see if it is a number */
		if ((LTYPE(*ARG2)==LSTRING_TY) && (_Lisnum(ARG2) == LINTEGER_TY))
			l = Lrdint(ARG2);
		else
		if (LTYPE(*ARG2) == LINTEGER_TY)
			l = (int)LINT(*ARG2);
		else
		if (LTYPE(*ARG2) == LREAL_TY)
			l = Lrdint(ARG2);
		else
		if (LTYPE(*ARG2) == LSTRING_TY) {
			switch (l2u[(byte)LSTR(*ARG2)[0]]) {
				case 'F':
					l = LREADFILE;
					break;
				case 'L':
					l = LREADLINE;
					break;
				case 'C':
					l = 1;
					break;
				default:
					Lerror(ERR_INCORRECT_CALL, 0);
			}
		} else
			Lerror(ERR_INCORRECT_CALL, 0);
	} else
		l = LREADLINE;

	Lread(file[i].f, ARGR, l);
} /* R_read */

/* --------------------------------------------------------------- */
/*  SEEK( file (,offset (,"TOF","CUR","EOF")))                     */
/* --------------------------------------------------------------- */
void __CDECL
R_seek( )
{
	int	i;
	long	l;
	int	SEEK=SEEK_SET;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	must_exist(1);	i = find_file(ARG1);
	if (i==-1)
		Lerror( ERR_FILE_NOT_OPENED, 0);

	if (exist(2)) {
		l = Lrdint(ARG2);
		if (exist(3)) {
			L2STR(ARG3);
			switch (l2u[(byte)LSTR(*ARG3)[0]]) {
				case 'T':	/* TOF */
					SEEK = SEEK_SET;
					break;
				case 'C':
					SEEK = SEEK_CUR;
					break;
				case 'E':
					SEEK = SEEK_END;
					break;
				default:
					Lerror(ERR_INCORRECT_CALL, 0 );
			}
		}
		FSEEK( file[i].f, l, SEEK );
	}
	Licpy(ARGR, FTELL(file[i].f));
} /* R_seek */
