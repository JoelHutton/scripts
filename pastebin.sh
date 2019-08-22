#!/bin/bash
PASTE_TEXT="$(</dev/stdin)"
echo -e $PASTE_TEXT
RESPONSE=`curl --user "$USER" --data-urlencode "paste_text=$PASTE_TEXT" https://p.arm.com/`
URL=`echo $RESPONSE | grep "Redirected\ to"`
URL=`echo $URL | sed -e 's/.*\(http.*\)\".*/\1/'`
echo $URL | xsel -ib
echo $URL
