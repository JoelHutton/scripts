#!/bin/bash

HOST=e113708-lin
BACKUP_NAME="$HOST""_$DATE"
BACKUP_PATH=/data/backups/rsync
REMOTE_USER=joehut01
REMOTE_MACHINE=e115011-lin.cambridge.arm.com
REMOTE=$REMOTE_USER@$REMOTE_MACHINE

to_restore="
bin
etc
home
lib
lib32
lib64
libx32
opt
root
sbin
snap
srv
usr
var
"
CWD=`pwd`
set +x
for folder in $to_restore
do

	echo "restoring $folder to $CWD/$folder"
	sudo rsync -arvzPHx \
 		--delete\
 		--rsync-path="rsync --fake-super"\
 		"$REMOTE:$BACKUP_PATH/$HOST""_current"/$folder/\
 		$CWD/$folder
done
exit 0

