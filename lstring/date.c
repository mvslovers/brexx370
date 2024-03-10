#include <time.h>
#include "lerror.h"
#include "lstring.h"

/* ---------------------------------------------------------------------------------------------------------------------
 *  Date calculation and conversion between different formats
 *    Step 1 calculate given date according to its input format into a Julian Day Number(JDN)
 *    Step 2 convert date according to the output format from the Julian Day Number(JDN)
 *
 *  Julian Day Number(JDN) is the days since:
 *     Monday, January 1, 4713 BC Julian calendar
 *          which is:
 *     November 24, 4714 BC Gregorian calendar
 *
 *  Supported input formats
 *   Base          days since 01.01.0001
 *   JDN           days since Monday 24. November 4714 BC
 *   UNIX          days since 1. January 1970
 *   DEC           01-JAN-20                                    DEC format (Digital Equipment corporation)
 *   XDEC          01-JAN-2020                                  extended DEC format (Digital Equipment corporation)
 *   Julian        yyyyddd    e.g. 2018257
 *   European      dd/mm/yyyy e.g. 11/11/18
 *   xEuropean     dd/mm/yyyy e.g. 11/11/2018                   extended European (4 digits year)
 *   German        dd.mm.yyyy e.g. 20.09.2018
 *   USA           mm/dd/yyyy e.g. 12.31.18
 *   xUSA          mm/dd/yyyy e.g. 12.31.2018                   extended USA  (4 digits year)
 *   STANDARD      yyyymmdd   e.g. 20181219
 *   ORDERED       yyyy/mm/dd e.g. 2018/12/19
 *   LONG          dd month-name yyyy e.g. 12 March 2018       month is translated into month number (first 3 letters)
 *   NORMAL        dd 3-letter-month yyyy e.g. 12 Mar 2018     month is translated into month number
 *   QUALIFIED     Thursday, December 17, 2020
 *   INTERNATIONAL date format 2020-12-01
 *   TIME          date since 1.1.1970 in seconds
 *
 *  Supported output formats
 *   Base          days since 01.01.0001
 *   JDN           days since 24. November 4714 BC
 *   UNIX          days since 1. January 1970
 *   Julian        yyyyddd    e.g. 2018257
 *   Days          ddd days in this year e.g. 257
 *   Weekday       weekday of day e.g. Monday
 *   Century       dddd days in this century
 *   European      dd/mm/yy   e.g. 11/11/18
 *   XEuropea      dd/mm/yyyy e.g. 11/11/2018                  extended European (4 digits year)
 *   DEC           dd/mm/yy   e.g. 11-NOV-18                   DEC format (Digital Equipment corporation)
 *   XDEC          dd/mm/yyyy e.g. 11-NOV-2018                 extended DEC format (Digital Equipment corporation)
 *   German        dd.mm.yyyy e.g. 20.09.2018
 *   USA           mm/dd/yyyy e.g. 12/31/18
 *   xUSA          mm/dd/yyyy e.g. 12/31/2018                 extended USA (4 digits year)
 *   STANDARD      yyyymmdd        e.g. 20181219
 *   ORDERED       yyyy/mm/dd e.g. 2018/12/19
 *   LONG          dd. month-name yyyy e.g. 12 March 2018
 *   NORMAL        dd. month-name-short yyyy e.g. 12 Mar 2018
 *   QUALIFIED     Thursday, December 17, 2020
 *   INTERNATIONAL date format 2020-12-01
 *   TIME          date since 1.1.1970 in seconds
 *  --------------------------------------------------------------------------------------------------------------------
 */
static char *WeekDays[] = {
	TEXT("Sunday"), TEXT("Monday"), TEXT("Tuesday"), TEXT("Wednesday"),
	TEXT("Thursday"), TEXT("Friday"), TEXT("Saturday") };
static char *months[] = {
	TEXT("January"), TEXT("February"), TEXT("March"),
	TEXT("April"), TEXT("May"), TEXT("June"),
	TEXT("July"), TEXT("August"), TEXT("September"),
	TEXT("October"), TEXT("November"), TEXT("December") };
static char *monthsSH[] = {
    TEXT("Jan"), TEXT("Feb"), TEXT("Mar"),
    TEXT("Apr"), TEXT("May"), TEXT("Jun"),
    TEXT("Jul"), TEXT("Aug"), TEXT("Sep"),
    TEXT("Oct"), TEXT("Nov"), TEXT("Dec") };
