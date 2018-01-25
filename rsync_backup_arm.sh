#!/bin/sh

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
BACKUP_NAME="$DATE\_full_fs"
BACKUP_PATH=/work/backups/rsync
HOST=joehut01@e115011-lin.cambridge.arm.com

#x - don't cross file system boundaries
#a - archive (preserve permissions, symlinks etc.)
#r - recursive
#P - partial, pickup partial copies
#z - use zip compression to speedup transfer
sudo rsync -arvzPx \
	--exclude /home/joehut01/Downloads \
	--exclude /tmp --exclude /mnt \
	--exclude /media --exclude /proc \
	--exclude /arm --exclude /run \
	--exclude /dev --exclude /home/joehut01/.cache \
	--exclude /sys \
	--link-dest=$BACKUP_PATH/current \
	/ \
	$HOST:$BACKUP_PATH/$BACKUP_NAME
ssh $HOST  "rm -f $BACKUP_PATH/current \
	&& ln -s $BACKUP_PATH/$BACKUP_NAME $BACKUP_PATH/current"
