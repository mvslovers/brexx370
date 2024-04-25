*          DATA SET EXITDEF    AT LEVEL 001 AS OF 06/13/85
*          DATA SET EXITDEF    AT LEVEL 002 AS OF 03/03/83              00001
         MACRO                                                          00002
&LABEL   EXITDEF &FUNC,&NAME=,&TYPE=,&EVENTS=                           00003
.*                                                                      00004
.*-------------------------------------------------------------------   00005
.*   EXIT DEFINITION FUNCTION:                                          00006
.*                                                                      00007
.*   AN EXIT IS DEFINED TO THE LCS EXIT INTERFACE IN THE USER PROFILE.  00008
.*                                                                      00009
.*   EACH EXITDEF MACRO GENERATES INFORMATION FOR AN ENTRY IN THE       00010
.*   EXIT-EVENT TABLE.  THE ORDER OF THE EXITDEF MACROS DICTATES        00011
.*   THE SEQUENCE IN WHICH A SET OF EXITS IS INVOKED, WHEN AN EVENT     00012
.*   TRIGGERS MORE THAN ONE EXIT ROUTINE.                               00013
.*                                                                      00014
.*   LIMITATIONS:                                                       00015
.*     THIS MACRO PLACES A LIMIT OF 4095 EXIT NAMES AND EVENT NAMES.    00016
.*     BECAUSE IT USES SUBSCRIPTED GLOBALS TO KEEP TRACK OF THEM.       00017
.*     4095 IS THE MAXIMUM SUBSCRIPT CURRENTLY ALLOWED IN DOS.          00018
.*                                                                      00019
.*   PARAMETERS:                                                        00020
.*                                                                      00021
.*   FUNCTION         : OPTIONAL.                                       00022
.*                    : ONLY 2 SPECIAL CASES HAVE FUNCTIONS.            00023
.*      BEGIN         : BEGIN SIGNALS THE BEGINNING OF THE EXITDEF      00024
.*                    :       MACROS.                                   00025
.*      END           : END SIGNALS THE END OF THE EXITDEF MACROS.      00026
.*                    : THE FIRST EXITDEF MACRO MUST BE A BEGIN         00027
.*                    :       FUNCTION.                                 00028
.*                    : THE LAST EXITDEF MACRO MUST BE AN END           00029
.*                    :       FUNCTION.                                 00030
.*                    : THERE ARE NO OTHER VALID PARAMETERS ON A        00031
.*                    : EXITDEF MACRO WITH A FUNCTION.                  00032
.*                                                                      00033
.*   NAME=SYMBOL      : REQUIRED.                                       00034
.*                    : THE NAME OF THIS EXIT.                          00035
.*                                                                      00036
.*   TYPE=SYMBOL      : OPTIONAL.                                       00037
.*                    : THE TYPE OF EXIT.  EXIT TYPES ARE USER DEFINED. 00038
.*                                                                      00039
.*   EVENTS=(A,...)   : REQUIRED.                                       00040
.*                    : A LIST OF ALL EVENTS AT WHICH THIS EXIT IS TO   00041
.*                    : GET CONTROL.                                    00042
.*                    : A,... ARE EVENT-IDS.                            00043
.*                                                                      00044
.* AUTHOR:  KEITH STIDLEY                                               00045
.*                                                                      00046
.*-------------------------------------------------------------------   00047
         GBLA  &GEXDCTR        NUMBER OF EXITDEFS                       00048
         GBLC  &GEXDEF         BEGIN/END. SIGNALS EXITDEFS IN PROGESS   00049
         GBLC  &GEXITID(256)   EXITIDS DEFINED BY PREVIOUS EXITDEFS     00050
.*                                                                      00051
         LCLA  &GEXNDX         INDEX FOR SEARCH OF EXITID GLOBALS       00052
         LCLA  &GEVNDX         INDEX FOR EVENTS ON THIS MACRO           00053
         LCLA  &GXEVNDX        INDEX FOR SEARCH OF EVENTIDS IN &GXEVID  00054
         LCLC  &GXEVID(256)    EVENTIDS FOR DUPLICATE CHECK             00055
         LCLC  &GEXTYPE        EXIT TYPE                                00056
.*                                                                      00057
.*                                                                      00058
&GEXDCTR SETA  &GEXDCTR+1      INCREMENT COUNT OF EXITDEFS              00059
&GEXTYPE SETC  '&TYPE'         SAVE EXIT TYPE                           00060
.*                                                                      00061
.*                                                                      00062
         AIF   ('&FUNC' EQ '').NOFUNC                                   00063
