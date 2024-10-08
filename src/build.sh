#!/bin/bash

# create a temporary directory
mkdir ./temp
cd ./temp

# compile the project
if [[ $RUNNER_OS != "Linux" && $RUNNER_OS != "Windows" ]]; then
	echo "Unsupported OS: $RUNNER_OS"
	exit 1
fi

# detect architecture
ARCH=$(uname -m)
if [[ $ARCH == x86_64* ]]; then
	ARCH="x64"
elif [[ $ARCH == i*86 ]]; then
	ARCH="x32"
elif [[ $arch == arm* ]]; then
	ARCH="arm"
fi

# just in case
git pull

# compile
rm -rf ../build/$RUNNER_OS/$ARCH/
mkdir -p ../build/$RUNNER_OS/$ARCH/

g++ main.cpp -O2 -o main

[[ -f ./main ]] && cp -f ./main ../build/$RUNNER_OS-$ARCH/$PROJECT_NAME
[[ -f ./main.exe ]] && cp -f ./Debug/main.exe ../build/$RUNNER_OS-$ARCH/$PROJECT_NAME.exe
