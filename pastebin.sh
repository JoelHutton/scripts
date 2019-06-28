#!/bin/bash
PASTE_TEXT=`cat $1`
RESPONSE=`curl --user "$USER" --data-urlencode "paste_text=$PASTE_TEXT" http://p.arm.com/\?ns0`
URL=`echo $RESPONSE | grep "Redirected\ to"`
URL=`echo $URL | sed -e 's/.*\(http.*\)\".*/\1/'`
echo $URL | xsel -ib
echo $URL
