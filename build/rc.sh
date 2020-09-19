#!/usr/bin/bash
# uses JCL to check if all the steps in JCL 
# have RC= 0000/0004. If not set return code to 1
J=`head -1 $1|cut -d" " -f1`

JOBNAME=${J#//} 
IFS=$'\n'
proc=false
rc=0
echo "Time     Job  Num  Jobname    Stepname  Procstep  Program   Retcode"
for i in `grep ' EXEC \| PROC ' $1|grep -v "//\*"`
do
	S=`echo $i|cut -d " " -f1`
	STEPNAME=${S#//}
    if echo $i | grep -q PROC ; then
	    proc=true
		continue
	fi
    if $proc; then
		# skip PROC exec statements
		proc=false
		continue
    fi
	srch=`printf '%-8s   %s' "$JOBNAME"  "$STEPNAME"`
	status=`grep "$srch" $2|tail -1`
	
	if [ $? -eq 0 ]; then
		if echo $status|grep -q 0000 || echo $status|grep -q 0004; then
			echo $status
		else
			echo $status "<==== error"
			rc=1
		fi  
	else
		echo "$JOBNAME   $STEPNAME not found in $2" 
		rc=1
	fi
done
exit $rc
