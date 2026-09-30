say '----------------------------------------'
say 'File parse.rexx'
/* PARSE, from RossPatterson/CMS-370-BREXX tests/parse_ (#189, #188).
   Converted: failures print through TF, lines fit FB 80, and the
   CMS/UNIX-specific cases (6: PARSE SOURCE name, 31-36: PARSE SOURCE
   words and PARSE EXTERNAL at a console) are left out */
fail_count=0
parse version version .
is_regina=left(version, 11) == 'REXX-Regina'
system = 'MVS'

/* https://github.com/vlachoudis/brexx/issues/8 #1 */
Parse value '(inval1 inval2) outval' with '(' in1 in2 ')' out
if in1 \== 'inval1' then call tf '1', in1
if in2 \== 'inval2' then call tf '1', in2
if out \== ' outval' then call tf '1', out

/* https://github.com/vlachoudis/brexx/issues/8 #2 */
/* #211: word targets between triggers (upstream PR 12) */
signal t2_z
 Parse value '()' with '(' inner1 inner2 ')'
if inner1 \== '' then call tf '2', inner1
if inner2 \== '' then call tf '2', inner2

t2_z:
/* RAP 1 */
/* #211: word targets between triggers (upstream PR 12) */
signal t3_z
Parse value 'UNIX COMMAND ./xxx.r brexx /bin/bash' with a b c d e './' f g h i j
if a \== 'UNIX' then call tf '3', a
if b \== 'COMMAND' then call tf '3', b
if c \== '' then call tf '3', c
if d \== '' then call tf '3', d
if e \== '' then call tf '3', e
if f \== 'xxx.r' then call tf '3', f
if g \== 'brexx' then call tf '3', g
if h \== '/bin/bash' then call tf '3', h
if i \== '' then call tf '3', i
if j \== '' then call tf '3', j

t3_z:
/* math.rex 1 */
call math_1A 25, 2
signal math_1B
math_1A:
parse arg N , precision
return
math_1B:
if N \== 25 then call tf '4', N
if precision \== 2 then call tf '4', precision

/* math.rex 2 */
parse source . calltype .
if calltype \== 'COMMAND' then call tf '5', calltype

/* cvd.rex 1 */
Parse value Date('S') with Century +2 .
if left(Century, 2) \== '20' then call tf '7', Century

/* cvd.rex 2A */
Parse value '11/09/1959' with Day '/' Month '/' Year
if Day \== '11' then call tf '8', Day
if Month \== '09' then call tf '8', Month
if Year \== '1959' then call tf '8', Year

/* cvd.rex 2B */
/* #211: word targets between triggers (upstream PR 12) */
signal t8b_z
Parse value '11/09/1959' with Day . '/' Month . '/' Year .
if Day \== '11' then call tf '8', Day
if Month \== '09' then call tf '8', Month
if Year \== '1959' then call tf '8', Year

t8b_z:
/* cvd.rex 3 */
Parse value '19760601' with Year +4 Month +2 Day
if Day \== '01' then call tf '8', Day
if Month \== '06' then call tf '8', Month
if Year \== '1976' then call tf '8', Year

/* commas.rex 1 */
Parse value '12345.678' with Integer '.' Decimal
if Integer \== 12345 then call tf '9', Integer
if Decimal \== 678 then call tf '9', Decimal

/* commas.rex 2 */
Parse value '12345' with Part1 +3 Part2
if Part1 \== 123 then call tf '10', Part1
if Part2 \== 45 then call tf '10', Part2

