#include <stdarg.h>
#include <stdlib.h>
#include <bintree.h>
#include <rexx.h>
#include "lerror.h"
#include "lstring.h"

/* ============= Error messages =============== */
ErrorMsg	errortext[] = {
	{ ERRNUM(0,1), "Error <value> running <source>, line <linenumber>:" },
	{ ERRNUM(0,2), "Error <value> in interactive trace:" },
	{ ERRNUM(0,3), "Interactive trace.  \"Trace Off\" to end debug.  ENTER to continue." },
	{ ERRNUM(2,0), "Failure during finalization" },
	{ ERRNUM(2,1), "Failure during finalization: <description>" },
	{ ERRNUM(3,0), "Failure during initialization" },
	{ ERRNUM(3,1), "Failure during initialization: <description>" },
	{ ERRNUM(4,0), "Program interrupted" },
	{ ERRNUM(4,1), "Program interrupted with HALT condition: <description>" },
	{ ERRNUM(5,0), "System resources exhausted" },
	{ ERRNUM(5,1), "System resources exhausted: <description>" },
	{ ERRNUM(6,0), "Unmatched \"/*\" or quote" },
	{ ERRNUM(6,1), "Unmatched comment delimiter (\"/*\")" },
	{ ERRNUM(6,2), "Unmatched single quote (\')" },
	{ ERRNUM(6,3), "Unmatched double quote (\")" },
	{ ERRNUM(7,0), "WHEN or OTHERWISE expected" },
	{ ERRNUM(7,1), "SELECT requires WHEN; found \"<token>\"" },
	{ ERRNUM(7,2), "SELECT requires WHEN, OTHERWISE, or END; found \"<token>\"" },
	{ ERRNUM(7,3), "All WHEN expressions of SELECT are false; OTHERWISE expected" },
	{ ERRNUM(8,0), "Unexpected THEN or ELSE" },
	{ ERRNUM(8,1), "THEN has no corresponding IF or WHEN clause" },
	{ ERRNUM(8,2), "ELSE has no corresponding THEN clause" },
	{ ERRNUM(9,0), "Unexpected WHEN or OTHERWISE" },
	{ ERRNUM(9,1), "WHEN has no corresponding SELECT" },
	{ ERRNUM(9,2), "OTHERWISE has no corresponding SELECT" },
	{ ERRNUM(10,0), "Unexpected or unmatched END" },
	{ ERRNUM(10,1), "END has no corresponding DO or SELECT" },
	{ ERRNUM(10,2), "END corresponding to DO must have a symbol following that matches the control variable (or no symbol); found \"<token>\"" },
	{ ERRNUM(10,3), "END corresponding to DO must not have a symbol following it because there is no control variable; found \"<token>\"" },
	{ ERRNUM(10,4), "END corresponding to SELECT must not have a symbol following; found \"<token>\"" },
	{ ERRNUM(10,5), "END must not immediately follow THEN" },
	{ ERRNUM(10,6), "END must not immediately follow ELSE" },
	{ ERRNUM(13,0), "Invalid character in program" },
	{ ERRNUM(13,1), "Invalid character in program \"<char>\" (\'<hex-encoding>\'X)" },
	{ ERRNUM(14,0), "Incomplete DO/SELECT/IF" },
	{ ERRNUM(14,1), "DO instruction requires a matching END" },
	{ ERRNUM(14,2), "SELECT instruction requires a matching END" },
	{ ERRNUM(14,3), "THEN requires a following instruction" },
	{ ERRNUM(14,4), "ELSE requires a following instruction" },
	{ ERRNUM(15,0), "Invalid hexadecimal or binary string" },
	{ ERRNUM(15,1), "Invalid location of blank in position <position> in hexadecimal string" },
	{ ERRNUM(15,2), "Invalid location of blank in position <position> in binary string" },
	{ ERRNUM(15,3), "Only 0-9, a-f, A-F, and blank are valid in a hexadecimal string; found \"<char>\"" },
	{ ERRNUM(15,4), "Only 0, 1, and blank are valid in a binary string; found \"<char>\"" },
	{ ERRNUM(16,0), "Label not found" },
	{ ERRNUM(16,1), "Label \"<name>\" not found" },
	{ ERRNUM(16,2), "Cannot SIGNAL to label \"<name>\" because it is inside an IF, SELECT or DO group" },
	{ ERRNUM(16,3), "Cannot invoke label \"<name>\" because it is inside an IF, SELECT or DO group" },
	{ ERRNUM(17,0), "Unexpected PROCEDURE" },
	{ ERRNUM(17,1), "PROCEDURE is valid only when it is the first instruction executed after an internal CALL or function invocation" },
	{ ERRNUM(18,0), "THEN expected" },
	{ ERRNUM(18,1), "IF keyword requires matching THEN clause; found \"<token>\"" },
	{ ERRNUM(18,2), "WHEN keyword requires matching THEN clause; found \"<token>\"" },
	{ ERRNUM(19,0), "String or symbol expected" },
	{ ERRNUM(19,1), "String or symbol expected after ADDRESS keyword; found \"<token>\"" },
	{ ERRNUM(19,2), "String or symbol expected after CALL keyword; found \"<token>\"" },
	{ ERRNUM(19,3), "String or symbol expected after NAME keyword; found \"<token>\"" },
	{ ERRNUM(19,4), "String or symbol expected after SIGNAL keyword; found \"<token>\"" },
	{ ERRNUM(19,6), "String or symbol expected after TRACE keyword; found \"<token>\"" },
	{ ERRNUM(19,7), "Symbol expected in parsing pattern; found \"<token>\"" },
	{ ERRNUM(20,0), "Name expected" },
	{ ERRNUM(20,1), "Name required; found \"<token>\"" },
	{ ERRNUM(20,2), "Found \"<token>\" where only a name is valid" },
	{ ERRNUM(21,0), "Invalid data on end of clause" },
	{ ERRNUM(21,1), "The clause ended at an unexpected token; found \"<token>\"" },
	{ ERRNUM(22,0), "Invalid character string" },
	{ ERRNUM(22,1), "Invalid character string '<hex-encoding>'X" },
	{ ERRNUM(23,0), "Invalid data string" },
	{ ERRNUM(23,1), "Invalid data string '<hex-encoding>'X" },
	{ ERRNUM(24,0), "Invalid TRACE request" },
	{ ERRNUM(24,1), "TRACE request letter must be one of \"ACEFILNOR\"; found \"<value>\"" },
	{ ERRNUM(25,0), "Invalid sub-keyword found" },
	{ ERRNUM(25,1), "CALL ON must be followed by one of the keywords ERROR, HALT, NOVALUE, NOTREADY or SYNTAX; found \"<token>\"" },
	{ ERRNUM(25,2), "CALL OFF must be followed by one of the keywords ERROR, HALT, NOVALUE, NOTREADY or SYNTAX; found \"<token>\"" },
	{ ERRNUM(25,3), "SIGNAL ON must be followed by one of the keywords ERROR, HALT, NOVALUE, NOTREADY or SYNTAX; found \"<token>\"" },
	{ ERRNUM(25,4), "SIGNAL OFF must be followed by one of the keywords ERROR, HALT, NOVALUE, NOTREADY or SYNTAX; found \"<token>\"" },
	{ ERRNUM(25,5), "ADDRESS WITH must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,6), "INPUT must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,7), "OUTPUT must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,8), "APPEND must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,9), "REPLACE must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,11),"NUMERIC FORM must be followed by one of the keywords SCIENTIFIC or ENGINEERING; found \"<token>\"" },
	{ ERRNUM(25,12),"PARSE must be followed by one of the keywords UPPER, ARG, AUTHOR, EXTERNAL, LINEIN, NUMERIC, PULL, SOURCE, VALUE, VAR or VERSION; found \"<token>\"" },
	{ ERRNUM(25,13),"UPPER must be followed by one of the keywords ARG, AUTHOR, EXTERNAL, LINEIN, NUMERIC, PULL, SOURCE, VALUE, VAR or VERSION; found \"<token>\"" },
	{ ERRNUM(25,14),"ERROR must be followed by one of the keywords <keywords>; found \"<token>\"" },
	{ ERRNUM(25,15),"NUMERIC must be followed by one of the keywords DIGITS, FORM or FUZZ; found \"<token>\"" },
	{ ERRNUM(25,16),"FOREVER must be followed by one of the keywords WHILE, UNTIL or nothing; found \"<token>\"" },
	{ ERRNUM(25,17),"PROCEDURE must be followed by the keyword EXPOSE or nothing; found \"<token>\"" },
	{ ERRNUM(26,0), "Invalid whole number" },
	{ ERRNUM(26,1), "Whole numbers must fit within current DIGITS setting(<value>); found \"<value>\"" },
	{ ERRNUM(26,2), "Value of repetition count expression in DO instruction must be zero or a positive whole number; found \"<value>\"" },
	{ ERRNUM(26,3), "Value of FOR expression in DO instruction must be zero or a positive whole number; found \"<value>\"" },
	{ ERRNUM(26,4), "Positional pattern of parsing template must be a whole number; found \"<value>\"" },
	{ ERRNUM(26,5), "NUMERIC DIGITS value must be a positive whole number; found \"<value>\"" },
	{ ERRNUM(26,6), "NUMERIC FUZZ value must be zero or a positive whole number; found \"<value>\"" },
	{ ERRNUM(26,7), "Number used in TRACE setting must be a whole number; found \"<value>\"" },
	{ ERRNUM(26,8), "Operand to right of the power operator (\"**\") must be a whole number; found \"<value>\"" },
	{ ERRNUM(26,11),"Result of <value> % <value> operation would need exponential notation at current NUMERIC DIGITS <value>" },
	{ ERRNUM(26,12),"Result of % operation used for <value> // <value> operation would need exponential notation at current NUMERIC DIGITS <value>" },
	{ ERRNUM(27,0), "Invalid DO syntax" },
	{ ERRNUM(27,1), "Invalid use of keyword \"<token>\" in DO clause" },
	{ ERRNUM(28,0), "Invalid LEAVE or ITERATE" },
	{ ERRNUM(28,1), "LEAVE is valid only within a repetitive DO loop" },
	{ ERRNUM(28,2), "ITERATE is valid only within a repetitive DO loop" },
	{ ERRNUM(28,3), "Symbol following LEAVE (\"<token>\") must either match control variable of a current DO loop or be omitted" },
	{ ERRNUM(28,4), "Symbol following ITERATE (\"<token>\") must either match control variable of a current DO loop or be omitted" },
	{ ERRNUM(29,0), "Environment name too long" },
	{ ERRNUM(29,1), "Environment name exceeds #Limit_EnvironmentName 'characters; found \"<name>\"" },
	{ ERRNUM(30,0), "Name or string too long" },
	{ ERRNUM(30,1), "Name exceeds' #Limit_Name 'characters" },
	{ ERRNUM(30,2), "Literal string exceeds' #Limit_Literal 'characters" },
	{ ERRNUM(31,0), "Name starts with number or \".\"" },
	{ ERRNUM(31,1), "A value cannot be assigned to a number; found \"<token>\"" },
	{ ERRNUM(31,2), "Variable symbol must not start with a number; found \"<token>\"" },
	{ ERRNUM(31,3), "Variable symbol must not start with a \".\"; found \"<token>\"" },
	{ ERRNUM(33,0), "Invalid expression result" },
	{ ERRNUM(33,1), "Value of NUMERIC DIGITS must exceed value of NUMERIC FUZZ" },
	{ ERRNUM(33,2), "Value of NUMERIC DIGITS must not exceed LIMIT_DIGITS" },
	{ ERRNUM(33,3), "Result of expression following NUMERIC FORM must start with \"E\" or \"S\"; found \"<value>\"" },
	{ ERRNUM(34,0), "Logical value not \"0\" or \"1\"" },
	{ ERRNUM(34,1), "Value of expression following IF keyword must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(34,2), "Value of expression following WHEN keyword must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(34,3), "Value of expression following WHILE keyword must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(34,4), "Value of expression following UNTIL keyword must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(34,5), "Value of expression to left of logical operator \"<operator>\" must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(34,6), "Value of expression to right of logical operator \"<operator>\" must be exactly \"0\" or \"1\"; found \"<value>\"" },
	{ ERRNUM(35,0), "Invalid expression" },
	{ ERRNUM(35,1), "Invalid expression detected at \"<token>\"" },
	{ ERRNUM(36,0), "Unmatched \"(\" in expression" },
	{ ERRNUM(37,0), "Unexpected \",\" or \")\"" },
	{ ERRNUM(37,1), "Unexpected \",\"" },
	{ ERRNUM(37,2), "Unmatched \")\" in expression" },
	{ ERRNUM(38,0), "Invalid template or pattern" },
	{ ERRNUM(38,1), "Invalid parsing template detected at \"<token>\"" },
	{ ERRNUM(38,2), "Invalid parsing position detected at \"<token>\"" },
	{ ERRNUM(38,3), "PARSE VALUE instruction requires WITH keyword" },
	{ ERRNUM(40,0), "Incorrect call to routine" },
	{ ERRNUM(40,1), "External routine \"<name>\" failed" },
	{ ERRNUM(40,3), "Not enough arguments in invocation of <bif>; minimum expected is <argnumber>" },
	{ ERRNUM(40,4), "Too many arguments in invocation of <bif>; maximum expected is <argnumber>" },
	{ ERRNUM(40,5), "Missing argument in invocation of <bif>; argument <argnumber> is required" },
	{ ERRNUM(40,9), "argument <argnumber> exponent exceeds Exponent Digits limit; found \"<value>\"" },
	{ ERRNUM(40,11),"argument <argnumber> must be a number; found \"<value>\"" },
	{ ERRNUM(40,12),"argument <argnumber> must be a whole number; found \"<value>\"" },
	{ ERRNUM(40,13),"argument <argnumber> must be zero or positive; found \"<value>\"" },
	{ ERRNUM(40,14),"argument <argnumber> must be positive; found \"<value>\"" },
	{ ERRNUM(40,15),"argument <argnumber> must fit in <value> digits; found \"<value>\"" },
	{ ERRNUM(40,16),"argument 1 requires a whole number fitting within DIGITS(<value>); found \"<value>\"" },
	{ ERRNUM(40,17),"argument 1 must have an integer part in the range 0:90 and a decimal part no larger than .9; found \"<value>\"" },
	{ ERRNUM(40,18),"conversion must have a year in the range 0001 to 9999" },
	{ ERRNUM(40,19),"argument 2, \"<value>\", is not in the format described by argument 3, \"<value>\"" },
	{ ERRNUM(40,21),"argument <argnumber> must not be null" },
	{ ERRNUM(40,23),"argument <argnumber> must be a single character; found \"<value>\"" },
	{ ERRNUM(40,24),"argument 1 must be a binary string; found \"<value>\"" },
	{ ERRNUM(40,25),"argument 1 must be a hexadecimal string; found \"<value>\"" },
	{ ERRNUM(40,26),"argument 1 must be a valid symbol; found \"<value>\"" },
	{ ERRNUM(40,27),"argument 1 must be a valid stream name; found \"<value>\"" },
	{ ERRNUM(40,28),"argument <argnumber>, option must start with one of \"<optionslist>\"; found \"<value>\"" },
	{ ERRNUM(40,29),"conversion to format \"<value>\" is not allowed" },
	{ ERRNUM(40,31),"argument 1 (\"<value>\") must not exceed 100000" },
	{ ERRNUM(40,32),"the difference between argument 1 (\"<value>\") and argument 2 (\"<value>\") must not exceed 100000" },
	{ ERRNUM(40,33),"argument 1 (\"<value>\") must be less than or equal to argument 2 (\"<value>\")" },
	{ ERRNUM(40,34),"argument 1 (\"<value>\") must be less than or equal to the number of lines in the program (<sourceline()>)" },
	{ ERRNUM(40,35),"argument 1 cannot be expressed as a whole number; found \"<value>\"" },
	{ ERRNUM(40,36),"argument 1 must be the name of a variable in the pool; found \"<value>\"" },
	{ ERRNUM(40,37),"argument 3 must be the name of a pool; found \"<value>\"" },
	{ ERRNUM(40,38),"argument <argnumber> is not large enough to format \"<value>\"" },
	{ ERRNUM(40,39),"argument 3 is not zero or one; found \"<value>\"" },
	{ ERRNUM(40,41),"argument <argnumber> must be within the bounds of the stream; found \"<value>\"" },
	{ ERRNUM(40,42),"argument 1; cannot position on this stream; found \"<value>\"" },
	{ ERRNUM(40,45),"missing input format" },
    { ERRNUM(40,46),"invalid or missing input format \"<value>\"" },
    { ERRNUM(40,47),"invalid or missing output format \"<value>\"" },
    { ERRNUM(40,48),"invalid input date \"<value>\"" },
    { ERRNUM(40,49),"invalid month name in date \"<value>\"" },
    { ERRNUM(40,50),"invalid date/input format or invalid combination \"<value>\"" },
    { ERRNUM(40,99), "Error detected \"<value>\"" },
	{ ERRNUM(41,0), "Bad arithmetic conversion" },
	{ ERRNUM(41,1), "Non-numeric value (\"<value>\") to left of arithmetic operation \"<operator>\"" },
	{ ERRNUM(41,2), "Non-numeric value (\"<value>\") to right of arithmetic operation \"<operator>\"" },
	{ ERRNUM(41,3), "Non-numeric value (\"<value>\") used with prefix operator \"<operator>\"" },
	{ ERRNUM(41,4), "Value of TO expression in DO instruction must be numeric; found \"<value>\"" },
	{ ERRNUM(41,5), "Value of BY expression in DO instruction must be numeric; found \"<value>\"" },
	{ ERRNUM(41,6), "Value of control variable expression of DO instruction must be numeric; found \"<value>\"" },
	{ ERRNUM(41,7), "Exponent exceeds Exponent Digits limit; found \"<value>\"" },
	{ ERRNUM(42,0), "Arithmetic overflow/underflow" },
	{ ERRNUM(42,1), "Arithmetic overflow detected at \"<value> <operation> <value>\"; exponent of result requires more than #Limit_ExponentDigits 'digits" },
	{ ERRNUM(42,2), "Arithmetic underflow detected at \"<value> <operation> <value>\"; exponent of result requires more than #Limit_ExponentDigits 'digits" },
	{ ERRNUM(42,3), "Arithmetic overflow; divisor must not be zero" },
	{ ERRNUM(43,0), "Routine not found" },
	{ ERRNUM(43,1), "Could not find routine \"<name>\"" },
	{ ERRNUM(44,0), "Function did not return data" },
	{ ERRNUM(44,1), "No data returned from function \"<name>\"" },
	{ ERRNUM(45,0), "No data specified on function RETURN" },
	{ ERRNUM(45,1), "Data expected on RETURN instruction because routine \"<name>\" was called as a function" },
	{ ERRNUM(46,0), "Invalid variable reference" },
	{ ERRNUM(46,1), "Extra token (\"<token>\") found in variable reference; \")\" expected" },
	{ ERRNUM(47,0), "Unexpected label" },
	{ ERRNUM(47,1), "INTERPRET data must not contain labels; found \"<name>\"" },
	{ ERRNUM(48,0), "Failure in system service" },
	{ ERRNUM(48,1), "Failure in system service: <description>" },
	{ ERRNUM(49,0), "Interpretation Error" },
	{ ERRNUM(49,1), "Interpretation Error: <description>" },
	{ ERRNUM(50,0), "Unrecognized reserved symbol" },
	{ ERRNUM(50,1), "Unrecognized reserved symbol \"<token>\"" },
	{ ERRNUM(51,0), "Invalid function name" },
	{ ERRNUM(51,1), "Unquoted function names must not end with a period; found \"<token>\"" },
	{ ERRNUM(52,0), "Result returned by \"<name>\" is longer than #Limit_String 'characters" },
	{ ERRNUM(53,0), "Invalid option" },
	{ ERRNUM(53,1), "Variable reference expected after STREAM keyword; found \"<token>\"" },
	{ ERRNUM(53,2), "Variable reference expected after STEM keyword; found \"<token>\"" },
	{ ERRNUM(53,3), "Argument to STEM must have one period, as its last character; found \"<name>\"" },
	{ ERRNUM(54,0), "Invalid STEM value" },
	{ ERRNUM(54,1), "For this STEM APPEND, the value of \"<name>\" must be a count of lines; found: \"<value>\"" },
	{ ERRNUM(55,0), "Database Error" },
	{ ERRNUM(55,1),"Database is not openned" },
	{ ERRNUM(55,2),"Field not found" },
	{ ERRNUM(55,2),"Not valid statement" },
	{ ERRNUM(56,0),"Shared library error \"<dlopen>\"" },
	{ ERRNUM(56,1),"System error" },
	{ ERRNUM(57,0),"Cannot open file" },
	{ ERRNUM(58,0),"File not found" },
	{ ERRNUM(59,0),"File not opened" },
	{ ERRNUM(60,0),"Memory allocation failed." },
	{ ERRNUM(61,0),"Memory reallocation failed." },
	{ ERRNUM(62,0),"Illegal DD name <value> " },
	{ ERRNUM(63,0),"Missing TCPIP support in Hercules" },
	{ ERRNUM(64,0),"TCPIP subsystem not initialized" }

};

