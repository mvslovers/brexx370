/*
 * $Id: lerror.h,v 1.6 2008/07/15 07:40:07 bnv Exp $
 * $Log: lerror.h,v $
 * Revision 1.6  2008/07/15 07:40:07  bnv
 * MVS, CMS support
 *
 * Revision 1.5  2003/02/26 16:30:56  bnv
 * Minor changes
 *
 * Revision 1.4  2002/07/03 13:14:17  bnv
 * Added: MYSQL Database error
 *
 * Revision 1.3  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/29 14:58:00  bnv
 * Changed: Some defines
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 */

#ifndef	__ERROR_H__
#define	__ERROR_H__

#include "ldefs.h"

#define	ERR_MESSAGE		0
#define	ERR_FINALIZATION	2
#define	ERR_INITIALIZATION	3
#define	ERR_PROG_INTERRUPT	4
#define	ERR_STORAGE_EXHAUSTED	5
#define	ERR_UNMATCHED_QUOTE	6
#define	ERR_WHEN_EXCEPTED	7
#define	ERR_THEN_UNEXCEPTED	8
#define	ERR_WHEN_UNCEPTED	9
#define	ERR_UNMATCHED_END	10


#define	ERR_INVALID_CHAR	13
#define	ERR_INCOMPLETE_STRUCT	14
#define	ERR_INVALID_HEX_CONST	15
#define	ERR_UNEXISTENT_LABEL	16
#define	ERR_UNEXPECTED_PROC	17
#define	ERR_THEN_EXPECTED	18
#define	ERR_STRING_EXPECTED	19
#define	ERR_SYMBOL_EXPECTED	20
#define	ERR_EXTRAD_DATA		21
#define	ERR_INV_CHAR_STRING	22
#define	ERR_INV_DATA_STRING	23
#define	ERR_INVALID_TRACE	24
#define	ERR_INV_SUBKEYWORD	25
#define	ERR_INVALID_INTEGER	26
#define	ERR_INVALID_DO_SYNTAX	27
#define	ERR_INVALID_LEAVE	28
#define	ERR_ENVIRON_TOO_LONG	29
#define	ERR_TOO_LONG_STRING	30
#define	ERR_INVALID_START	31

#define	ERR_INVALID_RESULT	33
#define	ERR_UNLOGICAL_VALUE	34
#define	ERR_INVALID_EXPRESSION	35
#define	ERR_UNMATCHED_PARAN	36
#define	ERR_UNEXPECTED_PARAN	37
#define	ERR_INVALID_TEMPLATE	38

#define	ERR_INCORRECT_CALL	40
#define	ERR_BAD_ARITHMETIC	41
#define	ERR_ARITH_OVERFLOW	42
#define	ERR_ROUTINE_NOT_FOUND	43
#define	ERR_NO_DATA_RETURNED	44
#define	ERR_DATA_NOT_SPEC	45
#define	ERR_INV_VAR_REFERENCE	46
#define	ERR_UNEXPECTED_LABEL	47
#define	ERR_SYSTEM_FAILURE	48
#define	ERR_INTERPRETER_FAILURE	49
#define	ERR_UNRECOGNIZED_SYMBOL	50
#define	ERR_INVALID_FUNCTION	51
#define	ERR_LONGER_RESULT	52
#define	ERR_INVALID_OPTION	53
#define	ERR_INVALID_STEM	54

#define	ERR_DATABASE		55
#define	ERR_LIBRARY		56

#define	ERR_CANT_OPEN_FILE	57
#define	ERR_FILE_NOT_FOUND	58
#define	ERR_FILE_NOT_OPENED	59

#define ERR_MALLOC_FAILED   60
#define ERR_REALLOC_FAILED  61

#define ERR_ILLEGAL_DDN     62
#define ERR_COMMAND_NOT_FOUND 63

/*#define ERR_PARADOX_ERROR	23*/
/*#define ERR_FULL_CTRL_STACK	11*/
/*#define ERR_TOO_LONG_LINE	12*/
/*#define ERR_STACK_OVERFLOW	39*/

/* ------------- error text  structure ------------------ */
#define ERRNUM(a,b)	(((a)<<8) | (b))
typedef struct terror_st {
	word	errorno;
	char	*errormsg;
} ErrorMsg;

#endif
