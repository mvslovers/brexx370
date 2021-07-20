/* Rexx  */
/*..+....1....+....2....+....3....+....4....+....5....+....6....+....7....+...*/
/* Date() in Rexx for BREXX and CREXX                                         */
/* Based on work from Brian Marks for the Rexx ISO/INCITS/ANSI standard       */
/* Basic time conversion algorithm by Klaus Hansjakob                         */
/* Adapted to work around the BREXX bug that invokes labels recursively       */
/* Added Data('J') because VM has Julian date that later became non-standard  */
/* Added Data('I') ISO because ooRexx has it                                  */
/*..+....1....+....2....+....3....+....4....+....5....+....6....+....7....+...*/
dummy: /* need a dummy label per just because you cannot start with procedure */

Time: procedure
  if arg()>3 then return
  numeric digits 18
  if arg(1,'E') then
    if pos(translate(left(arg(1),1)),"CEHLMNRS")=0 then return
  /* (The standard would also allow 'O' but what this code is running
  on would not.) */
  if arg(3,'E') then
    if pos(translate(left(arg(3),1)),"CHLMNS")=0 then return
  /* If the third argument is given then the second is mandatory. */
  if arg(3,'E') & arg(2,'E')=0 then return
  /* Default the first argument. */
  if arg(1,'E') then Option = translate(left(arg(1),1))
                else Option = 'N'
  /* If there is no second argument, the current time is returned. */
  if arg(2,'E') = 0 then if arg(1,'E') then return 'TIME'(arg(1))
                                       else return 'TIME'()
  /* One cannot convert to elapsed times. */
  if pos(Option, 'ERO') > 0 then return
  InValue = arg(2)
  if arg(3,'E') then InOption = arg(3)
                else InOption = 'N'
  HH = 0
  MM = 0
  SS = 0
  HourAdjust = 0
  select
    when InOption == 'C' then do
      parse var InValue HH ':' . +1 MM +2 XX
      if HH=12 then HH=0
      if XX == 'pm' then HourAdjust = 12
      end
    when InOption == 'H' then HH = InValue
    when InOption == 'L' | InOption == 'N' then
      parse var InValue HH ':' MM ':' SS
    when InOption == 'M' then MM = InValue
    otherwise SS = InValue
    end
  if datatype(HH,'W')=0 | datatype(MM,'W')=0 | datatype(SS,'N')=0 then
    return
  HH = HH + HourAdjust
  /* Convert to microseconds */
  Micro = trunc((((HH * 60) + MM) * 60 + SS) * 1000000)
  /* There is no special message for time-out-of-range; the bad-format
  message is used. */
  if Micro<0 | Micro > 24*3600*1000000 then return
  /* Reconvert to further check the original. */
  if TimeFormat(Micro,InOption) == InValue then
    return TimeFormat(Micro, Option)
  return

TimeFormat:procedure
/* Convert from microseconds to given format. */
/* The day will be irrelevant; actually it will be the first day possible. */
  x = Time2Date2(arg(1))
  parse value x with,
       Year Month Day Hour Minute Second Microsecond Base Days
  select
    when arg(2) == 'C' then
       select
         when Hour>12 then return Hour-12':'right(Minute,2,'0')'pm'
         when Hour=12 then return '12:'right(Minute,2,'0')'pm'
         when Hour>0  then return Hour':'right(Minute,2,'0')'am'
         when Hour=0  then return '12:'right(Minute,2,'0')'am'
         end
    when arg(2) == 'H' then return Hour
    when arg(2) == 'L' then
       return right(Hour,2,'0')':'right(Minute,2,'0')':'right(Second,2,'0'),
         || '.'right(Microsecond,6,'0')
    when arg(2) == 'M' then return 60*Hour+Minute
    when arg(2) == 'N' then
       return right(Hour,2,'0')':'right(Minute,2,'0')':'right(Second,2,'0')
    otherwise /* arg(2) == 'S' */
      return 3600*Hour+60*Minute+Second
    end

Time2Date:
   /* These are checks on the range of the date. */
   if arg(1) < 0 then
     return 'Bad'
   if arg(1) >= 315537897600000000 then
     return 'Bad'
   return Time2Date2(arg(1))

