         MACRO
&LAB1    ENTERNR &SA=SAVEAREA,&LEVEL=
         MNOTE '        SA=&SA,LEVEL=&LEVEL'
&LAB1    START
         SAVE  (14,12),,&LAB1-&LEVEL
         LR    R12,R15            HOPE HE KNOWS WHAT HE'S DOING
         USING &LAB1,R12
         ST    R13,&SA.+4         SAVE HIS SAVEAREA PTR
         LR    R11,R13            SAVE THE SAVE POINTER
         LA    R13,&SA            R13->SAVEAREA (MINE)
         ST    R13,8(,R11)        MINE IN HIS
         B     ENTEX
&SA      DS    18F
         REGEQU
ENTEX    DS    0H
         MEND
