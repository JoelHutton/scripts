#!/bin/bash
if [ -z "$CHECKPATCH" ]
then
	echo "set your checkpatch"
else
	if make help | grep 'checkpatch' > /dev/null
	then
		make checkpatch
	fi
fi	
