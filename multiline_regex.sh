#!/bin/bash

set -x
# Set bl31 limit high, so that when we insert extra stuff into the binary to
# determine stack usage it doesn't give errors for the binaries being to big
sed -i 's/BL31_LIMIT/0xffffffff/' bl31/bl31.ld.S > bl31/bl31.ld.S.tmp

# Remove all ASSERTIONS (we are not running the code, so these assertions only
# hinder us.
NOT_FINISHED="1"
while [ $NOT_FINISHED -eq "1" ];
do
	# Swap newline characters using tr so that we can use a perl regex on
	# 'single line'. Will not work if there are 2 levels of nested brackets
	# inside ASSERT
	cat bl31/bl31.ld.S | tr '\n' '\f' \
		| perl -pe 's/ASSERT\((\(.*?\)|[^()])*?\)//' \
		| tr '\f' '\n' > bl31/bl31.ld.S.tmp
	#diff returns 0 if inputs are identical, 1 for different, 2 for trouble
	diff bl31/bl31.ld.S bl31/bl31.ld.S.tmp >/dev/null
	NOT_FINISHED=$?
	mv bl31/bl31.ld.S.tmp bl31/bl31.ld.S
	if [ "$NOT_FINISHED" -eq "2" ]
	then
		echo "Something went wrong with processing linker file" >&2
		exit 2
	fi
done
