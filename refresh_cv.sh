#!/bin/bash

CV_DIR=$HOME/git/cv
WEB_DIR=$HOME/git/web

pushd $CV_DIR
git pull
make cv
cp build/cv.pdf $WEB_DIR
chmod 744 $WEB_DIR/cv.pdf
popd