Time2Date2:Procedure
   /*  Convert a timestamp to a date.
   Argument is a timestamp (the number of microseconds relative to
   0001 01 01 00:00:00.000000)
   Returns a date in the form
     year month day hour minute second microsecond base days     */
   /* Argument is relative to the virtual date 0001 01 01 00:00:00.000000 */
   Time=arg(1)

   Second = Time   % 1000000    ; Microsecond = Time   // 1000000
   Minute = Second %      60    ; Second      = Second //      60
   Hour   = Minute %      60    ; Minute      = Minute //      60
   Day    = Hour   %      24    ; Hour        = Hour   //      24
   /* At this point, the days are the days since the 0001 base date. */
   BaseDays = Day
   Day = Day + 1
   /* Compute either the fitting year, or some year not too far earlier.
   Compute the number of days left on the first of January of this
   year. */
   Year   = Day % 366
   Day    = Day - (Year*365 + Year%4 - Year%100 + Year%400)
   Year   = Year + 1
   /* Now if the number of days left is larger than the number of days
   in the year we computed, increment the year, and decrement the
   number of days accordingly. */
   do while Day > (365 + Leap(Year))
     Day = Day - (365 + Leap(Year))
     Year = Year + 1
   end
   /* At this point, the days left pertain to this year. */
   YearDays = Day
   /* Now step through the months, increment the number of the month,
   and decrement the number of days accordingly (taking into
   consideration that in a leap year February has 29 days), until
   further reducing the number of days and incrementing the month
   would lead to a negative number of days */
   Days = '31 28 31 30 31 30 31 31 30 31 30 31'
   do Month = 1 to words(Days)
     ThisMonth = Word(Days, Month) + (Month = 2) * Leap(Year)
     if Day <= ThisMonth then leave
     Day = Day - ThisMonth
   end

return Year Month Day Hour Minute Second Microsecond BaseDays YearDays

