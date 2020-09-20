dynparm='BREXX.V2R1M0.RXLIB'
/* returns Member List as Variables */
num=PDSDIR(dynparm)
do i=1 to num
   say PDSList.Membername.i
end
/* reports Member List  */
dynparm='BREXX.V2R1M0.RXLIB'
num=PDSDIR(dynparm,'REPORT')
exit
