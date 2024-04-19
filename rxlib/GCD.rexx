/* ---------------------------------------------------------------------
 * Greatest Common Divisor
 *   GCD(p0,p1,...)
 * ............................... Created by PeterJ on 2. February 2022
 * ---------------------------------------------------------------------
 */
GCD: Procedure
  p0=arg(1)%1
  p1=arg(2)%1
  argn=arg()
  if p0 == 0 then return abs(p1)
  if p1 == 0 then return abs(p0)
  do while p1 \= 0
     px = p0//p1%1
     p0 = p1
     p1 = px
  end
  p0=p0%1
  do i=3 to argn
     p0=gcd(p0,arg(i))
     if p0==0 then leave
  end
return abs(p0)