static char *monthsSHUC[] = {
    TEXT("JAN"), TEXT("FEB"), TEXT("MAR"),
    TEXT("APR"), TEXT("MAY"), TEXT("JUN"),
    TEXT("JUL"), TEXT("AUG"), TEXT("SEP"),
    TEXT("OCT"), TEXT("NOV"), TEXT("DEC") };

/* ---------------------------------------------------------------------------------------------------------------------
 *  calculate Julian Day Number Calculation, number of days since:
 *     Monday, January 1, 4713 BC Julian calendar which is
 *     November 24, 4714 BC Gregorian calendar
 * ---------------------------------------------------------------------------------------------------------------------
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
    int i,j,wrds, parms=0;
    Lstr word;
    LINITSTR(word);
    Lscpy(&word,",:.;/-"); // temporary usage of word (to minimise allocs) to receive the TRANSLATE input table,
    Ltranslate(parm,parm,NULL,&word,' '); // clear out the typical date delimiters
    wrds=Lwords(parm);

    for (i = 1; i <= 3; ++i) {
        if (i > wrds) parmi[i] = 0;
        else {
            Lword(&word, parm, i);
            LASCIIZ(word);
            if (_Lisnum(&word) == LINTEGER_TY) parmi[i] = lLastScannedNumber;
            else {
                for (j = 0; j < 12; ++j) {
                    if (strncasecmp(months[j], LSTR(word), 3) != 0) continue;
                    parmi[i] = j + 1;
                    break;
                }
                if (j == 12) Lerror(ERR_INCORRECT_CALL, 49, parm);
            }
        }
    }
    LFREESTR(word);
    return wrds;
}
/* ------------------------------------------------------------------------------------
 * Parse a give numeric string in its words
 * ------------------------------------------------------------------------------------
 */
void parseStandardDate(PLstr parm,int parmi[3]) {
    L2INT(parm);
    parmi[3]= LINT(*parm)/10000;
    LINT(*parm)=LINT(*parm)%10000;
    parmi[2]= LINT(*parm)/100;
    parmi[1]=LINT(*parm)%100;
}
/* =====================================================================================================================
 * Ldate Main procedure
 * =====================================================================================================================
 */
