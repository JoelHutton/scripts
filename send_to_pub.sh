#!/bin/bash

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
WEB_PATH=/var/www/html

if [ -d "$1" ] ; then
	cp -r $1 $WEB_PATH/$filename
	chmod -R 755 $WEB_PATH/$filename
else
	cp $1 $WEB_PATH/$filename
	chmod 644 $WEB_PATH/$filename
fi
echo "http://$HOSTNAME.cambridge.arm.com/$filename"
echo "http://$HOSTNAME.cambridge.arm.com/$filename" | xsel -ib
echo "link copied to clipboard"
