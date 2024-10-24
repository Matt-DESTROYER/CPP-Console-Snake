#!/bin/bash

# compile the project
if [[ $RUNNER_OS != "Linux" && $RUNNER_OS != "Windows" ]]; then
	echo "Unsupported OS: $RUNNER_OS"
	exit 1
fi

# detect architecture
if [[ -z $ARCH ]]; then
	ARCH=$(uname -m)
	if [[ $ARCH == "x64" || $ARCH == "x86_64" || $ARCH == "amd64" ]]; then
		ARCH="x64"
	elif [[ $ARCH == "x32" || $ARCH == "i686" || $ARCH == "amd" ]]; then
		ARCH="x86"
	elif [[ $ARCH == "arm" ]]; then
		ARCH="arm"
  	elif [[ $ARCH == "arm64" ]]; then
   		ARCH="arm64"
	fi
fi

# just in case
git pull

# compile
rm -rf ../build/$RUNNER_OS/$ARCH/
mkdir -p ../build/$RUNNER_OS/$ARCH/

g++ ./main.cpp -O2 -o ../build/$RUNNER_OS/$ARCH/$PROJECT_NAME
