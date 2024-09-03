#!/bin/bash

PROJECT_NAME="CPP-Console-Snake"

# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
echo $OSTYPE
if [[ $OSTYPE == "linux-gnu" ]]; then
	echo "calling make"
	make
else
	echo "calling msbuild"
	devenv=vswhere -latest -prerelease -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe
	eval("$devenv ./$PROJECT_NAME.sln /property:Configuration=Release")
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
if [ -d ../build/$OSTYPE-$ARCH/ ]; then
	rm -r -f ../build/$OSTYPE-$ARCH/
fi
mkdir -p ../build/$OSTYPE-$ARCH/
[[ -f ./$PROJECT_NAME ]] && cp -f ./main ../build/$OSTYPE-$ARCH/
[[ -f ./Release/main.exe ]] && cp -f ./Release/main.exe ../build/$OSTYPE-$ARCH/$PROJECT_NAME.exe

# clean up temporary directory
cd ../
#rm -r -f ./temp
