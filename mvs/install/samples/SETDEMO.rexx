trace ?r

/* This program demonstrates how environment variables work through 4DOS5.x
   Envirnoment variables can create a great confusion so they must be used
   with care. The problem arises because every time a program has its own
   copy of environment variables from his parent....  */

address command        /* let's address all commands through a new copy
                          of command interpreter */
say getenv("PATH")     /* function "getenv" returns the variable "PATH"
                          as it appears in the copy at the header of
                          rexx interpreter.
                          it is the same from what we get from dos prompt */
"SET PATH=Hello"       /* WILL DO NOTHING!!!
                          because the command will be executed like
                              %COMSPEC% /c SET PATH=Hello
                          a new copy of command interpreter will
                          be loaded to execute the command and the path
                          will be changed in this secondary interpreter
                          and not in the master interpreter.
                        */
say getenv("PATH")      /* So it will display the same as before the SET cmd*/
"PATH"                  /* same */

/* now in 4DOS there is an option is SET command,  SET /m
   to make the change in the MASTER command interpreter */

"SET /m PATH=Hello"     /* Will be changed in the master environment
                           but not in the program environment */
/* Another way to redirect the command to master environment is
   to use:  address int2e "SET PATH=Hello" works also with COMMAND.COM
   BUT use it with care since int2e is a tricky interrupt */


say getenv("PATH")      /* since GETENV() displays the program variable
                           will display the old value not the new one "Hello" */
"PATH"                  /* will display the variable PATH that it is copied
                           from PROGRAMS variables into the secondary shell.
                           So it displays the old value not "Hello" */

address int2e "PATH"    /* if we route the command to master environment
                           through int2e which is the back door of command.com
                           (faster but undocumented from microsoft)
                           it will execute the command in the master shell
                           where the PATH is "Hello" and it will display "Hello"
                         */
                         /* After the exit of the program the variable PATH
                            is now "Hello" */
