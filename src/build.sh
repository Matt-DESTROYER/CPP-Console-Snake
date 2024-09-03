#!/bin/bash

# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
make

# detect architecture
arch=$(uname -m)
if [[ $arch == x86_64* ]]; then
	arch="x64"
elif [[ $arch == i*86 ]]; then
	arch="x32"
elif  [[ $arch == arm* ]]; then
	arch="arm"
fi

# copy the executable to the build directory
mkdir -p ../build/$OSTYPE-$arch/
[[ -f ./main ]] && cp -f ./main ../build/$OSTYPE-$arch/
[[ -f ./main.exe ]] && cp -f ./main.exe ../build/$OSTYPE-$arch/

echo $(ls ./)
echo $OSTYPE-$arch

# clean up temporary directory
cd ../
rm -r -f ./temp
