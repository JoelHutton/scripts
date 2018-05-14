#!/bin/bash
CUR_LAYOUT=`setxkbmap -query`

if [[ -z `echo $CUR_LAYOUT | grep 'dvorak'` ]]
then
	setxkbmap -layout "gb" -variant "dvorak" -option caps:swapescape
else
	setxkbmap -layout "gb"
fi
