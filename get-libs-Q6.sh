cd ..
CS1=$(pwd)
NETMAN_DIR="$CS1/space-netman"
echo "CS1 Dir: $CS1"

echo "Netman Dir: $NETMAN_DIR"
mkdir -p $NETMAN_DIR/lib/include
mkdir -p $NETMAN_DIR/bin

echo '\n Building shakespeare...\n'
cd $CS1/space-lib/shakespeare
mkdir -p $CS1/space-lib/shakespeare/lib
echo "cd: \c"
pwd
cp inc/shakespeare.h $NETMAN_DIR/lib/include
sh mbcc-compile-lib-static.sh 
cp lib/libshakespeare-mbcc.a $NETMAN_DIR/lib

# Builds libhe100.a 
echo '\n Building HE100 Library...\n'

cd $CS1/HE100-lib/C
mkdir $CS1/HE100-lib/C/lib
echo "cd: \c" 
pwd
sh mbcc-compile-lib-static-cpp.sh
cp lib/libhe100-mbcc.a $NETMAN_DIR/lib
cp inc/SC_he100.h $NETMAN_DIR/lib/include

# Timer library
echo '\n Building timer Library...\n'
cd $NETMAN_DIR
cd $CS1/space-timer-lib 
mkdir -p $CS1/space-timer-lib/lib
echo "cd: \c" 
pwd
sh mbcc-compile-lib-static-cpp.sh
cp lib/libtimer-mbcc.a $NETMAN_DIR/lib
cp inc/timer.h $NETMAN_DIR/lib/include

# namedpipe & commander
echo '\n Building Namedpipes and commander...\n'
cd $NETMAN_DIR
cd $CS1/space-commander
mkdir -p $CS1/space-commander/lib
mkdir -p $CS1/space-commander/bin
echo "cd: \c" 
pwd
cp include/Net2Com.h $NETMAN_DIR/lib/include
cp include/NamedPipe.h $NETMAN_DIR/lib/include
make buildQ6
cp bin/space-commanderQ6 $NETMAN_DIR/bin
make staticlibsQ6.tar
cp staticlibsQ6.tar $NETMAN_DIR/lib
cd $NETMAN_DIR/lib
echo 'Extracting NamedPipes and Net2Com library'
tar -xf staticlibsQ6.tar
rm staticlibsQ6.tar

cd $NETMAN_DIR/lib
ls | grep 'mbcc*'
