/* ---------------------------------------------------------------------
 * Least Common Multiple
 *   LCM(p0,p1,...)
 * ............................... Created by PeterJ on 2. February 2022
 * ---------------------------------------------------------------------
 */
LCM: Procedure
  p0=arg(1)
  do i=2 to arg()
     px=gcd(p0,arg(i))
     if px==0 then return 0
     p0=p0%px*(arg(i)%1)
  end
return p0%1
