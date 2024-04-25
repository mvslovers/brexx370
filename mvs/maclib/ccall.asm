         MACRO
&L1      CCALL &ENTRY
         AIF   ('&SYSECT' EQ 'C$START').ENTRY
         DC    V(&ENTRY)
         MEXIT
.ENTRY   ANOP
&ENTRY   B     COMMON-*(15)
         ENTRY &ENTRY
         SPACE
         MEND
