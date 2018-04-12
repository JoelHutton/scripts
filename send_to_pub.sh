#!/bin/bash

set -x

if [[ -z $1 ]]
then
	echo "specify the file to copy"
	exit 1
fi
if [[ -z $2 ]]
then
	filename=`basename $1`
else
	filename=$2
fi



scp $1 e115011-lin.cambridge.arm.com:/pub/$filename
ssh e115011-lin.cambridge.arm.com "chmod 444 /pub/$filename"
echo "http://e115011-lin.cambridge.arm.com/$filename"
