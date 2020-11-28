
#include <time.h>
#include "lerror.h"
#include "lstring.h"
#include "rxmvsext.h"

#ifdef __CROSS__
#include "jccdummy.h"
#endif

static double elapsed=0.0;
static double starttime=0.0;

/* ------------------ _Ltimeinit ----------------- */
void __CDECL
_Ltimeinit( void )
{
	struct timeval tv;
	struct timezone tz;
	//struct tm * tm;
	//time_t rawtime;

	gettimeofday(&tv, &tz);
	//rawtime = time(NULL);
	starttime = (double) tv.tv_sec + (double) tv.tv_usec / 1000000.0;
	elapsed=0.0;
    //tm=gmtime(&rawtime);

} /* _Ltimeinit */

/* -------------------- Ltime ---------------------- */
void __CDECL
Ltime( const PLstr timestr, char option )
{
	double	unow;
	int	hour, msec;

	time_t	now;
	char	*ampm;

	struct tm *tmdata ;
    struct tm *tm;

    struct timeval tv;
    struct timezone tz;

    char                *wptmadr;
    unsigned            *wptladr;
    unsigned            *wptccadr;
    unsigned            *wptwkadr;

	option = l2u[(byte)option];
	Lfx(timestr,30); LZEROSTR(*timestr);

	now = time(NULL);
	tmdata = localtime(&now) ;

	switch (option) {
		case 'C':
			hour = tmdata->tm_hour ;
			ampm = (hour>11) ? "pm" : "am" ;
			if ((hour=hour%12)==0)  hour = 12 ;

			sprintf((char *) LSTR(*timestr),"%d:%02d%s",
				hour, tmdata->tm_min, ampm) ;

			break;

		case 'E':

			gettimeofday(&tv, &tz);
			elapsed = (double) tv.tv_sec + (double) tv.tv_usec / 1000000.0 - starttime;
			LREAL(*timestr) = elapsed;
			LTYPE(*timestr) = LREAL_TY;
			LLEN(*timestr) = sizeof(double);
			return;

		case 'H':
			sprintf((char *) LSTR(*timestr), "%d", tmdata->tm_hour) ;

			break;

		case 'L':
            gettimeofday(&tv,&tz);

            sprintf((char *) LSTR(*timestr), "%02d:%02d:%02d.%06ld",
                    tmdata->tm_hour, tmdata->tm_min,
                    tmdata->tm_sec, tv.tv_usec) ;

		case 'M':
			sprintf((char *) LSTR(*timestr), "%d",
				tmdata->tm_hour*60 + tmdata->tm_min) ;
			break;

		case 'N':
			sprintf((char *) LSTR(*timestr), "%02d:%02d:%02d",
				tmdata->tm_hour, tmdata->tm_min,
				tmdata->tm_sec ) ;
			break;

		case 'R':
			gettimeofday(&tv, &tz);
			elapsed = (double) tv.tv_sec + (double) tv.tv_usec / 1000000.0 - starttime;
			LREAL(*timestr) = elapsed;
			starttime = (double) tv.tv_sec + (double) tv.tv_usec / 1000000.0;
			LTYPE(*timestr) = LREAL_TY;
			LLEN(*timestr) = sizeof(double);
			return;

		case 'S':
			sprintf((char *) LSTR(*timestr), "%ld",
				(long)((long)(tmdata->tm_hour*60L)+tmdata->tm_min)
				*60L + (long)tmdata->tm_sec) ;
			break;
        case 'U':   /* Unix Time Stamp */
            sprintf((char *) LSTR(*timestr),"%d\n", (int) time(NULL));
            break;

        case 'X':
            printf("FOO> %s \n", "MILLIS");

            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%d.%3d",
                    tmdata->tm_hour * 3600 + tmdata->tm_min * 60 + tmdata->tm_sec,
                    (tv.tv_usec/1000));
            break;

        case 'Y':
            printf("FOO> %s \n", "MICROS");

            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%d.%6d",
                    tmdata->tm_hour * 3600 + tmdata->tm_min * 60 + tmdata->tm_sec,
                    (tv.tv_usec));
            break;

		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
	LLEN(*timestr) = STRLEN((char *) LSTR(*timestr));
} /* Ltime */