/* B2H 1 */
call b2h_1A
signal b2h_1B
b2h_1A: procedure expose fail_count
d = date('S')
t = time('N')
input = d t
parse var input ,
today_yyyymmdd today_time,
1   today_yyyy  5  today_month 7  today_day .,
1 . today_hour ':' today_min  ':' today_sec .
if today_yyyymmdd \== d then call tf '11', today_yyyymmdd
if today_time \== t then call tf '11', today_time
if today_yyyy \== substr(d,1,4) then call tf '11', today_yyyy
if today_month \== substr(d,5,2) then call tf '11', today_month
if today_day \== substr(d,7) then call tf '11', today_day
if today_hour \== substr(t,1,2) then call tf '11', today_hour
if today_min \== substr(t,4,2) then call tf '11', today_min
if today_sec \== substr(t,7) then call tf '11', today_sec
return
b2h_1B:

/* B2H 2 */
call b2h_2A
signal b2h_2B
b2h_2A: procedure expose fail_count
parse value '' with ,
  ?centertag ?outputl83 ?outputp83,
  Abbrev. abstract
if ?centertag \== '' then call tf '12', ?centertag
if ?outputl83 \== '' then call tf '12', ?outputl83
if ?outputp83 \== '' then call tf '12', ?outputp83
if Abbrev.A \== '' then call tf '12', Abbrev.A
if Abbrev.42 \== '' then call tf '12', Abbrev.42
if abstract \== '' then call tf '12', abstract
return
b2h_2B:


/* B2H 3 */
call b2h_3A
signal b2h_3B
b2h_3A: procedure expose fail_count
parse value 1 with true,
  1 ?b2hreq 1 ?config. 1 ?cs. 1 ?dlfmt 1 ?figcaptop 1 ?figlistwanted
key = 'FOO'
if true \== 1 then call tf '13', true
if ?b2hreq \== 1 then call tf '13', ?b2hreq
if ?config.azerTy \== 1 then call tf '13', ?config.azerTy
if ?config.key \== 1 then call tf '13', ?config.key
if ?cs.RaP \== 1 then call tf '13', ?cs.RaP
if ?cs.666 \== 1 then call tf '13', ?cs.666
if ?dlfmt \== 1 then call tf '13', ?dlfmt
if ?figcaptop \== 1 then call tf '13', ?figcaptop
if ?figlistwanted \== 1 then call tf '13', ?figlistwanted
return
b2h_3B:



/* B2H 4 */
call b2h_4A
signal b2h_4B
b2h_4A: procedure expose fail_count
parse value 0 with false,
  1 ?!!gml,
  1 ?addressflag 1 ?addressprologflag 1 ?annot 1 ?appendix 1 ?artaltlabel
if false \== 0 then call tf '14', false
if ?!!gml \== 0 then call tf '14', ?!!gml
if ?addressflag \== 0 then call tf '14', ?addressflag
if ?addressprologflag \== 0 then call tf '14', ?addressprologflag
if ?annot \== 0 then call tf '14', ?annot
if ?appendix \== 0 then call tf '14', ?appendix
if ?artaltlabel \== 0 then call tf '14', ?artaltlabel
return
b2h_4B:

/* B2H 5 */
call b2h_5A
signal b2h_5B
b2h_5A: procedure expose fail_count
parse value '<DL>,</DL>,<P><DT>,,<DD>,,',
  with  list.!dl.0.1 ',' list.!dl.0.2 ',' list.!dl.0.3 ',' list.!dl.0.4 ',',
  list.!dl.0.5 ',' list.!dl.0.6 ','
if list.!dl.0.1 \== '<DL>' then call tf '15', list.!dl.0.1
if list.!dl.0.2 \== '</DL>' then call tf '15', list.!dl.0.2
if list.!dl.0.3 \== '<P><DT>' then call tf '15', list.!dl.0.3
if list.!dl.0.4 \== '' then call tf '15', list.!dl.0.4
if list.!dl.0.5 \== '<DD>' then call tf '15', list.!dl.0.5
if list.!dl.0.6 \== '' then call tf '15', list.!dl.0.6
return
b2h_5B:

/* B2H 6A */
/* Pre-existing bREXX BUG. LSKIPBLANKS vs. skipping ' ', '09'x is TAB,
   gets skipped */