.*                                                                      00064
.*                                                                      00065
         AIF   (N'&SYSLIST NE 1).INVPARM                                00066
         AIF   ('&EVENTS' NE '').INVPARM                                00067
         AIF   ('&NAME' NE '').INVPARM                                  00068
         AIF   ('&TYPE' NE '').INVPARM                                  00069
.*                                                                      00070
.*                                                                      00071
         AIF   ('&FUNC' EQ 'BEGIN').BEGIN                               00072
         AIF   ('&FUNC' EQ 'END').END                                   00073
         MNOTE 12,'INVALID FUNCTION ON EXITDEF MACRO'                   00074
         MEXIT                                                          00075
.*                                                                      00076
.*                                                                      00077
.INVPARM ANOP                                                           00078
         MNOTE 12,'INVALID SYNTAX ON EXITDEF MACRO'                     00079
         MEXIT                                                          00080
.*                                                                      00081
.************************************                                   00082
.*       BEGIN FUNCTION             *                                   00083
.************************************                                   00084
.*                                                                      00085
.BEGIN   ANOP                                                           00086
         AIF   ('&GEXDEF' EQ '').BEGIN2                                 00087
         MNOTE 12,'THERE CAN BE NO EXITDEFS BEFORE EXITDEF BEGIN'       00088
         MEXIT                                                          00089
.*                                                                      00090
.*                                                                      00091
.BEGIN2  ANOP                                                           00092
&GEXDEF SETC   'BEGIN'                                                  00093
.*                                                                      00094
.*                                                                      00095
&LABEL   DS    0A                          LABEL FOR EXITDEFS           00096
GEMEXBEG DC    A(GEMEX1ST)                 BEGINNING OF EXITDEFS        00097
         DC    A(GEMEXEND)                 END OF EXITDEFS              00098
GEMEX1ST DS    0C                          1ST DATADEF                  00099
         AGO   .DONE                                                    00100
.*                                                                      00101
.************************************                                   00102
*        CSECT                                                          001024
*        DC    CL21'001EXITDEF   06/13/85'                              001025
.*       END FUNCTION               *                                   00103
.************************************                                   00104
.*                                                                      00105
.END     ANOP                                                           00106
         AIF   ('&GEXDEF' EQ 'BEGIN').END2                              00107
         MNOTE 12,'EXITDEF END MUST BE PRECEDED BY EXITDEF BEGIN'       00108
         MEXIT                                                          00109
.END2    ANOP                                                           00110
&GEXDEF SETC   'END'                                                    00111
GEMEXEND DS    0H                          END OF EXIT DEFS             00112
         AGO   .DONE                                                    00113
.*                                                                      00114
.*********************************************************              00115
.*       NO FUNCTION, I.E., EXITDEF DESCRIBING AN EXIT   *              00116
.*********************************************************              00117
.*                                                                      00118
.NOFUNC  ANOP                                                           00119
         AIF   ('&GEXDEF' EQ 'BEGIN').NOFUNC1                           00120
         MNOTE 12,'ALL EXITDEFS MUST BE BETWEEN EXITDEF BEGIN AND END'  00121
         MEXIT                                                          00122
.*                                                                      00123
.*                                                                      00124
.NOFUNC1 ANOP                                                           00125
         AIF   ('&NAME' NE '').NOFUNC2                                  00126
         MNOTE 12,'NAME IS A REQUIRED PARAMETER ON EXITDEF'             00127
         MEXIT                                                          00128
.*                                                                      00129
.*                                                                      00130
.NOFUNC2 ANOP                                                           00131
         AIF   ('&EVENTS' NE '').NOFUNC3                                00132
         MNOTE 12,'EVENTS IS A REQUIRED PARAMETER ON EXITDEF'           00133
         MEXIT                                                          00134
.*                                                                      00135
.*                                                                      00136
.NOFUNC3 ANOP                                                           00137
         AIF   ('&GEXTYPE' NE '').NOFUNC4                               00138
&GEXTYPE   SETC  ' '                                                    00139
.*                                                                      00140
.*                                                                      00141
.NOFUNC4 ANOP                                                           00142
         AIF   (K'&NAME LE 8).NOFUNC5                                   00143
         MNOTE 12,'EXIT NAMES ARE 1 - 8 CHARACTERS'                     00144
         MEXIT                                                          00145
.NOFUNC5 ANOP                                                           00146
         AIF   (K'&TYPE LE 8).LOOP1                                     00147
         MNOTE 12,'EXIT TYPES ARE 1 - 8 CHARACTERS'                     00148
         MEXIT                                                          00149
.*                                                                      00150
.******************************************************************     00151
.* THIS LOOP CHECKS FOR DUPLICATE EXITDEFS                        *     00152
.* ALL VALID EXITIDS IN EXITDEFS ARE SAVED AS GLOBALS.            *     00153
.* IF A MATCH OCCURS WHEN CHECKING THE GLOBALS IT IS A DUPLICATE. *     00154
.******************************************************************     00155
.*                                                                      00156
.LOOP1   ANOP                                                           00157
&GEXNDX SETA   &GEXNDX+1                                                00158
         AIF   (&GEXNDX GE &GEXDCTR).ENDLP1                             00159
         AIF   ('&NAME' NE '&GEXITID(&GEXNDX)').LOOP1                   00160
         MNOTE 12,'DUPLICATE EXIT NAME ON EXITDEF MACRO'                00161
         MEXIT                                                          00162
.ENDLP1  ANOP                                                           00163
.*                                                                      00164
.**********************************************************             00165
.*       VERIFY EACH EVENT ON THE MACRO AND GENERATE DC'S *             00166
.**********************************************************             00167
.*                                                                      00168
.LOOP2   ANOP                                                           00169
&GEVNDX  SETA  &GEVNDX+1                                                00170
         AIF   (&GEVNDX GT N'&EVENTS).DONE                              00171
         AIF   (K'&EVENTS(&GEVNDX) EQ 0).EVNTNUL                        00172
         AIF   (K'&EVENTS(&GEVNDX) GT 8).EVNTBAD                        00173
         AGO   .EVNTOK                                                  00174
.EVNTNUL ANOP                                                           00175
         MNOTE 12,'NULL EVENT NAMES NOT VALID, MUST BE 1-8 CHARACTERS'  00176
         MEXIT                                                          00177
.EVNTBAD ANOP                                                           00178
         MNOTE 12,'EVENT NAMES ARE 1 - 8 CHARACTERS'                    00179
         MEXIT                                                          00180
.*                                                                      00181
.EVNTOK  ANOP                                                           00182
.*                                                                      00183
.*                                                                      00184
&GXEVNDX SETA  0                                                        00185
.*                                                                      00186
.*****************************************************************      00187
.*       VERIFY THAT THIS EVENT IS NOT ON THIS EXITDEF ALREADY   *      00188
.*       THIS IS DONE BY CHECKING LOCALS SAVED FOR ALL PREVIOUS  *      00189
.*       EVENTS ON THIS MACRO                                    *      00190
.*****************************************************************      00191
.*                                                                      00192
.LOOP3   ANOP                                                           00193
&GXEVNDX SETA  &GXEVNDX+1                                               00194
         AIF   (&GXEVNDX GE &GEVNDX).ENDLP3                             00195
         AIF   ('&EVENTS(&GEVNDX)' NE '&GXEVID(&GXEVNDX)').LOOP3        00196
         MNOTE 12,'DUPLICATE EVENT NAME ON EXITDEF'                     00197
         MEXIT                                                          00198
.ENDLP3  ANOP                                                           00199
.*                                                                      00200
.**************************************************                     00201
.* THIS IS FOR THE SPECIAL CASE OF EVENTS=()      *                     00202
.**************************************************                     00203
.*                                                                      00204
         AIF   ('&EVENTS(&GEVNDX)'(1,1) NE '(').EVGO                    00205
         MNOTE 12,'NULL EVENT NAMES NOT VALID, MUST BE 1-8 CHARACTERS'  00206
         MEXIT                                                          00207
.EVGO    ANOP                                                           00208
.*                                                                      00209
.***************************************************                    00210
.*       SAVE EVENTID IN LOCAL TO BE ABLE TO MAKE  *                    00211
.*       SURE IT IS NOT ON THIS MACRO AGAIN.       *                    00212
.***************************************************                    00213
.*                                                                      00214
&GXEVID(&GXEVNDX) SETC '&EVENTS(&GEVNDX)'                               00215
.*                                                                      00216
.*                                                                      00217
&LABEL   DC    CL8'&NAME'                EXIT NAME                      00218
         DC    CL8'&GEXTYPE'             EXITTYPE                       00219
         DC    CL8'&EVENTS(&GEVNDX)'     EVENT NAME                     00220
         AGO   .LOOP2                                                   00221
.*                                                                      00222
.DONE    ANOP                                                           00223
.*                                                                      00224
.***********************************                                    00225
.*       SAVE EXITID IN GLOBAL     *                                    00226
.***********************************                                    00227
.*                                                                      00228
&GEXITID(&GEXDCTR) SETC '&NAME'                                         00229
.*                                                                      00230
         MEND                                                           00231
