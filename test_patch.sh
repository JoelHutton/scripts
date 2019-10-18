#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PATCH=`readlink -e "$1"`

set -x
set -e

test() {
  cd $DIR/gcc/objdir
  rm -rf ./*
  rm -rf $RESULT_DIR/*
  echo `date --rfc-3339=seconds` "configuring" > $RESULT_DIR/stage.log
  ../src/configure --prefix=$DIR/gcc/install\
    --disable-nls --disable-multilib \
    --enable-languages=c,c++,fortran,lto | tee $RESULT_DIR/configure.log
  echo `date --rfc-3339=seconds` "building" >> $RESULT_DIR/stage.log
  make -j 100           | tee $RESULT_DIR/make.log
  echo `date --rfc-3339=seconds` "installing" >> $RESULT_DIR/stage.log
  make -j 100 install   | tee $RESULT_DIR/install.log
  echo `date --rfc-3339=seconds` "checking" >> $RESULT_DIR/stage.log
  make -j 100 check | tee $RESULT_DIR/check.log
  echo `date --rfc-3339=seconds` "copying artefacts" >> $RESULT_DIR/stage.log
  cp -r $DIR/gcc $RESULT_DIR/gcc
  echo `date --rfc-3339=seconds` "finished" >> $RESULT_DIR/stage.log
}

if [ -z "$PATCH" ]
then
  echo "no patch to test" > /dev/stderr
  exit 1
fi

cd $DIR
if [ ! -d gcc/src ]
then
  mkdir -p gcc/src
  git clone --branch master --single-branch git://gcc.gnu.org/git/gcc.git gcc/src
  cd gcc/src
  ./contrib/download_prerequisites
  cd $DIR
fi

ESSENTIAL_DIRS="gcc gcc/src gcc/install gcc/objdir"
for dir in $ESSENTIAL_DIRS
do
  if [ ! -d $dir ]
  then
    mkdir -p $dir
  fi
done

cd $DIR/gcc/src
git reset --hard
git clean -fd
git fetch
git checkout origin/master

HEAD_COMMIT=`git rev-parse HEAD | cut -c1-5`
PATCH_HASH=`md5sum $PATCH | awk '{print($1)}' | cut -c1-5`

CLEAN_DIR=$DIR/$HEAD_COMMIT
PATCH_DIR=$DIR/"$HEAD_COMMIT"-"$PATCH_HASH"

if [ ! -d $CLEAN_DIR ]
then
  mkdir $CLEAN_DIR
  RESULT_DIR=$CLEAN_DIR test
fi
if [ ! -d $PATCH_DIR ]
then
  mkdir $PATCH_DIR
  cp $PATCH $PATCH_DIR
  cd $DIR/gcc/src
  ./gcc/contrib/check_GNU_style.sh $PATCH | tee $PATCH_DIR/$PATCH_HASH-patch_style
  rm -f $DIR/patch_style
  ln -s $DIR/$PATCH_HASH-patch_style $PATCH_DIR/patch_style
  git apply $PATCH
  RESULT_DIR=$PATCH_DIR test
fi

cd $DIR

rm -f patch
rm -f clean
ln -s $PATCH_DIR patch
ln -s $CLEAN_DIR clean
