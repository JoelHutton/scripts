#!/bin/bash
set -e

PASTE_TEXT=`cat $1`

if [ -z "$PASTE_TEXT" ]
then
  echo "no input"
  exit 1
fi

RESPONSE=`curl --user "$USER" --data-urlencode "paste_text=$PASTE_TEXT" https://p.arm.com/`
URL=`echo $RESPONSE | grep "Redirected\ to"`
URL=`echo $URL | sed -e 's/.*\(http.*\)\".*/\1/'`
if [ -z "$URL" ]
then
  exit_code=1
else
  exit_code=0
fi
if which xsel > /dev/null
then
  echo $URL | xsel -ib
  echo "link  copied to clipboard"
else
  echo "skipping copy to clipboard: xsel not installed"
fi
echo "file available at:"
echo $URL
exit $exit_code
