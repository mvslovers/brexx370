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

/* ----------------------------------------------------------
 *  Julian Day Number Calculation, number of days since:
 *     Monday, January 1, 4713 BC Julian calendar which is
 *     November 24, 4714 BC Gregorian calendar
 * ----------------------------------------------------------
 */
int JULDAYNUM(int day,int month,int year) {
    int a, m, y, jdn;
    a = (14 - month)/12;
    m = month + 12 * a - 3;
    y = year + 4800 - a;
    jdn = day + (int) (153 * m + 2)/5 + 365 * y;
    jdn = jdn + (int) y/4 - (int) y/100 + (int) y/400 - 32045;
    return jdn;
}
void FromJulian(int JDN, int parmo[3]) {
    int l,n,i,j;
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
/* ------------------------------------------------------------------------------------
 * Parse a give numeric string in its words
 * ------------------------------------------------------------------------------------
 */
int parseDate(PLstr parm,int parmi[3]) {
        int i,wrds, parms=0;
        Lstr word;
        LINITSTR(word);
        Lfx(&word,16);
        Lscpy(&word,",:.;/");
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
/* ------------------------------------------------------------------------------------
 * Parse a give numeric string in its words
 * ------------------------------------------------------------------------------------
 */
int parseStandardDate(PLstr parm,int parmi[3]) {
    parmi[3]= LINT(*parm)/10000;
    LINT(*parm)=LINT(*parm)%10000;
    parmi[2]= LINT(*parm)/100;
    parmi[1]=LINT(*parm)%100;
}
/* ----------------- Ldate ------------------ */
void Ldate(PLstr datestr, PLstr format1, PLstr input_date, PLstr format2) {
    int julian, parm[4], noO = 0, checked;
    time_t now;
    struct tm *tmdata;
/* ---------------------------------------------------------------------------------------------------------------------
 * Date input formats
 *  Base      is days since 01.01.0001
 *  JDN       is days since Monday 24. November 4714 BC
 *  UNIX      is days since 1. January 1970
 *  Julian    is yyyyddd    e.g. 2018257
 *  European  is dd/mm/yyyy e.g. 11/11/2018
 *  German    is dd.mm.yyyy e.g. 20.09.2018
 *  USA       is mm/dd/yyyy e.g. 12.31.2018
 *  STANDARD  is yyyymmdd   e.g. 20181219
 *  ORDERED   is yyyy/mm/dd e.g. 2018/12/19
 */
/* ---------------------------------------------------------------------------------------------------------------------
 *  process date according to input format
 *  Part I process input dates which are already numeric (JDN or BASE)
 *       or the date field is empty, then we need no input format
 * ---------------------------------------------------------------------------------------------------------------------
 */
    if (input_date == NULL) {
        now = time(NULL);
        tmdata = localtime(&now);
        julian = JULDAYNUM((int) tmdata->tm_mday, (int) tmdata->tm_mon + 1, (int) tmdata->tm_year + 1900);
        goto processoutput;
    } else {
        goto checkInputFormat;    // check and process certain input formats for input formats
        returnfromcheck: ;
        if (checked==1) goto processoutput;
    }
    if (LLEN(*input_date) <5) {
        printf("invalid input date %s\n", LSTR(*input_date));
        Lerror(ERR_INCORRECT_CALL, 0);
    }
    if (parseDate(input_date, parm) != 3) {
        printf("invalid input date %s\n", LSTR(*format2));
        Lerror(ERR_INCORRECT_CALL, 0);
    }
/* ---------------------------------------------------------------------------------------------------------------------
 * process input date/input format part 2
 * Here are input definitions which require an analysis of the given date string
 * JULDAYNUM // ad=1 is a base date, starting 1.1.0000, ad=0 Monday, January 1, 4713 BC
 * ---------------------------------------------------------------------------------------------------------------------
 */
    if (strncasecmp(LSTR(*format2), "XEUROPEAN", 2) == 0)           julian = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "EUROPEAN", 1) == 0)       julian = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "GERMAN", 1) == 0) julian = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "USA", 1) == 0)    julian = JULDAYNUM(parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format2), "XUSA", 2) == 0)   julian = JULDAYNUM(parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format2), "SORTED", 1) == 0) julian = JULDAYNUM(parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format2), "ORDERED", 1) == 0) julian = JULDAYNUM(parm[2], parm[3], parm[1]);
    else {
       printf("invalid input format %s\n", LSTR(*format2));
       Lerror(ERR_INCORRECT_CALL, 0);
    }
