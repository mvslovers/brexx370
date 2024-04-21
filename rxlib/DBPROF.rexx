/* ---------------------------------------------------------------------
 * Standard Key/Value Profile
 * ---------------------------------------------------------------------
 */
 DBPROF:
    ddprof.DDKEY  ='KEYVALUE'        /* DD Name used for key/value DB */
    ddprof.DDREF  ='KEYREFS'         /* DD Name used for Reference    */
    ddprof.DSNKEY ='BREXX.KEYVALUE'  /* DSN used for key/value DB     */
    ddprof.DSNREF ='BREXX.KEYREFS'   /* DSN used for Reference        */
    ddprof.keylen =32                /* Plain Key length              */
    ddprof.roomlen=2                 /* Room length                   */
    ddprof.quallen=10                /* Qualifier/Project/Bucket      */
    ddprof.typelen=16                /* Type length in Reference DB   */

    ddprof.keyupper=1                /* upper case translation of the */
                                     /* key. 0: no, 1: yes            */
    ddprof.EnableDummy=1             /* allow links between records   */
                                     /* which do not exist, they will */
                                     /* DUMMY source records          */
                                     /* 0: no, 1: yes                 */
 return 0
/* ---------------------------------------------------------------------
 * KEYS Definition of Key/Value Cluster
 *      must be: ddprof.roomlen+ddprof.quallen+ddprof.keylen
 * -- here it is KEYS(44 0)
 * KEYS Definition of Reference Cluster
 *      1+ddprof.typelen+2*(KEYS of Key/Value Cluster)
 * -- here it is KEYS(105 0)
 * ---------------------------------------------------------------------
 */
