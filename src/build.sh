# create a temporary directory
mkdir ./temp
cd ./temp

# build the project
cmake ../src
cmake --build ./
make

# copy the executable to the build directory
[[ -e ./main ]] && cp ./main ../build
[[ -e ./main.exe ]] && cp ./main.exe ../build

# clean up temporary directory
cd ../
rm -r -f ./temp
