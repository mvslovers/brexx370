/*
 * $Id: time.c,v 1.11 2009/06/02 09:40:53 bnv Exp $
 * $Log: time.c,v $
 * Revision 1.11  2009/06/02 09:40:53  bnv
 * MVS/CMS corrections
 *
 * Revision 1.10  2009/02/02 09:26:34  bnv
 * Modications for CMS,MVS
 *
 * Revision 1.9  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.8  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.7  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.6  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.5  1999/11/26 12:52:25  bnv
 * Added: Windows CE support
 *
 * Revision 1.4  1999/03/10 16:55:55  bnv
 * Added MSC support
 *
 * Revision 1.3  1999/03/01 11:06:33  bnv
 * Change in the format to long int for tv.tv_usec just to keep compiler happy
 *
 * Revision 1.2  1998/11/06 08:57:08  bnv
 * Added: in the includes the time.h and sys/time.h
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#if defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER) && !defined(WCE)
#	include <dos.h>
#	include <time.h>
#elif defined(WCE)
#elif defined(_MSC_VER)
#	include <time.h>
#	include <sys/types.h>
#	include <sys/timeb.h>
#else
/* Load both of them time.h and sys/time.h, you never now where the
 * struct timeval is
 */
#	include <time.h>
#	if !defined(__CMS__) && !defined(__MVS__)
#		include <sys/time.h>
#		include <unistd.h>
#	endif
#endif
#include "lerror.h"
#include "lstring.h"
#if defined(__MVS__) && defined(JCC) || defined(__CROSS__)
# include "rxmvsext.h"
#endif

static double elapsed=0.0;
#if defined(JCC)
	static double starttime=0.0;
#endif

/* ------------------ _Ltimeinit ----------------- */
void __CDECL
_Ltimeinit( void )
{
#if defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
	struct time	t;
#elif defined(WCE)
	/* nothing to declare */
#elif defined(_MSC_VER)
	struct _timeb tb;
#elif defined(__CMS__) || (defined(__MVS__) && !defined(JCC))
	unsigned int vmnow[2];
	struct tm * tv;
	time_t rawtime;
#elif defined(JCC)
	struct timeval vmtime;
	struct timezone vmzone;
	struct tm * tv;
	time_t rawtime;
#else
	struct timeval	tv;
	struct timezone	tz;
#endif

#ifdef WCE
	elapsed = (double)GetTickCount() / 1000.0;
#elif defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
	gettime(&t);
	elapsed = (double)t.ti_hour*3600 + (double)t.ti_min*60 +
		(double)t.ti_sec + (double)t.ti_hund/100.0;
#elif defined(_MSC_VER)
	_ftime(&tb);
	elapsed = (double)tb.time + (double)tb.millitm/1000.0;
#elif defined(__CMS__)
	rawtime = rexclock(vmnow);
	tv=gmtime(&rawtime);
	elapsed = (double)vmnow[0] + (double)vmnow[1]/1000000.0;
#elif defined(__MVS__)
#if defined(JCC)
	gettimeofday(&vmtime,&vmzone);
	rawtime = time(NULL);
	starttime = (double) vmtime.tv_sec + (double) vmtime.tv_usec/1000000.0;
	elapsed=0.0;
#else
	rawtime = __getclk(vmnow);
	elapsed = (double)(vmnow[0] >> 12) + (double)(vmnow[1] >> 12)/1000000.0;
#endif
	tv=gmtime(&rawtime);
#else
	gettimeofday(&tv,&tz);
	elapsed = tv.tv_sec + (double)tv.tv_usec/1000000.0;
#endif
} /* _Ltimeinit */

