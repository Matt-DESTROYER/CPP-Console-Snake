#!/bin/bash

# detect OS
if [[ -z $RUNNER_OS  ]]; then
	if [[ $OSTYPE == "linux" || $OSTYPE == "linux-gnu" ]]; then
 		RUNNER_OS="Linux"
	elif [[ $OSTYPE == "msys" || $OSTYPE == "cygwin" ]]; then
   		RUNNER_OS="Windows"
	elif [[ $OSTYPE == "darwin" ]]; then
 		RUNNER_OS="macOS"
	else
        echo "Failed to autodetect OS..."
        exit 1
	fi
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

# extra compile flags
EXTRA_FLAGS=""
if [[ $RUNNER_OS == "macOS" ]]; then
	EXTRA_FLAGS+="-std=c++17 -lcurses"
fi

# compile
rm -rf ../build/$RUNNER_OS/$ARCH/
mkdir -p ../build/$RUNNER_OS/$ARCH/

g++ -O2 $EXTRA_FLAGS -o ../build/$RUNNER_OS/$ARCH/$PROJECT_NAME ./main.cpp
