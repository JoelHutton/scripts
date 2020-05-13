#!/bin/bash
set -x

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
LOGDIR=/var/log/borg
LOGFILE=$LOGDIR/$DATE

borg create --exclude "$HOME/tmp*"\
            --exclude "$HOME/Downloads/*"\
            --exclude "$HOME/.cache/*"\
            --exclude "$HOME/.config/*"\
            --exclude "$HOME/pCloudDrive/*"\
            --verbose\
            --stats\
            --show-rc\
            --list\
            $REMOTE::$DATE $HOME | tee -a $LOGFILE

borg prune                          \
    --list                          \
    --show-rc                       \
    --keep-within   3d              \
    --keep-daily    7              \
    --keep-weekly   20              \
    --keep-monthly  20              \
    $REMOTE | tee -a $LOGFILE
rm $LOGDIR/latest
ln -s $LOGDIR/$DATE $LOGDIR/latest