/* -------------------- Ltime ---------------------- */
void __CDECL
Ltime( const PLstr timestr, char option )
{
	double	unow;
	int	hour;
#ifdef WCE
	SYSTEMTIME	time;
	TCHAR	buf[30];
	TCHAR	*ampm;
#else
	time_t	now;
	char	*ampm;
	struct tm *tmdata ;
#	if defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
		struct time t;
#	elif defined(_MSC_VER)
		struct _timeb tb;
#	elif defined(__CMS__) // (defined(__MVS__) && !defined(JCC))
		unsigned int vmnow[2];
		struct tm * tv;
#	elif defined(__MVS__) && defined(JCC)
		struct timeval vmtime;
		struct timezone vmzone;
		struct tm * tv;
        RX_PTIME_PARAMS_PTR  params;
        char                *wptmadr;
        unsigned            *wptladr;
        unsigned            *wptccadr;
        unsigned            *wptwkadr;
#	else
		struct timeval tv;
		struct timezone tz;
#	endif
#endif

	option = l2u[(byte)option];
	Lfx(timestr,30); LZEROSTR(*timestr);

#ifndef WCE
	now = time(NULL);
	tmdata = localtime(&now) ;
#else
	GetLocalTime(&time);
#endif

	switch (option) {
		case 'C':
#ifndef WCE
			hour = tmdata->tm_hour ;
			ampm = (hour>11) ? "pm" : "am" ;
			if ((hour=hour%12)==0)  hour = 12 ;
			sprintf(LSTR(*timestr),"%d:%02d%s",
				hour, tmdata->tm_min, ampm) ;
#else
			hour = time.wHour ;
			ampm = (hour>11) ? TEXT("pm") : TEXT("am");
			if ((hour=hour%12)==0)  hour = 12 ;
			swprintf(buf,TEXT("%d:%02d%s"),
				hour, time.wMinute, ampm) ;
#endif
			break;

		case 'E':
#ifdef WCE
			unow = (double)GetTickCount() / 1000.0;
#elif defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
			gettime(&t);
			unow = (double)t.ti_hour*3600 + (double)t.ti_min*60 +
				(double)t.ti_sec + (double)t.ti_hund/100.0;
#elif defined(_MSC_VER)
			_ftime(&tb);
			unow = (double)tb.time + (double)tb.millitm/1000.0;
#elif defined(__CMS__)
			rexclock(vmnow);
			unow = (double)vmnow[0]+(double)vmnow[1]/1000000.0;
#elif (defined(__MVS__) && !defined(JCC))
			__getclk(vmnow);
			unow = (double)(vmnow[0]>>12)+(double)(vmnow[1]>>12)/1000000.0;
#elif defined(JCC)
			gettimeofday(&vmtime,&vmzone);
			elapsed = (double) vmtime.tv_sec + (double) vmtime.tv_usec/1000000.0 - starttime;
#else
			gettimeofday(&tv,&tz);
			unow = (double)tv.tv_sec + (double)tv.tv_usec/1000000.0;
#endif
#if defined(JCC)
			LREAL(*timestr) = elapsed;
#else
			LREAL(*timestr) = unow-elapsed;
#endif
			LTYPE(*timestr) = LREAL_TY;
			LLEN(*timestr) = sizeof(double);
			return;

		case 'H':
#ifndef WCE
			sprintf(LSTR(*timestr), "%d", tmdata->tm_hour) ;
#else
			swprintf(buf, TEXT("%d"), time.wHour) ;
#endif
			break;

		case 'L':
#ifdef WCE
			swprintf(buf, TEXT("%02d:%02d:%02d.%03d"), time.wHour,
					time.wMinute, time.wSecond, time.wMilliseconds) ;
#elif defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
			gettime(&t);
			sprintf(LSTR(*timestr), "%02d:%02d:%02d.%02d",
				t.ti_hour, t.ti_min, t.ti_sec, t.ti_hund);
#elif defined(_MSC_VER)
			_ftime(&tb);
			sprintf(LSTR(*timestr), "%02d:%02d:%02d.%03ld",
				tmdata->tm_hour, tmdata->tm_min,
				tmdata->tm_sec, tb.millitm) ;
#elif defined(__CMS__)
			/* need to provide a replacement here for CMS & MVS */
#elif defined(__MVS__) && defined(JCC)
			params   = malloc(sizeof(RX_PTIME_PARAMS));
            wptmadr  = (char     *) malloc(12);
            wptladr  = (unsigned *) malloc(4);
            wptccadr = (unsigned *) malloc(4);
            wptwkadr = (unsigned *) malloc(256);

            memset(wptmadr,0,12);

            params->wptmadr  = (unsigned *) wptmadr;
            params->wptladr  = (unsigned *) wptladr;
            params->wptccadr = (unsigned *) wptccadr;
            params->wptwkadr = (unsigned *) wptwkadr;

            call_rxptime(params);

            sprintf(LSTR(*timestr), "%s",
            wptmadr) ;

            free(wptmadr);
            free(wptladr);
            free(wptccadr);
            free(wptwkadr);
            free(params);

#else
			gettimeofday(&tv,&tz);
			sprintf(LSTR(*timestr), "%02d:%02d:%02d.%06ld",
				tmdata->tm_hour, tmdata->tm_min,
				tmdata->tm_sec, tv.tv_usec) ;
#endif
			break;

		case 'M':
#ifndef WCE
			sprintf(LSTR(*timestr), "%d",
				tmdata->tm_hour*60 + tmdata->tm_min) ;
#else
			swprintf(buf, TEXT("%d"),
				time.wHour*60 + time.wMinute);
#endif
			break;

		case 'N':
#ifndef WCE
			sprintf(LSTR(*timestr), "%02d:%02d:%02d",
				tmdata->tm_hour, tmdata->tm_min,
				tmdata->tm_sec ) ;
#else
			swprintf(buf, TEXT("%02d:%02d:%02d"),
				time.wHour, time.wMinute, time.wSecond);
#endif
			break;

		case 'R':
#ifdef WCE
			unow = (double)GetTickCount() / 1000.0;
#elif defined(MSDOS) && !defined(__WIN32__) && !defined(_MSC_VER)
			gettime(&t);
			unow = (double)t.ti_hour*3600 + (double)t.ti_min*60 +
				(double)t.ti_sec + (double)t.ti_hund/100.0;
#elif defined(_MSC_VER)
			_ftime(&tb);
			unow = (double)tb.time + (double)tb.millitm/1000.0;
#elif defined(__CMS__)
			rexclock(vmnow);
			unow=(double)vmnow[0] + (double)vmnow[1]/1000000.0;
#elif (defined(__MVS__) && !defined(JCC))
			__getclk(vmnow);
			unow=(double)(vmnow[0] >> 12) + (double)(vmnow[1] >> 12)/1000000.0;
#elif defined(JCC)
			gettimeofday(&vmtime,&vmzone);
			elapsed = (double) vmtime.tv_sec + (double) vmtime.tv_usec/1000000.0 - starttime;
#else
			gettimeofday(&tv,&tz);
			unow = (double)tv.tv_sec + (double)tv.tv_usec/1000000.0;
#endif
#if defined(JCC)
			LREAL(*timestr) = elapsed;
			starttime = (double) vmtime.tv_sec + (double) vmtime.tv_usec/1000000.0;
#else
			LREAL(*timestr) = unow-elapsed;
			elapsed = unow;
#endif
			LTYPE(*timestr) = LREAL_TY;
			LLEN(*timestr) = sizeof(double);
			return;

		case 'S':
#ifndef WCE
			sprintf(LSTR(*timestr), "%ld",
				(long)((long)(tmdata->tm_hour*60L)+tmdata->tm_min)
				*60L + (long)tmdata->tm_sec) ;
#else
			swprintf(buf, TEXT("%ld"),
				(long)((long)(time.wHour*60L)+time.wMinute)
				*60L + (long)time.wSecond) ;
#endif
			break;

		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
#ifndef WCE
	LLEN(*timestr) = STRLEN(LSTR(*timestr));
#else
	wcstombs(LSTR(*timestr), buf, LLEN(*timestr)=wcslen(buf));
#endif
} /* Ltime */
