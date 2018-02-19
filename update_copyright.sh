#!/bin/bash

FILES=`git diff HEAD  --name-only`

YEAR=`date +"%Y"`
while read -r FILE; do
	if grep "opyright.*$YEAR.*\(ARM\|Arm\|arm\)" "$FILE">/dev/null
	then
		echo "$FILE:File already correctly copyrighted"
	else
		if grep "opyright.*\(ARM\|Arm\|arm\)" "$FILE" >/dev/null
		then
			#change year range to startyear-current year
			sed -i "s/\(opyright[^0-9]*[0-9][0-9][0-9][0-9]-\)\([0-9][0-9][0-9][0-9]\)\(.*ARM\|.*Arm\|.*arm\)/\1$YEAR\3/" $FILE

			#change single year to year-current year
			sed -i "s/\(opyright[^0-9]*[0-9][0-9][0-9][0-9]\)\([^\-]\)\(.*ARM\|.*Arm\|.*arm\)/\1-$YEAR\2\3/" $FILE
			echo "Changed copyright year of: $FILE"
			git add "$FILE"
		else
			echo "No Arm copyright in file"
			exit -1
		fi
	fi
done <<< "$FILES"
