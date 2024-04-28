/*
 * $Id: systemx.h,v 1.2 2001/06/25 18:52:04 bnv Exp $
 * $Log: systemx.h,v $
 * Revision 1.2  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 *
 * Function prototypes for calling external programs
 */

/* ---------------------------------------------------------- */
/* like system() function except that it returns the real     */
/* Return Code from the function                              */
/* ---------------------------------------------------------- */
extern int far systemx(const char far *cmd);

/* ----------------------------------------------BNV 1991 --- */
/* prototype to call asm int2e back door of command.com       */
/* int2e, executes a dos command without loading command.com  */
/* but uses the parent proccess command interpreter           */
/* ---------------------------------------------------------- */
extern void far int2e(char far *);
