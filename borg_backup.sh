#!/bin/bash
set -x

DATE=`date "+%Y-%m-%dT%H:%M:%S"`

borg create --exclude "$HOME/tmp*"\
            --exclude "$HOME/Downloads/*"\
            --exclude "$HOME/.cache/*"\
            --verbose\
            --stats\
            --show-rc\
            --list\
            $REMOTE::$DATE $HOME

borg prune                          \
    --list                          \
    --show-rc                       \
    --keep-within   3d              \
    --keep-daily    7              \
    --keep-weekly   20              \
    --keep-monthly  20              \
    $REMOTE
