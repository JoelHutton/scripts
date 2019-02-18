#!/bin/bash

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
	# Check for trailing space
	if grep -nr '\s$' $FILE >/dev/null 2>&1
	then
		MESSAGE="trailing whitespace in $RED$FILE$BLANK...gross"
		echo -e "$MESSAGE"
		grep -nr '\s$' $FILE
	fi
	# Check comments
	if echo "$FILE" | grep ".*\.c\|.*\.h\|.*\.S" > /dev/null 2>&1
	then
		if git diff HEAD~1 HEAD $FILE | grep '//' | grep '^+' > /dev/null 2>&1
		then
			MESSAGE="Double slash commenting in $RED$FILE$BLANK"
			echo -e "$MESSAGE"
			SLASH_COMMENTS=`git diff HEAD~1 $FILE | grep '//' | grep '^+\s'`
			echo -e "$RED$SLASH_COMMENTS$BLANK"
		fi
		GREP_EXPR="/\*[^$\ *]\|[^$\ *]\*/"
		if git diff HEAD~1 HEAD $FILE | grep "$GREP_EXPR" | grep '^+\s' > /dev/null 2>&1
		then
			MESSAGE="Spaces around comments in $FILE"
			echo -e "$RED$MESSAGE$BLANK"
			SLASH_COMMENTS=`git diff HEAD~1 $FILE | grep "$GREP_EXPR" | grep '^+'`
			echo -e "$RED$SLASH_COMMENTS$BLANK"
		fi
		GREP_EXPR="[a-zA-Z0-9][+\-\/%][a-zA-Z0-9]"
		if git diff HEAD~1 HEAD $FILE | grep "$GREP_EXPR" | grep '^+\s' > /dev/null 2>&1
		then
			MESSAGE="No space around operator $FILE"
			echo -e "$RED$MESSAGE$BLANK"
			SLASH_COMMENTS=`git diff HEAD~1 $FILE | grep "$GREP_EXPR" | grep '^+'`
			echo -e "$RED$SLASH_COMMENTS$BLANK"
		fi
	fi
done <<< "$FILES"