void Ldate(PLstr datestr, PLstr format1, PLstr input_date, PLstr format2) {
    extern char brxoptions[16];
    int JDN, parm[4], noO, checked, wrd, todayYear;
    Lstr indate;
    time_t now;
    struct tm *tmdata;

/* ---------------------------------------------------------------------------------------------------------------------
 *  Supported input formats
 *   Base          days since 01.01.0001
 *   JDN           days since Monday 24. November 4714 BC
 *   UNIX          days since 1. January 1970
 *   DEC           01-JAN-20                                    DEC format (Digital Equipment corporation)
 *   XDEC          01-JAN-2020                                  extended DEC format (Digital Equipment corporation)
 *   Julian        yyyyddd    e.g. 2018257
 *   European      dd/mm/yyyy e.g. 11/11/18
 *   xEuropean     dd/mm/yyyy e.g. 11/11/2018                   extended European (4 digits year)
 *   German        dd.mm.yyyy e.g. 20.09.2018
 *   USA           mm/dd/yyyy e.g. 12.31.18
 *   xUSA          mm/dd/yyyy e.g. 12.31.2018                   extended USA  (4 digits year)
 *   STANDARD      yyyymmdd   e.g. 20181219
 *   ORDERED       yyyy/mm/dd e.g. 2018/12/19
 *   LONG          dd month-name yyyy e.g. 12 March 2018       month is translated into month number (first 3 letters)
 *   NORMAL        dd 3-letter-month yyyy e.g. 12 Mar 2018     month is translated into month number
 *   QUALIFIED     Thursday, December 17, 2020
 *   INTERNATIONAL date format 2020-12-01
 *   TIME          date since 1.1.1970 in seconds
 */

/* ---------------------------------------------------------------------------------------------------------------------
 *  process date according to input format
 *  Part 1 process input dates which are already numeric (JDN or BASE) the conversion into JDN can be done directly
 *         or the date field is empty, then we need no input format
 * ---------------------------------------------------------------------------------------------------------------------
 */
    LSTRALLOC(indate,42);
 // init with todays date, just in case we need it
    now = time(NULL);
    tmdata = localtime(&now);
    todayYear=tmdata->tm_year + 1900;
    if (input_date == NULL) {
        JDN = JULDAYNUM((int) tmdata->tm_mday, (int) tmdata->tm_mon + 1, todayYear);
        goto processoutput;
    } else {
        Lstrcpy(&indate,input_date);  // Save parm, to avoid overwrite of the variable which passes it
        L2STR(&indate);            // translate to string, incoming date might be an integer (JDN/BASE)
        LASCIIZ(indate);
        goto checkInputFormat;        // check and process certain input formats for input formats
        returnCheckInput:
        if (checked == 1) goto processoutput;
    }
    if (LLEN(indate) < 5) Lerror(ERR_INCORRECT_CALL, 48, input_date);
    if (format2 == NULL) Lerror(ERR_INCORRECT_CALL, 46, format2);

    if (strncasecmp(LSTR(*format2), "QUALIFIED",1)==0) {  // drop first word, day name
        wrd=Lwordindex(&indate,2);
        if (wrd>0) Lsubstr(&indate,&indate,wrd,-1,' ');
    }
    if (parseDate(&indate, parm)!=3) goto invalidinput;

/* ---------------------------------------------------------------------------------------------------------------------
 * Part 2 process input date representing a certain format
 *        We need to analyse it and convert it to days, month, year format first
 *        followed by its converions into JDN
 * ---------------------------------------------------------------------------------------------------------------------
 */
    JDN = 0;
    if (strncasecmp(LSTR(*format2), "ORDERED", 1) == 0)  ;  // no parm checking
    else if (strncasecmp(LSTR(*format2), "INT", 1) == 0) ;  // no parm checking

    else if (parm[3] < 100) { // complete 2 digit years to 20yy, if not wanted use the extended format, XUSA,XDEC,XEUR
        if (parm[3]<=todayYear%100) parm[3] = parm[3]+ 2000;
           else parm[3] = parm[3]+ 1900;
        if (strncasecmp(LSTR(*format2), "EUROPEAN", 1) == 0) JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
        else if (strncasecmp(LSTR(*format2), "DEC", 3) == 0) JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
        else if (strncasecmp(LSTR(*format2), "USA", 1) == 0) JDN = JULDAYNUM(parm[2], parm[1], parm[3]);
    }
    if (JDN > 0) goto processoutput;   // already set above!

    if (strncasecmp(LSTR(*format2), "XEUROPEAN", 2) == 0)     JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "EUROPEAN", 1) == 0) JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "NORMAL", 1) == 0)   JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "SHORT", 2) == 0)    JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "LONG", 1) == 0)     JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "DEC", 3) == 0)      JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "XDEC", 3) == 0)     JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "GERMAN", 1) == 0)   JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*format2), "USA", 1) == 0)      JDN = JULDAYNUM(parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format2), "XUSA", 2) == 0)     JDN = JULDAYNUM(parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*format2), "SORTED", 1) == 0)   JDN = JULDAYNUM(parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format2), "INT", 1) == 0)      JDN = JULDAYNUM(parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format2), "ORDERED", 1) == 0)  JDN = JULDAYNUM(parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*format2), "QUALIFIED", 1) == 0) JDN = JULDAYNUM(parm[2], parm[1], parm[3]);
    else Lerror(ERR_INCORRECT_CALL, 46, format2);

