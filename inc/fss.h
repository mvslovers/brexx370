/*-----------------------------------------------------------------
 |  Copyright (c) 2012-, Tommy Sprinkle (tommy@tommysprinkle.com)
 |  Licensed under the NEW BSD Open Source License
  -----------------------------------------------------------------*/

#ifndef FSS_H
#define FSS_H

int     fssInit(void);
int     fssTerm(void);
int     fssReset(void);

int     fssFld(int row, int col, int attr, char *fldName, int len, char *text);
int     fssTxt(int row, int col, int attr, char *text);


int     fssSetField(char *fldName, char *text);
char  * fssGetField(char *fldName);
int     fssGetAID(void);
int     fssGetAlternateScreenWidth();
int     fssGetAlternateScreenHeight();
int     fssRefresh(void);
int     fssSetCursor(char *fldName);
int     fssSetAttr(char *fildName, int attr);
int     fssSetColor(char *fldName, int color);
int     fssSetXH(char *fldName, int attr);

char  * fssTrim(     char * data);
int     fssIsNumeric(char * data);
int     fssIsBlank(  char * data);
int     fssIsHex(    char * data);



#define fssPROT   0x30
#define fssNUM    0x10
#define fssHI     0x08
#define fssNON    0x0C

#define fssBLUE   0xF100
#define fssRED    0xF200
#define fssPINK   0xF300
#define fssGREEN  0xF400
#define fssTURQ   0xF500
#define fssYELLOW 0xF600
#define fssWHITE  0xF700

#define fssBLINK      0xF10000
#define fssREVERSE    0xF20000
#define fssUSCORE     0xF40000

#define fssENTER      0x7D
#define fssPFK01      0xF1
#define fssPFK02      0xF2
#define fssPFK03      0xF3
#define fssPFK04      0xF4
#define fssPFK05      0xF5
#define fssPFK06      0xF6
#define fssPFK07      0xF7
#define fssPFK08      0xF8
#define fssPFK09      0xF9
#define fssPFK10      0x7A
#define fssPFK11      0x7B
#define fssPFK12      0x7C
#define fssPFK13      0xC1
#define fssPFK14      0xC2
#define fssPFK15      0xC3
#define fssPFK16      0xC4
#define fssPFK17      0xC5
#define fssPFK18      0xC6
#define fssPFK19      0xC7
#define fssPFK20      0xC8
#define fssPFK21      0xC9
#define fssPFK22      0x4A
#define fssPFK23      0x4B
#define fssPFK24      0x4C
#define fssCLEAR      0x6D
#define fssRESHOW     0x6E

#endif
