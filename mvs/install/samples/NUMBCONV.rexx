/*
 * Convert a numeric format to french number
 */
power_names. = ""
power_names.0 = "trillion"
power_names.1 = "milliard"
power_names.2 = "million"
powers.  = ""
powers.0 = 1000000000000
powers.1 = 1000000000
powers.2 = 1000000

french_onetotwenty. = ""
french_onetotwenty.0 = "z ro"
french_onetotwenty.1 = "un"
french_onetotwenty.2 = "deux"
french_onetotwenty.3 = "trois"
french_onetotwenty.4 = "quatre"
french_onetotwenty.5 = "cinq"
french_onetotwenty.6 = "six"
french_onetotwenty.7 = "sept"
french_onetotwenty.8 = "huit"
french_onetotwenty.9 = "neuf"
french_onetotwenty.10 = "dix"
french_onetotwenty.11 = "onze"
french_onetotwenty.12 = "douze"
french_onetotwenty.13 = "treize"
french_onetotwenty.14 = "quatorze"
french_onetotwenty.15 = "quinze"
french_onetotwenty.16 = "seize"
french_onetotwenty.17 = "dix-sept"
french_onetotwenty.18 = "dix-huit"
french_onetotwenty.19 = "dix-neuf"

french_teens. =  ""
french_teens.0 = "vingt"
french_teens.1 = "trente"
french_teens.2 = "quarante"
french_teens.3 = "cinquante"
french_teens.4 = "soixante"

signal on syntax
signal on error
signal on halt

nums = arg(1)
if nums = ""
 then times = 9999
 else times = 1

syntax:
error:

do times
 if times>1 then do
  call write ,"Enter number? "
  parse pull nums
 end
 if abbrev("QUIT",translate(nums),1) then leave
 do while nums <> ""
  parse var nums n nums
  say n convertNumberToFrench(n,0,0)
 end
end
halt:
exit

/* ------------- convertNumberToFrench ------------- */
/* arguments: number include_de include_s */
convertNumberToFrench: procedure expose power_names. powers.,
                       french_onetotwenty. french_teens.
 number = arg(1)
 include_de = arg(2)
 include_s = arg(3)

 numberstring = ""
 de_needed = 0
 if number > 999 * powers.0 then return ""
 if number = 0 then return french_onetotwenty.0
 if number < 0 then do
  numberstring = "moins"
  number = -number
 end

 do i=0 while  power_names.i <> ""
  nopowers = number % powers.i
  if nopowers > 0 then do
   numberstring = numberstring,
    convertNumberToFrench(nopowers,0,0) power_names.i
   if nopowers > 1 then numberstring = numberstring"s"
   numberstring = numberstring" "
   number = number - nopowers * powers.i
   de_needed = 1
  end
 end
 thousands = number % 1000
 if thousands > 0 then do
  if thousands = 1 then
   numberstring = numberstring "mille"
  else
   numberstring = numberstring,
    convertNumberToFrench(thousands, 0, 0) "mille"
  number = number - 1000 * thousands
 end
 if number > 0 then do
  hundreds = number % 100
  number = number - 100 * hundreds
  if hundreds > 0 then do
   if hundreds = 1 then
    /*numberstring = numberstring ((number = 0) ? "cent " : "cent ");*/
    numberstring = numberstring "cent"
   else do
    numberstring = numberstring convertNumberToFrench(hundreds, 0, 0)
    if include_s & number=0 then
     numberstring = numberstring "cents"
    else
     numberstring = numberstring "cent"
   end
  end
  if number>0 | hundreds=0 then
   numberstring = numberstring convertSmallNumberToFrench(number, include_s)
 end

 return space(numberstring)

/* ------------- convertSmallNumberToFrench ------------- */
/* args: numbers include_s */
convertSmallNumberToFrench: procedure expose power_names. powers.,
                            french_onetotwenty. french_teens.
 number = arg(1)
 include_s = arg(2)

 if number<20 then return french_onetotwenty.number

 if number<80 then do
  teen = (number-20) % 10
  if teen=5 then teen = 4
      number = number - 10*(teen+2)
  if number=0 then return french_teens.teen
  if number=1 | number=11 then
   return french_teens.teen || "-et-" || french_onetotwenty.number
  else
   return french_teens.teen || "-" || french_onetotwenty.number
 end
 if number=80 then return "quatre-vingts"
 number = number - 80
 return "quatre-vingt-" || french_onetotwenty.number

/*
function tidyString(string) {
  var ix, len = string.length, c, allowspace = false, allow;
  outputstring = "";
  for (ix = 0; ix < len; ix++) {
    c = string.charAt(ix);
    allow = true;
    switch (c) {
      case ' ' :
        if (allowspace) {
          allowspace = false;
          //if (ix = (len - 1)) allow = false;
        } else {
          allow = false;
        }
        break;
      default :
        allowspace = true;
        allow = true;
        break;
    }
    if (allow) outputstring += c;
  }
  return outputstring;
}
*/
