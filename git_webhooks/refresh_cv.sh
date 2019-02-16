#!/bin/sh
# -*- coding: utf-8 -*-
echo "Content-type:text/html\r\n"
set -e
CV_DIR=/home/www-data/cv
WEB_DIR=/var/www/html/

cd $CV_DIR
git pull > /dev/null 2>&1
make cv  > /dev/null 2>&1
cp build/cv.pdf $WEB_DIR > /dev/null 2>&1
chmod 744 $WEB_DIR/cv.pdf > /dev/null 2>&1
cd - > /dev/null 2>&1
echo "success"