/*  --------------------------------------------------------------------------------------------------------------------
 *  Create output date according to output format
 *  Supported output formats
 *   Base          days since 01.01.0001
 *   JDN           days since 24. November 4714 BC
 *   UNIX          days since 1. January 1970
 *   Julian        yyyyddd    e.g. 2018257
 *   Days          ddd days in this year e.g. 257
 *   Weekday       weekday of day e.g. Monday
 *   Century       dddd days in this century
 *   European      dd/mm/yy   e.g. 11/11/18
 *   XEuropean     dd/mm/yyyy e.g. 11/11/2018                  extended European (4 digits year)
 *   DEC           dd/mm/yy   e.g. 11-NOV-18                   DEC format (Digital Equipment corporation)
 *   XDEC          dd/mm/yyyy e.g. 11-NOV-2018                 extended DEC format (Digital Equipment corporation)
 *   German        dd.mm.yyyy e.g. 20.09.2018
 *   USA           mm/dd/yyyy e.g. 12/31/18
 *   xUSA          mm/dd/yyyy e.g. 12/31/2018                 extended USA (4 digits year)
 *   STANDARD      yyyymmdd        e.g. 20181219
 *   ORDERED       yyyy/mm/dd e.g. 2018/12/19
 *   LONG          dd. month-name yyyy e.g. 12 March 2018
 *   NORMAL        dd. month-name-short yyyy e.g. 12 Mar 2018
 *   QUALIFIED     Thursday, December 17, 2020
 *   INTERNATIONAL date format 2020-12-01
 *   TIME          date since 1.1.1970 in seconds
 *  --------------------------------------------------------------------------------------------------------------------
 */
  processoutput:
    LFREESTR(indate);

    //* Convert the Julian day number (JDN) to day month year
    FromJulian(JDN, parm);   // ad=1 is a base date, starting 1.1.0000, ad=0 Monday, January 1, 4713 BC
    if (format1 != NULL && LLEN(*format1)>0) Lstrcpy(datestr, format1);   // use temporarily datestr PLSTR to avoid memory allocation
    else {
        if      (brxoptions[1]=='A') Lscpy(datestr, "XEUROPEAN");
        else if (brxoptions[1]=='B') Lscpy(datestr, "XGERMAN");
        else if (brxoptions[1]=='C') Lscpy(datestr, "XUSA");
        else if (brxoptions[1]=='E') Lscpy(datestr, "EUROPEAN");
        else if (brxoptions[1]=='G') Lscpy(datestr, "GERMAN");
        else if (brxoptions[1]=='U') Lscpy(datestr, "USA");
        else Lscpy(datestr, "XEUROPEAN");
    }
    noO = 1;   // preset to date is numeric
    if (strncasecmp(LSTR(*datestr), "BASE", 1) == 0) JDN = JDN + 1721426;
    else if (strncasecmp(LSTR(*datestr), "UNIX", 2) == 0) JDN = JDN - JULDAYNUM(1, 1, 1970);
    else if (strncasecmp(LSTR(*datestr), "TIME", 1) == 0) JDN = 86400*(JDN - JULDAYNUM(1, 1, 1970));
    else if (strncasecmp(LSTR(*datestr), "CENTURY", 1) == 0) JDN = JDN + 1 - JULDAYNUM(1, 1, parm[3] / 100 * 100);
    else if (strncasecmp(LSTR(*datestr), "DEC", 3) == 0) noO = 0; // nop, to avoid conflict with DAYS
    else if (strncasecmp(LSTR(*datestr), "DAYS", 1) == 0) JDN = JDN + 1 - JULDAYNUM(1, 1, parm[3]);
    else if (strncasecmp(LSTR(*datestr), "JDN", 3) == 0);   // noO already sset
    else noO = 0;

    if (noO == 1) {
        Licpy(datestr, JDN);
        return;
    }
