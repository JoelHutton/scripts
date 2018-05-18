#!/bin/bash
if [ -z "$CHECKPATCH" ]
then
	echo "set your checkpatch"
else
	if make help 2>/dev/null | grep 'checkpatch' > /dev/null 2>&1
	then
		make checkpatch
	fi
fi	

FILES=`git diff HEAD HEAD~2 --name-only`
YEAR=`date +"%Y"`

YEAR_RGX="[0-9][0-9][0-9][0-9]"
ARM_RGX="\(ARM\|Arm\|arm\)"

while read -r FILE; do
	if [ -z "$FILE" ]
	then
		break
	fi
	if ! grep "opyright.*$YEAR.*$ARM_RGX" "$FILE">/dev/null 2>&1
	then
		if grep "opyright.*$YEAR_RGX.*$ARM_RGX" "$FILE" >/dev/null 2>&1
		then
			#change year range to startyear-current year
			#sed -i "s/\(opyright.*$YEAR_RGX-\)\($YEAR_RGX\)\(.*$ARM_RGX\)/\1$YEAR\3/" $FILE

			#change single year to year-current year
			#sed -i "s/\(opyright.*[^\-]$YEAR_RGX\)\([^\-]\)\(.*$ARM_RGX\)/\1-$YEAR\2\3/" $FILE
			echo "Copyright of $FILE needs updated"
			grep -nr "opyright.*$ARM_RGX" "$FILE"
		fi
	fi
done <<< "$FILES"
