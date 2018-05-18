#!/bin/bash

# Copyright 2017 Arm

RED="\033[00;31m"
BLANK="\033[00;00m"
if [ -z "$CHECKPATCH" ]
then
	echo "set your checkpatch"
else
	if make help 2>/dev/null | grep 'checkpatch' > /dev/null 2>&1
	then
		make checkpatch
	fi
fi	

FILES=`git diff HEAD HEAD~1 --name-only`
YEAR=`date +"%Y"`

YEAR_RGX="[0-9][0-9][0-9][0-9]"
ARM_RGX="\(ARM\|Arm\|arm\)"

while read -r FILE; do
	if [ -z "$FILE" ]
	then
		break
	fi
	# Check copyright
	if ! grep "opyright.*$YEAR.*$ARM_RGX" "$FILE">/dev/null 2>&1
	then
		if grep "opyright.*$YEAR_RGX.*$ARM_RGX" "$FILE" >/dev/null 2>&1
		then
			echo -e "Copyright of $RED$FILE$BLANK needs updated"
			grep -nr "opyright.*$YEAR_RGX.*$ARM_RGX" "$FILE"
		fi
	fi
	# Check comments
	if echo "$FILE" | grep ".*c\|.*h" > /dev/null 2>&1
	then
		if git diff HEAD~1 $FILE | grep '//' > /dev/null 2>&1
		then
			MESSAGE="Double slash commenting in $RED$FILE$BLANK"
			echo -e "$MESSAGE"
			SLASH_COMMENTS=`git diff HEAD~1 $FILE | grep '//'`
			echo -e "$RED$SLASH_COMMENTS$BLANK"
		fi
		GREP_EXPR="/\*[^$\ *]\|[^$\ *]\*/"
		if git diff HEAD~1 $FILE | grep "$GREP_EXPR" > /dev/null 2>&1
		then
			MESSAGE="Spaces around comments in $FILE"
			echo -e "$RED$MESSAGE$BLANK"
			SLASH_COMMENTS=`git diff HEAD~1 $FILE | grep "$GREP_EXPR"`
			echo -e "$RED$SLASH_COMMENTS$BLANK"
		fi
	fi
done <<< "$FILES"

