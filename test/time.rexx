say '----------------------------------------'
say 'File time.rexx'
say 'Look for TIME OK'
/* From TRL */

rc = 0

say time()

say time('C')

say time('H')

say time('L')

say time('M')

say time('n')

say time('s')

/* There are also lots of conversions. */

/* say time('s',"16:54:22",'N') need to debug */
say ('TIME OK')
exit rc
