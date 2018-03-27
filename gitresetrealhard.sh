#!/bin/bash
# for when you've really fucked it, clone the repo again, and add the remotes/
# hooks
set -x
OLDDIR=`pwd`
origin=`git remote show origin | grep 'Fetch\ URL' | sed 's/.*:\ \([^\ ]*\)/\1/'`
NEWDIR="$OLDDIR"-new
mkdir $NEWDIR
git clone $origin $NEWDIR
for remote in `git remote show | grep -v origin`
do
	cd $OLDDIR
	fetch_url=`git remote show $remote |grep 'Fetch\ URL' | sed 's/.*:\ \([^\ ]*\)/\1/'`
	cd $NEWDIR
	git remote add $remote $fetch_url
	git remote update
done
cp $OLDDIR/.git/hooks/* $NEWDIR/.git/hooks/
