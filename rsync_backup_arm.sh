#!/bin/bash
#Put in crontab with something like "30 10,16 * * 1-5 /home/joel/git/scripts/rsync_backup_arm.sh >/tmp/rsync_log 2>&1 || echo "echo backup failed" >> /home/joel/.zshrc"
set -x

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

USER=joel
DATE=`date "+%Y-%m-%dT%H:%M:%S"`
HOST=`cat /etc/hostname`
BACKUP_NAME="$HOST""_$DATE"
BACKUP_PATH=/media/data/backups/rsync
REMOTE_USER=joel
REMOTE_MACHINE=staticbeans.cambridge.arm.com
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
	--exclude /home/$USER/Downloads \
	--exclude /tmp --exclude /mnt \
	--exclude /media --exclude /proc \
	--exclude /arm --exclude /run \
	--exclude /dev --exclude /home/$USER/.cache \
	--exclude /sys --exclude /home/$USER/.ssh/\
	--exclude /home/$USER/tmp --exclude /root/.ssh\
	--exclude "/home/$USER/VirtualBox VMs" --exclude /lost+found\
	--exclude /home/$USER/.local/share/Trash --exclude /home/$USER/pCloudDrive\
	/ \
	--link-dest="$BACKUP_PATH/$HOST""_current" \
	$REMOTE:$BACKUP_PATH/$BACKUP_NAME

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
