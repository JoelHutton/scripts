#!/bin/bash

set -e

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
if [[ -z "$1" ]]
then
	echo "specify the file to copy" >&2
	exit 1
fi
if [[ -z "$2" ]]
then
	filename="$DATE"_`basename $1`
else
	filename=$2
fi
if [[ -z "$SVALBARD_USER" ]]
then
	echo "set SVALBARD_USER variable" >&2
	exit 1
fi
WEB_PATH=/usr/local/www/nginx/$SVALBARD_USER

scp $1 $SVALBARD_USER@svalbard.cambridge.arm.com:$WEB_PATH/$filename
ssh $SVALBARD_USER@svalbard.cambridge.arm.com "chmod 644 $WEB_PATH/$filename"
echo "http://svalbard.cambridge.arm.com/$SVALBARD_USER/$filename" | xsel -ib
echo "link copied to clipboard"
