#!/bin/bash
CUR_LAYOUT=`setxkbmap -query`

if [[ -z `echo $CUR_LAYOUT | grep 'dvorak'` ]]
then
	setxkbmap -layout "gb" -variant "dvorak" -option caps:swapescape
	xmodmap -e "clear mod5"
	xmodmap -e "keycode 108 = Alt_L"
else
	setxkbmap -layout "gb"
	setxkbmap -option
fi
