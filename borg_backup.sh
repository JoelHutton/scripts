#!/bin/bash
set -x

DATE=`date "+%Y-%m-%dT%H:%M:%S"`

borg create --verbose --stats --show-rc --list  $REMOTE::$DATE $HOME

borg prune                          \
    --list                          \
    --show-rc                       \
    --keep-daily    21              \
    --keep-weekly   20              \
    --keep-monthly  20              \
    /mnt/data/borg
