#!/usr/local/bin/rexx
/* */
if arg(1) = "?" then do
    say "syntax: calc [<expr>]"
    say "desc:   Scientific calculator, command line or input mode"
    say "examples: sqrt(sin(0.2*pi)*pow10(5)+1)"
    say "        x = 5.1"
    say "        2*x/pi"
    say "The special variable '$' hold the result of the last expression"
    say "author: Vasilis.Vlachoudis@cern.ch"
    say "date:   Apr 1996"
    exit
end
 
call import "veclib"
 
numeric digits 15
 
trace o
signal on error
signal on syntax
signal on halt
 
C  = 299792458.0        /* m/s */
h  = 6.6260755e-34        /* J s */
pi = 3.14159265358979323846
qe = 1.6021773349e-19        /* C */
me = 0.51099906            /* MeV */
mp = 938.27231            /* MeV */
mn = 939.56563            /* MeV */
fwhm = 2.355
 
if arg() > 0 then do
    interpret "say" arg(1)
    exit
end
 
parse source os .
if os="WINCE" | os="WIN" then call WindowTitle "Calculator"
 
rad=1
_hist = 1
 
mainloop:
do forever
    pull line
        if ^rad then do
            line=changestr("SIN(",line,"SIND(")
            line=changestr("COS(",line,"COSD(")
            line=changestr("TAN(",line,"TAND(")
            line=changestr("ASIN(",line,"ASIND(")
            line=changestr("ACOS(",line,"ACOSD(")
            line=changestr("ATAN(",line,"ATAND(")
        end
    /* line = space(line,1) */
    line = space(line,1)
    if line="END" | line="QUIT" then exit
 
    if word(line,1) = "SET" then do
        parse var line . opt value
        select
            when opt = "RAD" then rad=1
            when opt = "DEG" then rad=0
            when abbrev("DIGITS", opt, 3) then numeric digits value
        end
        iterate
    end
    line = space(line)
 
    parse var line front "=" rest
    if rest <> "" then do
        if front="" then signal error
        front = strip(front)
        if words(front)=1 | pos("(",front) = 0 then do
            interpret line
            $ = value(front)
            say ">>>" front "=" $
        end; else do
            parse var front name "(" vars ")" .
            interpret name "= rest"
            say ">>>" name"("vars") = "rest
        end
    end; else do
        if line <> "" then interpret "$ =" line
        _var = "$"_hist
        call value(_var,$)
        say ">>>" _var '=' $
        _hist = _hist + 1
    end
end
exit
 
error:
    say "+++ Error in expression +++"
    signal mainloop
 
syntax:
    say "+++ Error in expression +++"
    signal mainloop
 
halt:
    say "Ending program..."
    exit
 
/* -------- solve -------- */
solve:
    parse arg _func, _low, _high, _eps
    if _eps="" then _eps=1E-10
    if _func="" | _low="" | _high="" then do
        say "solve(function,low,high[,eps])"
        return 0
    end
 
    x = _low
    interpret "_yl="_func
    _sl = sign(_yl)
    if ABS(_yl)<_eps then return _low
 
    x = _high
    interpret "_yh="_func
    _sh = sign(_yh)
    if ABS(_yh)<_eps then return _high
 
    do forever
        if _sl=_sh then do
            say  "NO SOLUTION: Both values are from the same side"
            return 0
        end
        x = (_low+_high)/2
        interpret "_ym="_func
        _sm = sign(_ym)
        if ABS(_ym)<_eps then return x
 
        if _sl=_sm then do
            _low = x; _yl = _ym
        end; else do
            _high = x; _yh = _ym
        end
    end
return
 
d2r: return arg(1)/180*PI
r2d: return arg(1)/PI*180
 
sind: return sin(d2r(arg(1)))
cosd: return cos(d2r(arg(1)))
tand: return tan(d2r(arg(1)))
 
asind: return r2d(asin(arg(1)))
acosd: return r2d(acos(arg(1)))
atand: return r2d(atan(arg(1)))
 
/* convert dd,mm,ss to decimal angle */
ang: procedure
    parse arg dd,mm,ss
    if ^datatype(dd,"N") & mm="" & ss="" then
        parse var dd dd mm ss
    if ^datatype(mm,"N") then mm=0.0
    if ^datatype(ss,"N") then ss=0.0
return dd + mm/60.0 + ss/3600.0
 
/* convert decimal angle to dd mm ss */
dms: procedure
    parse arg a
    if a<0 then do
        a=-a
        sgn="-"
    end; else
        sgn=""
    dd = trunc(a)
    a = (a - dd)*60
    mm = trunc(a)
    ss = (a - mm)*60
return sgn||dd mm ss
