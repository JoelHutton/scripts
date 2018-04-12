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
	ssh $REMOTE "mkdir $BACKUP_PATH/$HOST""_current"
	if [[ "$?" -ne "0" ]]
	then
		echo "Could not create $HOST""_current on $REMOTE" >&2
		exit 1
	fi
fi

# rsync backup, then move 'current' link to point at backup
# a - archive (preserve permissions, symlinks etc.)
# A - preserve ACLs (Access control lists)
# r - recursive
# v - verbose
# z - use zip compression to speedup transfer
# P - partial, pickup partial copies
# H - preserve hard links
# x - don't cross filesystem boundaries
# X - preserve extended attributes
rsync -aArvzPHxX \
	--rsync-path="rsync --fake-super"\
	--exclude /home/joehut01/Downloads \
	--exclude /tmp --exclude /mnt \
	--exclude /media --exclude /proc \
	--exclude /arm --exclude /run \
	--exclude /dev --exclude /home/joehut01/.cache \
	--exclude /sys --exclude /home/joehut01/.ssh/\
	--exclude /home/joehut01/tmp --exclude /root/.ssh\
	--exclude "/home/joehut01/VirtualBox VMs" --exclude /lost+found\
	/ \
	--link-dest="$BACKUP_PATH/$HOST""_current" \
	$REMOTE:$BACKUP_PATH/$BACKUP_NAME &&\

if [[ "$?" -ne "0" ]]
then
	echo "Backup failed" >&2
	exit 1
fi

ssh $REMOTE "rm -rf $BACKUP_PATH/$HOST""_current" &&\
ssh $REMOTE "ln -s $BACKUP_PATH/$BACKUP_NAME $BACKUP_PATH/$HOST""_current"

# to restore
# sudo rsync -arvzPHx \
# 	--delete\
# 	--rsync-path="rsync --fake-super"\
# 	"$REMOTE:$BACKUP_PATH/$HOST""_current"/*
# 	/
