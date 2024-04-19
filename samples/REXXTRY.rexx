        /* Read from the keyboard and interpret REXX instructions.                  */

        PARSE ARG yourMotherShouldKnow /* any instruction entered with the command? */
        IF yourMotherShouldKnow <> "" THEN DO           /* just execute it and quit */
           INTERPRET yourMotherShouldKnow
           EXIT
           END

        Start:
        PARSE VERSION rexxinfo
        SAY "REXX interpreter running ("rexxinfo")"
        SAY "Enter any valid REXX instruction... type EXIT to quit."
        SIGNAL ON ERROR
        SIGNAL ON HALT
        /* SIGNAL ON NOVALUE */
        SIGNAL ON SYNTAX

        DO FOREVER
           SAY "Rexxtry;"
           PARSE PULL yourMotherShouldKnow
           INTERPRET yourMotherShouldKnow
           END
        Error:
           SAY "REXX:- Application returned an errorlevel" rc
           SIGNAL Start

        Syntax:
           SAY 'REXX:-'  errortext(rc) '(error' rc')'
           SIGNAL Start

        NoValue:
           SAY 'REXX:- uninitialized variable, or failure in system service'
           SIGNAL Start

        Halt:
           SAY 'REXX:- HI intercepted'
           SIGNAL Start
