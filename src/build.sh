#!/bin/bash

# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
make

# copy the executable to the build directory
[[ -f ./main ]] && cp -f ./main ../build
[[ -f ./main.exe ]] && cp -f ./main.exe ../build

# clean up temporary directory
cd ../
rm -r -f ./temp
