/*----------------------------------------------------------*/
/* Mike Cowlishaw, December 1979 - January 1985             */
/*----------------------------------------------------------*/
/* QT. This program displays the time in natural English.   */
/* Two argument strings may be supplied. If "?" is given    */
/* as the first argument then the program displays a        */
/* description of itself.  If a second argument is supplied */
/* it is used as a test value to check the operation of the */
/* program.  This second value must be a time in the format */
/* HH:MM:SS, and does not have its syntax checked.          */
/*----------------------------------------------------------*/

/*------------ First process the argument strings ----------*/
parse arg parm .        /* get the argument strings */
select
  when parm="?" then call tell        /* say what we do   */
  when parm=""  then nop    /* OK (no first argument)   */
/*
  otherwise
    say 'The only valid parameter to QT is "?". The argument'
    say 'that you supplied ("'parm'") has been ignored.'
    call tell    /* usually helpful to describe the program  */
*/
  end

testtime = parm
if testtime='' then now=time()    /* default - use time now   */
               else now=testtime /* caller gave test value  */


/*------------ Now start processing in earnest -------------*/
/* Nearness phrases - using a compound variable as example  */
near.0=''                    /* exact    */
near.1=' just gone';  near.2=' just after'    /* after    */
near.3=' nearly';     near.4=' almost'        /* before   */

/* Extract the hours, minutes, and seconds from the time.   */
parse var now hour':'min':'sec

if sec>29 then min=min+1        /* round up minutes */
mod=trunc(min//5) /* where we are in 5 minute bracket */
out="It's"near.mod    /* start building the result        */
if min>32 then hour=hour+1    /* we are T0 the hour       */
min=min+2     /* shift minutes to straddle a 5-minute point */

/* Now special-case the result fro Noon and Midnight hours  */
if hour//12=0 & min//60<=4 then do
  if hour=12 then say out 'Noon.'
             else say out 'Midnight.'
                      /* we are finished here     */
  exit
  end

min=min-(min//5)        /* find nearest 5 mins      */
if hour>12
  then hour=hour-12             /* get rid of 24-hour clock */
  else
    if hour=0 then hour=12      /* and allow for midnight   */

/* Determine the phrase to use for each 5-minute segment    */
select
  when min= 0 then nop        /* add "o'clock" later      */
  when min=60 then min=0            /* ditto    */
  when min= 5 then out=out 'five past'
  when min=10 then out=out 'ten past'
  when min=15 then out=out 'a quarter past'
  when min=20 then out=out 'twenty past'
  when min=25 then out=out 'twenty-five past'
  when min=30 then out=out 'half past'
  when min=35 then out=out 'twenty-five to'
  when min=40 then out=out 'twenty to'
  when min=45 then out=out 'a quarter to'
  when min=50 then out=out 'ten to'
  when min=55 then out=out 'five to'
  end

numbers='one two three four five six',    /* (continuation)   */
  'seven eight nine ten eleven twelve'
out=out word(numbers,hour)    /* add the hour number      */
if min=0 then out=out "o'clock"    /* .. and o'clock if exact  */

say out'.'            /* display the final result */
exit

/*----------------------------------------------------------*/
/* Subroutine that describes the purpose of the program     */
/*----------------------------------------------------------*/
Tell:
  say 'QT will display the current time in natural English.'
  say 'Call without any arguments to display the time, or with'
  say '"?" to display this information. A second argument (in'
  say 'the format "HH:MM:SS") will be used as a test value.'
  say 'British English idioms are used in this program.'
  say /* blank line - we are about to continue and show time*/
  return
