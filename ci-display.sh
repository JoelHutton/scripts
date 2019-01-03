#!/bin/bash
set -x
urls="file:///home/pi/messages.html http://xkcd.com http://jenkins.oss.arm.com/view/TF"
sleep_duration=45

unclutter &
midori -e Fullscreen &
sleep $sleep_duration

for url in $urls
do
	midori -e Go $url
	sleep $sleep_duration
	if [ -z $started ]
	then
		midori -e TabCloseOther
	fi
	started="$started $url"
done

while true
do
	sleep $sleep_duration
	midori -e TabNext
	midori -e Reload
done
