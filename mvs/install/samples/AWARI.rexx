/*
                                 A  W  A  R  I                        o o
                               ~~~~~~~~~~~~~~~~~                    ____oo_
                                                            1989   /||    |\
                                   My Side                 by BNV   ||    |
                                                                     .___.'
                           | 6 | 5 | 4 | 3 | 2 | 1 |                MARMITA
                           |ooo|ooo|ooo|ooo|ooo|ooo|
                  My home  |   |   |   |   |   |   | Your home
                           |ooo|ooo|ooo|ooo|ooo|ooo|
                           | 1 | 2 | 3 | 4 | 5 | 6 |
 
                                 Your  Side
 
             Awari is an  African  game  played  with seven sticks and
          thirty-six stones or  beans  laid  out  as  shown above. The
          board is divided into six compartments or pits on each side.
          In addition, there are two special HOME pits at the end.
 
             A  move  is  made  by  taking  all  the  beans  from  any
          (non-empty) pit on your own  side.  Starting from the pit to
          the right of this one,  these  beans  are "sown" one in each
          pit working around the board anticlockwise.
 
             A turn consists of one or  two moves. If the last bean of
          your move is sown in  your  own  home  you may take a second
          move.
 
             If the last bean is sown in a move lands in an empty pit,
          provided that the opposite pit is no empty, all the beans in
          the opposite  pit,  together  with  the  last  bean sown are
          "captured" and moved to the players home.
 
             When either side  is  empty,  the  game  is finished. The
          player with the most beans in his home has won.
 
             In the  computer  version,  the  board  is  printed as 14
          numbers representing the 14 pits.

                            3   3   3   3   3   3
                         0                         0
                            3   3   3   3   3   3
 
             The pits on your (lower)  side are numbered 1-6 from left
          to right. The pits on  my  side (computer) are numbered from
          my left (your right).
 
             To make a move you type in the number of the pit.
 
             If the last bean  lands  in  your home the computer types
          "Again?" and then you type in the second move.
 
             If you want to terminate the game just type "END" in your
          move.
 
             The computer move  is typed  followed by a diagram of the
          board in its new state.  The computer allways offers you the
          first move. This consider to be a slight advantage.

             There is a learning mechanism  in the program that causes
          the play of the computer to improve as it plays more games.

             This version  of  Awari  is  adopted  from one originally
          written by Geoff Wyvill  of  Bradford, Yorksire, England and
          translated to IBM REXX by Vasilis N. Vlachoudis.
                     email: Vasilis.Vlachoudis@cern.ch
*/
Arg Args .
if Args = '?' then Call Help

Say
Say Center('A  W  A  R  I',79)
Say Center('~~~~~~~~~~~~~~~~~',79)
Say ; Say Center('by Vasilis.Vlachoudis@cern.ch',79)
Say ;
Say Center('For instructions about the game enter "awari ?" in cmd line.',79)
Say Center('or simply enter "?" in your move.',80)

n = 0
awarif = open("awari.var","r")
If awarif ~= -1 then Do
    Do until eof(awarif)
        interpret read(awarif)
    End
    Call close awarif
End
/* // 'GLOBALV SELECT AWARI STACK N'
Pull N
if N = '';then  N = 0
    ;else Do i = 0 to N-1
        'GLOBALV SELECT AWARI GET F.'i
    End
*/
Begin:
E = 0 ;  B. = 3 ; C = 0 ; F.n = 0 ;
Do i = 0 to 13
    b.i = 3
End
B.6 = 0 ; B.13 = 0

Do forever                        /* Main Loop */
    Call Print
    Call Input "Your move?"
    if  ~E   then Leave
    if M = H then Call Input "Again?"
    if  ~E   then Leave
    Move = "My move is"
    Call CPU_move
    if  ~E   then Leave
    if M = H then Do
        Move = Move || ","
        Call Cpu_move
        if  ~E   then Leave
    End
    Say; Say Move
End

/* Game Over */
if H = 13 then Do
    Say; Say Move
    Call Print
End
Say ; Say "Game Over"
D = B.6 - B.13
if D < 0 ;then Sa =  "I win by "0-D" point"
else
if D = 0 ;then Do
    N = N + 1
    Sa = "Drawn game"
End
else Do
    N = N + 1
    Sa =  "You win by "D" point"
End
if abs(D)=1 | D = 0 ;then Say Sa'.'
                    ;else Say Sa's.'
