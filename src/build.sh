#!/bin/bash

# detect architecture
ARCH=$(uname -m)
if [[ $ARCH == x86_64* ]]; then
	ARCH="x64"
elif [[ $ARCH == i*86 ]]; then
	ARCH="x32"
elif [[ $arch == arm* ]]; then
	ARCH="arm"
fi

# create a build directory (if it doesn't exist)
mkdir -p ../build/$OSTYPE-$ARCH/
cd ../build/$OSTYPE-$ARCH/

# build the project
cmake ../src
cmake --build ./
make