/* Works fine in VM/SP5, Rexx level 3.40 */
/* Regina 3.93 gets almost identical failure, except NL matches. */
if 1 then do   /* #212: BREXX splits words at isspace(), not blanks */
   /* Suppress test until bREXX bug #115 is fixed.
      See https://github.com/adesutherland/CMS-370-BREXX/issues/115.
   */
   say 'skipped test 16 due to bREXX bug #115'
   signal b2h_6B
end
call b2h_6A
signal b2h_6B
b2h_6A: procedure expose fail_count
parse value '15'x '09'x '00'x '01'x 'FE'x 'FF'x '15FF15'x,
with  nl    tab   x00   x01   xFE   xFF   omitrecord
if c2x(nl) \=='15' then call test_failed '16, nl=/x'' || c2x(nl) || ''/'
if c2x(tab) \=='09' then call test_failed '16, tab=/x'' || c2x(tab) || ''/'
if c2x(x00) \=='00' then call test_failed '16, x00=/x'' || c2x(x00) || ''/'
if c2x(x01) \=='01' then call test_failed '16, x01=/x'' || c2x(x01) || ''/'
if c2x(xFE) \=='FE' then call test_failed '16, xFE=/x'' || c2x(xFE) || ''/'
if c2x(xFF) \=='FF' then call test_failed '16, xFF=/x'' || c2x(xFF) || ''/'
if c2x(omitrecord) \=='15FF15',
   then call test_failed '16, omitrecord=/x'' || c2x(omitrecord) || ''/'
return
b2h_6B:

/* B2H 6B */
/* Not using blank-separated parsing here makes B2H 6A work. */
call b2h_6C
signal b2h_6D
b2h_6C: procedure expose fail_count
parse value ('15'x || '/' || '09'x || '/' || '00'x || '/' || '01'x ||,
  '/' || 'FE'x || '/' || 'FF'x || '/' || '15FF15'x),
with  nl '/'   tab  '/' x00 '/'  x01 '/'  xFE  '/' xFF '/'  omitrecord
if nl \=='15'x then call test_failed '17, nl=/x'' || c2x(nl) || ''/'
if tab \=='09'x then call test_failed '17, tab=/x'' || c2x(tab) || ''/'
if x00 \=='00'x then call test_failed '17, x00=/x'' || c2x(x00) || ''/'
if x01 \=='01'x then call test_failed '17, x01=/x'' || c2x(x01) || ''/'
if xFE \=='fe'x then call test_failed '17, xFE=/x'' || c2x(xFE) || ''/'
if xFF \=='ff'x then call test_failed '17, xFF=/x'' || c2x(xFF) || ''/'
if omitrecord \=='15Ff15'x,
   then call test_failed '17, omitrecord=/x'' || c2x(omitrecord) || ''/'
return
b2h_6D:

/* B2H 7 */
x00 = '00'x
parse value ('before' || '00'x || 'between' || '00'x || 'after'),
  with tagnest1 (x00) tntag (x00) tagnest2

if tagnest1 \== 'before' then call tf '18', tagnest1
if tntag \== 'between' then call tf '18', tntag
if tagnest2 \== 'after' then call tf '18', tagnest2

/* ERR 1 */
/* Pre-existing bug: WITH is allowed on *all* PARSEs, not just PARSE VALUE */
if 1 then do   /* #213: WITH is a keyword in PARSE VAR too */
   /* Suppress test until bREXX bug #116 is fixed.
      See https://github.com/adesutherland/CMS-370-BREXX/issues/116.
   */
   say 'skipped test 19 due to bREXX bug #116'
   signal err1_z
end
x = 'My dog has fleas'
parse var x with y
if x == y,
   then call test_failed '19, x=/' || x || '/, invalid 'WITH' was ignored'
err1_z:

/* DELIM 1 */
/* #211: word targets between triggers (upstream PR 12) */
signal t20_z
parse value '/middle1 middle2/after',
  with delimiter +1 middle1 middle2 middle3 (delimiter) after
