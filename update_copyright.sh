#!/bin/bash

FILES=`git diff HEAD HEAD~2 --name-only`
YEAR=`date +"%Y"`

YEAR_RGX="[0-9][0-9][0-9][0-9]"
ARM_RGX="\(ARM\|Arm\|arm\)"

while read -r FILE; do
	if [ -z "$FILE" ]
	then
		break
	fi
	if grep "opyright.*$YEAR.*$ARM_RGX" "$FILE">/dev/null
	then
		echo "$FILE:File already correctly copyrighted"
	else
		if grep "opyright.*$ARM_RGX" "$FILE" >/dev/null
		then
			#change year range to startyear-current year
			sed -i "s/\(opyright.*$YEAR_RGX-\)\($YEAR_RGX\)\(.*$ARM_RGX\)/\1$YEAR\3/" $FILE

			#change single year to year-current year
			sed -i "s/\(opyright.*[^\-]$YEAR_RGX\)\([^\-]\)\(.*$ARM_RGX\)/\1-$YEAR\2\3/" $FILE
			echo "Changed copyright year of: $FILE"
			git add "$FILE"
		else
			echo "No Arm copyright in file $FILE"
		fi
	fi
done <<< "$FILES"
