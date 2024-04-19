say copies('-',50)
say "Select Lines if ON is contained"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
ssc="ON"
ssi=ssearch(s1,ssc) /* Search strin OF in array */
do while ssi>0
   say "Found at "ssi": "sget(s1,ssi)
   ssi=ssearch(s1,ssc,ssi+1)
end
