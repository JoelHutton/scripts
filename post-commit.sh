#!/bin/bash
if [ -z "$CHECKPATCH" ]
then
	echo "set your checkpatch"
else
	make checkpatch
fi	
