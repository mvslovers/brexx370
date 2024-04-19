/* Written by Stig Hemmer <stig@solan.unit.no> */

node = 'an elephant'
do until left(svar,1) = 'N'
   where = 'NODE'
   finished = 0
   do while finished = 0
      if symbol(where'.Y')='VAR' then do
         say value(where)
         pull answer
         if left(answer,1) = 'N' then
            where = where'.N'
         else
            where = where'.Y'
      end; else do
         finished = 1;
         say 'Did you think of 'value(where)'?'
         pull answer
         if left(answer,1) = 'Y' then
            say 'Good!'
         else do
            say 'Hmmm, what did you think of?'
            parse pull newanimal
            say 'Give me a question that separates between 'newanimal' from',
                value(where)':'
            parse pull quest
            say 'And what is the answer for 'newanimal'?'
            pull answer
            if left(answer,1) = 'Y' then do
               interpret where'.N =' where
               interpret where'.Y = newanimal'
               interpret where '= quest'
            end; else do
               interpret where'.Y =' where
               interpret where'.N = newanimal'
               interpret where '= quest'
            end
         end
      end
   end
   say 'Another play?'
   pull answer .
   if left(answer,1)=='N' then exit
end /* do until left(svar,1) = 'N' */


