say '----------------------------------------'
say 'File value.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
drop A3; A33=7; K=3; fred='K'; list.5='?'
r=r+itest("value('a'k)","\== 'A3'",1)
r=r+itest("value('a'k||k)","\== '7'",2)
r=r+itest("value('fred')","\== 'K'",3)
r=r+itest("value(fred)","\== '3'",4)
r=r+itest("value(fred,5)","\== '3'",5)
r=r+itest("value(fred)","\== '5'",6)
r=r+itest("value('LIST.'k)","\== '?'",7)
/* From: Mark Hessling */
x.a = 'asdf';x.b = 'foo';x.c = 'A';a = 'B';b = 'C';c = 'A'
xyzzy = 'foo'
r=r+itest("value('a')","\== 'B'",8)
r=r+itest("value(a)","\== 'C'",9)
r=r+itest("value(c)","\== 'B'",10)
r=r+itest("value('c')","\== 'A'",11)
r=r+itest("value('x.A')","\== 'foo'",12)
r=r+itest("value(x.B)","\== 'B'",13)
r=r+itest("value('x.B')","\== 'A'",14)
r=r+itest("value('x.'||a)","\== 'A'",15)
r=r+itest("value(value(x.b))","\== 'C'",16)
r=r+itest("value('xyzzy')","\== 'foo'",17)
r=r+itest("value('xyzzy','bar')","\== 'foo'",18)
r=r+itest("value('xyzzy')","\== 'bar'",19)
r=r+itest("value('xyzzy','bar')","\== 'bar'",20)
r=r+itest("value('xyzzy')","\== 'bar'",21)
r=r+itest("value('xyzzy','foo')","\== 'bar'",22)
r=r+itest("value('xyzzy')","\== 'foo'",23)
say 'Done value.rexx'
exit r


itest:
maxrc=0
signal on syntax name funcerr
parse arg func,tresult,tno
rc=0 ; okresult=''
if tresult='' then tresult=addresult()
parse upper var func name "(" .
s = left(name,8,' ') '- test' right(tno,3,' ')
call interpret_it
if rc<8 then s = s '.. PASS'
else if rc==8 then do
   s = s '.. *FAIL* - function' func
   if okresult='' then s = s 'expected' tresult
      else s = s 'expected' okresult
   s = s 'actual' tvalue 'HEX('|| c2x(tvalue) ||')'
end
signal off syntax
say s
maxrc=max(maxrc,rc)
return maxrc
/* interpret */
interpret_it:
  interpret 'tvalue='value(func)
  interpret 'if tvalue ' tresult 'then rc=8'
  return
/* ----- Add missing Result Parameter  -------------------------------*/
addresult:
  if substr(strip(func),1,1)\='\' then do
     okresult='==1'
     return '==0'
  end
  else do
     okresult='==0'
     return '==1'
  end
return
/* ----- Error Exit, if function call terminates ---------------------*/
funcerr:
 signal off syntax
 s = s '.. *ERROR* - function' func '-' errortext(rc)
 maxrc=max(maxrc,8)
return