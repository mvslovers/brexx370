         MACRO
&N       K     ,                       IDENTICAL TO THE ERASE MACRO.
&N       LA    0,9                     LOAD LENGTH.
         LA    1,=X'F11140403C40400013'
         ICM   1,8,=X'03'              SET FULLSCR OPTION.
         SVC   93                      INVOKE TPUT.
         MEND
