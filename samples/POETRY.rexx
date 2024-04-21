/*===================================================================*/
/*     Bill N. Vlachoudis                                     o o    */
/*     Computer adDREss.......CACZ0200 AT Grtheun1.EARN     ____oo_  */
/*     HomE AdDreSs...........Parodos Filippoy 51          /||    |\ */
/*   !                        TK 555-35 Pylaia              ||    |  */
/* !  tHe bESt Is             ThesSALONIKI, GREECE          '.___.'  */
/*  Y e t  to   Co mE !                                     MARMITA  */
/*===================================================================*/
Lines = 14
I = Random(1,Lines) ; U = 0 ; J = 0 ; K = 0
P = ''
Line1:
Select
   When I =  1 then    P = P 'thow shalt not'
   When I =  2 then    P = P 'foxe''s hair'
   When I =  3 then    P = P 'snail of fear'
   When I =  4 then    P = P 'tounge of Turk'
   When I =  5 then    P = P 'Slammer'
   When I =  6 then    P = P 'yeald of ferms'
   When I =  7 then    P = P 'morning dawn'
   When I =  8 then    P = P 'tang of sunrise'
   When I =  9 then    P = P 'swaying pines'
   When I = 10 then    P = P 'living pig'
   When I = 11 then    P = P 'trailing feathers'
   When I = 12 then    P = P 'barking dogs'
   When I = 13 then    P = P 'dying lives'
   When I = 14 then    P = P 'earthquakes'
End
Signal Line210
Line2:
Select
   When I =  1 then Do;   P = P 'wrestling beings' ;U=2 ; End
   When I =  2 then    P = P 'thrilled me'
   When I =  3 then    P = P 'still sitting upright...'
   When I =  4 then Do;   P = P 'never ever flitting';U=2 ; End
   When I =  5 then    P = P 'burt'
   When I =  6 then    P = P 'entrances me'
   When I =  7 then    P = P 'soothing me'
   When I =  8 then    P = P 'rustling leaves'
   When I =  9 then    P = P 'radiates calm'
   When I = 10 then    P = P 'radiates sun'
   When I = 11 then    P = P 'absorbs nature'
   When I = 12 then    P = P 'intakes grabs'
   When I = 13 then    P = P 'judjing liers'
   When I = 14 then    P = P 'fires'
End
Signal Line210
Line3:
Select
   When I =  1 then  P = P 'and my heart'
   When I =  2 then  P = P 'darkness here'
   When I =  3 then  P = P 'shall be lifted and dropped'
   When I =  4 then  P = P 'quoth the raven'
   When I =  5 then  P = P 'sight of parting'
   When I =  6 then  P = P 'mighty Oaks'
   When I =  7 then  P = P 'grace and beauty'
   When I =  8 then  P = P 'silelntly singing an ever ending'
   When I =  9 then  P = P 'nature speaking of glory'
   When I = 10 then  P = P 'creatures fearing'
   When I = 11 then  P = P 'animals of distruction'
   When I = 12 then  P = P 'guns and carnations'
   When I = 13 then  P = P 'greenhorns and rapists'
   When I = 14 then  P = P 'valuable receptors'
End
Signal Line210
Line4:
Select
   When I =  1 then    P = P 'nothing more nothing less'
   When I =  2 then    P = P 'Yet again'
   When I =  3 then    P = P 'slowly creeping'
   When I =  4 then    P = P '... Evermore'
   When I =  5 then    P = P 'nevermore'
   When I =  6 then    P = P 'untouch, unspoiled'
   When I =  7 then    P = P 'shades of green and passion'
   When I =  8 then    P = P 'tranquility and faith'
   When I =  9 then    P = P '... so peacefully'
   When I = 10 then    P = P 'and yet again ... '
   When I = 11 then    P = P 'but'
   When I = 12 then    P = P 'and...'
   When I = 13 then    P = P 'enough.'
   When I = 14 then    P = P 'again.'
End

Line210:
If ¬(U = 0 | Random(1,100) > 19) then Do
   P = P ','  ; U = 2
End

if Random(1,100) < 66 then Do
   P = P' ' ; U = U + 1
End
Else Do
    say P
    U = 0 ; P = ''
End

Line215:
I = random() // Lines + 1
J = J + 1 ; K = K + 1

if ¬(U>0 | J%2 ¬= J/2) then P = '    '

Interpret 'Signal Line'J

Line5:
J = 0 ;
if K < 21 then signal Line215
   say '* -----------------------------------------------'
 M.0  = 13
 M.1  = 'Wow he is great.'
 M.2  = 'He is the best poet of all times.'
 M.3  = 'I think that his last frase was the best of them all.'
 M.4  = 'Didn''t  you like that ?'
 M.5  = 'Well don''t you just love that guy ? '
 M.6  = 'What is he talking about ?'
 M.7  = 'Do you call this POETRY ?!!!!!!!!!!'
 M.8  = 'Rubish.'
 M.9  = 'Oh my GOD. What was that ? '
 M.10 = 'Send him something else to find out how great he is......'
 M.11 = 'I really think that you have something better to do......'
 M.12 = 'Well, when the time comes for great men to do their job, they always remind me of him (fazz0100)'
 M.13 = 'So, this is all that poetry is about.'
 E = random(1,M.0)
 say '* POETRY CRITICS *** 'M.E
Exit 0
