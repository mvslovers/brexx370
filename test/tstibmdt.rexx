/* These are the testcases for the Classic Rexx 4.02 compatible bRexx/NetRexx Ibmdate() */
/* trace 'r' */
call load "ibmdate.rexx"
say 'Date single options'
say "ibmdate() -->" ibmdate()
say "ibmdate('W') -->" ibmdate('W')
say "ibmdate('S') -->" ibmdate('S')
say "ibmdate('E') -->" ibmdate('E')
say "ibmdate('J') -->" ibmdate('J')
say "ibmdate('D') -->" ibmdate('D')
say "ibmdate('C') -->" ibmdate('C')
say "ibmdate('B') -->" ibmdate('B')
say "ibmdate('M') -->" ibmdate('M')
say "ibmdate('N') -->" ibmdate('N')
say "ibmdate('O') -->" ibmdate('O')


/* say '' */
/* say 'Time (only has single option)' */
/* say "time()    -->" time() */
/* say "time('C') -->" time('C') */
/* say "time('E') -->" time('E') */
/* say "time('H') -->" time('H') */
/* say "time('L') -->" time('L') */
/* say "time('M') -->" time('M') */
/* say "time('N') -->" time('N') */
/* say "time('O') -->" time('O') */
/* say "time('R') -->" time('R') */
/* say "time('E') -->" time('E') */
/* say "time('S') -->" time('S') */

say''
say 'Date input/conversion options'
say "ibmdate('B','10 Mar 1962') --> 716308 :" ibmdate('B','10 Mar 1962')
say "ibmdate('W','10 Mar 1962','N') --> Saturday :" ibmdate('W','10 Mar 1962','N')
say "ibmdate('W','716308','B') --> Saturday :" ibmdate('W','716308','B')
say "ibmdate('S','716308','B')  --> 10 Mar 1962 :" ibmdate('S','716308','B')
say "ibmdate('c','1 Feb 2021')       ==> 7703        :" ibmdate('c','1 Feb 2021')
say "ibmdate('J','18 Jan 2021')      ==> 2021018     :" ibmdate('j','18 Jan 2021')
say "ibmdate('J','10 Mar 1962')      ==> 1962069     :" ibmdate('j','10 Mar 1962')

/* say '' */
/* say 'with separators specified' */
/* say "ibmdate('s','716308','b','/')   ==> 1962/03/10  :" ibmdate('s','716308','b','/') */
/* say "ibmdate('s','716308','b','-')   ==> 1962-03-10  :" ibmdate('s','716308','b','-') */
/* say "ibmdate('w',7688,'c')           ==> Sunday      :" ibmdate('w',7688,'c') */
/* say "ibmdate('c','1 Feb 2021')       ==> 7703        :" ibmdate('c','1 Feb 2021') */
/* say "ibmdate('J','18 Jan 2021')      ==> 2021018     :" ibmdate('j','18 Jan 2021') */
/* say "ibmdate('J','10 Mar 1962')      ==> 1962069     :" ibmdate('j','10 Mar 1962') */

