#!/bin/bash
while true
do
    #extract % packet loss and ping time
    OUTPUT=$(ping -c 1 8.8.8.8 2>1 | tail -2 |  sed 's/.*\ \([0-9]*%\).*/\1/' \
        | sed 's/.*=\ \([0-9\.]*\).*/\1/' | grep '^[0-9].*' ) 2>/dev/null
    DATE=$(date  +%Y-%m-%dT%H:%M:%S)
    if [ "$OUTPUT" != ""  ] && [ "$OUTPUT" != "100%" ]
    then
        OUTPUT=$(echo "$OUTPUT" | tail -1)
        echo "$DATE $OUTPUT"
    else
        echo "$DATE -1"
    fi
    sleep 1
done
