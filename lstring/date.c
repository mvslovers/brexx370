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


void PrintDate(PLstr to,int dd,int mm,int yy, char omode) {
    static	char *fmt = TEXT("%02d/%02d/%02d");
    static	char *fmtx = TEXT("%02d/%02d/%04d");
    static	char *iso = TEXT("%4d%02d%02d");

    if (omode=='E') sprintf((char *) LSTR(*to),fmt,dd,mm,yy);
    else if (omode=='4') sprintf((char *) LSTR(*to),fmtx,dd,mm,yy);
    else sprintf((char *) LSTR(*to),fmtx,dd,mm,yy);

    LLEN(*to) = STRLEN((char *)LSTR(*to));
}



/* ----------------------------------------------------------
 *  Julian Day Number Calculation, number of days since:
 *     Monday, January 1, 4713 BC Julian calendar which is
 *     November 24, 4714 BC Gregorian calendar
 * ----------------------------------------------------------
 */
int JULDAYNUM(int day,int month,int year,int AD) {
    int a, m, y, jdn;
    a = (14 - month)/12;
    m = month + 12 * a - 3;
    y = year + 4800 - a;
    jdn = day + (int) (153 * m + 2)/5 + 365 * y;
    jdn = jdn + (int) y/4 - (int) y/100 + (int) y/400 - 32045;
    if (AD==1) jdn=jdn-1721426;
    return jdn;
}
void FromJulian(int JDN, int parmo[3],int ad) {
    int l,n,i,j;
    if (ad==1) JDN=JDN+1721426;
    l = JDN+68569;
    n = 4*l/146097;
    l = l-(146097*n+3)/4;
    i = 4000*(l+1)/1461001;
    l = l-1461*i/4+31;
    j = 80*l/2447;
    parmo[1] = l-2447*j/80;
    l = j / 11;
    parmo[2] = j+2-12*l;
    parmo[3] = 100*(n-49)+i+l;
}