/*  --------------------------------------------------------------------------------------------------------------------
 *  process output according to output format
 *   Base      is days since 01.01.0001
 *   JDN       is days since 24. November 4714 BC
 *   UNIX      is days since 1. January 1970
 *   Julian    is yyyyddd    e.g. 2018257
 *   Days      is ddd days in this year e.g. 257
 *   Weekday   is weekday of day e.g. Monday
 *   Century   is dddd days in this century
 *   European  is dd/mm/yy   e.g. 11/11/18
 *   XEuropea  is dd/mm/yyyy e.g. 11/11/2018  extended European (4 digits year)
 *   German    is dd.mm.yyyy e.g. 20.09.2018
 *   USA       is mm/dd/yyyy e.g. 12.31.18
 *   xUSA       is mm/dd/yyyy e.g. 12.31.2018 extended USA (4 digits year)
 *   STANDARD  is yyyymmdd        e.g. 20181219
 *   ORDERED   is yyyy/mm/dd e.g. 2018/12/19
 *   NORMAL     is dd month yyyy e.g. 12. MARCH 2018
 *  --------------------------------------------------------------------------------------------------------------------
 */
processoutput:
    //* Convert the Julian day number (JDN) to day month year
    FromJulian(julian, parm);   // ad=1 is a base date, starting 1.1.0000, ad=0 Monday, January 1, 4713 BC

    noO = 1;   // preset to date is numeric
    if      (strncasecmp(LSTR(*format1), "BASE", 1) == 0)   julian = julian + 1721426;
    else if (strncasecmp(LSTR(*format1), "UNIX",2) == 0)    julian = julian -JULDAYNUM(1, 1, 1970);
    else if (strncasecmp(LSTR(*format1), "CENTURY",1) == 0) julian = julian+1-JULDAYNUM(1, 1,parm[3]/100*100);
    else if (strncasecmp(LSTR(*format1), "DAYS",1) == 0)    julian = julian+1-JULDAYNUM(1, 1,parm[3]);
    else if (strncasecmp(LSTR(*format1), "JDN",3) == 0) ; // noO already sset
    else noO=0;

    if (noO==1) {
       Licpy(datestr, julian);
       return;
    }
//* Translate into appropriate date according to out format
    if (strncasecmp(LSTR(*format1), "XEUROPEAN",2) == 0)      sprintf((char *) LSTR(*datestr), "%02d/%02d/%04d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format1), "EUROPEAN",1) == 0)  sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[1], parm[2], parm[3]%100);
    else if (strncasecmp(LSTR(*format1), "GERMAN",1) == 0)    sprintf((char *) LSTR(*datestr), "%02d.%02d.%02d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format1), "USA",1) == 0)       sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3]%100);
    else if (strncasecmp(LSTR(*format1), "XUSA",2) == 0)      sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format1), "ORDERED",1) == 0)   sprintf((char *) LSTR(*datestr), "%04d/%02d/%02d", parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format1), "STANDARD",1) == 0)  sprintf((char *) LSTR(*datestr), "%04d%02d%02d", parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format1), "NORMAL",1) == 0)    sprintf((char *) LSTR(*datestr), "%02d %s% 04d", parm[1], months[parm[2]-1], parm[3]);
    else if (strncasecmp(LSTR(*format1), "WEEK",1) == 0)      STRCPY((char *)  LSTR(*datestr), WeekDays[(julian+1)%7]);
    else if (strncasecmp(LSTR(*format1), "JULIAN",1) == 0)    sprintf((char *) LSTR(*datestr), "%04d%03d", parm[3], julian+1-JULDAYNUM(1, 1,parm[3]));

    LLEN(*datestr) = STRLEN((char *)LSTR(*datestr));
    return;
/* ---------------------------------------------------------------------------------------------------------------------
 * Here are some sub function to make it modular and better readable
 * ---------------------------------------------------------------------------------------------------------------------
 */
checkInputFormat:
    checked=1;
    if (format2== NULL) {
       printf("missing input format \n");
       Lerror(ERR_INCORRECT_CALL, 0);
    }
    if (strncasecmp(LSTR(*format2), "UNIX", 2) == 0) {
        L2INT(input_date);
        julian = LINT(*input_date) + JULDAYNUM(1, 1, 1970);
    } else if (strncasecmp(LSTR(*format2), "BASE", 1) == 0) {
        L2INT(input_date);
        julian = LINT(*input_date)-1721426;
    } else if (strncasecmp(LSTR(*format2), "JDN", 3) == 0) {
        L2INT(input_date);
        julian = LINT(*input_date);
    } else if (strncasecmp(LSTR(*format2), "JULIAN", 1) == 0) {
        Lsubstr(datestr, input_date, 1, 4, ' ');
        L2INT(datestr);
        julian = JULDAYNUM(0, 1, LINT(*datestr));
        Lsubstr(datestr, input_date, 5, 3, ' ');
        L2INT(datestr);
        julian = julian + LINT(*datestr);  // daysofyear = substr(idate, 5, 3)
        LZEROSTR(*datestr);
    } else if (strncasecmp(LSTR(*format2), "STANDARD", 1) == 0) {
        parseStandardDate(input_date, parm);
        julian = JULDAYNUM(parm[1], parm[2], parm[3]);
    } else checked=0;
goto  returnfromcheck;
}