Leap: procedure
   /* Return 1 if the year given as argument is a leap year, or 0
   otherwise. */
   return (arg(1)//4 = 0) & ((arg(1)//100 <> 0) | (arg(1)//400 = 0))

ibmdate: procedure
  if arg() > 5 then return
  numeric digits 18
  if arg(1,'E') then
    if pos(translate(left(arg(1),1)),"CBDEJMNOSUW")=0 then return
  if arg(3,'E') then
    if pos(translate(left(arg(3),1)),"BDENOSU")=0 then return
  /* If the third argument is given then the second is mandatory. */
  if arg(3,'E') & arg(2,'E')=0 then return
  /* Default the first argument. */
  if arg(1,'E') then Option = translate(left(arg(1),1))
                else Option = 'N'
  /* If there is no second argument, the current date is returned. */
  if arg() <= 1 then if arg(1,'E') then signal onearg
  else do /*it is the empty date argument */
   return nativedate()
  end
  if arg(3,'E') then InOption = arg(3)
  else InOption = 'N'

/* In September 97 the standardizing committee decided how DATE should
be extended to generalize the separators used. */
  if Option == 'S' then OutSeparator = ''
                   else OutSeparator = translate(Option,"xx/x //x","BDEMNOUW")
  if arg(4,'E') then do
/* The text for the following error 40.46 is '<bif> argument <argnumber>,
"<value>", is a format incompatible with separator specified in argument
<argnumber>'
*/
    if OutSeparator == 'x' then return
    OutSeparator = arg(4)
/* The text for the following error 40.45 is '<bif> argument <argnumber>
must be a single non-alphanumeric character or the null string; found <value>"'
*/
    if length(OutSeparator) > 1 | datatype(OutSeparator,'A') then return
    end
  if InOption == 'S' then InSeparator = ''
                     else InSeparator = translate(InOption,"xx/ //","BDENOU")
  if arg(5,'E') then do
    if InSeparator == 'x' then return
    InSeparator = arg(5)
    if length(InSeparator) > 1 | datatype(InSeparator,'A') then return
    end

  /* English spellings are used, even if messages not in English are
used. */
  Months = 'January February March April May June July',
           'August September October November December'
  WeekDays = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'

  Value = arg(2)
  /* First try for Year Month Day */
  Logic = 'NS'
  select
    when InOption == 'N' then do
      if InSeparator == '' then do
          if length(Value)<8 then return
          Year = right(Value,4)
          MonthIs = substr(right(Value,7),1,3)
          Day = left(Value,length(Value)-7)
          end
      else parse var Value Day (InSeparator) MonthIs (InSeparator) Year
      do Month = 1 to 12
        if left(word(Months, Month), 3) == MonthIs then leave
        end Month
      end
    when InOption == 'S' then
      if InSeparator == '' then parse var Value Year +4 Month +2 Day
      else parse var Value Year (InSeparator) Month (InSeparator) Day
    otherwise Logic = 'EOU' /* or BD */
    end
  /* Next try for year without century */
  if logic = 'EOU' then
    Select
      when InOption == 'E' then
        if InSeparator == '' then parse var Value Day +3 Month +3 YY
        else parse var Value Day (InSeparator) Month (InSeparator) YY
      when InOption == 'O' then
        if InSeparator == '' then parse var Value YY +3 Month +3 Day
        else parse var Value YY (InSeparator) Month (InSeparator) Day
      when InOption == 'U' then
        if InSeparator == '' then parse var Value Month +3 Day +3 YY
        else parse var Value Month (InSeparator) Day (InSeparator) YY
      otherwise Logic = 'BD'
      end
  if Logic = 'EOU' then do
    /* The century is assumed, on the basis of the current year. */
    if datatype(YY,'W')=0 then return
    YearNow = left('IBMDATE'('S'),4)
    Year = YY
    do while Year < YearNow-50
      Year = Year + 100
      end
  end /* Century assumption -- if Logic */

  if Logic <> 'BD' then do
    /* Convert Month & Day to Days of year. */
    if datatype(Month,'W')=0 | datatype(Day,'W')=0 | datatype(Year,'W')=0 then
       return
    Days = word('0 31 59 90 120 151 181 212 243 273 304 334',Month) + ,
    (Month>2)*Leap(Year) + Day-1
  end
  else
    if datatype(Value,'W')=0 then return
    if InOption == 'D' then do
    Year = left('IBMDATE'('S'),4)
    Days = Value - 1 /* 'D' includes current day */
  end
    if InOption = 'C' then do
      Year = left(right(nativeDate(),4),1)||'000'
      Days = Value - 1 /* 'C' includes current day */
    end
    if InOption = 'J' then do
      Year = right(nativeDate(),4)
      Days = Value - 1 /* 'C' includes current day */
    end
  /* Convert to BaseDays */
  if InOption <> 'B' then
    BaseDays = (Year-1)*365 + (Year-1)%4 - (Year-1)%100 + (Year-1)%400,
    + Days
  else Basedays = Value
  /* Convert to microseconds from 0001 */
  Micro = BaseDays * 86400 * 1000000
  /* Reconvert to check the original. (eg for Month = 99) */
  if DateFormat(Micro,InOption,InSeparator) == Value then
    return DateFormat(Micro,Option,OutSeparator)
  return

  onearg:
  /* we did not pass this yet in this path */
  Months = 'January February March April May June July',
  'August September October November December'
  WeekDays = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
  Option = arg(1)
  BaseDays = ibmdate('B',nativedate())
  Micro = BaseDays * 86400 * 1000000
  if Option == 'S' then OutSeparator = ''
  else OutSeparator = translate(Option,"xx/x //x","BDEMNOUW")
  return DateFormat(Micro,Option,OutSeparator)

DateFormat:
/* Convert from microseconds to given format and separator. */

  x = Time2Date(arg(1))
  format=translate(arg(2))
  if x='Bad' then return 'Bad'
  parse value x with,
  Year Month Day Hour Minute Second Microsecond Base Days
  select
    when format == 'B' then
      return Base
    when format = 'C' then
      do
	yy=Year
	y0=left(yy,1)||'000' /* start of century */
	yp=(yy-y0) /* preceding years */
	ly=(yp-1)%4 /* number of leap years */
	if y0//4=0 then ly=ly+1 /* if start of century way a leap year */
	dca=365*yp+ly+Days
	return dca
      end
    when format == 'D' then
      return Days
    when format == 'E' then return,
    right(Day,2,'0')(arg(3))right(Month,2,'0')(arg(3))right(Year,2,'0')
    when format == 'J' then return,
	   Year||right(Days,3,'0')
    when format == 'M' then
      return word(Months,Month)
    when format == 'N' then
      return Day left(word(Months,Month),3) right(Year,4,'0')
    when format == 'O' then return,
    right(Year,2,'0')(arg(3))right(Month,2,'0')(arg(3))right(Day,2,'0')
    when format == 'S' then return,
    right(Year,4,'0')(arg(3))right(Month,2,'0')(arg(3))right(Day,2,'0')
    when format == 'U' then return,
    right(Month,2,'0')(arg(3))right(Day,2,'0')(arg(3))right(Year,2,'0')
    when format == 'W' then return word(Weekdays,1+Base//7)
    otherwise
      return 'Unknown Date option'
  end

/* nativedate: procedure */ /* this works on brexx */
/*   "date (STACK" */
/*   parse pull outcome */
/*   parse var outcome . mon dt . . yr */
/*   return dt mon yr */

  nativedate: procedure /* this works on brexx/370 */
  dte = date('N')
  parse var dte with dt mon yr 
  return dt mon yr
  
  