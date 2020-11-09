#!/bin/bash

# 0: patch has no style issues and no regressions
# 1: patch failed test suite
# 2: patch did not apply
# 3: patch did not build
# 4: patch had style issues
# 5: scripting problems
EC_TESTSUITE=1
EC_PATCHAPPLY=2
EC_PATCHBUILD=3
EC_PATCHSTYLE=4
EC_SCRIPTISSUES=5
EC_NOPATCH=6
EC_PATCHCHECK=7
EC_PATCHCONFIGURE=8

# Get the directory this script is contained within
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -x

# Get the 'real' path to the patch
PATCH=`readlink -e "$1"`
exit_code=0

exit_with_message() {
	exit_code=$1

	cd $DIR

	# Update symlinks
	ln -s $PATCH_DIR patch
	ln -s $CLEAN_DIR clean

	if [ "$exit_code" -eq "$EC_TESTSUITE" ]
	then
	  echo "testsuite failures" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_PATCHBUILD" ]
	then
	  echo "build failures" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_PATCHAPPLY" ]
	then
	  echo "patch failed to apply" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_PATCHSTYLE" ]
	then
	  echo "patch style problems" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_SCRIPTISSUES" ]
	then
	  echo "scripting issues" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_NOPATCH" ]
	then
	  echo "no patch to test" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_PATCHCHECK" ]
	then
	  echo "check failed" >&2
	  exit $exit_code
	fi
	if [ "$exit_code" -eq "$EC_PATCHCONFIGURE" ]
	then
	  echo "configure failed" >&2
	  exit $exit_code
	fi

	echo "success"
	exit $exit_code
}

# Test a particular src
test() {
  if [ -z "$RESULT_DIR" ]
  then
    exit_with_message $EC_SCRIPTISSUES
  fi

  cd $DIR/gcc/objdir

  echo `date --rfc-3339=seconds` "building" >> $RESULT_DIR/stage.log
  make -j 100 > $RESULT_DIR/make.log 2>$RESULT_DIR/make.err || exit_with_message $EC_PATCHBUILD

  echo `date --rfc-3339=seconds` "checking" >> $RESULT_DIR/stage.log
  make -j 100 check-gcc >$RESULT_DIR/check.log 2>$RESULT_DIR/check.err || exit_with_message $EC_PATCHCHECK


  echo `date --rfc-3339=seconds` "copying artefacts" >> $RESULT_DIR/stage.log
  cp -r $DIR/gcc $RESULT_DIR/gcc

  echo `date --rfc-3339=seconds` "finished" >> $RESULT_DIR/stage.log
}

if [ -z "$PATCH" ]
then
  exit_with_message $EC_NOPATCH
fi

rm -f patch
rm -f clean

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

# Get latest trunk
cd $DIR/gcc/src
git reset --hard
git clean -fd
git fetch
git checkout origin/master

HEAD_COMMIT=`git rev-parse HEAD | cut -c1-5`
PATCH_HASH=`md5sum $PATCH | awk '{print($1)}' | cut -c1-5`

CLEAN_DIR=$DIR/results/$HEAD_COMMIT
PATCH_DIR=$DIR/results/"$HEAD_COMMIT"-"$PATCH_HASH"

mkdir -p $CLEAN_DIR

cd $DIR/gcc/objdir
BOOTSTRAP="--enable-bootstrap"
ENABLE_LANGUAGES="--enable-languages=c,c++,fortran,lto"
PREFIX="--prefix=$DIR/gcc/install"
#
#echo `date --rfc-3339=seconds` "configuring" > $CLEAN_DIR/stage.log
echo "configure with: $DIR/gcc/src/configure $PREFIX\
  --disable-nls $BOOTSTRAP --disable-multilib \
  $ENABLE_LANGUAGES"
rm -rf ./*
$DIR/gcc/src/configure $PREFIX\
  --disable-nls $BOOTSTRAP --disable-multilib \
  $ENABLE_LANGUAGES
#echo "skipping configure..."

cd ..

RESULT_DIR=$CLEAN_DIR test
if [ ! -d $PATCH_DIR ]
then
  mkdir -p $PATCH_DIR
  cp $PATCH $PATCH_DIR
  cd $DIR/gcc/src
  ./contrib/check_GNU_style.sh $PATCH > $PATCH_DIR/$PATCH_HASH-patch_style
  style_issues=`cat $PATCH_DIR/$PATCH_HASH-patch_style | wc -l`
  if [ "$style_issues" -gt "1" ]
  then
    style_issues=1
  fi
  rm -f $DIR/patch_style
  ln -s $DIR/$PATCH_HASH-patch_style $PATCH_DIR/patch_style
  if git apply $PATCH
  then
    RESULT_DIR=$PATCH_DIR test
  else
    exit_with_message $EC_PATCHAPPLY
  fi

  clean_expected_passes=`cat $CLEAN_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of expected passes' | awk '{ print($5) }'`
  clean_unexpected_passes=`cat $CLEAN_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of unexpected passes' | awk '{ print($5) }'`
  clean_expected_failures=`cat $CLEAN_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of expected failures' | awk '{ print($5) }'`
  clean_unexpected_failures=`cat $CLEAN_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of unexpected failures' | awk '{ print($5) }'`

  patch_expected_passes=`cat $PATCH_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of expected passes' | awk '{ print($5) }'`
  patch_unexpected_passes=`cat $PATCH_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of unexpected passes' | awk '{ print($5) }'`
  patch_expected_failures=`cat $PATCH_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of expected failures' | awk '{ print($5) }'`
  patch_unexpected_failures=`cat $PATCH_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum |\
                   grep '# of unexpected failures' | awk '{ print($5) }'`

  if [ "$patch_unexpected_failures" -gt "$clean_unexpected_failures" ]
  then
    exit_with_message $EC_TESTSUITE
  fi
fi

cd $DIR


diff $CLEAN_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum $PATCH_DIR/gcc/objdir/gcc/testsuite/gcc/gcc.sum
exit_with_message $exit_code
