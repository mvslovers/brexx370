         MACRO
         TLINE  &LIT
         B   X&SYSNDX
LIT&SYSNDX DC   C&LIT
X&SYSNDX DS    0H
         TPUT  LIT&SYSNDX,L'LIT&SYSNDX
         MEND
