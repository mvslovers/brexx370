/*-----------------------------------------------------------------
 |  Copyright (c) 2012-, Tommy Sprinkle (tommy@tommysprinkle.com)
 |  Licensed under the NEW BSD Open Source License
  -----------------------------------------------------------------*/

#ifndef TSO_H
#define TSO_H

/* ---------------------------------------------------------- */
/* parameters for GTTERM macro                                */
/* ---------------------------------------------------------- */
typedef struct trx_gtterm_params
{
    unsigned    *primadr;
    unsigned    *altadr;
    unsigned    *attradr;
    unsigned    *termidadr;
} RX_GTTERM_PARAMS, *RX_GTTERM_PARAMS_PTR;

void tput(char * data, int length);
int  tget(char * data, int length);

int  tput_fullscr(char * data, int legnth);
int  tget_asis   (char * data, int length);

void gtterm(RX_GTTERM_PARAMS_PTR pParams);

void stfsmode(int opt);   /* 1-ON, 0-OFF */
void sttmpmd (int opt);   /* 1-ON, 0-Off */
void stlineno(int line);

int  getBufOffset(int bufAddr);
int  getBufAddr(int row, int col);
int  offToBuf(int offset);
int  rcToOff(int x, int y);
int  xlate3270(int byte);

#define cmd3270_SF                0x1D
#define cmd3270_SBA               0x11
#define cmd3270_IC                0x13
#define cmd3270_PT                0x05
#define cmd3270_RA                0x3C
#define cmd3270_EUA               0x12

#define cmd3270_SA                0x28
#define cmd3270_SA_exth           0x41
#define cmd3270_SA_color          0x42

#define attr3270_protected        0x30
#define attr3270_numeric          0x10
#define attr3270_hi               0x08

#define color3270_Default         0x00
#define color3270_Blue            0xF1
#define color3270_Red             0xF2
#define color3270_Pink            0xF3
#define color2370_Green           0xF4
#define color3270_Turquoise       0xF5
#define color3270_Yellow          0xF6
#define color3270_White           0xF7

#define highlight3270_Default     0x00
#define highlight3270_Blink       0xF1
#define highlight3270_Reverse     0xF2
#define highlight3270_Underscore  0xF4

#define AID_Enter 0x7D
#define AID_PF01  0xF1
#define AID_PF02  0xF2
#define AID_PF03  0xF3
#define AID_PF04  0xF4
#define AID_PF05  0xF5
#define AID_PF06  0xF6
#define AID_PF07  0xF7
#define AID_PF08  0xF8
#define AID_PF09  0xF9
#define AID_PF10  0x7A
#define AID_PF11  0x7B
#define AID_PF12  0x7C
#define AID_PF13  0xC1
#define AID_PF14  0xC2
#define AID_PF15  0xC3
#define AID_PF16  0xC4
#define AID_PF17  0xC5
#define AID_PF18  0xC6
#define AID_PF19  0xC7
#define AID_PF20  0xC8
#define AID_PF21  0xC9
#define AID_PF22  0x4A
#define AID_PF23  0x4B
#define AID_PF24  0x4C
#define AID_PA1   0x6C
#define AID_PA2   0x6E
#define AID_PA3   0x6B
#define AID_Clear 0x6D
#define AID_Reshow 0x6E

#endif
