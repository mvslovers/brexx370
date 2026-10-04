#include <time.h>
#include "lerror.h"
#include "lstring.h"
#include "rxmvsext.h"

#ifdef __CROSS__
#include "jccdummy.h"
#endif

#ifdef __MVS__
#include <sys/select.h>         /* libc370 defines struct timeval here */
#include <ext/time64.h>

/* time of day in seconds and microseconds; libc370 has no
 * gettimeofday(), JCC's came from its runtime */
static void
timeOfDay(struct timeval *tv)
{
    uclock64_t now = uclock64();

    tv->tv_sec  = (long) (now / 1000000);
    tv->tv_usec = (long) (now % 1000000);
}
#else
static void
timeOfDay(struct timeval *tv)
{
    gettimeofday(tv, NULL);
}
#endif

static struct timeval tv_start;

double
MVScputime( )
{
    char time[16];
    char *sTime = time;

    memset(time, 0, 16);
    cputime(&sTime);

    return (double) strtol(time, &sTime, 10)/1000000;
}

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
	timeOfDay(&tv_start);
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

    struct timeval tv_elapsed;

	option = l2u[(byte)option];
 /*   extended time parms
  *     option = '1' = MS   time of day in milliseconds;
  *     option = '2' = US   time of day in microseconds ;
  *     option = '3  = CPU  cpu time
  *     option = '4' = HS   time of day in hundreds of a seconds (integer value)
  *     option = '5' = LS   time of day in micro seconds, in string format, 5 chars (digits) seconds, 6 chars micro seconds without delimiters
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
		    timeOfDay(&tv);

			timeval_subtract(&tv_elapsed, &tv, &tv_start);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                   (int) tv_elapsed.tv_sec,
                         (int) tv_elapsed.tv_usec);

			break;
		case 'H':
			sprintf((char *) LSTR(*timestr), "%d", tmdata->tm_hour) ;

			break;
		case 'L':
            timeOfDay(&tv);

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
			timeOfDay(&tv);

            timeval_subtract(&tv_elapsed, &tv, &tv_start);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                    (int) tv_elapsed.tv_sec,
                    (int) tv_elapsed.tv_usec);

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
            timeOfDay(&tv);
            sprintf((char *) LSTR(*timestr), "%d.%03ld",
                    (tmdata->tm_hour * 3600) +          // hh -> ss +
                    (tmdata->tm_min  * 60  ) +          // mm -> ss +
                    (tmdata->tm_sec),                   // ss
                    tv.tv_usec/1000);                   // us
            break;
        case '2':
            timeOfDay(&tv);
            sprintf((char *) LSTR(*timestr), "%d.%06d",
                    (tmdata->tm_hour * 3600) +          // hh -> ss +
                    (tmdata->tm_min  * 60  ) +          // mm -> ss +
                    (tmdata->tm_sec),                   // ss
                    (int) tv.tv_usec);                        // us

             break;
        case '3':
            sprintf((char *) LSTR(*timestr), "%.3f",MVScputime());
            break;
        case '4':
            timeOfDay(&tv);
            sprintf((char *) LSTR(*timestr), "%d",
                    (tmdata->tm_hour * 360000) +          // hh -> ss +
                    (tmdata->tm_min  * 6000  ) +          // mm -> ss +
                    (tmdata->tm_sec  * 100)    +         // ss
                    (int) tv.tv_usec/10000);                   // us
            break;
		case '5':
			timeOfDay(&tv);
			sprintf((char *) LSTR(*timestr), "%05d%06d",
					(tmdata->tm_hour * 3600) +          // hh -> ss +
					(tmdata->tm_min  * 60  ) +          // mm -> ss +
					(tmdata->tm_sec),                   // ss
					(int) tv.tv_usec);                        // us

			break;

		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
	LLEN(*timestr) = STRLEN((char *) LSTR(*timestr));
} /* Ltime */
