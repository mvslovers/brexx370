/*
 * $Id: rxdefs.h,v 1.10 2009/06/02 09:41:43 bnv Exp $
 * $Log: rxdefs.h,v $
 * Revision 1.10  2009/06/02 09:41:43  bnv
 * MVS/CMS corrections
 *
 * Revision 1.9  2008/07/15 14:57:11  bnv
 * mvs corretions
 *
 * Revision 1.8  2008/07/14 13:09:21  bnv
 * MVS,CMS support
 *
 * Revision 1.7  2006/01/26 10:30:04  bnv
 * Corrected for Windows CE
 *
 * Revision 1.6  2003/10/30 13:17:23  bnv
 * Variable change
 *
 * Revision 1.5  2003/02/12 16:39:33  bnv
 * Added: Lhashvalue
 *
 * Revision 1.4  2002/06/06 08:23:36  bnv
 * Added: logical operations
 *
 * Revision 1.3  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/29 14:58:00  bnv
 * Changed: Some defines
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 */

#ifndef __RXDEFS_H__
#define __RXDEFS_H__

#if defined(__CMS__) || defined(__MVS__)
#	include "rxmvs.h"
#endif

#define ARGN   (rxArg.n)
#define ARGR   (rxArg.r)
#define ARG1   (rxArg.a[0])
#define ARG2   (rxArg.a[1])
#define ARG3   (rxArg.a[2])
#define ARG4   (rxArg.a[3])
#define ARG5   (rxArg.a[4])
#define ARG6   (rxArg.a[5])
#define ARG7   (rxArg.a[6])
#define ARG8   (rxArg.a[7])
#define ARG9   (rxArg.a[8])
#define ARG10  (rxArg.a[9])

#define must_exist(I) if (ARG##I == NULL) \
		Lerror(ERR_INCORRECT_CALL,0)
#define exist(I)  (ARG##I != NULL)

#define get_s(I)   { must_exist(I); L2STR(ARG##I); }
#define get_i(I,N) { must_exist(I); N = Lrdint(ARG##I); \
		 if (N<=0) Lerror(ERR_INCORRECT_CALL,0); }

#define get_oi(I,N) { if (exist(I)) \
		{	N = Lrdint(ARG##I); \
			if (N<=0) Lerror(ERR_INCORRECT_CALL,0); \
		} else N = 0; }

#define get_i0(I,N) { must_exist(I); N = Lrdint(ARG##I); \
		 if (N<0) Lerror(ERR_INCORRECT_CALL,0); }

#define get_oi0(I,N) { if (exist(I)) \
		{	N = Lrdint(ARG##I); \
			if (N<0) Lerror(ERR_INCORRECT_CALL,0); \
		} else N = 0; }

#define get_oiv(I,N,V) { if (exist(I)) \
		{	N = Lrdint(ARG##I); \
			if (N<0) Lerror(ERR_INCORRECT_CALL,0); \
		} else N = V; }

#define get_pad(I,pad) { if (exist(I)) \
		{	L2STR(ARG##I); \
			if (LLEN(*ARG##I)!=1) Lerror(ERR_INCORRECT_CALL,0); \
			pad = LSTR(*ARG##I)[0];  \
		} else pad = ' '; }

enum functions {
 f_abbrev,        f_addr,          f_address,       f_arg,
 f_bitand,        f_bitor,         f_bitxor,        f_compare,
 f_copies,        f_center,        f_close,         f_c2d,
 f_c2x,           f_date,          f_datatype,      f_delstr,
 f_delword,       f_d2c,           f_d2x,           f_d2p, f_p2d,   f_digits,
 f_errortext,     f_eof,           f_getenv,        f_find, f_filter,
 f_flush,         f_form,          f_format,        f_fuzz,
 f_justify,       f_index,         f_insert,        f_lastpos,
 f_left,          f_length,        f_load,          f_max,   f_makebuf,
 f_min,           f_open,          f_overlay,       f_value,
 f_pos,           f_putenv,        f_queued,        f_random,
 f_read,          f_reverse,       f_right,         f_time,
 f_trace,         f_translate,     f_trunc,         f_seek,
 f_sourceline,    f_space,         f_storage,       f_strip,
 f_subword,       f_substr,        f_symbol,        f_vartree,
 f_verify,        f_word,          f_wordindex,     f_wordlength,
 f_wordpos,       f_words,         f_write,         f_x2c,
 f_x2d,           f_xrange,        f_desbuf,        f_soundex,
 f_dropbuf,       f_hashvalue,     f_import,

 f_changestr,     f_countstr,
 f_b2x,           f_x2b,
 f_charin,        f_charout,
 f_linein,        f_lineout,
 f_chars,         f_lines,
 f_stream,

#ifdef __MSDOS__
 f_intr, f_port,
#endif

/* Math routines */
 f_abs  ,    f_acos ,    f_asin ,    f_atan ,
 f_atan2,    f_cos  ,    f_cosh ,    f_exp  ,
 f_log  ,    f_log10,    f_pow  ,    f_pow10,
 f_sin  ,    f_sinh ,    f_sign ,    f_sqrt ,
 f_tan  ,    f_tanh ,    f_ceil,     f_floor,
 f_round,
 f_and  ,    f_or   ,    f_xor  ,    f_not  ,
 f_lasterror,	f_a2u,	f_u2a,

#ifdef __CMS__
 f_cmsflag,
 f_cmsline,
 f_cmsuser,
#endif

 f_lastfunc	/* this will be used for the user builtin functions */
};

#endif
