#!/bin/bash

# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
make

# detect architecture
ARCH=$(uname -m)
if [[ $ARCH == x86_64* ]]; then
	ARCH="x64"
elif [[ $ARCH == i*86 ]]; then
	ARCH="x32"
elif  [[ $arch == arm* ]]; then
	ARCH="arm"
fi

# copy the executable to the build directory
mkdir -p ../build/$OSTYPE-$ARCH/
[[ -f ./main ]] && cp -f ./main ../build/$OSTYPE-$ARCH/
[[ -f ./main.exe ]] && cp -f ./main.exe ../build/$OSTYPE-$ARCH/

# clean up temporary directory
cd ../
rm -r -f ./temp
