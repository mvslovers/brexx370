say copies('-',60)
say "Display Directory of  SYS2.PROCLIB"
say copies('-',60)
/* The directory is provided in the stem variable DIRENTRY.
   DIRENTRY.0  contains the number of directory members
   DIRENTRY.n.CDATE creation date of the member, e.g. => "19-04-18"
   DIRENTRY.n .INIT"  initial size of member
   DIRENTRY.n.MOD" mod level
   DIRENTRY.n.NAME member name
   DIRENTRY.n.SIZE" current size of member
   DIRENTRY.n.TTR TTR of member
   DIRENTRY.n.UDATE last update date, e.g. " 20-06-09"
   DIRENTRY.n.UID last updated by user- id
   DIRENTRY.n.UTIME" last updated time
   DIRENTRY.n.CDATE creation date
*/
call DIR("'sys2.proclib'")
do i=1 to direntry.0
   say left(direntry.i.name,9)Direntry.i.ttr
end