int dateI(int dd,int mm, int yy, char date_format1) {
	static	char *fmt = TEXT("%02d/%02d/%02d");
    static	char *fmtx = TEXT("%02d/%02d/%04d");
	static	char *iso = TEXT("%4d%02d%02d");
	long	length, extended=0;
	char	*chptr;

	time_t now ;
	struct tm *tmdata ;

 /*   extended Date parms
  *     option = '1' = EX    European date with 4 digit year
  *     option = '2' = 'JDN' Days
  *                     since  Monday, January 1, 4713 BC Julian calendar which is
  *                     November 24, 4714 BC Gregorian calendar
  */


    date_format1 = l2u[(byte)date_format1];



	switch (date_format1) {
		case 'C':     // Days since 1.1.1900
			length = tmdata->tm_yday + 1 +
			(long)(((double)tmdata->tm_year-1)*365.25) + 365 ;
//			sprintf((char *) LSTR(*datestr),"%ld",length) ;
			break;

		case 'D':
//			sprintf((char *) LSTR(*datestr), "%d", tmdata->tm_yday+1) ;
			break;

		case 'E':
//			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_mday,
//				tmdata->tm_mon+1, tmdata->tm_year%100) ;
			break;
        case '1':     // Format-1 Ex European with 4 digit year
 //           sprintf((char *) LSTR(*datestr), fmtx, tmdata->tm_mday,
//                    tmdata->tm_mon+1, tmdata->tm_year+1900) ;
            break;

		case 'J':
//			sprintf((char *) LSTR(*datestr),"%004d%03d",
//				tmdata->tm_year+1900, tmdata->tm_yday+1);
			break;

		case 'M':
//			STRCPY((char *) LSTR(*datestr),months[tmdata->tm_mon]);
			break;

		case 'N':
			chptr = months[tmdata->tm_mon] ;
//			sprintf((char *) LSTR(*datestr),"%d %c%c%c %4d",
//				tmdata->tm_mday, chptr[0], chptr[1],
//				chptr[2], tmdata->tm_year+1900) ;
			break;

		case 'O':
//			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_year%100,
//				tmdata->tm_mon+1, tmdata->tm_mday);
			break;

		case 'S':
//			sprintf((char *) LSTR(*datestr), iso, tmdata->tm_year+1900,
//				tmdata->tm_mon+1, tmdata->tm_mday) ;
			break;

		case 'U':
//			sprintf((char *) LSTR(*datestr), fmt, tmdata->tm_mon+1,
//				tmdata->tm_mday, tmdata->tm_year%100 ) ;
			break;

		case 'W':
//			STRCPY((char *) LSTR(*datestr), WeekDays[tmdata->tm_wday]);
			break;
        case '2':     // Julian Day Number
 //           sprintf((char *) LSTR(*datestr),"%d", JULDAYNUM(2,1,2021)); // 2459217
  //          break;
        case '3':     // Julian Day Number
            return JULDAYNUM(dd,mm,yy,1); // 737791
            break;
        case '4':     // convert from Julian Day Number
 //           FromJulian(datestr,2459217,date_format1); // 737791
            break;
		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
} /* Ldate */
/* ------------------------------------------------------------------------------------
 * Parse a give numeric string in its words
 * ------------------------------------------------------------------------------------
 */
int parseDate(PLstr parm,int parmi[3]) {
        int i,wrds, parms=0;
        Lstr word;
        LINITSTR(word);
        Lfx(&word,16);
        Lscpy(&word,",:.;/-");
        Lfilter(parm,parm,&word,'B');
        wrds=Lwords(parm);

        parmi[0]=0;
        for (i = 1; i <= 3; ++i) {
            if (i<=wrds) {
                Lword(&word, parm, i);
                LSTR(word)[LLEN(word)]=0;
                L2int(&word);
                parmi[i] = LINT(word);
            } else parmi[i]=0;
        }
        LFREESTR(word);
    return wrds;
    }



/* ----------------- Ldate ------------------ */
void Ldate(PLstr datestr, PLstr format1, PLstr input_date, PLstr format2) {
    int julian, parm[4], noO=0;
    time_t now;
    struct tm *tmdata;

    /* Date input formats
    *  Base      is days since 01.01.0001
    *  JDN       is days since 24. November 4714 BC
    *  UNIX      is days since 1. January 1970
    *  Julian    is yyyyddd    e.g. 2018257
    *  European  is dd/mm/yyyy e.g. 11/11/2018
    *  German    is dd.mm.yyyy e.g. 20.09.2018
    *  USA       is mm/dd/yyyy e.g. 12.31.2018
    *  STANDARD  is yyyymmdd   e.g. 20181219
    *  ORDERED   is yyyy/mm/dd e.g. 2018/12/19
    */
    if (input_date != NULL) {
        if (strncasecmp(LSTR(*format2), "UNIX",2) == 0) {
            L2INT(input_date);
            julian = LINT(*input_date) + JULDAYNUM(1, 1, 1970, 1);
        } else  if (strncasecmp(LSTR(*format2), "B",1) == 0) {
            L2INT(input_date);
            julian = LINT(*input_date);
        } else  if (strncasecmp(LSTR(*format2), "J",1) == 0) {
            Lsubstr(datestr,input_date, 1, 4,' ');
            L2INT(datestr);
            julian=JULDAYNUM(0, 1, LINT(*datestr),1);
            Lsubstr(datestr,input_date, 5, 3,' ');
            L2INT(datestr);
            julian=julian+LINT(*datestr);  // daysofyear = substr(idate, 5, 3)
            LZEROSTR(*datestr);
        } else if (LLEN(*input_date) > 6) {
            if (parseDate(input_date, parm) ==3) {  // JULDAYNUM // ad=1 is a base date, starting 1.1.0000, ad=0 Monday, January 1, 4713 BC
                if      (strncasecmp(LSTR(*format2), "XEUROPEAN",2) == 0) julian = JULDAYNUM(parm[1], parm[2], parm[3], 1);
                else if (strncasecmp(LSTR(*format2), "EUROPEAN",1) == 0)  julian = JULDAYNUM(parm[1], parm[2], parm[3], 1);
                else if (strncasecmp(LSTR(*format2), "GERMAN",1) == 0)    julian = JULDAYNUM(parm[1], parm[2], parm[3], 1);
                else if (strncasecmp(LSTR(*format2), "USA",1) == 0)       julian = JULDAYNUM(parm[2], parm[1], parm[3], 1);
                else if (strncasecmp(LSTR(*format2), "XUSA",2) == 0)      julian = JULDAYNUM(parm[2], parm[1], parm[3], 1);
                else if (strncasecmp(LSTR(*format2), "SORTED",1) == 0)    julian = JULDAYNUM(parm[3], parm[2], parm[1], 1);
                else if (strncasecmp(LSTR(*format2), "ORDERED",1) == 0)   julian = JULDAYNUM(parm[2], parm[3], parm[1], 1);
            } else {  }
        }
    } else {
        now = time(NULL);
        tmdata = localtime(&now);
        julian = JULDAYNUM((int) tmdata->tm_mday, (int) tmdata->tm_mon + 1, (int) tmdata->tm_year + 1900, 1);
    }


    if (strncasecmp(LSTR(*format1), "BASE",1) == 0) noO=1;
    else if (strncasecmp(LSTR(*format1), "UNIX",2) == 0) {
        julian = julian -JULDAYNUM(1, 1, 1970, 1);
        noO = 1;
    }
    if (strncasecmp(LSTR(*format1), "JDN",3) == 0) {
        julian = julian +1721426;
        noO = 1;
    }
    if (noO==1) {
       Licpy(datestr, julian);
       return;
    }
    FromJulian(julian, parm, 1);   // ad=1 is a base date, starting 1.1.0000, ad=0 Monday, January 1, 4713 BC

    if (strncasecmp(LSTR(*format1), "XEUROPEAN",2) == 0)      sprintf((char *) LSTR(*datestr), "%02d/%02d/%04d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format1), "EUROPEAN",1) == 0)  sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[1], parm[2], parm[3]%100);
    else if (strncasecmp(LSTR(*format1), "GERMAN",1) == 0)    sprintf((char *) LSTR(*datestr), "%02d.%02d.%02d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format1), "USA",1) == 0)       sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3]%100);
    else if (strncasecmp(LSTR(*format1), "XUSA",2) == 0)      sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format1), "ORDERED",1) == 0)   sprintf((char *) LSTR(*datestr), "%04d/%02d/%02d", parm[3], parm[2], parm[1]);


    LLEN(*datestr) = STRLEN((char *)LSTR(*datestr));
}

