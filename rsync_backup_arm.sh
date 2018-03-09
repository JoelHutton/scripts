#!/bin/bash

set -x
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
HOST=`cat /etc/hostname`
BACKUP_NAME="$HOST""_$DATE"
BACKUP_PATH=/data/backups/rsync
REMOTE_USER=joehut01
REMOTE_MACHINE=e115011-lin.cambridge.arm.com
REMOTE=$REMOTE_USER@$REMOTE_MACHINE

if ping -c 1 $REMOTE_MACHINE
then
	:
else
	echo "Cannot access backup machine" >&2
	exit 1
fi

if ssh $REMOTE "ls $BACKUP_PATH/$HOST""_current" 2>&1 1>/dev/null
then
	:
else
	ssh $REMOTE "mkdir $BACKUP_PATH/$HOST""_current" || \
		(echo "Could not create $HOST""_current on $REMOTE" && exit 1)
fi

# rsync backup, then move 'current' link to point at backup
# x - don't cross file system boundaries
# a - archive (preserve permissions, symlinks etc.)
# r - recursive
# P - partial, pickup partial copies
# z - use zip compression to speedup transfer
(rsync -arvzPx \
	--rsync-path="rsync --fake-super"\
	--exclude /home/joehut01/Downloads \
	--exclude /tmp --exclude /mnt \
	--exclude /media --exclude /proc \
	--exclude /arm --exclude /run \
	--exclude /dev --exclude /home/joehut01/.cache \
	--exclude /sys --exclude $HOME/.ssh/\
	/ \
	--link-dest="$BACKUP_PATH/$HOST""_current" \
	$REMOTE:$BACKUP_PATH/$BACKUP_NAME &&\
ssh $REMOTE "rm -rf $BACKUP_PATH/$HOST""_current" &&\
ssh $REMOTE "ln -s $BACKUP_PATH/$BACKUP_NAME $BACKUP_PATH/$HOST""_current") ||\
	(echo "Backup failed" >&2 && exit 1)

#sudo rsync -arvzPx \
#	--delete\
#	--rsync-path="rsync --fake-super"\
#	"$REMOTE:$BACKUP_PATH/$HOST""_current"/*
#	/
