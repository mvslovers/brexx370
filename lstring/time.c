#include <time.h>
#include "lerror.h"
#include "lstring.h"

#ifdef __CROSS__
#include "jccdummy.h"
#endif

static struct timeval tv_start;

int
timeval_subtract (struct timeval *result, struct timeval *x, struct timeval *y)
{
    /* Perform the carry for the later subtraction by updating y. */
    if (x->tv_usec < y->tv_usec) {
        int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
        y->tv_usec -= 1000000 * nsec;
        y->tv_sec += nsec;
    }
    if (x->tv_usec - y->tv_usec > 1000000) {
        int nsec = (x->tv_usec - y->tv_usec) / 1000000;
        y->tv_usec += 1000000 * nsec;
        y->tv_sec -= nsec;
    }

    /* Compute the time remaining to wait.
       tv_usec is certainly positive. */
    result->tv_sec = x->tv_sec - y->tv_sec;
    result->tv_usec = x->tv_usec - y->tv_usec;

    /* Return 1 if result is negative. */
    return x->tv_sec < y->tv_sec;
}

/* ------------------ _Ltimeinit ----------------- */
void __CDECL
_Ltimeinit( void )
{
	gettimeofday(&tv_start, NULL);
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

    struct timeval tv_elapsed;

	option = l2u[(byte)option];
 /*   extended time parms
  *     option = '1' = MS   time of day in milliseconds;
  *     option = '2' = US   time of day in microseconds ;
  *     option = '3  = CPU  cpu time
  */

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

			timeval_subtract(&tv_elapsed, &tv, &tv_start);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                   (int) tv_elapsed.tv_sec,
                         tv_elapsed.tv_usec);

			break;
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

            timeval_subtract(&tv_elapsed, &tv, &tv_start);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                    (int) tv_elapsed.tv_sec,
                    tv_elapsed.tv_usec);

			tv_start = tv;

			break;
		case 'S':
			sprintf((char *) LSTR(*timestr), "%ld",
				(long)((long)(tmdata->tm_hour*60L)+tmdata->tm_min)
				*60L + (long)tmdata->tm_sec) ;

			break;
        case 'U':   /* Unix Time Stamp */
            sprintf((char *) LSTR(*timestr),"%d", (int) time(NULL));
            break;
        case '1':
            gettimeofday(&tv, &tz);
            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%d.%03ld",
                    (tmdata->tm_hour * 3600) +          // hh -> ss +
                    (tmdata->tm_min  * 60  ) +          // mm -> ss +
                    (tmdata->tm_sec),                   // ss
                    tv.tv_usec/1000);                   // us
            break;
        case '2':
            gettimeofday(&tv, &tz);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                    (tmdata->tm_hour * 3600) +          // hh -> ss +
                    (tmdata->tm_min  * 60  ) +          // mm -> ss +
                    (tmdata->tm_sec),                   // ss
                    tv.tv_usec);                        // us

             break;
        case '3':
            sprintf((char *) LSTR(*timestr), "%.3f",(double) clock()/1000);
            break;
		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
	LLEN(*timestr) = STRLEN((char *) LSTR(*timestr));
} /* Ltime */
