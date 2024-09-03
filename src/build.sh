#!/bin/bash

# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
if [[ $RUNNER_OS == "Linux" ]]; then
	make
elif [[ $RUNNER_OS == "Windows" ]]; then
	eval "$MSBUILD ./$PROJECT_NAME.sln \"/property:Configuration=Release\""
else
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

# copy the executable to the build directory
if [ -d ../build/$RUNNER_OS-$ARCH/ ]; then
	rm -r -f ../build/$RUNNER_OS-$ARCH/
fi
mkdir -p ../build/$RUNNER_OS-$ARCH/
[[ -f ./main ]] && cp -f ./main ../build/$RUNNER_OS-$ARCH/$PROJECT_NAME
[[ -f ./Release/main.exe ]] && cp -f ./Release/main.exe ../build/$RUNNER_OS-$ARCH/$PROJECT_NAME.exe

# clean up temporary directory
cd ../
if [[ $RUNNER_OS == "Linux" ]]; then
	rm -r -f ./temp
fi