/* Extract Data from a certain line of a SARRAY */
say copies('-',60)
say "Extract Data from a SARRAY"
say copies('-',60)
s1=screate(100)
/* create stream     */
do i=1 to 5
   call sset(s1,,'Record 'i)
end
call sset(s1,,'from here *******')        /* insert begin string */
do i=1 to 3
   call sset(s1,,'my Data 'i)
end
call sset(s1,,'to there *******')         /* insert end string */
do i=6 to 10
   call sset(s1,,'Record 'i)
end
call slist s1,,,"Original SARRAY"
/* now extract lines */
s2=scut(s1,"from here","to there",1,"DEL")
call slist s2,,,"extracted including delimiters"
s3=scut(s1,"from here","to there",1,"NO-DEL")
call slist s3,,,"extracted excluding delimiters"
