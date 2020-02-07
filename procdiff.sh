#!/bin/bash
# Watch 2 files until they differ

SCRIPTNAME=`basename $0`
USAGE="""[INTERVAL=<interval>] $0 <program 1> <program 2>"""

INTERVAL=${INTERVAL:-1}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-1}
A_CMD=${A_CMD:-$1}
B_CMD=${B_CMD:-$2}

if [ -z "$A_CMD" ] || [ -z "$B_CMD" ]
then
  echo "$USAGE"
  exit 1
fi
A_FILE=`mktemp`
B_FILE=`mktemp`

rm $A_FILE
rm $B_FILE
mkfifo $A_FILE
mkfifo $B_FILE

$A_CMD | tee a.log > $A_FILE 2>&1 &
A_PROC=$!

$B_CMD | tee b.log > $B_FILE 2>&1 &
B_PROC=$!

cleanup(){
  kill $A_PROC
  kill $B_PROC
  rm $A_FILE
  rm $B_FILE
}

trap "cleanup; exit;" SIGHUP SIGINT SIGTERM

exec 3< $A_FILE
exec 4< $B_FILE

A_ATTEMPTS=0
B_ATTEMPTS=0

LINE_NO=0

while true
do
  let LINE_NO=$LINE_NO+1
  if read -r -u 3 A_LINE;then
    while true
    do
      if read -r -u 4 B_LINE;then
	diff <(echo "$A_LINE") <(echo "$B_LINE")
	if [ $? -ne "0" ]
	then
	 echo "programs differ after $LINE_NO lines"
	 cleanup
	 exit
	fi
	break;
      else
	if [ "$B_ATTEMPTS" -ge "$MAX_ATTEMPTS" ]
	then
	  echo "$2 has stopped producing output" > /dev/stderr
	  cleanup
	  exit 0
	fi
	let B_ATTEMPTS=B_ATTEMPTS+1
	sleep $INTERVAL
      fi
    done
  else
    if [ "$A_ATTEMPTS" -ge "$MAX_ATTEMPTS" ]
    then
      echo "$1 has stopped producing output" > /dev/stderr
      cleanup
      exit 0
    fi
    let A_ATTEMPTS=A_ATTEMPTS+1
    sleep "$INTERVAL"
  fi
done
