#!/bin/bash

FILES=`git diff HEAD  --name-only`

YEAR=`date +"%Y"`
while read -r FILE; do
	if grep "Copyright.*$YEAR" "$FILE">/dev/null
	then
		echo "$FILE:File already correctly copyrighted"
	else
		if grep "Copyright" "$FILE" >/dev/null
		then
			#change year range to startyear-current year
			sed -i "s/\(Copyright[^0-9]*[0-9][0-9][0-9][0-9]-\)\([0-9][0-9][0-9][0-9]\).*\(ARM\|Arm\)/\1$YEAR/" $FILE

			#change single year to year-current year
			sed -i "s/\(Copyright[^0-9]*[0-9][0-9][0-9][0-9]\)\([^\-]\).*\(ARM\|Arm\)/\1-$YEAR\2/" $FILE
			git add "$FILE"
		else
			echo "No copyright in file"
			exit -1
		fi
	fi
done <<< "$FILES"
