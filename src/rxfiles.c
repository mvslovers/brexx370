/*
 * $Id: rxfiles.c,v 1.14 2013/09/03 20:03:40 bnv Exp $
 * $Log: rxfiles.c,v $
 * Revision 1.14  2013/09/03 20:03:40  bnv
 * Condition not ready for file
 *
 * Revision 1.13  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.12  2006/01/26 10:27:13  bnv
 * Corrected: When a file has a name as ddd.dd floating point number
 *
 * Revision 1.11  2004/08/16 15:29:21  bnv
 * Spaces
 *
 * Revision 1.10  2004/04/30 15:29:14  bnv
 * Spaces...
 *
 * Revision 1.9  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.8  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.7  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.6  1999/11/26 13:13:47  bnv
 * Added: Windows CE support.
 * Changed: To use the new macros.
 *
 * Revision 1.5  1999/03/10 16:55:02  bnv
 * Added MSC support
 *
 * Revision 1.4  1999/02/10 15:43:36  bnv
 * Long file name support for Win95/98/NT
 *
 * Revision 1.3  1999/01/22 17:29:17  bnv
 * Added the xxxBINARY options in the STREAM function
 *
 * Revision 1.2  1998/11/06 08:58:10  bnv
 * Corrected: real numbers with mantissa zero (integer)
 *            are treated as integers
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <stdlib.h>
#include <string.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"
#include "util.h"
#include "rxmvsext.h"

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

static
struct files_st {
	PLstr	name;	/* IN STRUCTURE */
	FILEP	f;
	long	line;
} *file;

#ifdef JCC
extern char* _style;
#else
char* _style;
#endif

extern RX_ENVIRONMENT_CTX_PTR environment;

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
		file[i].line = 1;
	}

	i = 0;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDIN>");    file[i].f = STDIN;
	file[i].line = 1;

	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDOUT>");   file[i].f = STDOUT;
	file[i].line = 1;

	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDERR>");   file[i].f = STDERR;
	file[i].line = 1;

#if defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDAUX>");   file[i].f = stdaux;
	file[i].line = 1;

	i++;
	LPMALLOC(file[i].name);
	Lscpy(file[i].name,"<STDPRN>");   file[i].f = stdprn;
	file[i].line = 1;
#endif
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
#if defined(MSDOS) || defined(WCE)
	Lstr	str;
#endif

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

#if defined(MSDOS) || defined(WCE)
	LINITSTR(str); Lfx(&str,LLEN(*fn));
	Lstrcpy(&str,fn);

	/* Make case insensity search */
	Lupper(&str);

	for (i=0; i<file_size; i++)
		if (file[i].name != NULL)
			if (!Lstrcmp(&str, file[i].name)) {
				LFREESTR(str);
				return i;
			}
	LFREESTR(str);
#else
	for (i=0; i<file_size; i++)
		if (file[i].name != NULL)
			if (!Lstrcmp(fn, file[i].name))
				return i;
#endif
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

/* -------------------------* open_file *------------------------- */
static int
open_file( const PLstr fn, const char *mode)
{
	int	i;
	Lstr	str;
    QuotationType quotationType;

	char* _style_old = _style;

	i = find_empty();

    quotationType = CheckQuotation((char *)fn->pstr);
    switch (quotationType) {
        case UNQUOTED:

            if (environment->SYSPREF[0] != '\0') {

                LINITSTR(str)
                Lcat(&str, environment->SYSPREF);
                Lcat(&str, ".");
                Lcat(&str, (char *)fn->pstr);
                LASCIIZ(str)

                _style = "//DSN:";
                if ((file[i].f=FOPEN((char*)LSTR(str),mode))==NULL) {

                    LFREESTR(str)
                    LINITSTR(str)
                    Lfx(&str,LLEN(*fn));
                    Lcat(&str, (char *)fn->pstr);
                    LASCIIZ(str)

                    if ((strchr((const char *)LSTR(str), '.') == 0) &&
                        (strchr((const char *)LSTR(str), '(') == 0) &&
                        (strchr((const char *)LSTR(str), ')') == 0)) {

                        _style = "//DDN:";
                        if ((file[i].f=FOPEN((char*)LSTR(str),mode))==NULL) {
                            LFREESTR(str);
                            return -1;
                        }
                    } else {
                        LFREESTR(str)
                        return -1;
                    }

                }
            } else {

                LINITSTR(str)
                Lfx(&str,LLEN(*fn));
                Lcat(&str, (char *)fn->pstr);
                LASCIIZ(str)

                if ((strchr((const char *)LSTR(str), '.') == 0) &&
                    (strchr((const char *)LSTR(str), '(') == 0) &&
                    (strchr((const char *)LSTR(str), ')') == 0)) {

                    _style = "//DDN:";
                    if ((file[i].f=FOPEN((char*)LSTR(str),mode))==NULL) {
                        LFREESTR(str);
                        return -1;
                    }

                } else {
                    LFREESTR(str)
                    Lerror(ERR_ILLEGAL_DDN, 0, fn);
                }
            }
            break;
        case FULL_QUOTED:

            LINITSTR(str)
            Lfx(&str,LLEN(*fn)-2);
            memcpy(str.pstr, (fn->pstr) + 1, fn->len - 2);
            str.len = fn->len - 2;

            LASCIIZ(str)

            _style = "//DSN:";
            if ((file[i].f=FOPEN((char*)LSTR(str),mode))==NULL) {
                LFREESTR(str);
                return -1;
            }

            break;
        default:
            Lerror(ERR_DATA_NOT_SPEC, 0);
    }

	LPMALLOC(file[i].name);

	//Lstrcpy(file[i].name, &str);
	Lstrcpy(file[i].name, fn);
	file[i].line = 1;

	LFREESTR(str);

	_style = _style_old;

	return i;
} /* open_file */

