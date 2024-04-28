/*
||
|| Header file for rxconio.c ...
|| Some <conio.h> functions for BREXX
|| Fully compatible with ansi.r by bnv
||
|| 13-Feb-1999 by Generoso Martello (generoso@martello.com)
||
*/

#define ANSI_GOTOXY(z,s)		gotoxy(z,s)
#define ANSI_CLEAR_SCREEN()		clrscr()
#define ANSI_COLOR(f,b)			textcolor(f) ; textbackground(b)
#define ANSI_FG_LCOLOR(f)		textcolor(f)
#define ANSI_ERASE_EOL()		clreol()
#define ANSI_MODE(m)			textmode(m)
#define ANSI_PRINTF			cprintf

#define ANSI_DEFAULT()			ANSI_PRINTF("\033[0m")
#define ANSI_CURSOR_UP(n)		ANSI_PRINTF("\033[%dA", (n))
#define ANSI_CURSOR_DOWN(n)		ANSI_PRINTF("\033[%dB", (n))
#define ANSI_CURSOR_RIGHT(n)		ANSI_PRINTF("\033[%dC", (n))
#define ANSI_CURSOR_LEFT(n)		ANSI_PRINTF("\033[%dD", (n))
#define ANSI_SAVE_CURSOR()		ANSI_PRINTF("\033[s")
#define ANSI_LOAD_CURSOR()		ANSI_PRINTF("\033[u")
#define ANSI_ATTR(m)			ANSI_PRINTF("\033[%dm", (m))

enum conio_functions {
 f_ansicls=f_lastfunc+1,
 f_ansieraseeol,
 f_ansidelline,
 f_ansiinsline,
 f_getch,
 f_kbhit,
 f_wherex,
 f_wherey,
 f_ansimode,
 f_ansiattr,
 f_setcursor,
 f_ansicolor,
 f_ansigoto,
 f_ansicursorup,
 f_ansicursordown,
 f_ansicursorright,
 f_ansicursorleft,
 f_ansisavecursor,
 f_ansiloadcursor
};
