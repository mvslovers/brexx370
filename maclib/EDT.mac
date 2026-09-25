*
* COMMON NAME   -   ELIGIBLE DEVICE TABLE
* MACRO         -   EDT
* DSECT NAMES   -   EDTHEAD,LOOKSEC,GENSEC,GPTRSEC,GRPSEC
* CREATED BY    -   SYSGEN
* POINTED TO BY -   JESCT
* SERIALIZATION -   NONE
* FUNCTION      -   ASSOCIATE DEVICES WITH UNIT NAMES
*
EDT      DSECT                         ELIGIBLE DEVICE TABLE
EDTHEAD  EQU   *                       EDT HEADER
LOOKPTR  DS    A                       ->LOOKUP SECTION
         ORG   EDT
LOOKSEC  EQU   *                       LOOKUP SECTION
LOOK#ENT DS    F                       # ENTRIES
LOOKLENT DS    F                       LENGTH OF AN ENTRY
LOOKUNIT DS    CL8                     UNIT NAME
LOOKVAL  DS    F                       LOOKUP VALUE
LOOKMPTR DS    A                       ->GROUP MASK ENTRY
LOOK#GEN DS    F                       # GENERICS
LOOKGPTR DS    A                       ->GENERIC SECTION
         ORG   EDT
GENSEC   EQU   *                       GENERIC SECTION
GENDEV   DS    XL4                     GENERIC DEVICE TYPE
GEN#GRP  DS    F                       # GROUPS
GENGPTR  DS    A                       ->FIRST GROUP POINTER
         ORG   EDT
GPTRSEC  EQU   *                       GROUP POINTER TABLE
GPTRGRP  DS    A                       ->FIRST GROUP ENTRY
         ORG   EDT
GRPSEC   EQU   *                       GROUP SECTION ENTRY
GRPID    DS    F                       GROUP ID
GRP#UCB  DS    F                       # UCBS
GRPOUCB  DS    A                       ->FIRST UCB ENTRY