open_vio_file( const PLstr fn, const char *mode)
{
    int	i;
    Lstr	str;
    QuotationType quotationType;

    char* _style_old = _style;

    i = find_empty();

    quotationType = CheckQuotation((char *)fn->pstr);
    switch (quotationType) {
        case UNQUOTED:

            LINITSTR(str)
            Lfx(&str,LLEN(*fn));
            Lcat(&str, (char *)fn->pstr);
            LASCIIZ(str)

            if ((strchr((const char *)LSTR(str), '.') == 0) &&
                (strchr((const char *)LSTR(str), '(') == 0) &&
                (strchr((const char *)LSTR(str), ')') == 0)) {

                _style = "//MEM:";
                if ((file[i].f=FOPEN((char*)LSTR(str),mode))==NULL) {
                    LFREESTR(str);
                    return -1;
                }

            } else {
                LFREESTR(str)
                Lerror(ERR_ILLEGAL_DDN, 0, fn);
            }
            break;
        case FULL_QUOTED:

            printf("FOO> FQ NAMES NOT ALLOWED FOR VIO\n");

            break;
        default:
            Lerror(ERR_DATA_NOT_SPEC, 0);
    }

    LPMALLOC(file[i].name);

    Lstrcpy(file[i].name, fn);
    file[i].line = 1;

    LFREESTR(str);

    _style = _style_old;

    return i;
} /* open_vio_file */

/* -------------------------* close_file *------------------------ */
static int
close_file( const int f )
{
	int	r;
	r = FCLOSE(file[f].f);
	file[f].f = NULL;
	LPFREE(file[f].name);
	file[f].name = NULL;
	return r;
} /* close_file */

/* --------------------------------------------------------------- */
/*  OPEN( file, mode, dmode                                        */
/* --------------------------------------------------------------- */
void __CDECL
R_open( )
{
	if ((ARGN < 2) || (ARGN > 3)) Lerror(ERR_INCORRECT_CALL, 0 );
	must_exist(1); L2STR(ARG1);
	must_exist(2); L2STR(ARG2);
	Llower(ARG1); LASCIIZ(*ARG1);
	Llower(ARG2); LASCIIZ(*ARG2);

	if (exist(3)) {
		L2STR(ARG3);
		Lupper(ARG3); LASCIIZ(*ARG3);

		if (strcmp((char *)LSTR(*ARG3),"VIO") == 0) {
			Licpy(ARGR, open_vio_file(ARG1,(char *)LSTR(*ARG2)));
		} else {
            Licpy(ARGR, open_file(ARG1,(char *)LSTR(*ARG2)));
			//Lerror(ERR_INCORRECT_CALL, 0);
		}

	} else {
		Licpy(ARGR, open_file(ARG1,(char *)LSTR(*ARG2)));
	}
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
				if (i>=0) FSEEK( file[i].f, 0L, SEEK_SET );
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
				if (FEOF(file[i].f))
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
	int    i;

	if (ARGN > 1)
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDIN;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"r+");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);

	if (func == f_chars)
		Licpy(ARGR,Lchars(file[i].f));
	else
	if (func == f_lines)
		Licpy(ARGR,Llines(file[i].f));
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
	long	start,length;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDIN;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) i = open_file(ARG1,"r+");
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);
	get_oiv(2,start,LSTARTPOS);
	get_oiv(3,length,1);

	if (LLEN(*ARGR)==0 && FEOF(file[i].f))
		RxSignalCondition(SC_NOTREADY);

	if (func == f_charin)
		Lcharin(file[i].f,ARGR,start,length);
	else
	if (func == f_linein)
		Llinein(file[i].f,ARGR,&(file[i].line),start,length);
} /* R_charlinein */

/* --------------------------------------------------------------- */
/*  CHAROUT((file)(,(string)(,start)))                             */
/* --------------------------------------------------------------- */
/*  LINEOUT((file)(,(string)(,start)))                             */
/* --------------------------------------------------------------- */
void __CDECL
R_charlineout( const int func )
{
	int	i;
	long	start;
	PLstr	str;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL, 0);
	i = FSTDOUT;
	if (exist(1))
		if (LLEN(*ARG1)) i = find_file(ARG1);
	if (i==-1) {
		i = open_file(ARG1,"r+");
		if (i==-1) i = open_file(ARG1,"w+");
	}
	if (i==-1)
		Lerror(ERR_CANT_OPEN_FILE,0);

	if (exist(2)) {
		L2STR(ARG2);
		str = ARG2;
	} else
		str = &(nullStr->key);

	get_oiv(3,start,LSTARTPOS);

	if (func == f_charout) {
		Lcharout(file[i].f,str,start);
		Licpy(ARGR,LLEN(*ARG2));
	} else
	if (func == f_lineout)
		Licpy(ARGR,Llineout(file[i].f,str,&(file[i].line),start));
	FFLUSH(file[i].f);
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
	long	l;

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
