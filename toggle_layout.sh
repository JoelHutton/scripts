#!/bin/bash
CUR_LAYOUT=`setxkbmap -query`

if [[ -z `echo $CUR_LAYOUT | grep 'dvorak'` ]]
then
	setxkbmap -layout "gb" -variant "dvorak"
else
	setxkbmap -layout "gb"
fi