//* Translate into appropriate date according to out format
    if (strncasecmp(LSTR(*datestr), "XEUROPEAN", 2) == 0)
        sprintf((char *) LSTR(*datestr), "%02d/%02d/%04d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "EUROPEAN", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[1], parm[2], parm[3] % 100);
    else if (strncasecmp(LSTR(*datestr), "XDEC", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d-%02s-%04d", parm[1], monthsSHUC[parm[2] - 1], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "DEC", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d-%02s-%02d", parm[1], monthsSHUC[parm[2] - 1], parm[3] % 100);
      else if (strncasecmp(LSTR(*datestr), "XGERMAN", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d.%02d.%04d", parm[1], parm[2], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "GERMAN", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d.%02d.%04d", parm[1], parm[2], parm[3] %100);
    else if (strncasecmp(LSTR(*datestr), "USA", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3] % 100);
    else if (strncasecmp(LSTR(*datestr), "XUSA", 3) == 0)
        sprintf((char *) LSTR(*datestr), "%02d/%02d/%02d", parm[2], parm[1], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "ORDERED", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%04d/%02d/%02d", parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*datestr), "LONG", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%02d %s %04d", parm[1], months[parm[2] - 1], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "QUALIFIED", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%s, %s %02d, %04d", WeekDays[(JDN + 1) % 7],months[parm[2] - 1], parm[1],parm[3]);
    else if (strncasecmp(LSTR(*datestr), "SHORT", 2) == 0)
        sprintf((char *) LSTR(*datestr), "%02d %s %04d", parm[1], monthsSH[parm[2] - 1], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "STANDARD", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%04d%02d%02d", parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*datestr), "MONTH", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%s",months[parm[2]-1]);
    else if (strncasecmp(LSTR(*datestr), "INT", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%04d-%02d-%02d", parm[3], parm[2], parm[1]);
    else if (strncasecmp(LSTR(*datestr), "NORMAL", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%02d %s %04d", parm[1], monthsSH[parm[2] - 1], parm[3]);
    else if (strncasecmp(LSTR(*datestr), "WEEK", 1) == 0) STRCPY((char *) LSTR(*datestr), WeekDays[(JDN + 1) % 7]);
    else if (strncasecmp(LSTR(*datestr), "JULIAN", 1) == 0)
        sprintf((char *) LSTR(*datestr), "%04d%03d", parm[3], JDN + 1 - JULDAYNUM(1, 1, parm[3]));
    else if (strncasecmp(LSTR(*datestr), "YEAR", 2) == 0) sprintf((char *) LSTR(*datestr), "%04d", parm[3]);
    else   Lerror(ERR_INCORRECT_CALL, 47, LSTR(*datestr)); // invalid output format

    LLEN(*datestr) = STRLEN((char *)LSTR(*datestr));
return;
/* ---------------------------------------------------------------------------------------------------------------------
 * Here are some sub function to make it modular and better readable
 * ---------------------------------------------------------------------------------------------------------------------
 */
checkInputFormat:
    checked=1;
    if (format2== NULL) Lerror(ERR_INCORRECT_CALL, 45);

    if (strncasecmp(LSTR(*format2), "UNIX", 2) == 0) {
        if (_Lisnum(&indate) != LINTEGER_TY) goto noInteger;
        L2INT(&indate);
        JDN = LINT(indate) + JULDAYNUM(1, 1, 1970);
    } else if (strncasecmp(LSTR(*format2), "BASE", 1) == 0) {
        if (_Lisnum(&indate) != LINTEGER_TY) goto noInteger;
        L2INT(&indate);
        JDN = LINT(indate) - 1721426;
    } else if (strncasecmp(LSTR(*format2), "JDN", 3) == 0) {
        if (_Lisnum(&indate) != LINTEGER_TY) goto noInteger;
        L2INT(&indate);
        JDN = LINT(indate);
    } else if (strncasecmp(LSTR(*format2), "JULIAN", 1) == 0) {
        Lsubstr(datestr, &indate, 1, 4, ' ');
        if (_Lisnum(datestr) != LINTEGER_TY) goto noInteger;
        L2INT(datestr);
        JDN = JULDAYNUM(0, 1, LINT(*datestr));
        Lsubstr(datestr, &indate, 5, 3, ' ');
        if (_Lisnum(datestr) != LINTEGER_TY) goto noInteger;
        L2INT(datestr);
        JDN = JDN + LINT(*datestr);  // daysofyear = substr(idate, 5, 3)
        LZEROSTR(*datestr);
    } else if (strncasecmp(LSTR(*format2), "SHORT", 2) == 0) checked=0;
      else if (strncasecmp(LSTR(*format2), "STANDARD", 1) == 0) {
        parseStandardDate(&indate, parm);
        JDN = JULDAYNUM(parm[1], parm[2], parm[3]);
    } else if (strncasecmp(LSTR(*format2), "TIME", 1) == 0) {
        if (_Lisnum(&indate) != LINTEGER_TY) goto noInteger;
        L2INT(&indate);
        JDN = LINT(indate)/86400;
        JDN = JDN+JULDAYNUM(1, 1, 1970);
    } else checked=0;
goto returnCheckInput;
noInteger:
invalidinput:
    LFREESTR(indate);
    Lcat(input_date,"/");
    Lstrcat(input_date,format2);
    Lerror(ERR_INCORRECT_CALL, 50, input_date);
}