Signal Begin

/*  Get input  */
Input:
   Parse Arg Text
   Valid = 0
   Do until Valid          /* Test if input is Valid */
      Call write ,Text' '
      Parse UPPER External M .
      Select
         When M = '?' then Do
            Call Help
            Call Print
         End
         When M = 'END' then Do
             Say "Thanks for the game."
             Say "Have a nice day."
/* Save everything we done till now */
             awarif = Open("awari.var","w")
             If awarif ~= -1 then Do
                Call write awarif,"N =" N
                Call write awarif
                Call write awarif, vardump('F.')
                Call close awarif
             End
/*//             'GLOBALV SELECT AWARI SETP N 'N
             Do i = 0 to N-1
                'GLOBALV SELECT AWARI SETP F.'I F.I
             End */
/* O.k. now Exit from the program */
             Exit 0
         End
         When ~Datatype(M,'NUM') then Say "Not valid move '"M"'"
         Otherwise Do
            M = Trunc(M) ; M = M - 1
            if M<0 | M>5 | B.M=0 ;then Say "Illegal move '"M+1"'"
            ;else Valid = 1
         End
      End              /* Of select             */
   End

   H = 6              /* O.k. it is valid       */
   Call MakeMove      /* Make the move he asked */
   Call Print         /* Print the board        */
Return

MakeMove:
      K = M
      Call Moveit M
      E = 0
      if k > 6 then k = k - 7
      C = C + 1
      if C < 9 then F.n = F.n * 6 + K    /* Learn dummit */
 /* Game Over ? */
      Do i = 7 to 12
         if B.i ~= 0 then Signal Cpufin
      End
      Return
CpuFin:
      Do i = 0 to 5
         if B.i ~= 0 then Do
            E = 1
            Return
         End
      End
   Return
 
Print:                     /* Procedure for printing the board */
   Say
   CC = copies(' ',22)
   P = CC '  '
   Do I = 12 to 7 by -1
      P = P || format(B.i,4)
   End
   Say P
   Say CC Format(B.13,2) '                        ' Format(B.6,2)
   P = CC '  '
   Do I = 0 to 5
      P = P || Format(B.i,4)
   End
   Say P
Return
 
Moveit: Procedure Expose B. H M        /* Move the 'M' pit */
   Arg M
   P = B.m   ; B.m = 0
   Do P
      M = M + 1
      if M > 13 then M = M - 14
      B.M = B.M + 1
   End
   P = 12 - M
   if B.M =  1 then          /* Last bit was empty         */
   if M  ~=  6 then          /* Not your home              */
   if M  ~= 13 then          /* Not my home                */
   if B.P~=  0 then Do       /* Opposite pit was empty too */
      B.H = B.H + B.P + 1
      B.M = 0
      B.P = 0
   End
Return
 
CPU_Move:
   D = -99  ;  H = 13  ; Q = -99
   Do I = 0 to 13
      G.i = B.i                        /* Save the board */
   End
 
   Do J = 7 to 12                      /* Calc for all the possible */
      if B.J = 0 then ITERATE          /* moves                     */
      G = 0
      Call Moveit J
 
      Do i = 0 to 5
         if B.i = 0 then ITERATE
         L = B.i + i
         R = (L>13)
         L = L // 14
         P = 12 - L
         if B.L =  0 then             /* Again the same story */
         if L  ~=  6 then             /* Life goes on...      */
         if L  ~= 13 then R = B.P + R
         if R > Q then Q = R
      End
 
      Q = B.13 - B.6 - Q
      if C < 9 then Do
         K = J
         if k > 6 then k = k - 7
         Do i = 0 to n-1
            if F.n*6 + k  =  Trunc(F.i/6**(7-C) + 0.1) then Q = Q - 2
         End
      End
 
      Do i = 0 to 13
         B.i = G.i           /* Restore the board             */
      End
 
      if Q >= D then Do      /* if the current move is better */
         A = J               /* then Save it                  */
         D = Q
      End
   End
 
   M = A
   Move = Move M-6
   Call MakeMove
Return
 
/* Help me if you can, I'm feeling down ...   */
Help:
Do Line = 2 by 1
   if left(Sourceline(Line),2) = '*/' then return
   Say Sourceline(Line)
   if line // 23 = 0 then Do
      Say 'Press <enter> to continue...'
      Pull .
   End
End
