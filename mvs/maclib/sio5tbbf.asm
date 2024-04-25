***********************************************************************
**                                                                   **
**     THESE PROGRAMS WILL BE BYPASSED DURING SIO PROCESSING         **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=BYPASS,PPREFIX=GIM
         SIO5TBL MODE=BYPASS,PPREFIX=DFH
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (QSAM REBUFFERING ONLY)            **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=A,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=B,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=C,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=D,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=E,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=F,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=G,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=H,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=I,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=J,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=K,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=L,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=M,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=N,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=O,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=P,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Q,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=R,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=S,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=T,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=U,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=V,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=W,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=X,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Y,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Z,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               SETBLK=NO,              NO REBLOCKING ALLOWED           X
               BUFNUM=(SPACE,131072),  ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (VSAM REBUFFERING ONLY)            **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=A,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=B,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=C,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=D,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=E,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=F,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=G,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=H,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=I,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=J,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=K,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=L,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=M,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=N,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=O,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=P,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Q,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=R,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=S,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=T,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=U,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=V,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=W,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=X,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Y,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=Z,               DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ,DIR),        VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,131072),  BUFSP=131072                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         END
