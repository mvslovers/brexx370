#include <time.h>
#include "lerror.h"
#include "lstring.h"

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

	gettimeofday(&tv, &tz);

	starttime = (double) tv.tv_sec + (double) tv.tv_usec / 1000000.0;
	elapsed=0.0;

} /* _Ltimeinit */

/* -------------------- Ltime ---------------------- */
void __CDECL
Ltime( const PLstr timestr, char option )
{
	int	hour;

	time_t	now;
	char	*ampm;

	struct tm *tmdata;

    struct timeval tv;
    struct timezone tz;

	option = l2u[(byte)option];
	Lfx(timestr,30); LZEROSTR(*timestr);

	now = time(NULL);
	tmdata = localtime(&now);

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
                    tmdata->tm_hour,
                    tmdata->tm_min,
                    tmdata->tm_sec,
                    (long) tv.tv_usec) ;

            break;
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
            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%ld",
                    (long)
                    ( (tmdata->tm_hour * 3600) +        // hh -> ss +
                      (tmdata->tm_min  * 60  ) +        // mm -> ss +
                      (tmdata->tm_sec)                  // ss
                    ) * 1000                            //    -> ms +
                      + (tv.tv_usec/1000));             // us -> ms

            break;
        case 'Y':
            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                    (tmdata->tm_hour * 3600) +          // hh -> ss +
                    (tmdata->tm_min  * 60  ) +          // mm -> ss +
                    (tmdata->tm_sec),                   // ss
                    tv.tv_usec);                        // us

             break;
		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
	LLEN(*timestr) = STRLEN((char *) LSTR(*timestr));
} /* Ltime */
