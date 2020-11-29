#include <time.h>
#include "lerror.h"
#include "lstring.h"

static char *WeekDays[] = {
	TEXT("Sunday"), TEXT("Monday"), TEXT("Tuesday"), TEXT("Wednesday"),
	TEXT("Thursday"), TEXT("Friday"), TEXT("Saturday") };

static char *months[] = {
	TEXT("January"), TEXT("February"), TEXT("March"),
	TEXT("April"), TEXT("May"), TEXT("June"),
	TEXT("July"), TEXT("August"), TEXT("September"),
	TEXT("October"), TEXT("November"), TEXT("December") };

/* ----------------- Ldate ------------------ */
void Ldate(PLstr datestr, char date_format1, PLstr input_date, char date_format2)
{
	static	char *fmt = TEXT("%02d/%02d/%02d");
	static	char *iso = TEXT("%4d%02d%02d");
	long	length;
	char	*chptr;

	time_t now ;
	struct tm *tmdata ;


    date_format1 = l2u[(byte)date_format1];
	Lfx(datestr,30); LZEROSTR(*datestr);

	now = time(NULL);
	tmdata = localtime(&now) ;

	switch (date_format1) {
		case 'C':
			length = tmdata->tm_yday + 1 +
			(long)(((double)tmdata->tm_year-1)*365.25) + 365 ;
			sprintf((char *) LSTR(*datestr),"%ld",length) ;
			break;

		case 'D':
			sprintf((char *) LSTR(*datestr), "%d", tmdata->tm_yday+1) ;
			break;

		case 'E':
			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_mday,
				tmdata->tm_mon+1, tmdata->tm_year%100) ;
			break;

		case 'J':
			sprintf((char *) LSTR(*datestr),"%004d%03d",
				tmdata->tm_year+1900, tmdata->tm_yday+1);
			break;

		case 'M':
			STRCPY((char *) LSTR(*datestr),months[tmdata->tm_mon]);
			break;

		case 'N':
			chptr = months[tmdata->tm_mon] ;
			sprintf((char *) LSTR(*datestr),"%d %c%c%c %4d",
				tmdata->tm_mday, chptr[0], chptr[1],
				chptr[2], tmdata->tm_year+1900) ;
			break;

		case 'O':
			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_year%100,
				tmdata->tm_mon+1, tmdata->tm_mday);
			break;

		case 'S':
			sprintf((char *) LSTR(*datestr), iso, tmdata->tm_year+1900,
				tmdata->tm_mon+1, tmdata->tm_mday) ;
			break;

		case 'U':
			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_mon+1,
				tmdata->tm_mday, tmdata->tm_year%100 ) ;
			break;

		case 'W':
			STRCPY((char *) LSTR(*datestr), WeekDays[tmdata->tm_wday]);
			break;

		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
	LLEN(*datestr) = STRLEN((char *)LSTR(*datestr));
} /* Ldate */