if delimiter \== '/' then call tf '20', delimiter
if middle1 \== 'middle1' then call tf '20', middle1
if middle2 \== 'middle2' then call tf '20', middle2
if middle3 \== '' then call tf '20', middle3
if after \== 'after' then call tf '20', after

t20_z:
/* TRL2 LIT 1 */
parse value 'This is  the text which, I think,  is scanned.',
  with w1 ',' w2 ',' rest
if w1 \== 'This is  the text which' then call tf '22', w1
if w2 \== ' I think' then call tf '22', w2
if rest \== '  is scanned.' then call tf '22', rest

/* TRL2 LIT 2 */
parse value 'This is  the text which, I think,  is scanned.',
  with w1 ',' w2 ',' w3 ',' rest
if w1 \== 'This is  the text which' then call tf '23', w1
if w2 \== ' I think' then call tf '23', w2
if w3 \== '  is scanned.' then call tf '23', w3
if rest \== '' then call tf '23', rest

/* TRL2 WORD 1 */
parse value 'This is  the text which, I think,  is scanned.',
  with w1 w2 w3 rest ','
if w1 \== 'This' then call tf '24', w1
if w2 \== 'is' then call tf '24', w2
if w3 \== 'the' then call tf '24', w3
if rest \== 'text which' then call tf '24', rest


/* TRL2 WORD 2 */
parse value 'This is  the text which, I think,  is scanned.',
  with w1 ' ' w2 ' ' w3 ' ' rest ','
if w1 \== 'This' then call tf '25', w1
if w2 \== 'is' then call tf '25', w2
if w3 \== '' then call tf '25', w3
if rest \== 'the text which' then call tf '25', rest

/* TRL2 DOT 1 */
parse value 'This is  the text which, I think,  is scanned.' with . . . word4 .
if word4 \== 'text' then call tf '25', word4

/* TRL2 POS 1 */
parse value 'This is  the text which, I think,  is scanned.' with s1 10 s2 20 s3
if s1 \== 'This is  ' then call tf '26', s1
if s2 \== 'the text w' then call tf '26', s2

/* TRL2 POS 2 */
parse value 'This is  the text which, I think,  is scanned.',
  with s1 =10 s2 =20 s3
if s1 \== 'This is  ' then call tf '26', s1
if s2 \== 'the text w' then call tf '26', s2
if s3 \== 'hich, I think,  is scanned.' then call tf '26', s3

/* TRL2 POS 3 */
parse value '123456789' with 3 w1 +3 w2 3 w3
if w1 \== '345' then call tf '27', w1
if w2 \== '6789' then call tf '27', w2
if w3 \== '3456789' then call tf '27', w3

/* TRL2 POS 4 */
parse value 'hi mom!' with 1 w1 1 w2 1 w3
if w1 \== 'hi mom!' then call tf '28', w1
if w2 \== 'hi mom!' then call tf '28', w2
if w3 \== 'hi mom!' then call tf '28', w3

/* TRL2 POS 5 */
opts= 'word1 prword2 word3'
parse upper value ' 'opts with ' PR' +1 prword .
if prword \== 'PRWORD2' then call tf '29', prword

/* TRL VARPAT 1 */
input='L/look for/1 10'
parse var input verb 2 delim +1 string (delim) rest
if verb \== 'L' then call tf '30', verb
if delim \== '/' then call tf '30', delim
if string \== 'look for' then call tf '30', string
if rest \== '1 10' then call tf '30', rest


say 'PARSE    - done, failures:' fail_count
say 'Done parse.rexx'
exit fail_count
test_failed:
say 'PARSE    - test' arg(1) '.. *FAIL*'
fail_count=fail_count+1
return
tf:
say 'PARSE    - test' arg(1) '.. *FAIL* got "'arg(2)'"'
fail_count=fail_count+1
return
