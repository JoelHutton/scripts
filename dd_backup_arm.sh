#!/bin/bash

set -x
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
HOST=`cat /etc/hostname`
BACKUP_NAME="$HOST""_$DATE".gz
BACKUP_PATH=/data/backups/dd
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

if ssh $REMOTE "ls $BACKUP_PATH" 2>&1 1>/dev/null
then
	:
else
	echo "Could not find backup directory on remote">&2
	exit 1
fi

if dd if=/dev/nvme0n1 | gzip | ssh $REMOTE "dd of=$BACKUP_PATH/$BACKUP_NAME.part"
then
	ssh $REMOTE "mv $BACKUP_PATH/$BACKUP_NAME.part $BACKUP_PATH/$BACKUP_NAME"
else
	echo "Backup failed" >&2
fi