/* ------------------ Lerrortext ------------------- */
void __CDECL
Lerrortext( const PLstr to, const int errn, const int subn, va_list *ap)
{
	word	err;
	int	first, middle, last, found;
	int	i;
	char	*ch,*chstart;
	PLstr	str;


	err = ERRNUM(errn,subn);
	LZEROSTR(*to);

	/* Binary search for the instruction */
	first = found = 0;
	last  = DIMENSION(errortext)-1;
	while (first<=last)   {
		middle = (first+last)/2;
		if (err==errortext[middle].errorno) {
			found=1;
			break;
		} else
		if (err < errortext[middle].errorno)
			last = middle-1;
		else
			first = middle+1;
	}

	if (!found) return;

	/* --- found --- */
	if (ap==NULL)
		Lscpy(to, errortext[middle].errormsg);
	else {
		chstart = errortext[middle].errormsg;
		while (1) {
			ch = STRCHR(chstart,'<');
			if (ch==NULL) {
				Lcat(to,chstart);
				break;
			}
			i = (char huge *)ch - (char huge *)chstart;
			MEMCPY(LSTR(*to)+LLEN(*to), chstart, i);
			LLEN(*to) += i;

			str = va_arg(*ap,PLstr);/* read next argument	*/
			Lstrcat(to,str);	/* append it to string	*/

			chstart = ch;
			ch = STRCHR(chstart,'>');	/* find end	*/
			chstart = ch+1;
		}
	}

/*
/////////
/////////  Be sure to check all the program for the correct number of
/////////  arguments otherwise a disaster may happen...
/////////  or to use a NULL pointer to mark the end of arguments
/////////
*/

} /* Lerrortext */
